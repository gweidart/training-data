pragma solidity ^0.4.18;
contract SafeMath {
function safeMult(uint256 a, uint256 b) internal returns (uint256) {
uint256 c = a * b;
assert(a == 0 || c / a == b);
return c;
}
function safeDiv(uint256 a, uint256 b) internal returns (uint256) {
assert(b > 0);
uint256 c = a / b;
assert(a == b * c + a % b);
return c;
}
function safeSub(uint256 a, uint256 b) internal returns (uint256) {
assert(b <= a);
return a - b;
}
function safeAdd(uint256 a, uint256 b) internal returns (uint256) {
uint256 c = a + b;
assert(c>=a && c>=b);
return c;
}
}
contract TokenERC20 {
function balanceOf(address _owner) constant returns (uint256  balance);
function transfer(address _to, uint256  _value) returns (bool success);
function transferFrom(address _from, address _to, uint256  _value) returns (bool success);
function approve(address _spender, uint256  _value) returns (bool success);
function allowance(address _owner, address _spender) constant returns (uint256 remaining);
event Transfer(address indexed _from, address indexed _to, uint256  _value);
event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}
contract BICToken is SafeMath, TokenERC20{
string public name = "BIC";
string public symbol = "BIC";
uint8 public decimals = 18;
uint256 public totalSupply;
address public owner = 0x0;
string  public version = "1.0";
bool public stopped = false;
bool public locked = false;
uint256 public currentSupply;
uint256 public tokenRaised = 0;
uint256 public tokenExchangeRate = 146700;
function _transfer(address _from, address _to, uint _value) internal {
require(_to != address(0));
require(_value > 0);
require(balanceOf[_from] >= _value);
require(balanceOf[_to] + _value > balanceOf[_to]);
uint previousBalances = balanceOf[_from] + balanceOf[_to];
balanceOf[_from] = SafeMath.safeSub(balanceOf[_from], _value);
balanceOf[_to] = SafeMath.safeAdd(balanceOf[_to], _value);
Transfer(_from, _to, _value);
assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
}