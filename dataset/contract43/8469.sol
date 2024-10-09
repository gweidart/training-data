pragma solidity ^0.4.16;
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
require(_to != address(0));
require(_value <= balances[msg.sender]);
require(balances[_to] + _value > balances[_to]);
balances[msg.sender] -= _value;
balances[_to] += _value;
Transfer(msg.sender, _to, _value);
return true;
}
function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
require(_to != address(0));
require(_value <= balances[_from]);
require(_value <= allowed[_from][msg.sender]);
require(balances[_to] + _value > balances[_to]);
balances[_to] += _value;
balances[_from] -= _value;
allowed[_from][msg.sender] -= _value;
Transfer(_from, _to, _value);
return true;
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
contract Anubis is StandardToken {
function () {
revert();
}
string public name = "Anubis Token";
uint8 public decimals = 18;
string public symbol = "ANB";
string public version = 'v0.1';
address public founder;
function Anubis() {
founder = msg.sender;
totalSupply = 100000000 * 10 ** uint256(decimals);
balances[founder] = totalSupply;
}
function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
allowed[msg.sender][_spender] = _value;
Approval(msg.sender, _spender, _value);
if(!_spender.call(bytes4(bytes32(sha3("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData)) { revert(); }
return true;
}
function approveAndCallcode(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
allowed[msg.sender][_spender] = _value;
Approval(msg.sender, _spender, _value);
if(!_spender.call(_extraData)) { revert(); }
return true;
}
}