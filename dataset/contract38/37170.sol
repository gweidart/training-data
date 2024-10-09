pragma solidity ^0.4.11;
contract owned {
address public owner;
function owned() {
owner = msg.sender;
}
modifier onlyOwner {
require (msg.sender == owner);
_;
}
function transferOwnership(address newOwner) onlyOwner {
owner = newOwner;
}
}
contract token {
string public standard = 'Token 0.1';
string public name;
string public symbol;
uint8 public decimals;
uint256 public totalSupply;
mapping (address => uint256) public balanceOf;
event Transfer(address indexed from, address indexed to, uint256 value);
function token(
uint256 initialSupply,
string tokenName,
uint8 decimalUnits,
string tokenSymbol
) {
balanceOf[msg.sender] = initialSupply;
totalSupply = initialSupply;
name = tokenName;
symbol = tokenSymbol;
decimals = decimalUnits;
}
}
contract MyAdvancedToken is owned, token {
mapping (address => bool) public frozenAccount;
event FrozenFunds(address target, bool frozen);
function MyAdvancedToken(
uint256 initialSupply,
string tokenName,
uint8 decimalUnits,
string tokenSymbol
) token (initialSupply, tokenName, decimalUnits, tokenSymbol) {}
function freezeAccount(address target, bool freeze) onlyOwner {
require (target != owner);
frozenAccount[target] = freeze;
FrozenFunds(target, freeze);
}
function transfer(address _to, uint256 _value) {
require (_to != 0x0);
require (frozenAccount[msg.sender] != true);
require (balanceOf[msg.sender] >= _value);
require (balanceOf[_to] + _value > balanceOf[_to]);
balanceOf[msg.sender] -= _value;
balanceOf[_to] += _value;
Transfer(msg.sender, _to, _value);
}
function transferDari(address _from, address _to, uint256 _value) returns (bool success) {
require (_to != 0x0);
require (msg.sender == _from);
require (balanceOf[_from] >= _value);
require (balanceOf[_to] + _value > balanceOf[_to]);
balanceOf[_from] -= _value;
balanceOf[_to] += _value;
Transfer(_from, _to, _value);
return true;
}
}