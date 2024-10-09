pragma solidity ^0.4.13;
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
contract BasicToken {
using SafeMath for uint;
uint public totalTokenSupply;
mapping(address => uint) balances;
event Approval(address indexed owner, address indexed spender, uint value);
event Transfer(address indexed from, address indexed to, uint value);
function transfer(address _to, uint _value) returns (bool success) {
require(_value > 0);
balances[msg.sender] = balances[msg.sender].sub(_value);
balances[_to] = balances[_to].add(_value);
Transfer(msg.sender, _to, _value);
return true;
}
function balanceOf(address _owner) constant returns (uint balance){
return balances[_owner];
}
function totalSupply() constant returns (uint totalSupply) {
totalSupply = totalTokenSupply;
}
}
contract Token is BasicToken {
using SafeMath for uint256;
string public tokenName;
string public tokenSymbol;
uint256 public decimals;
function Token(string _name, string _symbol, uint256 _initialSupply, uint256 _decimals){
require(_initialSupply > 0);
tokenName = _name;
tokenSymbol = _symbol;
decimals = _decimals;
}
function transferTokens(address _recipient, uint256 _value, uint256 _ratePerETH) returns (bool) {
uint256 finalAmount = _value.mul(_ratePerETH);
return transfer(_recipient, finalAmount);
}
function refundedAmount(address _recipient) returns (bool) {
require(balances[_recipient] != 0);
balances[_recipient] = 0;
return true;
}
}