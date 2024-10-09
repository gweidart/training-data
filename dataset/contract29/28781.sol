pragma solidity ^0.4.0;
contract SplitIt {
struct SplitAgreement {
address from;
address to1;
address to2;
}
address private owner;
mapping (address => address) private senderToOwner;
mapping (address => SplitAgreement) private splitAgreements;
event Sent(address from, address to, uint amount);
event Refunded(address from, address to, uint amount);
event OwnerRefunded(address agreementOwner, address from, address to, uint amount);
event Penalty(address agreementOwner, uint amount);
modifier onlyExecuteBy(address _account)
{
require(msg.sender == _account);
_;
}
function SplitIt() public {
owner = msg.sender;
}
function() payable public {
require(msg.value > 0);
uint splitValue = msg.value / 2;
processSplit(msg.sender, splitValue);
}
function createSplitAgreement(address from, address to1, address to2) public {
require(senderToOwner[from] == address(0));
splitAgreements[msg.sender].from = from;
splitAgreements[msg.sender].to1 = to1;
splitAgreements[msg.sender].to2 = to2;
senderToOwner[from] = msg.sender;
}
function endSplitAgreement() public {
address from = splitAgreements[msg.sender].from;
senderToOwner[from] = address(0);
splitAgreements[msg.sender].from = address(0);
splitAgreements[msg.sender].to1 = address(0);
splitAgreements[msg.sender].to2 = address(0);
}
function collectFees() public onlyExecuteBy(owner) {
msg.sender.transfer(this.balance);
}
function processSplit(address from, uint amount) private {
address agreementOwner = senderToOwner[from];
require(agreementOwner != address(0));
processSend(from, splitAgreements[agreementOwner].to1, amount);
processSend(from, splitAgreements[agreementOwner].to2, amount);
}
function processSend(address from, address to, uint amount) private {
if (to.send(amount)) {
Sent(from, to, amount);
} else if(from.send(amount)) {
Refunded(from, to, amount);
} else if(senderToOwner[from].send(amount)) {
OwnerRefunded(senderToOwner[from], from, to, amount);
} else {
Penalty(senderToOwner[from], amount);
}
}
}