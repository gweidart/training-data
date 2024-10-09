pragma solidity ^0.4.10;
contract SafeMath {
function safeAdd(uint256 x, uint256 y) internal returns(uint256) {
uint256 z = x + y;
assert((z >= x) && (z >= y));
return z;
}
function safeSubtract(uint256 x, uint256 y) internal returns(uint256) {
assert(x >= y);
uint256 z = x - y;
return z;
}
function safeMult(uint256 x, uint256 y) internal returns(uint256) {
uint256 z = x * y;
assert((x == 0)||(z/x == y));
return z;
}
}
contract Token {
uint256 public totalSupply;
function balanceOf(address _owner) constant returns (uint256 balance);
function transfer(address _to, uint256 _value) returns (bool success);
function transferFrom(address _from, address _to, uint256 _value) returns (bool success);
function approve(address _spender, uint256 _value) returns (bool success);
function allowance(address _owner, address _spender) constant returns (uint256 remaining);
event Transfer(address indexed _from, address indexed _to, uint256 _value);
event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}
contract StandardToken is Token {
function transfer(address _to, uint256 _value) returns (bool success) {
if (balances[msg.sender] >= _value && _value > 0) {
balances[msg.sender] -= _value;
balances[_to] += _value;
Transfer(msg.sender, _to, _value);
return true;
} else {
return false;
}
}
function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0) {
balances[_to] += _value;
balances[_from] -= _value;
allowed[_from][msg.sender] -= _value;
Transfer(_from, _to, _value);
return true;
} else {
return false;
}
}
function balanceOf(address _owner) constant returns (uint256 balance) {
return balances[_owner];
}
function approve(address _spender, uint256 _value) returns (bool success) {
allowed[msg.sender][_spender] = _value;
Approval(msg.sender, _spender, _value);
return true;
}
function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
return allowed[_owner][_spender];
}
mapping (address => uint256) balances;
mapping (address => mapping (address => uint256)) allowed;
}
contract FakeToken is StandardToken, SafeMath {
string public constant name = "Fake Token";
string public constant symbol = "FTK";
uint256 public constant decimals = 18;
string public version = "1.0";
address public ethFundDeposit;
bool public isFinalized;
uint256 public fundingStartBlock;
uint256 public fundingEndBlock;
uint256 public constant tokenExchangeRate = 6400;
function FakeToken(
address _owner,
uint256 _fundingStartBlock,
uint256 _fundingEndBlock)
{
isFinalized = false;
ethFundDeposit = _owner;
fundingStartBlock = _fundingStartBlock;
fundingEndBlock = _fundingEndBlock;
totalSupply = 0;
}
function () payable external {
require (block.number >= fundingStartBlock);
require (block.number <= fundingEndBlock);
if (msg.value == 0) throw;
uint256 tokens = safeMult(msg.value, tokenExchangeRate);
uint256 checkedSupply = safeAdd(totalSupply, tokens);
Transfer(0, msg.sender, tokens);
totalSupply = checkedSupply;
balances[msg.sender] += tokens;
}
function finalize() external {
if (msg.sender != ethFundDeposit) throw;
if(!ethFundDeposit.send(this.balance)) throw;
}
}