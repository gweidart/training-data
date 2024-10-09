pragma solidity ^0.4.16;
contract Refund {
address owner = 0x0;
function Refund() public payable {
owner = msg.sender;
}
}