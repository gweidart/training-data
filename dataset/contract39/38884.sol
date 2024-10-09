pragma solidity ^0.4.11;
contract ERC20 {
event Approval(address indexed _owner, address indexed _spender, uint _value);
event Transfer(address indexed _from, address indexed _to, uint _value);
function allowance(address _owner, address _spender) constant returns (uint remaining);
function approve(address _spender, uint _value) returns (bool success);
function balanceOf(address _owner) constant returns (uint balance);
function transfer(address _to, uint _value) returns (bool success);
function transferFrom(address _from, address _to, uint _value) returns (bool success);
}
contract Owned {
address public owner;
function Owned() {
owner = msg.sender;
}
modifier onlyOwner {
if (msg.sender != owner) throw;
_;
}
function transferOwnership(address newOwner) onlyOwner {
owner = newOwner;
}
}
contract Token is ERC20, Owned {
string public name;
string public symbol;
uint8 public decimals;
uint256 public totalSupply;
mapping (address => uint256) balance;
mapping (address => mapping (address => uint256)) allowed;
function Token(string tokenName, string tokenSymbol, uint8 decimalUnits, uint256 initialSupply) {
name = tokenName;
symbol = tokenSymbol;
decimals = decimalUnits;
totalSupply = initialSupply;
}
function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
return allowed[_owner][_spender];
}
function approve(address _spender, uint256 _value) returns (bool success) {
allowed[msg.sender][_spender] = _value;
Approval(msg.sender, _spender, _value);
return true;
}
function balanceOf(address _owner) constant returns (uint256 remainingBalance) {
return balance[_owner];
}
function transfer(address _to, uint256 _value) returns (bool success) {
if (balance[msg.sender] >= _value && balance[_to] + _value > balance[_to]) {
balance[msg.sender] -= _value;
balance[_to] += _value;
Transfer(msg.sender, _to, _value);
return true;
} else {
return false;
}
}
function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
if (balance[_from] >= _value && allowed[_from][msg.sender] >= _value && balance[_to] + _value > balance[_to]) {
balance[_to] += _value;
balance[_from] -= _value;
allowed[_from][msg.sender] -= _value;
Transfer(_from, _to, _value);
return true;
} else {
return false;
}
}
}
contract Prether is Token {
string public constant name = "PRETHER";
string public constant symbol = "PTH";
uint8 public constant decimals = 0;
uint256 public constant supply = 10000000;
function Prether()
Token(name, symbol, decimals, supply) {
balance[msg.sender] = supply;
}
function() {
throw;
}
function mintToken(address target, uint256 mintedAmount) onlyOwner returns (bool success) {
if ((totalSupply + mintedAmount) < totalSupply) {
throw;
} else {
balance[target] += mintedAmount;
totalSupply += mintedAmount;
Transfer(0, target, mintedAmount);
return true;
}
}
}