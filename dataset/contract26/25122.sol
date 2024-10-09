pragma solidity ^0.4.19;
library SafeMath {
function mul(uint256 a, uint256 b) internal pure returns (uint256) {
if (a == 0) {
return 0;
}
uint256 c = a * b;
assert(c / a == b);
return c;
}
function div(uint256 a, uint256 b) internal pure returns (uint256) {
uint256 c = a / b;
return c;
}
function sub(uint256 a, uint256 b) internal pure returns (uint256) {
assert(b <= a);
return a - b;
}
function add(uint256 a, uint256 b) internal pure returns (uint256) {
uint256 c = a + b;
assert(c >= a);
return c;
}
}
contract Ownable {
address public owner;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
function Ownable() public {
owner = msg.sender;
}
modifier onlyOwner() {
require(msg.sender == owner);
_;
}
function transferOwnership(address newOwner) public onlyOwner {
require(newOwner != address(0));
OwnershipTransferred(owner, newOwner);
owner = newOwner;
}
}
contract SkillChainContributions is Ownable {
using SafeMath for uint256;
mapping(address => uint256) public tokenBalances;
address[] public addresses;
function SkillChainContributions() public {}
function addBalance(address _address, uint256 _tokenAmount) onlyOwner public {
require(_tokenAmount > 0);
if (tokenBalances[_address] == 0) {
addresses.push(_address);
}
tokenBalances[_address] = tokenBalances[_address].add(_tokenAmount);
}
function getContributorsLength() view public returns (uint) {
return addresses.length;
}
}