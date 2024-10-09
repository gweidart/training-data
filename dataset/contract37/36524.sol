pragma solidity ^0.4.11;
library Math {
function max64(uint64 a, uint64 b) internal constant returns (uint64) {
return a >= b ? a : b;
}
function min64(uint64 a, uint64 b) internal constant returns (uint64) {
return a < b ? a : b;
}
function max256(uint256 a, uint256 b) internal constant returns (uint256) {
return a >= b ? a : b;
}
function min256(uint256 a, uint256 b) internal constant returns (uint256) {
return a < b ? a : b;
}
}
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
function transferOwnership(address newOwner) onlyOwner {
require(newOwner != address(0));
OwnershipTransferred(owner, newOwner);
owner = newOwner;
}
}
contract ERC20Basic {
uint256 public totalSupply;
function balanceOf(address who) constant returns (uint256);
function transfer(address to, uint256 value) returns (bool);
event Transfer(address indexed from, address indexed to, uint256 value);
}
contract ERC20 is ERC20Basic {
function allowance(address owner, address spender) constant returns (uint256);
function transferFrom(address from, address to, uint256 value) returns (bool);
function approve(address spender, uint256 value) returns (bool);
event Approval(address indexed owner, address indexed spender, uint256 value);
}
contract BasicToken is ERC20Basic {
using SafeMath for uint256;
mapping(address => uint256) balances;
function transfer(address _to, uint256 _value) returns (bool) {
require(_to != address(0));
balances[msg.sender] = balances[msg.sender].sub(_value);
balances[_to] = balances[_to].add(_value);
Transfer(msg.sender, _to, _value);
return true;
}
function balanceOf(address _owner) constant returns (uint256 balance) {
return balances[_owner];
}
}
contract StandardToken is ERC20, BasicToken {
mapping (address => mapping (address => uint256)) allowed;
function transferFrom(address _from, address _to, uint256 _value) returns (bool) {
require(_to != address(0));
var _allowance = allowed[_from][msg.sender];
balances[_from] = balances[_from].sub(_value);
balances[_to] = balances[_to].add(_value);
allowed[_from][msg.sender] = _allowance.sub(_value);
Transfer(_from, _to, _value);
return true;
}
function approve(address _spender, uint256 _value) returns (bool) {
require((_value == 0) || (allowed[msg.sender][_spender] == 0));
allowed[msg.sender][_spender] = _value;
Approval(msg.sender, _spender, _value);
return true;
}
function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
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
contract MintableToken is StandardToken, Ownable {
event Mint(address indexed to, uint256 amount);
event MintFinished();
bool public mintingFinished = false;
modifier canMint() {
require(!mintingFinished);
_;
}
function mint(address _to, uint256 _amount) onlyOwner canMint returns (bool) {
totalSupply = totalSupply.add(_amount);
balances[_to] = balances[_to].add(_amount);
Mint(_to, _amount);
Transfer(0x0, _to, _amount);
return true;
}
function finishMinting() onlyOwner returns (bool) {
mintingFinished = true;
MintFinished();
return true;
}
}
contract ABCToken is MintableToken {
string public name = "ABCToken";
string public symbol = "ABC";
uint256 public decimals = 18;
function() {
revert();
}
}
contract ABCPresale is Ownable {
using SafeMath for uint256;
ABCToken public token;
uint256 public startBlock;
uint256 public endBlock;
bool public presaleClosedManually = false;
bool public isFinalized = false;
address public founders;
address public developer;
uint256 public weiRaised;
uint public rate = 181818;
uint public hardcap = 5550 ether;
uint public softcap = 5500 ether;
uint founders_abc = 2500 ether;
uint developer_abc = 15 ether;
event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);
event Finalized();
event ClosedManually();
function ABCPresale(uint256 _startBlock, uint256 _endBlock, address _founders, address _developer) {
require(_startBlock >= block.number);
require(_endBlock >= _startBlock);
token = createTokenContract();
startBlock = _startBlock;
endBlock = _endBlock;
founders = _founders;
developer = _developer;
}
function createTokenContract() internal returns (ABCToken) {
return new ABCToken();
}
function () payable {
buyTokens(msg.sender);
}
function buyTokens(address beneficiary) payable {
require(beneficiary != 0x0);
require(validPurchase());
uint256 weiAmount = msg.value;
uint256 tokens = weiAmount.div(100).mul(rate);
weiRaised = weiRaised.add(weiAmount);
token.mint(beneficiary, tokens);
TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);
forwardFunds();
}
function forwardFunds() internal {
founders.transfer(msg.value);
}
function validPurchase() internal constant returns (bool) {
uint256 current = block.number;
bool withinPeriod = current >= startBlock && current <= endBlock;
bool nonZeroPurchase = msg.value != 0;
bool withinCap = weiRaised.add(msg.value) <= hardcap;
bool biggerThanLeftBound = msg.value >= 300 finney;
bool smallerThanRightBound = msg.value <= 1000 ether;
return withinPeriod && nonZeroPurchase && withinCap && biggerThanLeftBound && smallerThanRightBound && !presaleClosedManually && !isFinalized;
}
function hasEnded() public constant returns (bool) {
bool capReached = weiRaised >= softcap;
return block.number > endBlock || capReached || presaleClosedManually || isFinalized;
}
function changeTokenOwner(address newOwner) onlyOwner {
token.transferOwnership(newOwner);
}
function closePresale() onlyOwner {
require(!isFinalized);
require(!presaleClosedManually);
require(block.number > startBlock && block.number < endBlock);
presaleClosedManually = true;
finalization();
ClosedManually();
isFinalized = true;
}
function finalize() onlyOwner {
require(!isFinalized);
require(hasEnded());
finalization();
Finalized();
isFinalized = true;
}
function finalization() internal {
token.mint(developer, developer_abc.mul(2000));
token.mint(founders, founders_abc.mul(2000));
}
}