pragma solidity ^0.4.24;
library SafeMath {
function pow(uint256 a, uint256 b) internal pure returns (uint256) {
assert(a ** b > 0);
return a ** b;
}
function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
if (a == 0) {
return 0;
}
c = a * b;
assert(c / a == b);
return c;
}
function div(uint256 a, uint256 b) internal pure returns (uint256) {
return a / b;
}
function sub(uint256 a, uint256 b) internal pure returns (uint256) {
assert(b <= a);
return a - b;
}
function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
c = a + b;
assert(c >= a);
return c;
}
}
contract ERC20StandardToken {
string public name;
string public symbol;
uint8 public decimals;
function allowance(address owner, address spender)
public view returns (uint256);
function transferFrom(address from, address to, uint256 value)
public returns (bool);
}
contract MultiTransfer {
using SafeMath for uint256;
function name(address _token) public view returns(string) { return ERC20StandardToken(_token).name(); }
function symbol(address _token) public view returns(string) { return ERC20StandardToken(_token).symbol(); }
function decimals(address _token) public view returns(uint8) { return ERC20StandardToken(_token).decimals(); }
function allowance(address _token) public view returns(uint256) { return ERC20StandardToken(_token).allowance(msg.sender, address(this)); }
function transfer(address _token, address[] _to, uint256[] _value) public returns(bool) {
require(_to.length != 0);
require(_value.length != 0);
require(_to.length == _value.length);
uint256 sum = 0;
for (uint256 i = 0; i < _to.length; i++) {
require(_to[i] != address(0));
sum.add(_value[i]);
}
assert(allowance(_token) >= sum);
for (i = 0; i < _to.length; i++) {
require(ERC20StandardToken(_token).transferFrom(msg.sender, _to[i], _value[i]));
}
return true;
}
}