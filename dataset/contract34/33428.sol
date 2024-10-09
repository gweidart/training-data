pragma solidity ^0.4.18;
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
contract ChurchCoin is MintableToken {
string public name = "CHURCH COIN";
string public symbol = "CRC";
uint256 public decimals = 18;
}
contract Crowdsale {
using SafeMath for uint256;
MintableToken public token;
uint256 public startTime;
uint256 public endTime;
address public wallet;
uint256 public rate;
uint256 public cap;
uint256 public weiRaised;
event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);
function Crowdsale(uint256 _startTime, uint256 _endTime, uint256 _rate, uint256 _cap, address _wallet) {
token = createTokenContract();
startTime = _startTime;
endTime = _endTime;
rate = _rate;
cap = _cap;
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
bool withinCap = weiRaised.add(msg.value) <= cap;
bool nonZeroPurchase = msg.value != 0;
return withinPeriod && nonZeroPurchase && withinCap;
}
function hasEnded() public constant returns (bool) {
bool capReached = weiRaised >= cap;
return now > endTime || capReached;
}
}
contract ChurchCrowdsale is Crowdsale {
uint256 _startTime = 0;
uint256 _endTime = 1514764799;
uint256 _rate = 1000;
uint256 _cap = 400000000000000000000;
address _wallet = 0x85A363699C6864248a6FfCA66e4a1A5cCf9f5567;
function ChurchCrowdsale() Crowdsale(_startTime, _endTime, _rate, _cap, _wallet) {
}
function createTokenContract() internal returns (MintableToken) {
return new ChurchCoin();
}
}