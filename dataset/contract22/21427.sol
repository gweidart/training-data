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
function balanceOf(address who) constant returns (uint256);
function transfer(address to, uint256 value) returns (bool);
event Transfer(address indexed from, address indexed to, uint256 value);
}
contract ERC20 is ERC20Basic {
function allowance(address owner, address spender) constant returns (uint256);
function approve(address spender, uint256 value) returns (bool);
event Approval(address indexed owner, address indexed spender, uint256 value);
}
contract BasicToken is ERC20Basic {
using SafeMath for uint256;
mapping(address => uint256) balances;
function balanceOf(address _owner) constant returns (uint256 balance) {
return balances[_owner];
}
}
contract StandardToken is ERC20, BasicToken {
mapping (address => mapping (address => uint256)) allowed;
function approve(address _spender, uint256 _value) returns (bool) {
require((_value == 0) || (allowed[msg.sender][_spender] == 0));
allowed[msg.sender][_spender] = _value;
Approval(msg.sender, _spender, _value);
return true;
}
function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
return allowed[_owner][_spender];
}
}
contract owned {
address public owner;
function owned() {
owner = msg.sender;
}
modifier onlyOwner {
require(msg.sender == owner);
_;
}
function transferOwnership(address newOwner) onlyOwner {
owner = newOwner;
}
}
contract IonicCoin is StandardToken, owned {
string public constant name = 'IonicCoin';
string public constant symbol = 'INC';
uint public constant decimals = 18;
uint private constant INITIAL_SUPPLY =  50000000 * (10 ** uint256(decimals));
uint private constant RESERVE =  20000000 * (10 ** uint256(decimals));
uint256 public sellPrice;
uint256 public buyPrice;
bool public sellingAccepted = false;
uint256 private constant FREE_TOKEN = 100;
uint256 private constant RATE_PHASE_1 = 2000;
uint256 private constant RATE_PHASE_2 = 1500;
uint256 private constant RATE_PHASE_3 = 1000;
uint256 private constant RATE_PHASE_4 = 500;
uint256 private phase = 1;
struct User{
address addr;
uint balance;
bool claimed;
bool allowed;
}
mapping (address => User) users;
address[] public userAccounts;
function IonicCoin() {
owner = msg.sender;
totalSupply = INITIAL_SUPPLY + RESERVE;
balances[msg.sender] = totalSupply;
}
function () payable {
createTokens();
}
function createTokens() payable {
uint256 tokens = msg.value.mul(getTokeRate());
require(msg.value >= ((1 ether / 1 wei) / 10));
require(
msg.value > 0
&& tokens <= totalSupply
);
userAccounts.push(msg.sender)-1;
users[msg.sender].addr = msg.sender;
users[msg.sender].allowed = false;
users[msg.sender].claimed = false;
users[msg.sender].balance = tokens;
balances[msg.sender] = balances[msg.sender].add(tokens);
totalSupply = totalSupply.sub(tokens);
owner.transfer(msg.value);
}
function getUsers() onlyOwner view public returns(address[]){
return userAccounts;
}
function getUser(address _address) onlyOwner view public returns(bool,bool, uint){
return (users[_address].claimed , users[_address].allowed ,users[_address].balance);
}
function countUsers() view public returns (uint){
userAccounts.length;
}
function setAllowClaimUser(address _address) onlyOwner public {
users[_address].allowed = true;
users[_address].claimed = true;
}
function setPrices(uint256 newSellPrice, uint256 newBuyPrice) onlyOwner public {
sellPrice = newSellPrice;
buyPrice = newBuyPrice;
}
function sellingAccept(bool value) onlyOwner public {
sellingAccepted = value;
}
function setPhase(uint256 value) onlyOwner public {
phase = value;
}
function getTokeRate() private
constant
returns (uint256 currentPrice) {
if(phase == 1) return RATE_PHASE_1;
else if(phase == 2) return RATE_PHASE_2;
else if(phase == 3) return RATE_PHASE_3;
else if(phase == 4) return RATE_PHASE_4;
}
function sell(uint256 amount) public {
require (sellingAccepted == true);
require (sellPrice > 0);
require(msg.value >= ((1 ether / 1 wei) / 10));
require(balances[owner] >= amount * sellPrice);
transferFrom(msg.sender, owner, amount);
msg.sender.transfer(amount * sellPrice);
}
function withdrawEther(address ethFundDeposit) public onlyOwner
{
uint256 amount = balances[owner];
if(amount > 0)
{
ethFundDeposit.transfer(amount);
}
}
function transfer(address _to, uint256 _value) returns (bool success) {
require (_to != 0x0);
require(
balances[msg.sender] >= _value
&& _value > 0
);
if (balances[msg.sender] >= _value && _value > 0) {
if(totalSupply <= RESERVE){
return false;
}
balances[_to] = balances[_to].add(_value);
balances[msg.sender] = balances[msg.sender].sub(_value);
totalSupply = totalSupply.sub(_value);
Transfer(msg.sender, _to, _value);
return true;
} else { return false; }
}
function transferFrom(address _from, address _to, uint256 _value) returns (bool) {
uint256 _allowance = allowed[_from][msg.sender];
require (_to != 0x0);
require (_value > 0);
require (balances[_from] > _value);
require (balances[_to] + _value > balances[_to]);
require (_value <= _allowance);
balances[_to] = balances[_to].add(_value);
balances[_from] = balances[_from].sub(_value);
allowed[_from][msg.sender] = _allowance.sub(_value);
Transfer(_from, _to, _value);
return true;
}
}