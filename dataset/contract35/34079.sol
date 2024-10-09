pragma solidity ^0.4.11;
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
function transferFrom(address from, address to, uint256 value) returns (bool);
function approve(address spender, uint256 value) returns (bool);
event Approval(address indexed owner, address indexed spender, uint256 value);
}
contract ChronoBase is ERC20 {
using SafeMath for uint256;
string public name;
string public symbol;
uint8 public decimals;
string public version;
address public owner;
mapping (address => uint256) public balances;
mapping (address => uint256) public frozen;
mapping (address => mapping (address => uint256)) public allowed;
event Burn(address indexed from, uint256 value);
event Freeze(address indexed from, uint256 value);
event Unfreeze(address indexed from, uint256 value);
function ChronoBase() {
balances[msg.sender] = 10000000000000000;
totalSupply = 10000000000000000;
name = 'ChronoBase';
symbol = 'BASE';
decimals = 8;
version = 'BASE1.0';
owner = msg.sender;
}
function balanceOf(address _owner) constant returns (uint256 balance){
return balances[_owner];
}
modifier noBurn(address _to) {
require(_to != 0x0);
_;
}
function transfer(address _to, uint256 _value) noBurn(_to) returns (bool){
balances[msg.sender] = balances[msg.sender].sub(_value);
balances[_to] = balances[_to].add(_value);
Transfer(msg.sender, _to, _value);
return true;
}
function transferFrom(address _from, address _to, uint256 _value) noBurn(_to) returns (bool success) {
allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
balances[_from] = balances[_from].sub(_value);
balances[_to] = balances[_to].add(_value);
Transfer(_from, _to, _value);
return true;
}
function approve(address _spender, uint256 _value) returns (bool success) {
require((_value == 0) || (allowed[msg.sender][_spender] == 0));
allowed[msg.sender][_spender] = _value;
Approval(msg.sender, _spender, _value);
return true;
}
function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
return allowed[_owner][_spender];
}
function burn(uint256 _value) returns (bool success) {
balances[msg.sender] = balances[msg.sender].sub(_value);
totalSupply = totalSupply.sub(_value);
Burn(msg.sender, _value);
return true;
}
function freeze(uint256 _value) returns (bool success) {
balances[msg.sender] = balances[msg.sender].sub(_value);
frozen[msg.sender] = frozen[msg.sender].add(_value);
Freeze(msg.sender, _value);
return true;
}
function unfreeze(uint256 _value) returns (bool success) {
frozen[msg.sender] = frozen[msg.sender].sub(_value);
balances[msg.sender] = balances[msg.sender].add(_value);
Unfreeze(msg.sender, _value);
return true;
}
function freezeOf(address _owner) constant returns (uint256) {
return frozen[_owner];
}
function () payable {
revert();
}
}