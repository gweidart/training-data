pragma solidity ^0.4.18;
contract DraconeumToken {
string public name = "Draconeum";
string public symbol = "DRCM";
uint8 public decimals = 8;
uint256 public totalSupply = 14000000;
uint256 public initialSupply = 14000000;
mapping (address => uint256) public balanceOf;
mapping (address => mapping (address => uint256)) public allowance;
event Transfer(address indexed from, address indexed to, uint256 value);
function DraconeumToken
(string tokenName, string tokenSymbol)
public {
totalSupply = initialSupply * 10 ** uint256(decimals);
balanceOf[msg.sender] = totalSupply;
name = tokenName ="Draconeum";
symbol = tokenSymbol ="DRCM";
}
function _transfer(address _from, address _to, uint _value) internal {
require(_to != 0x0);
require(balanceOf[_from] >= _value);
require(balanceOf[_to] + _value > balanceOf[_to]);
balanceOf[_from] -= _value;
balanceOf[_to] += _value;
Transfer(_from, _to, _value);
}
function transfer(address _to, uint256 _value) public {
_transfer(msg.sender, _to, _value);
}
}