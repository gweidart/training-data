pragma solidity ^0.4.11;
contract ERC20Basic {
uint256 public totalSupply;
function balanceOf(address who) public view returns (uint256);
function transfer(address to, uint256 value) public returns (bool);
event Transfer(address indexed from, address indexed to, uint256 value);
}
library SafeMath {
function mul(uint256 a, uint256 b) internal pure returns (uint256) {
if (a == 0) {
return 0;
}
uint256 c = a * b;
assert(c / a == b);
return c;
}
function div(uint256 a, uint256 b) internal pure returns (uint256) {
uint256 c = a / b;
return c;
}
function sub(uint256 a, uint256 b) internal pure returns (uint256) {
assert(b <= a);
return a - b;
}
function add(uint256 a, uint256 b) internal pure returns (uint256) {
uint256 c = a + b;
assert(c >= a);
return c;
}
}
contract BasicToken is ERC20Basic {
using SafeMath for uint256;
mapping(address => uint256) balances;
function transfer(address _to, uint256 _value) public returns (bool) {
require(_to != address(0));
require(_value <= balances[msg.sender]);
balances[msg.sender] = balances[msg.sender].sub(_value);
balances[_to] = balances[_to].add(_value);
Transfer(msg.sender, _to, _value);
return true;
}
function balanceOf(address _owner) public view returns (uint256 balance) {
return balances[_owner];
}
}
contract ERC20 is ERC20Basic {
function allowance(address owner, address spender) public view returns (uint256);
function transferFrom(address from, address to, uint256 value) public returns (bool);
function approve(address spender, uint256 value) public returns (bool);
event Approval(address indexed owner, address indexed spender, uint256 value);
}
contract StandardToken is ERC20, BasicToken {
mapping (address => mapping (address => uint256)) internal allowed;
function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
require(_to != address(0));
require(_value <= balances[_from]);
require(_value <= allowed[_from][msg.sender]);
balances[_from] = balances[_from].sub(_value);
balances[_to] = balances[_to].add(_value);
allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
Transfer(_from, _to, _value);
return true;
}
function approve(address _spender, uint256 _value) public returns (bool) {
allowed[msg.sender][_spender] = _value;
Approval(msg.sender, _spender, _value);
return true;
}
function allowance(address _owner, address _spender) public view returns (uint256) {
return allowed[_owner][_spender];
}
function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
return true;
}
function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
uint oldValue = allowed[msg.sender][_spender];
if (_subtractedValue > oldValue) {
allowed[msg.sender][_spender] = 0;
} else {
allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
}
Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
return true;
}
}
contract Ownable {
address public owner;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
function Ownable() public {
owner = msg.sender;
}
modifier onlyOwner() {
require(msg.sender == owner);
_;
}
function transferOwnership(address newOwner) public onlyOwner {
require(newOwner != address(0));
OwnershipTransferred(owner, newOwner);
owner = newOwner;
}
}
contract MintableToken is StandardToken, Ownable {
event Mint(address indexed to, uint256 amount);
event MintFinished();
bool public mintingFinished = false;
modifier canMint() {
require(!mintingFinished);
_;
}
function mint(address _to, uint256 _amount) onlyOwner canMint public returns (bool) {
totalSupply = totalSupply.add(_amount);
balances[_to] = balances[_to].add(_amount);
Mint(_to, _amount);
Transfer(address(0), _to, _amount);
return true;
}
function finishMinting() onlyOwner canMint public returns (bool) {
mintingFinished = true;
MintFinished();
return true;
}
}
contract PullPayment {
using SafeMath for uint256;
mapping(address => uint256) public payments;
uint256 public totalPayments;
function asyncSend(address dest, uint256 amount) internal {
payments[dest] = payments[dest].add(amount);
totalPayments = totalPayments.add(amount);
}
function withdrawPayments() public {
address payee = msg.sender;
uint256 payment = payments[payee];
require(payment != 0);
require(this.balance >= payment);
totalPayments = totalPayments.sub(payment);
payments[payee] = 0;
assert(payee.send(payment));
}
}
contract EvaCoin is MintableToken, PullPayment {
string public constant name = "EvaCoin";
string public constant symbol = "EVA";
uint8 public constant decimals = 18;
bool public transferAllowed = false;
address public keeper;
uint256 public raisedPreSaleUSD;
uint256 public raisedSale1USD;
uint256 public raisedSale2USD;
uint256 public payedDividendsUSD;
uint256 public totalSupplyPreSale = 0;
uint256 public totalSupplySale1 = 0;
uint256 public totalSupplySale2 = 0;
enum SaleStages { PreSale, Sale1, Sale2, SaleOff }
SaleStages public stage = SaleStages.PreSale;
function EvaCoin() public {
keeper = msg.sender;
}
modifier onlyKeeper() {
require(msg.sender == keeper);
_;
}
function sale1Started() onlyOwner public {
totalSupplyPreSale = totalSupply;
stage = SaleStages.Sale1;
}
function sale2Started() onlyOwner public {
totalSupplySale1 = totalSupply;
stage = SaleStages.Sale2;
}
function sale2Stopped() onlyOwner public {
totalSupplySale2 = totalSupply;
stage = SaleStages.SaleOff;
}
uint constant MULTIPLIER = 10e18;
mapping(address=>uint256) lastDividends;
uint public totalDividendsPerCoin;
uint public etherBalance;
modifier activateDividends(address account) {
if (totalDividendsPerCoin != 0) {
var actual = totalDividendsPerCoin - lastDividends[account];
var dividends = (balances[account] * actual) / MULTIPLIER;
if (dividends > 0 && etherBalance >= dividends) {
etherBalance -= dividends;
lastDividends[account] = totalDividendsPerCoin;
asyncSend(account, dividends);
}
lastDividends[account] = totalDividendsPerCoin;
}
_;
}
function activateDividendsFunc(address account) private activateDividends(account) {}
mapping(address=>uint256) sale1Coins;
mapping(address=>bool) sale2Payed;
modifier activateBonus(address account) {
if (stage == SaleStages.SaleOff && !sale2Payed[account]) {
uint256 coins = sale1Coins[account];
if (coins == 0) {
coins = balances[account];
}
balances[account] += balances[account] * coins / (totalSupplyPreSale + totalSupplySale1);
sale2Payed[account] = true;
} else if (stage != SaleStages.SaleOff) {
sale1Coins[account] = balances[account];
}
_;
}
function activateBonusFunc(address account) private activateBonus(account) {}
event TransferAllowed(bool);
modifier canTransfer() {
require(transferAllowed);
_;
}
function transferFrom(address from, address to, uint256 value) canTransfer
public returns (bool) {
activateDividendsFunc(from);
activateDividendsFunc(to);
activateBonusFunc(from);
activateBonusFunc(to);
return super.transferFrom(from, to, value);
}
function transfer(address to, uint256 value)
canTransfer activateDividends(to) activateBonus(to)
public returns (bool) {
return super.transfer(to, value);
}
function allowTransfer() onlyOwner public {
transferAllowed = true;
TransferAllowed(true);
}
function raisedUSD(uint256 amount) onlyOwner public {
if (stage == SaleStages.PreSale) {
raisedPreSaleUSD += amount;
} else if (stage == SaleStages.Sale1) {
raisedSale1USD += amount;
} else if (stage == SaleStages.Sale2) {
raisedSale2USD += amount;
}
}
function canStartSale2() public constant returns (bool) {
return payedDividendsUSD >= raisedPreSaleUSD + raisedSale1USD;
}
function sendDividends(uint256 ethrate) public payable onlyKeeper {
require(totalSupply > 0);
totalDividendsPerCoin += (msg.value * MULTIPLIER / totalSupply);
etherBalance += msg.value;
payedDividendsUSD += msg.value * ethrate / 1 ether;
}
function mint(address _to, uint256 _amount)
onlyOwner canMint activateDividends(_to) activateBonus(_to)
public returns (bool) {
super.mint(_to, _amount);
if (stage == SaleStages.PreSale) {
totalSupplyPreSale += _amount;
} else if (stage == SaleStages.Sale1) {
totalSupplySale1 += _amount;
} else if (stage == SaleStages.Sale2) {
totalSupplySale2 += _amount;
}
}
function withdrawPayments()
activateDividends(msg.sender) activateBonus(msg.sender)
public {
super.withdrawPayments();
}
function checkPayments()
activateDividends(msg.sender) activateBonus(msg.sender)
public returns (uint256) {
return payments[msg.sender];
}
function paymentsOf() constant public returns (uint256) {
return payments[msg.sender];
}
function checkBalance()
activateDividends(msg.sender) activateBonus(msg.sender)
public returns (uint256) {
return balanceOf(msg.sender);
}
function withdraw() onlyOwner public {
if (this.balance > etherBalance) {
owner.transfer(this.balance - etherBalance);
}
}
}