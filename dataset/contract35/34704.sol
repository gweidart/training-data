pragma solidity ^0.4.15;
contract SAUBAERtoken  {
string public constant symbol = "SAUBAER";
string public constant name = "SAUBAER";
uint8 public constant decimals = 1;
address public owner;
uint256 _totalSupply = 100000;
mapping (address => uint256) balances;
mapping (address => mapping (address => uint256)) allowed;
event Transfer(address indexed _from, address indexed _to, uint256 _value);
event Approval(address indexed _owner, address indexed _spender, uint256 _value);
function SAUBAERtoken() {
owner = msg.sender;
balances[owner] = _totalSupply;
}
function transfer(address _to, uint256 _value) returns (bool success) {
if (balances[msg.sender] >= _value && _value > 0) {
balances[msg.sender] -= _value;
balances[_to] += _value;
Transfer(msg.sender, _to, _value);
return true;
} else { return false; }
}
}