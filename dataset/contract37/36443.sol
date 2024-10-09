pragma solidity ^0.4.16;
contract Owned {
address owner;
function Owned() {
owner = msg.sender;
}
modifier onlyOwner() {
require(msg.sender == owner);
_;
}
}
interface ERC20 {
function totalSupply() constant returns (uint256);
function balanceOf(address _owner) constant returns (uint256);
function transfer(address _to, uint256 _value) returns (bool);
function transferFrom(address _from, address _to, uint256 _value) returns (bool);
function approve(address _spender, uint256 _value) returns (bool);
function allowance(address _owner, address _spender) constant returns (uint256);
event Transfer(address indexed _from, address indexed _to, uint256 _value);
event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}
contract Token is ERC20 {
string public name;
string public symbol;
uint8 public decimals;
uint256 public totalSupply;
address[] public holders;
mapping(address => uint256) index;
mapping(address => uint256) balances;
mapping(address => mapping(address => uint256)) allowances;
function Token(string _name, string _symbol, uint8 _decimals) {
name = _name;
symbol = _symbol;
decimals = _decimals;
}
function balanceOf(address _owner) constant returns (uint256) {
return balances[_owner];
}
function transfer(address _to, uint256 _value) returns (bool) {
if (balances[msg.sender] >= _value) {
balances[msg.sender] -= _value;
balances[_to] += _value;
if (_value > 0 && index[_to] == 0) {
index[_to] = holders.push(_to);
}
Transfer(msg.sender, _to, _value);
return true;
}
return false;
}
function transferFrom(address _from, address _to, uint256 _value) returns (bool) {
if (allowances[_from][msg.sender] >= _value &&
balances[_from] >= _value ) {
allowances[_from][msg.sender] -= _value;
balances[_from] -= _value;
balances[_to] += _value;
if (_value > 0 && index[_to] == 0) {
index[_to] = holders.push(_to);
}
Transfer(_from, _to, _value);
return true;
}
return false;
}
function approve(address _spender, uint256 _value) returns (bool) {
allowances[msg.sender][_spender] = _value;
Approval(msg.sender, _spender, _value);
return true;
}
function allowance(address _owner, address _spender) constant returns (uint256) {
return allowances[_owner][_spender];
}
function unapprove(address _spender) {
allowances[msg.sender][_spender] = 0;
}
function totalSupply() constant returns (uint256) {
return totalSupply;
}
function holderCount() constant returns (uint256) {
return holders.length;
}
}
contract Cat is Token("Test's Token", "TTS", 3), Owned {
function emit(uint256 _value) onlyOwner returns (bool) {
assert(totalSupply + _value >= totalSupply);
totalSupply += _value;
balances[owner] += _value;
return true;
}
}