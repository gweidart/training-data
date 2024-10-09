pragma solidity ^0.4.16;
interface token {
function transfer(address receiver, uint amount);
}
contract Crowdsale {
address public beneficiary = 0x8469DF13aA659504283bC60Df15E02e6F291bCF1;
uint public fundingGoal= 10000;
uint public amountRaised;
uint public deadline=1200;
uint public price=1;
token public tokenReward = token(0x0d276A2f26A4F508276739BA7F4716eb6ee2EA27);
mapping(address => uint256) public balanceOf;
bool fundingGoalReached = false;
bool crowdsaleClosed = false;
event GoalReached(address beneficiary1, uint amountRaised1);
event FundTransfer(address backer, uint amount, bool isContribution);
function Crowdsale(
address ifSuccessfulSendTo,
uint fundingGoalInEthers,
uint durationInMinutes,
uint etherCostOfEachToken,
address addressOfTokenUsedAsReward
) {
beneficiary = ifSuccessfulSendTo;
fundingGoal = fundingGoalInEthers * .003 ether;
deadline = now + durationInMinutes * 1 minutes;
price = etherCostOfEachToken * .003 ether;
tokenReward = token(addressOfTokenUsedAsReward);
}
function () payable {
require(!crowdsaleClosed);
uint amount = msg.value;
balanceOf[msg.sender] += amount;
amountRaised += amount;
tokenReward.transfer(msg.sender, amount / price);
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