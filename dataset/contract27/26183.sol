pragma solidity ^0.4.19;
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
contract Ownable {
address public owner;
function Ownable() {
owner = msg.sender;
}
modifier onlyOwner() {
require(msg.sender == owner);
_;
}
}
library SafeMath {
function mul(uint256 a, uint256 b) internal returns (uint256) {
uint256 c = a * b;
assert(a == 0 || c / a == b);
return c;
}
function div(uint256 a, uint256 b) internal returns (uint256) {
uint256 c = a / b;
return c;
}
function sub(uint256 a, uint256 b) internal returns (uint256) {
assert(b <= a);
return a - b;
}
function add(uint256 a, uint256 b) internal returns (uint256) {
uint256 c = a + b;
assert(c >= a);
return c;
}
function minimum( uint a, uint b) internal returns ( uint result) {
if ( a <= b ) {
result = a;
}
else {
result = b;
}
}
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
contract AACToken is StandardToken, Ownable {
string public constant name = "AACToken";
string public constant symbol = "2AC";
uint256 public constant decimals = 8;
uint256 public constant MAX_SUPPLY_OF_TOKEN = 1500000000 * 10 ** decimals;
function AACToken() {
owner = msg.sender;
balances[msg.sender] = MAX_SUPPLY_OF_TOKEN;
totalSupply = MAX_SUPPLY_OF_TOKEN;
}
function getAddressBalance(address addr) constant returns (uint256 balance)  {
balance = balances[addr];
}
function getAddressAndBalance(address addr) constant returns (address _address, uint256 _amount)  {
_address = addr;
_amount = balances[addr];
}
function getOwnerInfos() constant returns (address owneraddr, uint256 balance)  {
owneraddr = owner;
balance = balances[owneraddr];
}
}