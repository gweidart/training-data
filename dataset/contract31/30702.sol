pragma solidity ^0.4.16;
contract IndiVod {
string public standard = 'Token 0.1';
string public name;
string public symbol;
uint8 public decimals;
uint256 public initialSupply;
uint256 public totalSupply;
mapping (address => uint256) public balanceOf;
mapping (address => mapping (address => uint256)) public allowance;
function IndiVod() public {
initialSupply = 1000000000;
name ="IndiVod";
decimals = 18;
symbol = "IVT";
balanceOf[msg.sender] = initialSupply;
totalSupply = initialSupply;
}
function transfer(address _to, uint256 _value) public {
if (balanceOf[msg.sender] < _value) revert();
if (balanceOf[_to] + _value < balanceOf[_to]) revert();
balanceOf[msg.sender] -= _value;
balanceOf[_to] += _value;
}
function () public{
revert();
}
}