pragma solidity ^0.4.16;
contract ERC20Basic {
uint256 public totalSupply;
function balanceOf(address who) public constant returns (uint256);
function transfer(address to, uint256 value) public returns (bool);
event Transfer(address indexed from, address indexed to, uint256 value);
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
contract WHSCoin is StandardToken, Ownable {
string public constant name = "White Stone Coin";
string public constant symbol = "WHS";
uint256 public constant decimals = 18;
uint256 public constant UNIT = 10 ** decimals;
address public companyWallet;
uint256 public tokenPrice = 0.03 ether;
uint256 public totalSupply = 10000000 * UNIT;
uint256 public remainingSupply = totalSupply;
uint256 public totalWeiReceived = 0;
uint256 startDate  = 1513400400;
uint256 endDate    = 1523768400;
uint256 bonus30end = 1516078800;
uint256 bonus20end = 1518757200;
uint256 bonus10end = 1521176400;
event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);
function WHSCoin(address _companyWallet) {
companyWallet = _companyWallet;
balances[companyWallet] = 5000000 * UNIT;
remainingSupply = remainingSupply.sub(5000000 * UNIT);
}
function calcBonus(uint256 amount) internal returns (uint256) {
uint256 bonusPercentage = 30;
if (now > bonus30end) bonusPercentage = 20;
if (now > bonus20end) bonusPercentage = 10;
if (now > bonus10end) bonusPercentage = 0;
return amount * bonusPercentage / 100;
}
function buyTokens() public payable {
require(now < endDate);
require(now >= startDate);
require(msg.value > 0);
uint256 amount = msg.value * UNIT / tokenPrice;
uint256 bonus = calcBonus(amount);
require(remainingSupply.sub(amount.add(bonus)) > 0);
totalWeiReceived = totalWeiReceived.add(msg.value);
remainingSupply = remainingSupply.sub(amount);
balances[msg.sender] = balances[msg.sender].add(amount);
Transfer(address(0x0), msg.sender, amount);
if (bonus > 0) {
Transfer(companyWallet, msg.sender, bonus);
balances[companyWallet] = balances[companyWallet].sub(bonus);
balances[msg.sender] = balances[msg.sender].add(bonus);
}
TokenPurchase(msg.sender, msg.sender, msg.value, amount.add(bonus));
companyWallet.transfer(msg.value);
}
function() public payable {
buyTokens();
}
}