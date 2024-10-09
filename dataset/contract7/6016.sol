pragma solidity ^0.4.19;
library SafeMath {
function mul(uint a, uint b) internal pure  returns(uint) {
uint c = a * b;
assert(a == 0 || c / a == b);
return c;
}
function sub(uint a, uint b) internal pure  returns(uint) {
assert(b <= a);
return a - b;
}
function add(uint a, uint b) internal pure  returns(uint) {
uint c = a + b;
assert(c >= a && c >= b);
return c;
}
}
contract Ownable {
address public owner;
function Ownable() public {
owner = msg.sender;
}
modifier onlyOwner {
if (msg.sender != owner) revert();
_;
}
function transferOwnership(address newOwner) public onlyOwner {
if (newOwner != address(0)) {
owner = newOwner;
}
}
}
contract Lpktransfer is Ownable {
using SafeMath for uint;
mapping(address => uint) balances;
event Transfer(address indexed from, address indexed to, uint value);
function Lpktransfer() public {
}
function transferFrom(address _from, address _to, uint _tokens) external onlyOwner() returns (bool success) {
require(balances[_from] >= _tokens);
balances[_from] = balances[_from].sub(_tokens);
balances[_to] = balances[_to].add(_tokens);
Transfer(_from, _to, _tokens);
return true;
}
function balanceOf(address _owner) public view returns(uint balance) {
return balances[_owner];
}
}