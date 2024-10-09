pragma solidity ^0.4.10;
contract tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData); }
contract AICoreCoin {
string public name;
string public symbol;
uint8 public decimals;
uint256 public totalSupply;
mapping (address => uint256) public balanceOf;
mapping (address => mapping (address => uint256)) public allowance;
event Transfer(address indexed from, address indexed to, uint256 value);
event Burn(address indexed from, uint256 value);
function AICoreCoin() {
balanceOf[0x7C25E9F638eB1d12853d6bccb79411560de478f2] = 300000000000000;
totalSupply = 300000000000000;
name = "AICore Coin";
symbol = "AICC";
decimals = 6;
}
function _transfer(address _from, address _to, uint _value) internal {
require (_to != 0x0);
require (balanceOf[_from] > _value);
require (balanceOf[_to] + _value > balanceOf[_to]);
balanceOf[_from] -= _value;
balanceOf[_to] += _value;
Transfer(_from, _to, _value);
}
function transfer(address _to, uint256 _value) {
_transfer(msg.sender, _to, _value);
}
function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
require (_value < allowance[_from][msg.sender]);
allowance[_from][msg.sender] -= _value;
_transfer(_from, _to, _value);
return true;
}
function approve(address _spender, uint256 _value)
returns (bool success) {
allowance[msg.sender][_spender] = _value;
return true;
}
function approveAndCall(address _spender, uint256 _value, bytes _extraData)
returns (bool success) {
tokenRecipient spender = tokenRecipient(_spender);
if (approve(_spender, _value)) {
spender.receiveApproval(msg.sender, _value, this, _extraData);
return true;
}
}
function burn(uint256 _value) returns (bool success) {
require (balanceOf[msg.sender] > _value);
balanceOf[msg.sender] -= _value;
totalSupply -= _value;
Burn(msg.sender, _value);
return true;
}
function burnFrom(address _from, uint256 _value) returns (bool success) {
require(balanceOf[_from] >= _value);
require(_value <= allowance[_from][msg.sender]);
balanceOf[_from] -= _value;
allowance[_from][msg.sender] -= _value;
totalSupply -= _value;
Burn(_from, _value);
return true;
}
}