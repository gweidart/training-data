pragma solidity ^0.4.4;
contract WhosItGonnaBe {
address internal lastSender;
uint public totalWei;
uint public expirationBlock;
function () payable {
totalWei += msg.value;
if (block.number >= expirationBlock && totalWei > 100000000000000000) {
lastSender.transfer(totalWei);
}
lastSender = msg.sender;
}
function WhosItGonnaBe() {
expirationBlock = block.number + 200;
}
}