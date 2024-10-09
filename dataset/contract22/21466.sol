pragma solidity ^0.4.16;
contract HDT_Token {
string public name;
string public symbol;
uint8 public decimals;
mapping (address => uint256) public balanceOf;
event Transfer(address indexed from, address indexed to, uint256 value);
function HDT_Token() public
{
balanceOf[msg.sender] = 210000000;
name ='HDTTC';
symbol = 'HTCC';
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