pragma solidity ^0.4.18;
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
library SafeMath {
function mul(uint256 a, uint256 b) internal pure returns (uint256) {
uint256 c = a * b;
if (a != 0 && c / a != b) {
revert();
}
return c;
}
function div(uint256 a, uint256 b) internal pure returns (uint256) {
uint256 c = a / b;
return c;
}
function sub(uint256 a, uint256 b) internal pure returns (uint256) {
if (b > a) {
revert();
}
return a - b;
}
function add(uint256 a, uint256 b) internal pure returns (uint256) {
uint256 c = a + b;
if (c < a) {
revert();
}
return c;
}
}
contract VLBBonusStore is Ownable {
mapping(address => uint8) public rates;
function collectRate(address investor) onlyOwner public returns (uint8) {
require(investor != address(0));
uint8 rate = rates[investor];
if (rate != 0) {
delete rates[investor];
}
return rate;
}
function addRate(address investor, uint8 rate) onlyOwner public {
require(investor != address(0));
rates[investor] = rate;
}
}