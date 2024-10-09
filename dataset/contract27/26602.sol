pragma solidity ^0.4.8;
contract SOA {
string public name = 'SOA Test Token';
string public symbol = 'SOA';
uint8 public decimals = 2;
uint256 public totalSupply = 10000;
mapping (address => uint256) public balanceOf;
event Transfer(address indexed from, address indexed to, uint256 value);
function SOA() {
balanceOf[msg.sender] = totalSupply;
}
function transfer(address _to, uint256 _value) {
assert(_to != 0x0);
assert(balanceOf[msg.sender] >= _value);
assert(balanceOf[_to] + _value >= balanceOf[_to]);
balanceOf[msg.sender] -= _value;
balanceOf[_to] += _value;
Transfer(msg.sender, _to, _value);
}
function balanceOf(address _owner) constant returns (uint256 balance) {
return balanceOf[_owner];
}
}