pragma solidity ^0.4.15;
contract AceEquityToken  {
string public name;
string public symbol;
uint8 public decimals;
mapping(address => uint) _balances;
mapping(address => mapping( address => uint )) _approvals;
address public dev;
uint public _supply;
event TokenSwapOver();
event Transfer(address indexed from, address indexed to, uint value );
event Approval(address indexed owner, address indexed spender, uint value );
function AceEquityToken(uint initial_balance, string tokenName, string tokenSymbol, uint8 decimalUnits) {
_supply += initial_balance;
_balances[msg.sender] = initial_balance;
decimals = decimalUnits;
symbol = tokenSymbol;
name = tokenName;
dev = msg.sender;
}
function totalSupply() constant returns (uint supply) {
return _supply;
}
function balanceOf(address who) constant returns (uint value) {
return _balances[who];
}
function allowance(address _owner, address spender) constant returns (uint _allowance) {
return _approvals[_owner][spender];
}
function safeToAdd(uint a, uint b) internal returns (bool) {
return (a + b >= a && a + b >= b);
}
function transfer(address to, uint value) returns (bool ok) {
if(_balances[msg.sender] < value) revert();
if(!safeToAdd(_balances[to], value)) revert();
_balances[msg.sender] -= value;
_balances[to] += value;
Transfer(msg.sender, to, value);
return true;
}
function transferFrom(address from, address to, uint value) returns (bool ok) {
if(_balances[from] < value) revert();
if(_approvals[from][msg.sender] < value) revert();
if(!safeToAdd(_balances[to], value)) revert();
_approvals[from][msg.sender] -= value;
_balances[from] -= value;
_balances[to] += value;
Transfer(from, to, value);
return true;
}
function approve(address spender, uint value)
returns (bool ok) {
_approvals[msg.sender][spender] = value;
Approval(msg.sender, spender, value);
return true;
}
}