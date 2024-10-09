pragma solidity ^0.4.16;
interface token {
function transfer(address receiver, uint amount);
}
contract PornTokenV2Crowdsale {
address public beneficiary;
uint public fundingGoal;
uint public amountRaised;
uint public deadline;
uint public price;
token public tokenReward;
mapping(address => uint256) public balanceOf;
bool fundingGoalReached = false;
bool crowdsaleClosed = false;
event GoalReached(address recipient, uint totalAmountRaised);
event FundTransfer(address backer, uint amount, bool isContribution);
function PornTokenV2Crowdsale(
address sendTo,
uint fundingGoalInEthers,
uint durationInMinutes,
address addressOfTokenUsedAsReward
) {
beneficiary = sendTo;
fundingGoal = fundingGoalInEthers * 1 ether;
deadline = now + durationInMinutes * 1 minutes;
price = 0.00001337 * 1 ether;
tokenReward = token(addressOfTokenUsedAsReward);
}
function () payable {
require(!crowdsaleClosed);
uint amount = msg.value;
balanceOf[msg.sender] += amount;
amountRaised += amount;
tokenReward.transfer(msg.sender, amount / price);
FundTransfer(beneficiary, amount, false);
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
if (beneficiary == msg.sender) {
if (beneficiary.send(amountRaised)) {
FundTransfer(beneficiary, amountRaised, false);
} else {
fundingGoalReached = false;
}
}
}
}