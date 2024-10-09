pragma solidity 0.4.11;
contract Wolker {
mapping (address => uint256) balances;
mapping (address => uint256) allocations;
mapping (address => mapping (address => uint256)) allowed;
mapping (address => mapping (address => bool)) authorized;
function transfer(address _to, uint256 _value) returns (bool success) {
if (balances[msg.sender] >= _value && _value > 0) {
balances[msg.sender] = safeSub(balances[msg.sender], _value);
balances[_to] = safeAdd(balances[_to], _value);
Transfer(msg.sender, _to, _value, balances[msg.sender], balances[_to]);
return true;
} else {
throw;
}
}
function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
var _allowance = allowed[_from][msg.sender];
if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0) {
balances[_to] = safeAdd(balances[_to], _value);
balances[_from] = safeSub(balances[_from], _value);
allowed[_from][msg.sender] = safeSub(_allowance, _value);
Transfer(_from, _to, _value, balances[_from], balances[_to]);
return true;
} else {
throw;
}
}
function totalSupply() external constant returns (uint256) {
return generalTokens + reservedTokens;
}
function balanceOf(address _owner) constant returns (uint256 balance) {
return balances[_owner];
}
function approve(address _spender, uint256 _value) returns (bool success) {
allowed[msg.sender][_spender] = _value;
Approval(msg.sender, _spender, _value);
return true;
}
function authorize(address _trustee) returns (bool success) {
authorized[msg.sender][_trustee] = true;
Authorization(msg.sender, _trustee);
return true;
}
function deauthorize(address _trustee_to_remove) returns (bool success) {
authorized[msg.sender][_trustee_to_remove] = false;
Deauthorization(msg.sender, _trustee_to_remove);
return true;
}
function check_authorization(address _owner, address _trustee) constant returns (bool authorization_status) {
return authorized[_owner][_trustee];
}
function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
return allowed[_owner][_spender];
}