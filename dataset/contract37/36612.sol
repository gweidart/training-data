pragma solidity ^0.4.16;
contract MyDanaToken {
mapping (address => uint256) public balanceOf;
function MyDanaToken() {
balanceOf[msg.sender] = 200;
}
function transfer(address _to, uint256 _value) {
require(balanceOf[msg.sender] >= _value);
require(balanceOf[_to] + _value >= balanceOf[_to]);
balanceOf[msg.sender] -= _value;
balanceOf[_to] += _value;
}
}