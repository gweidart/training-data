pragma solidity ^0.4.11;
contract Token {
string public symbol;
string public name;
uint8 public decimals;
uint256 public totalSupply;
mapping(address => uint256) balances;
mapping(address => mapping (address => uint256)) allowed;
event Transfer(address indexed from, address indexed to, uint256 value);
event Approval(address indexed from, address indexed to, uint256 value);
modifier when_can_transfer(address _from, uint256 _value) {
require (balances[_from] >= _value);
_;
}
modifier when_can_receive(address _recipient, uint256 _value) {
require (balances[_recipient] + _value > balances[_recipient]);
_;
}
modifier when_is_allowed(address _from, address _delegate, uint256 _value) {
require (allowed[_from][_delegate] >= _value);
_;
}
function Token(uint256 initialSupply, string tokenName, string tokenSymbol, uint8 decimalUnits) {
balances[msg.sender] = initialSupply;
totalSupply = initialSupply;
decimals = decimalUnits;
symbol = tokenSymbol;
name = tokenName;
}
function totalSupply() constant returns (uint256 _totalSupply) {
_totalSupply = totalSupply;
}
function balanceOf(address _owner) constant returns (uint256 balance) {
return balances[_owner];
}
function transfer(address _to, uint256 _amount)
when_can_transfer(msg.sender, _amount)
when_can_receive(_to, _amount)
returns (bool success) {
balances[msg.sender] -= _amount;
balances[_to] += _amount;
Transfer(msg.sender, _to, _amount);
return true;
}
function transferFrom(
address _from,
address _to,
uint256 _amount
)
when_can_transfer(_from, _amount)
when_can_receive(_to, _amount)
when_is_allowed(_from, msg.sender, _amount)
returns (bool success) {
allowed[_from][msg.sender] -= _amount;
balances[_from] -= _amount;
balances[_to] += _amount;
Transfer(_from, _to, _amount);
return true;
}
function approve(address _spender, uint256 _amount) returns (bool success) {
allowed[msg.sender][_spender] = _amount;
Approval(msg.sender, _spender, _amount);
return true;
}
function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
return allowed[_owner][_spender];
}
function() {
require(true);
}
}