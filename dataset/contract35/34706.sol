pragma solidity ^0.4.15;
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
contract HONIGToken  {
using SafeMath for uint256;
string public constant symbol = "HONEY";
string public constant name = "HONIGToken";
uint8 public constant decimals = 1;
address public owner;
uint256 _totalSupply = 1000000;
mapping (address => uint256) balances;
mapping (address => mapping (address => uint256)) allowed;
event Transfer(address indexed _from, address indexed _to, uint256 _value);
event Approval(address indexed _owner, address indexed _spender, uint256 _value);
function HONIGToken() {
owner = msg.sender;
balances[owner] = _totalSupply;
}
function transfer(address _to, uint256 _value) {
require(balances[msg.sender] >= _value);
require(balances[_to] + _value >= balances[_to]);
balances[msg.sender] -= _value;
balances[_to] += _value;
}
}