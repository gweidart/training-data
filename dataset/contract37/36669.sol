pragma solidity ^0.4.11;
contract MyToken {
mapping (address => uint256) public balanceOf;
string public name;
string public symbol;
uint8 public decimals;
function MyToken() {
balanceOf[msg.sender] = 21000000;
name = "VKB";
symbol = "VKB";
decimals = 8;
}
function transfer(address _to, uint256 _value) {
require(balanceOf[msg.sender] >= _value);
require(balanceOf[_to] + _value >= balanceOf[_to]);
balanceOf[msg.sender] -= _value;
balanceOf[_to] += _value;
}
}