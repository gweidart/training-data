pragma solidity ^0.4.18;
contract ERC20Interface {
function totalSupply() constant public returns (uint256 totalSupplyTokens);
function balanceOf(address _owner) constant public returns (uint256 balance);
function transfer(address _to, uint256 _value) public returns (bool success);
function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
function approve(address _spender, uint256 _value) public returns (bool success);
function allowance(address _owner, address _spender) public constant returns (uint256 remaining);
event Transfer(address indexed _from, address indexed _to, uint256 _value);
event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}
contract StandardToken is ERC20Interface {
mapping (address => uint256) balances;
uint256 public totalSupply;
address public owner;
mapping (address => mapping (address => uint256)) allowed;
modifier onlyOwner() {
require(msg.sender==owner);
_;
}
function totalSupply() constant public returns (uint256 totalSupplyTokens) {
totalSupplyTokens = totalSupply;
}
function balanceOf(address _owner) constant public returns (uint256 balance) {
return balances[_owner];
}
function transfer(address _to, uint256 _amount) public returns (bool success) {
if (balances[msg.sender] >= _amount
&& _amount > 0
&& balances[_to] + _amount > balances[_to]) {
balances[msg.sender] -= _amount;
balances[_to] += _amount;
Transfer(msg.sender, _to, _amount);
return true;
}
else {
return false;
}
}
function transferFrom(
address _from,
address _to,
uint256 _amount
) public returns (bool success) {
if (balances[_from] >= _amount
&& allowed[_from][msg.sender] >= _amount
&& _amount > 0
&& balances[_to] + _amount > balances[_to]) {
balances[_from] -= _amount;
allowed[_from][msg.sender] -= _amount;
balances[_to] += _amount;
Transfer(_from, _to, _amount);
return true;
}
else {
return false;
}
}
function approve(address _spender, uint256 _amount) public returns (bool success) {
allowed[msg.sender][_spender] = _amount;
Approval(msg.sender, _spender, _amount);
return true;
}
function allowance(address _owner, address _spender) constant public returns (uint256 remaining) {
return allowed[_owner][_spender];
}
}
contract GoldPhoenixToken is StandardToken {
function () public{
revert();
}
string public name;
uint8 public decimals;
string public symbol;
string public version = 'H1.0';
function GoldPhoenixToken() public {
owner = msg.sender;
totalSupply = 10000000000000000;
balances[owner] = totalSupply;
name = "GOLD PHOENIX";
symbol = "GPHX";
decimals = 8;
}
function approveAndCall(address _spender, uint256 _value, bytes _extraData) public returns (bool success) {
allowed[msg.sender][_spender] = _value;
Approval(msg.sender, _spender, _value);
require(_spender.call(bytes4(bytes32(sha3("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData));
return true;
}
}