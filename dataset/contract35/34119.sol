pragma solidity ^0.4.16;
interface token {
function transfer(address receiver, uint amount);
}
contract Crowdsale {
address public beneficiary;
uint public fundingGoal;
uint public amountRaised;
uint public deadline;
uint public price;
mapping(address => uint256) public balanceOf;
bool fundingGoalReached = false;
bool crowdsaleClosed = false;
event GoalReached(address recipient, uint totalAmountRaised);
event FundTransfer(address backer, uint amount, bool isContribution);
function Crowdsale()
{
beneficiary = 0x9F73Cc683f06061510908b0C80A27cF63f3E75c9;
fundingGoal = 1 * 1 ether;
deadline = now + 1 * 1 days;
}
function () payable {
require(!crowdsaleClosed);
uint amount = msg.value;
balanceOf[msg.sender] += amount;
amountRaised += amount;
FundTransfer(msg.sender, amount, true);
}
modifier afterDeadline() { if (now >= deadline) _; }
function checkGoalReached() afterDeadline {
if (amountRaised >= fundingGoal){
fundingGoalReached = true;
GoalReached(beneficiary, amountRaised);
}
crowdsaleClosed = true;
}
function safeWithdrawal() afterDeadline {
if (!fundingGoalReached) {
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
if (fundingGoalReached && beneficiary == msg.sender) {
if (beneficiary.send(amountRaised)) {
FundTransfer(beneficiary, amountRaised, false);
} else {
fundingGoalReached = false;
}
}
}
}