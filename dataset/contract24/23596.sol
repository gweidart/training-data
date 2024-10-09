pragma solidity ^0.4.18;
contract Griefing {
uint public griefCost;
address public owner;
function Griefing(uint _griefCost) public payable {
griefCost=_griefCost;
owner=msg.sender;
}
function () public payable {
require(msg.value==griefCost);
address(0x0).send(this.balance);
}
function getBack() public {
require(msg.sender==owner);
msg.sender.send(this.balance);
}
}