pragma solidity ^0.4.18;
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
contract ERC20Basic {
function totalSupply() public view returns (uint256);
function balanceOf(address who) public view returns (uint256);
function transfer(address to, uint256 value) public returns (bool);
event Transfer(address indexed from, address indexed to, uint256 value);
}
contract ERC20 is ERC20Basic {
function allowance(address owner, address spender) public view returns (uint256);
function transferFrom(address from, address to, uint256 value) public returns (bool);
function approve(address spender, uint256 value) public returns (bool);
event Approval(address indexed owner, address indexed spender, uint256 value);
}
contract BasicToken is ERC20Basic {
using SafeMath for uint256;
mapping(address => uint256) balances;
uint256 totalSupply_;
function totalSupply() public view returns (uint256) {
return totalSupply_;
}
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
contract MintableToken is StandardToken, Ownable {
event Mint(address indexed to, uint256 amount);
event MintFinished();
bool public mintingFinished = false;
modifier canMint() {
require(!mintingFinished);
_;
}
function mint(address _to, uint256 _amount) onlyOwner canMint public returns (bool) {
totalSupply_ = totalSupply_.add(_amount);
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
contract NooToken is MintableToken {
string public constant name = "GMine Token";
string public constant symbol = "GNM";
uint32 public constant decimals = 18;
}
contract NooCrowdsale is Ownable {
using SafeMath for uint;
NooToken public token = new NooToken();
uint public status = 0;
mapping(address => uint) public balances;
uint public balanceTotal = 0;
uint public start;
uint8 public period;
uint8 public periodLimit;
uint public softcap;
uint public hardcap;
uint public rate;
uint public minAmount;
uint public restricted;
function NooCrowdsale() public {
start = 1523199600;
period = 42;
periodLimit = 75;
softcap = 500 ether;
hardcap = 1500 ether;
rate = 6250000000000000;
minAmount = 125000000000000000;
restricted = 13;
}
function() external payable {
createTokens();
}
function createTokens() public checkAmount saleIsOn underHardcap payable {
require(status != 2);
uint tokens = msg.value.div(rate);
uint bonusTokens = calcBonusTokens(tokens);
mintAndTransfer(msg.sender, tokens + bonusTokens);
balances[msg.sender] = balances[msg.sender].add(msg.value);
balanceTotal = balanceTotal.add(msg.value);
}
function finishMinting() public onlyOwner saleFinished overSoftcap {
require(status == 1 || (status != 2 && now < start + period * 1 days && balanceTotal < hardcap));
uint issuedTokenSupply = token.totalSupply();
uint restrictedTokens = issuedTokenSupply.mul(restricted).div(100 - restricted);
mintAndTransfer(owner, restrictedTokens);
token.finishMinting();
owner.transfer(this.balance);
}
function takeUpWork() public onlyOwner overSoftcap {
require(status == 0);
status = 1;
}
function refuseWork() public onlyOwner {
require(status == 0);
status = 2;
}
function takeEther(uint amount) public onlyOwner {
require(status == 1);
owner.transfer(amount);
}
function refund() public {
require(status == 2 || (status != 1 && now > start + period * 1 days && balanceTotal < softcap));
require(balances[msg.sender] > 0);
uint value = balances[msg.sender];
balances[msg.sender] = 0;
msg.sender.transfer(value);
}
function calcBonusTokens(uint tokens) public view returns (uint) {
uint delta = now - start;
if (delta <= 7 days) {
return tokens.mul(3).div(10);
} else if (delta <= 21 days) {
return tokens.mul(2).div(10);
} else if (delta <= 42 days) {
return tokens.div(10);
}
return 0;
}
function expandPeriod(uint8 byDays) public onlyOwner {
require(period + byDays <= periodLimit);
period = period + byDays;
}
function mintAndTransfer(address receiver, uint amount) private {
token.mint(this, amount);
token.transfer(receiver, amount);
}
modifier overSoftcap() {
require(balanceTotal >= softcap);
_;
}
modifier underHardcap() {
require(balanceTotal <= hardcap);
_;
}
modifier saleIsOn() {
require(now > start && now < start + period * 1 days);
_;
}
modifier saleFinished() {
require(now > start + period * 1 days);
_;
}
modifier checkAmount() {
require(msg.value >= minAmount);
_;
}
}