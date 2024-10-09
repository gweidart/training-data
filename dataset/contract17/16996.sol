pragma solidity 0.4.19;
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
contract Migrations is Ownable {
uint public lastCompletedMigration;
function setCompleted(uint completed) public onlyOwner {
lastCompletedMigration = completed;
}
function upgrade(address newAddress) public onlyOwner {
Migrations upgraded = Migrations(newAddress);
upgraded.setCompleted(lastCompletedMigration);
}
}