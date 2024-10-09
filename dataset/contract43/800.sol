pragma solidity ^0.4.16;
contract SafeMath {
function safeMul(uint256 a, uint256 b) internal pure returns (uint256) {
uint256 c = a * b;
require(a == 0 || c / a == b);
return c;
}
function safeDiv(uint256 a, uint256 b) internal pure returns (uint256) {
require(b > 0);
uint256 c = a / b;
require(a == b * c + a % b);
return c;
}
function safeSub(uint256 a, uint256 b) internal pure returns (uint256) {
require(b <= a);
return a - b;
}
function safeAdd(uint256 a, uint256 b) internal pure returns (uint256) {
uint256 c = a + b;
require(c>=a && c>=b);
return c;
}
}
contract GameCoin is SafeMath {
string public name;
string public symbol;
uint8 public decimals;
uint256 public totalSupply;
mapping (address => uint256) public balanceOf;
mapping (address => mapping (address => uint256)) public allowance;
event Transfer(address indexed from, address indexed to, uint256 value);
constructor() public {
totalSupply = 10*10**27;
balanceOf[msg.sender] = totalSupply;
name = "Game Coin";
symbol = "GC";
decimals = 18;
}
function _transfer(address _from, address _to, uint _value) internal {
require(_to != 0x0);
require(balanceOf[_from] >= _value);
require(balanceOf[_to] + _value > balanceOf[_to]);
uint previousBalances = balanceOf[_from] + balanceOf[_to];
balanceOf[_from] -= _value;
balanceOf[_to] += _value;
assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
}
function transfer(address _to, uint256 _value) public {
_transfer(msg.sender,_to,_value);
emit Transfer(msg.sender, _to, _value);
}
function approve(address _spender, uint256 _value) public returns (bool success) {
require(_value==0 || allowance[msg.sender][_spender]==0);
allowance[msg.sender][_spender] = _value;
return true;
}
function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
require(_value <= allowance[_from][msg.sender]);
allowance[_from][msg.sender] = SafeMath.safeSub(allowance[_from][msg.sender], _value);
_transfer(_from, _to, _value);
emit Transfer(_from, _to, _value);
return true;
}
}