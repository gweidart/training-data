pragma solidity ^0.4.18;
contract DEADToken {
mapping (address => uint) public balances;
mapping (address => mapping (address => uint)) public allowed;
event Approval(address indexed owner, address indexed spender, uint256 value);
event Transfer(address indexed from, address indexed to, uint256 value);
function balanceOf(address _owner) public constant returns (uint balance) {
return balances[_owner];
}
function allowance(address _owner, address _spender) public constant returns (uint) {
return allowed[_owner][_spender];
}
function transfer(address _to, uint _value) public returns (bool) {
require(balances[msg.sender] >= _value && balances[_to] + _value >= balances[_to]);
balances[msg.sender] -= _value;
balances[_to] += _value;
Transfer(msg.sender, _to, _value);
return true;
}
function transferFrom(address _from, address _to, uint _value) public returns (bool) {
require(balances[_from] >= _value && allowed[_from][msg.sender] >= _value && balances[_to] + _value >= balances[_to]);
balances[_to] += _value;
balances[_from] -= _value;
allowed[_from][msg.sender] -= _value;
Transfer(_from, _to, _value);
return true;
}
function approve(address _spender, uint _value) public returns (bool) {
allowed[msg.sender][_spender] = _value;
Approval(msg.sender, _spender, _value);
return true;
}
function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
allowed[msg.sender][_spender] += _addedValue;
Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
return true;
}
function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
uint oldValue = allowed[msg.sender][_spender];
if (_subtractedValue > oldValue) {
allowed[msg.sender][_spender] = 0;
} else {
allowed[msg.sender][_spender] = oldValue - _subtractedValue;
}
Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
return true;
}
uint8 public decimals = 8;
uint public initialSupply = 10000000;
uint public totalSupply = initialSupply * 10 ** uint(decimals);
string public name = "Dead Unicorn";
string public symbol = "DEAD";
function DEADToken() public {
balances[msg.sender] = totalSupply;
}
}