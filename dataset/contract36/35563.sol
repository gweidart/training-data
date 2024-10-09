pragma solidity ^0.4.15;
contract Ownable {
address public owner;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
function Ownable() {
owner = msg.sender;
}
modifier onlyOwner() {
require(msg.sender == owner);
_;
}
function transferOwnership(address newOwner) onlyOwner public {
require(newOwner != address(0));
OwnershipTransferred(owner, newOwner);
owner = newOwner;
}
}
contract ReturnVestingRegistry is Ownable {
mapping (address => address) public returnAddress;
function record(address from, address to) {
require(from != 0);
require(returnAddress[from] == 0);
require(Ownable(msg.sender).owner() == owner);
returnAddress[from] = to;
}
}