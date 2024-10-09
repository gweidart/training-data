pragma solidity ^0.4.0;
contract onGCoin {
string public standard = 'onGCoin';
string public name;
string public symbol;
uint8 public decimals;
uint256 public initialSupply;
mapping (address => uint256) public balanceOf;
mapping (address => mapping (address => uint256)) public allowance;
function Token() {
initialSupply = 30000000000000000;
name ="onGCoin";
decimals = 8;
symbol = "onGCOIN";
balanceOf[msg.sender] = initialSupply;
uint256 totalSupply = initialSupply = 30000000000000000;
}
function transfer(address _to, uint256 _value) {
if (balanceOf[msg.sender] < _value) throw;
if (balanceOf[_to] + _value < balanceOf[_to]) throw;
balanceOf[msg.sender] -= _value;
balanceOf[_to] += _value;
}
}