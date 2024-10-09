pragma solidity ^0.4.8;
contract token {function transfer(address receiver, uint amount){ }}
contract Crowdsale {
uint public amountRaised; uint public resAmount; uint public soldTokens;
mapping(address => uint256) public balanceOf;
event GoalReached(address beneficiary, uint amountRaised);
event FundTransfer(address backer, uint amount, bool isContribution);
bool public crowdsaleClosed = false;
bool public minimumTargetReached = false;
function () payable {
if (crowdsaleClosed || (maximumTarget - amountRaised) < msg.value) throw;
uint amount = msg.value;
balanceOf[msg.sender] += amount;
amountRaised += amount;
resAmount += amount;
soldTokens += amount / price;
tokenReward.transfer(msg.sender, amount / price);
FundTransfer(msg.sender, amount, true);
if (amountRaised >= minimumTarget && !minimumTargetReached) {
minimumTargetReached = true;
GoalReached(beneficiary, minimumTarget);
}
if (minimumTargetReached) {
if (beneficiary.send(amount)) {
FundTransfer(beneficiary, amount, false);
resAmount -= amount;
}
}
}
function devWithdrawal(uint num, uint den) {
if (!minimumTargetReached || !(beneficiary == msg.sender)) throw;
uint wAmount = num / den;
if (beneficiary.send(wAmount)) {
FundTransfer(beneficiary, wAmount, false);
}
}
function devResWithdrawal() {
if (!minimumTargetReached || !(beneficiary == msg.sender)) throw;
if (beneficiary.send(resAmount)) {
FundTransfer(beneficiary, resAmount, false);
resAmount = 0;
}
}
function closeCrowdsale(bool closeType) {
if (beneficiary == msg.sender) {
crowdsaleClosed = closeType;
}
}
modifier afterDeadline() { if (now >= deadline) _; }
function checkTargetReached() afterDeadline {
if (amountRaised >= minimumTarget) {
minimumTargetReached = true;
}
}
function returnTokens(uint tokensAmount) afterDeadline {
if (!crowdsaleClosed) throw;
if (beneficiary == msg.sender) {
tokenReward.transfer(beneficiary, tokensAmount);
}
}
function safeWithdrawal() afterDeadline {
if (!minimumTargetReached && crowdsaleClosed) {
uint amount = balanceOf[msg.sender];
balanceOf[msg.sender] = 0;
if (amount > 0) {
if (msg.sender.send(amount)) {
FundTransfer(msg.sender, amount, false);
} else {
balanceOf[msg.sender] = amount;
}
}
}
}
}