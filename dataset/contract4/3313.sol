pragma solidity ^0.4.23;
contract SafeMath {
function safeAdd(uint256 x, uint256 y) internal returns (uint256) {
uint256 z = x + y;
assert((z >= x) && (z >= y));
return z;
}
function safeSubtract(uint256 x, uint256 y) internal returns (uint256) {
assert(x >= y);
uint256 z = x - y;
return z;
}
function safeMult(uint256 x, uint256 y) internal returns (uint256) {
uint256 z = x * y;
assert((x == 0) || (z / x == y));
return z;
}
}
contract Token {
uint256 public totalSupply;
function balanceOf(address _owner) constant returns (uint256 balance);
function transfer(address _to, uint256 _value) returns (bool success);
function transferFrom(
address _from,
address _to,
uint256 _value
) returns (bool success);
function approve(address _spender, uint256 _value) returns (bool success);
function allowance(
address _owner,
address _spender
) constant returns (uint256 remaining);
event Transfer(address indexed _from, address indexed _to, uint256 _value);
event Approval(
address indexed _owner,
address indexed _spender,
uint256 _value
);
}
contract CutieBit is StandardToken {
string public name = "CutieBit Coin";
string public symbol = "CUTIE";
uint256 public decimals = 18;
uint256 public INITIAL_SUPPLY = 267000000 * 1 ether;
function CutieBit() {
totalSupply = INITIAL_SUPPLY;
balances[msg.sender] = INITIAL_SUPPLY;
}
}