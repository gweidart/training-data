pragma solidity ^0.4.24;
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
owner = newOwner;
emit OwnershipTransferred(owner, newOwner);
}
}
contract BtradeWhiteList {
mapping(address => bool) public whiteList;
function BtradeWhiteList() public {
}
function register(address _address) public {
whiteList[msg.sender] = true;
}
function unregister(address _address) public {
whiteList[msg.sender] = false;
}
function isRegistered(address _address) public view returns (bool registered) {
return whiteList[_address];
}
}