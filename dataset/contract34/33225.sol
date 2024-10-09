pragma solidity 0.4.15;
contract Token {
function transfer(address to, uint256 value) returns (bool success);
function transferFrom(address from, address to, uint256 value) returns (bool success);
function approve(address spender, uint256 value) returns (bool success);
function balanceOf(address owner) constant returns (uint256 balance);
function allowance(address owner, address spender) constant returns (uint256 remaining);
event Transfer(address indexed from, address indexed to, uint256 value);
event Approval(address indexed owner, address indexed spender, uint256 value);
}
contract StandardToken is Token {
mapping (address => uint256) balances;
mapping (address => mapping (address => uint256)) allowed;
uint256 public totalSupply;
function transfer(address _to, uint256 _value)
public
returns (bool)
{
if (balances[msg.sender] < _value) {
revert();
}
balances[msg.sender] -= _value;
balances[_to] += _value;
Transfer(msg.sender, _to, _value);
return true;
}
function transferFrom(address _from, address _to, uint256 _value)
public
returns (bool)
{
if (balances[_from] < _value || allowed[_from][msg.sender] < _value) {
revert();
}
balances[_to] += _value;
balances[_from] -= _value;
allowed[_from][msg.sender] -= _value;
Transfer(_from, _to, _value);
return true;
}
function approve(address _spender, uint256 _value)
public
returns (bool)
{
allowed[msg.sender][_spender] = _value;
Approval(msg.sender, _spender, _value);
return true;
}
function allowance(address _owner, address _spender)
constant
public
returns (uint256)
{
return allowed[_owner][_spender];
}
function balanceOf(address _owner)
constant
public
returns (uint256)
{
return balances[_owner];
}
}
contract VirtuePlayerPoints is StandardToken {
string constant public name = "Virtue Player Points";
string constant public symbol = "VPP";
uint8 constant public decimals = 18;
function VirtuePlayerPoints(address dutchAuction, address[] owners, uint[] tokens)
public
{
require (dutchAuction != 0);
totalSupply = 10000000 * 10**18;
balances[dutchAuction] = 5000000 * 10**18;
Transfer(0, dutchAuction, balances[dutchAuction]);
uint assignedTokens = balances[dutchAuction];
for (uint i=0; i<owners.length; i++) {
require (owners[i] != 0);
balances[owners[i]] += tokens[i];
Transfer(0, owners[i], tokens[i]);
assignedTokens += tokens[i];
}
require (assignedTokens == totalSupply);
}
}