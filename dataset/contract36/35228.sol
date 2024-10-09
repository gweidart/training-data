pragma solidity ^0.4.13;
library SafeMath {
function mul(uint256 a, uint256 b) internal constant returns (uint256) {
uint256 c = a * b;
assert(a == 0 || c / a == b);
return c;
}
function div(uint256 a, uint256 b) internal constant returns (uint256) {
uint256 c = a / b;
return c;
}
function sub(uint256 a, uint256 b) internal constant returns (uint256) {
assert(b <= a);
return a - b;
}
function add(uint256 a, uint256 b) internal constant returns (uint256) {
uint256 c = a + b;
assert(c >= a);
return c;
}
}
contract Crowdsale {
using SafeMath for uint256;
MintableToken public token;
uint256 public startTime;
uint256 public endTime;
address public wallet;
uint256 public rate;
uint256 public weiRaised;
event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);
function Crowdsale(uint256 _startTime, uint256 _endTime, uint256 _rate, address _wallet) {
require(_startTime >= now);
require(_endTime >= _startTime);
require(_rate > 0);
require(_wallet != 0x0);
token = createTokenContract();
startTime = _startTime;
endTime = _endTime;
rate = _rate;
wallet = _wallet;
}
function createTokenContract() internal returns (MintableToken) {
return new MintableToken();
}
function () payable {
buyTokens(msg.sender);
}
function buyTokens(address beneficiary) public payable {
require(beneficiary != 0x0);
require(validPurchase());
uint256 weiAmount = msg.value;
uint256 tokens = weiAmount.mul(rate);
weiRaised = weiRaised.add(weiAmount);
token.mint(beneficiary, tokens);
TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);
forwardFunds();
}
function forwardFunds() internal {
wallet.transfer(msg.value);
}
function validPurchase() internal constant returns (bool) {
bool withinPeriod = now >= startTime && now <= endTime;
bool nonZeroPurchase = msg.value != 0;
return withinPeriod && nonZeroPurchase;
}
function hasEnded() public constant returns (bool) {
return now > endTime;
}
}
contract ERC20Basic {
uint256 public totalSupply;
function balanceOf(address who) public constant returns (uint256);
function transfer(address to, uint256 value) public returns (bool);
event Transfer(address indexed from, address indexed to, uint256 value);
}
contract BasicToken is ERC20Basic {
using SafeMath for uint256;
mapping(address => uint256) balances;
function transfer(address _to, uint256 _value) public returns (bool) {
require(_to != address(0));
balances[msg.sender] = balances[msg.sender].sub(_value);
balances[_to] = balances[_to].add(_value);
Transfer(msg.sender, _to, _value);
return true;
}
function balanceOf(address _owner) public constant returns (uint256 balance) {
return balances[_owner];
}
}
contract ERC20 is ERC20Basic {
function allowance(address owner, address spender) public constant returns (uint256);
function transferFrom(address from, address to, uint256 value) public returns (bool);
function approve(address spender, uint256 value) public returns (bool);
event Approval(address indexed owner, address indexed spender, uint256 value);
}
contract StandardToken is ERC20, BasicToken {
mapping (address => mapping (address => uint256)) allowed;
function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
require(_to != address(0));
uint256 _allowance = allowed[_from][msg.sender];
balances[_from] = balances[_from].sub(_value);
balances[_to] = balances[_to].add(_value);
allowed[_from][msg.sender] = _allowance.sub(_value);
Transfer(_from, _to, _value);
return true;
}
function approve(address _spender, uint256 _value) public returns (bool) {
allowed[msg.sender][_spender] = _value;
Approval(msg.sender, _spender, _value);
return true;
}
function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
return allowed[_owner][_spender];
}
function increaseApproval (address _spender, uint _addedValue)
returns (bool success) {
allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
return true;
}
function decreaseApproval (address _spender, uint _subtractedValue)
returns (bool success) {
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
function Ownable() {
owner = msg.sender;
}
modifier onlyOwner() {
require(msg.sender == owner);
_;
}
function transferOwnership(address newOwner) onlyOwner public {
require(newOwner != address(0));
OwnershipTransferred(owner, newOwner);
owner = newOwner;
}
}
contract FinalizableCrowdsale is Crowdsale, Ownable {
using SafeMath for uint256;
bool public isFinalized = false;
event Finalized();
function finalize() onlyOwner public {
require(!isFinalized);
require(hasEnded());
finalization();
Finalized();
isFinalized = true;
}
function finalization() internal {
}
}
contract RefundableCrowdsale is FinalizableCrowdsale {
using SafeMath for uint256;
uint256 public goal;
RefundVault public vault;
function RefundableCrowdsale(uint256 _goal) {
require(_goal > 0);
vault = new RefundVault(wallet);
goal = _goal;
}
function forwardFunds() internal {
vault.deposit.value(msg.value)(msg.sender);
}
function claimRefund() public {
require(isFinalized);
require(!goalReached());
vault.refund(msg.sender);
}
function finalization() internal {
if (goalReached()) {
vault.close();
} else {
vault.enableRefunds();
}
super.finalization();
}
function goalReached() public constant returns (bool) {
return weiRaised >= goal;
}
}
contract RefundVault is Ownable {
using SafeMath for uint256;
enum State { Active, Refunding, Closed }
mapping (address => uint256) public deposited;
address public wallet;
State public state;
event Closed();
event RefundsEnabled();
event Refunded(address indexed beneficiary, uint256 weiAmount);
function RefundVault(address _wallet) {
require(_wallet != 0x0);
wallet = _wallet;
state = State.Active;
}
function deposit(address investor) onlyOwner public payable {
require(state == State.Active);
deposited[investor] = deposited[investor].add(msg.value);
}
function close() onlyOwner public {
require(state == State.Active);
state = State.Closed;
Closed();
wallet.transfer(this.balance);
}
function enableRefunds() onlyOwner public {
require(state == State.Active);
state = State.Refunding;
RefundsEnabled();
}
function refund(address investor) public {
require(state == State.Refunding);
uint256 depositedValue = deposited[investor];
deposited[investor] = 0;
investor.transfer(depositedValue);
Refunded(investor, depositedValue);
}
}
contract DeckCoinCrowdsale is RefundableCrowdsale {
using SafeMath for uint256;
uint256 public constant startTime = 1508824800;
uint256 public constant endTime = 1511506800;
uint256 public constant fortyEndTime = 1509516000;
uint256 public constant twentyEndTime = 1510124400;
uint256 public constant tenEndTime = 1510729200;
uint256 public constant tokenGoal = 8000000 * 10 ** 18;
uint256 public constant tokenCap = 70000000 * 10 ** 18;
uint256 public constant rate = 28000;
address public constant wallet = 0x67cE4BFf7333C091EADc1d90425590d931A3E972;
uint256 public tokensSold;
function DeckCoinCrowdsale()
FinalizableCrowdsale()
RefundableCrowdsale(1)
Crowdsale(startTime, endTime, rate, wallet) public {}
function bulkMint(uint[] data) onlyOwner public {
DeckCoin(token).bulkMint(data);
}
function finishMinting() onlyOwner public  {
token.finishMinting();
}
function weiToTokens(uint256 weiAmount) public constant returns (uint256){
uint256 tokens;
if (now < fortyEndTime) {
tokens = weiAmount.mul(rate.add(11200));
} else if (now < twentyEndTime) {
tokens = weiAmount.mul(rate.add(5600));
} else if (now < tenEndTime) {
tokens = weiAmount.mul(rate.add(2800));
} else {
tokens = weiAmount.mul(rate);
}
return tokens;
}
function buyTokens(address beneficiary) public payable {
require(beneficiary != 0x0);
require(validPurchase());
uint256 weiAmount = msg.value;
uint256 tokens = weiToTokens(weiAmount);
tokensSold = tokensSold.add(tokens);
weiRaised = weiRaised.add(weiAmount);
token.mint(beneficiary, tokens);
TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);
forwardFunds();
}
function goalReached() public constant returns (bool) {
return tokensSold >= tokenGoal;
}
function hasEnded() public constant returns (bool) {
bool capReached = tokensSold >= tokenCap;
return super.hasEnded() || capReached;
}
function validPurchase() internal constant returns (bool) {
bool withinCap = tokensSold.add(weiToTokens(msg.value)) <= tokenCap;
return super.validPurchase() && withinCap;
}
function createTokenContract() internal returns (MintableToken) {
return new DeckCoin();
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
Transfer(0x0, _to, _amount);
return true;
}
function finishMinting() onlyOwner public returns (bool) {
mintingFinished = true;
MintFinished();
return true;
}
}
contract DeckCoin is MintableToken {
string public constant name = "Deck Coin";
string public constant symbol = "DEK";
uint8 public constant decimals = 18;
uint256 private constant D160 = 0x10000000000000000000000000000000000000000;
function bulkMint(uint256[] data) onlyOwner canMint public {
uint256 totalMinted = 0;
for (uint256 i = 0; i < data.length; i++) {
address beneficiary = address(data[i] & (D160 - 1));
uint256 amount = data[i] / D160;
totalMinted += amount;
balances[beneficiary] += amount;
}
totalSupply = totalSupply.add(totalMinted);
Mint(0x0, totalMinted);
}
}