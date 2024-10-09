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
emit OwnershipTransferred(owner, newOwner);
owner = newOwner;
}
}
contract TXOsale is Ownable {
event ReceiveEther(address indexed from, uint256 value);
address public TXOtoken = 0xe3e0CfBb19D46DC6909C6830bfb25107f8bE5Cb7;
bool public goalAchieved = false;
address public constant wallet = 0x8dA7477d56c90CF2C5b78f36F9E39395ADb2Ae63;
uint public  constant saleStart = 1526860800;
uint public constant saleEnd = 1531871999;
function TXOsale() public {
}
function() public payable {
require(now >= saleStart && now <= saleEnd);
require(!goalAchieved);
require(msg.value >= 0.1 ether);
require(msg.value <= 65 ether);
wallet.transfer(msg.value);
emit ReceiveEther(msg.sender, msg.value);
}
function setGoalAchieved(bool _goalAchieved) public onlyOwner {
goalAchieved = _goalAchieved;
}
}