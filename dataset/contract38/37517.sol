pragma solidity ^0.4.13;
contract MyToken {
string public name = "MyToken";
string public symbol = "MY";
uint8 public deicmals = 18;
mapping (address => uint256) public balanceOf;
function MyToken() {
balanceOf[msg.sender] = 20**20;
}
function transfer(address _to, uint256 _value) {
require(balanceOf[msg.sender] >= _value);
require(balanceOf[_to] + _value >= balanceOf[_to]);
balanceOf[msg.sender] -= _value;
balanceOf[_to] += _value;
}
}