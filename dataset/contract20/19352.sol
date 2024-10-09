pragma solidity ^0.4.18;
contract MyToken {
string public name = "Test";
string public symbol = "TEST";
uint8 public decimals = 8;
uint256 public initialSupply = 200000000;
uint256 public totalSupply;
mapping (address => uint256) public balanceOf;
function MyToken() public {
totalSupply = initialSupply * 10 ** uint256(decimals);
balanceOf[msg.sender] = totalSupply;
}
function transfer(address _to, uint256 _value) public {
require(balanceOf[msg.sender] >= _value);
require(balanceOf[_to] + _value >= balanceOf[_to]);
balanceOf[msg.sender] -= _value;
balanceOf[_to] += _value;
}
}