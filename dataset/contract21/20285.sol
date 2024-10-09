pragma solidity ^0.4.21;
interface token {
function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);
}
contract Crowdsale {
address public owner;
address public SSOTHEALTH_FUNDS_ADDRESS = 0x4F1Fa6F553AF4696f00FCad6f495D3F1eB1BE2fe;
address public SEHR_WALLET_ADDRESS = 0xcA027bF2179325B9D31689cdbFbf242aF34c79DE;
token public tokenReward = token(0xE8c881422CA4c2ab9a9bC9d58e75178e0e28eEd5);
uint public fundingGoal = 100000000 * 1 ether;
uint public hardCap = 500000000 * 1 ether;
uint public amountRaised = 0;
uint public sehrRaised = 0;
uint public startTime;
uint public deadline;
uint public price = 80 szabo;
mapping(address => uint256) public balanceOf;
bool public fundingGoalReached = false;
bool public crowdsaleClosed = false;
bool public checkDone = false;
event GoalReached(address recipient, uint totalAmountRaised);
event FundTransfer(address backer, uint amount, bool isContribution);
function Crowdsale() public
{
startTime = now;
deadline = now + 62 days;
owner = msg.sender;
}
modifier afterDeadline() { if (now >= deadline) _; }
modifier beforeDeadline() { if (now < deadline) _; }
modifier isCrowdsale() { if (!crowdsaleClosed) _; }
modifier isCheckDone() { if (checkDone) _; }
function () payable isCrowdsale beforeDeadline public {
uint amount = msg.value;
if(amount == 0 ) revert();
else if( amount < 250 finney) {
if (sehrRaised < fundingGoal) {
if(now < startTime + 31 days) revert();
}
}
uint tokenAmount = (amount / price) * 1 ether;
if(sehrRaised < fundingGoal) {
if(now < startTime + 10 days) {
tokenAmount = (13 * tokenAmount) / 10;
}
else if(now < startTime + 20 days) {
tokenAmount = (12 * tokenAmount) / 10;
}
else if(now < startTime + 31 days) {
tokenAmount = (11 * tokenAmount) / 10;
}
}
balanceOf[msg.sender] += amount;
amountRaised += amount;
sehrRaised += tokenAmount;
tokenReward.transferFrom(SEHR_WALLET_ADDRESS, msg.sender, tokenAmount);
emit FundTransfer(msg.sender, amount, true);
}
function checkGoalReached() afterDeadline public {
if (sehrRaised >= fundingGoal){
fundingGoalReached = true;
emit GoalReached(SSOTHEALTH_FUNDS_ADDRESS, amountRaised);
}
crowdsaleClosed = true;
checkDone = true;
}
function safeWithdrawal() afterDeadline isCheckDone public{
if (!fundingGoalReached) {
uint amount = balanceOf[msg.sender];
balanceOf[msg.sender] = 0;
if (amount > 0) {
if (msg.sender.send(amount)) {
emit FundTransfer(msg.sender, amount, false);
} else {
balanceOf[msg.sender] = amount;
}
}
}
if (fundingGoalReached && SSOTHEALTH_FUNDS_ADDRESS == msg.sender) {
if (SSOTHEALTH_FUNDS_ADDRESS.send(amountRaised)) {
emit FundTransfer(SSOTHEALTH_FUNDS_ADDRESS, amountRaised, false);
} else {
fundingGoalReached = false;
}
}
}
function hardCapReached() public {
if(sehrRaised == hardCap) {
deadline = now;
}
else revert();
}
}