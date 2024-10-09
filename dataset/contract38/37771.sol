pragma solidity ^0.4.4;
contract SafeMath {
function safeMul(uint a, uint b) internal returns (uint) {
uint c = a * b;
assert(a == 0 || c / a == b);
return c;
}
function safeSub(uint a, uint b) internal returns (uint) {
assert(b <= a);
return a - b;
}
function safeAdd(uint a, uint b) internal returns (uint) {
uint c = a + b;
assert(c>=a && c>=b);
return c;
}
function assert(bool assertion) internal {
if (!assertion) throw;
}
}
contract Token is SafeMath {
function totalSupply() constant returns (uint256 supply) {}
function balanceOf(address _owner) constant returns (uint256 balance) {}
function transfer(address _to, uint256 _value) {}
function transferFrom(address _from, address _to, uint256 _value){}
function approve(address _spender, uint256 _value) returns (bool success) {}
function allowance(address _owner, address _spender) constant returns (uint256 remaining) {}
event Transfer(address indexed _from, address indexed _to, uint256 _value);
event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}
contract StdToken is Token {
mapping(address => uint256) balances;
mapping (address => mapping (address => uint256)) allowed;
uint public totalSupply = 0;
function transfer(address _to, uint256 _value) {
if((balances[msg.sender] < _value) || (balances[_to] + _value <= balances[_to])) {
throw;
}
balances[msg.sender] -= _value;
balances[_to] += _value;
Transfer(msg.sender, _to, _value);
}
function transferFrom(address _from, address _to, uint256 _value) {
if((balances[_from] < _value) ||
(allowed[_from][msg.sender] < _value) ||
(balances[_to] + _value <= balances[_to]))
{
throw;
}
balances[_to] += _value;
balances[_from] -= _value;
allowed[_from][msg.sender] -= _value;
Transfer(_from, _to, _value);
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
modifier onlyPayloadSize(uint _size) {
if(msg.data.length < _size + 4) {
throw;
}
_;
}
}
contract GOLD is StdToken {
string public constant name = "Goldmint GOLD Token";
string public constant symbol = "GOLD";
uint public constant decimals = 18;
address public creator = 0x0;
address public tokenManager = 0x0;
bool public lock = true;
modifier onlyCreator() { if(msg.sender != creator) throw; _; }
modifier onlyCreatorOrTokenManager() { if((msg.sender!=creator) && (msg.sender!=tokenManager)) throw; _; }
function setCreator(address _creator) onlyCreator {
creator = _creator;
}
function setTokenManager(address _manager) onlyCreator {
tokenManager = _manager;
}
function lockContract(bool _lock) onlyCreator {
lock = _lock;
}
function GOLD() {
creator = msg.sender;
tokenManager = msg.sender;
}
function transfer(address _to, uint256 _value) public {
if(lock && (msg.sender!=tokenManager)){
throw;
}
super.transfer(_to,_value);
}
function transferFrom(address _from, address _to, uint256 _value)public{
if(lock && (msg.sender!=tokenManager)){
throw;
}
super.transferFrom(_from,_to,_value);
}
function approve(address _spender, uint256 _value) public returns (bool) {
if(lock && (msg.sender!=tokenManager)){
throw;
}
return super.approve(_spender,_value);
}
function issueTokens(address _who, uint _tokens) onlyCreatorOrTokenManager {
if(lock && (msg.sender!=tokenManager)){
throw;
}
balances[_who] += _tokens;
totalSupply += _tokens;
}
function burnTokens(address _who, uint _tokens) onlyCreatorOrTokenManager {
if(lock && (msg.sender!=tokenManager)){
throw;
}
balances[_who] = safeSub(balances[_who], _tokens);
totalSupply = safeSub(totalSupply, _tokens);
}
function() {
throw;
}
}