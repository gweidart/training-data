pragma solidity ^0.4.16;
contract TestCoin {
string public name;
string public symbol;
uint8 public decimals;
event Transfer(address indexed from, address indexed to, uint256 value);
mapping (address => uint256) public balanceOf;
function TestCoin() {
balanceOf[msg.sender] = 4000000;
name = "TestCoin";
symbol = "TEST";
decimals = 2;
}
function transfer(address _to, uint256 _value) {
require(balanceOf[msg.sender] >= _value);
require(balanceOf[_to] + _value >= balanceOf[_to]);
balanceOf[msg.sender] -= _value;
balanceOf[_to] += _value;
Transfer(msg.sender, _to, _value);
}
}