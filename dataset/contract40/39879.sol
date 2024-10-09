pragma solidity ^0.4.4;
contract SafeMath
{
function safeMul(uint a, uint b) internal returns (uint)
{
uint c = a * b;
assert(a == 0 || c / a == b);
return c;
}
function safeSub(uint a, uint b) internal returns (uint)
{
assert(b <= a);
return a - b;
}
function safeAdd(uint a, uint b) internal returns (uint)
{
uint c = a + b;
assert(c>=a && c>=b);
return c;
}
function assert(bool assertion) internal
{
if (!assertion) throw;
}
}
contract Token
{
function totalSupply() constant returns (uint256 supply) {}
function balanceOf(address _owner) constant returns (uint256 balance) {}
function transfer(address _to, uint256 _value) returns (bool success) {}
function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {}
function approve(address _spender, uint256 _value) returns (bool success) {}
function allowance(address _owner, address _spender) constant returns (uint256 remaining) {}
event Transfer(address indexed _from, address indexed _to, uint256 _value);
event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}
contract StdToken is Token
{
mapping(address => uint256) balances;
mapping (address => mapping (address => uint256)) allowed;
uint256 public allSupply = 0;
function transfer(address _to, uint256 _value) returns (bool success)
{
if((balances[msg.sender] >= _value) && (balances[_to] + _value > balances[_to]))
{
balances[msg.sender] -= _value;
balances[_to] += _value;
Transfer(msg.sender, _to, _value);
return true;
}
else
{
return false;
}
}
function transferFrom(address _from, address _to, uint256 _value) returns (bool success)
{
if((balances[_from] >= _value) && (allowed[_from][msg.sender] >= _value) && (balances[_to] + _value > balances[_to]))
{
balances[_to] += _value;
balances[_from] -= _value;
allowed[_from][msg.sender] -= _value;
Transfer(_from, _to, _value);
return true;
}
else
{
return false;
}
}
function balanceOf(address _owner) constant returns (uint256 balance)
{
return balances[_owner];
}
function approve(address _spender, uint256 _value) returns (bool success)
{
allowed[msg.sender][_spender] = _value;
Approval(msg.sender, _spender, _value);
return true;
}
function allowance(address _owner, address _spender) constant returns (uint256 remaining)
{
return allowed[_owner][_spender];
}
function totalSupply() constant returns (uint256 supplyOut)
{
supplyOut = allSupply;
return;
}
}
contract ZilleriumToken is StdToken
{
string public name = "Zillerium Token";
uint public decimals = 18;
string public symbol = "ZTK";
address public creator = 0x0;
address public tokenClient = 0x0;
bool locked = false;
function ZilleriumToken()
{
creator = msg.sender;
tokenClient = msg.sender;
}
function changeClient(address newAddress)
{
if(msg.sender!=creator)throw;
tokenClient = newAddress;
}
function lock(bool value)
{
if(msg.sender!=creator) throw;
locked = value;
}
function transfer(address to, uint256 value) returns (bool success)
{
if(locked)throw;
success = super.transfer(to, value);
return;
}
function transferFrom(address from, address to, uint256 value) returns (bool success)
{
if(locked)throw;
success = super.transferFrom(from, to, value);
return;
}
function issueTokens(address forAddress, uint tokenCount) returns (bool success)
{
if(msg.sender!=tokenClient)throw;
if(tokenCount==0) {
success = false;
return ;
}
balances[forAddress]+=tokenCount;
allSupply+=tokenCount;
success = true;
return;
}
}