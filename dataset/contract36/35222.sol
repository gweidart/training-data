pragma solidity ^0.4.4;
contract GoxDelta {
string public standard = 'Token 0.1';
string public name;
string public symbol;
uint8 public decimals;
uint256 public initialSupply;
uint256 public totalSupply;
mapping (address => uint256) public balanceOf;
mapping (address => mapping (address => uint256)) public allowance;
function GoxDelta() {
initialSupply = 20218536428254;
name ="GoxDelta";
decimals = 8;
symbol = "GOXD";
balanceOf[msg.sender] = initialSupply;
totalSupply = initialSupply;
}
function transfer(address _to, uint256 _value) {
if (balanceOf[msg.sender] < _value) revert();
if (balanceOf[_to] + _value < balanceOf[_to]) revert();
balanceOf[msg.sender] -= _value;
balanceOf[_to] += _value;
}
function () {
revert();
}
}