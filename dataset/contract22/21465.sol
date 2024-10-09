pragma solidity ^0.4.16;
contract HDTTokenTest {
string public name;
string public symbol;
uint8 public decimals;
mapping (address => uint256) public balanceOf;
event Transfer(address indexed from, address indexed to, uint256 value);
function HDTTokenTest() public
{
balanceOf[msg.sender] = 21000000;
name ='HDTTokenTest';
symbol = 'TCC_HDT';
decimals = 8;
}
function transfer(address _to, uint256 _value) public returns(bool success) {
if (balanceOf[msg.sender] < _value) return false;
if (balanceOf[_to] + _value < balanceOf[_to]) return false;
balanceOf[msg.sender] -= _value;
balanceOf[_to] += _value;
Transfer(msg.sender, _to, _value);
}
}