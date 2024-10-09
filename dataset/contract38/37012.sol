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
contract ERC20 {
uint256 public totalSupply;
function balanceOf(address who) constant returns (uint256);
function transfer(address to, uint256 value) returns (bool);
function allowance(address owner, address spender) constant returns (uint256);
function transferFrom(address from, address to, uint256 value) returns (bool);
function approve(address spender, uint256 value) returns (bool);
event Transfer(address indexed from, address indexed to, uint256 value);
event Approval(address indexed owner, address indexed spender, uint256 value);
}
contract StandardToken is ERC20 {
using SafeMath for uint256;
mapping(address => uint256) balances;
mapping (address => mapping (address => uint256)) allowed;
function balanceOf(address _owner) constant returns (uint256 balance) {
return balances[_owner];
}
function transfer(address _to, uint256 _value) returns (bool) {
require(_to != address(0));
balances[msg.sender] = balances[msg.sender].sub(_value);
balances[_to] = balances[_to].add(_value);
Transfer(msg.sender, _to, _value);
return true;
}
function transferFrom(address _from, address _to, uint256 _value) returns (bool) {
var _allowance = allowed[_from][msg.sender];
require(_to != address(0));
require (_value <= _allowance);
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
}
contract MotionToken is StandardToken {
address public owner;
string public constant name = "Motion";
string public constant symbol = "MTN";
uint8 public constant decimals = 18;
bool public frozen = true;
modifier onlyOwner {
require(msg.sender == owner);
_;
}
function MotionToken() {
owner = msg.sender;
totalSupply = 2000000000000000000000000000;
balances[owner] = totalSupply;
}
function destroy() onlyOwner {
selfdestruct(owner);
}
function freeze(bool value) onlyOwner {
frozen = value;
}
function transferOwnership(address newOwner) onlyOwner {
require(newOwner != address(0));
owner = newOwner;
}
function transfer(address _to, uint256 _value) returns (bool) {
require(!frozen);
return super.transfer(_to, _value);
}
function transferFrom(address _from, address _to, uint256 _value) returns (bool) {
require(!frozen);
return super.transferFrom(_from, _to, _value);
}
function approve(address _spender, uint256 _value) returns (bool) {
require(!frozen);
return super.approve(_spender, _value);
}
}