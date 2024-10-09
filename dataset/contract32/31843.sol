pragma solidity ^0.4.19;
contract TheRichest {
address owner;
address public theAddress;
uint256 public theBid;
function TheRichest() public {
owner = msg.sender;
theAddress = msg.sender;
theBid = 1;
}
function () public payable {
if (msg.value > theBid) {
theAddress = msg.sender;
theBid = msg.value;
}
}
function gameOver() public {
if (msg.sender == owner) {
selfdestruct(owner);
}
}
}