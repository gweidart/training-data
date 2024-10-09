pragma solidity ^0.4.21;
interface token {
function transferFrom(address _from, address _to, uint256 _value) returns (bool success);
}
contract Crowdsale {
address public owner;
address public SSOTHEALTH_FUNDS_ADDRESS = 0x0089C7EC084355019A057abEDF4E8F6864242465;
address public SEHR_WALLET_ADDRESS = 0x00efA609EC93Db54a7977691CCa920e623f07258;
token public tokenReward = token(0xEE660Bef1Ee1697F63554c92e372fc862f384810);
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
function Crowdsale()
{
startTime = now;
deadline = now + 62 days;
owner = msg.sender;
}
modifier afterDeadline() { if (now >= deadline) _; }
modifier beforeDeadline() { if (now < deadline) _; }
modifier isCrowdsale() { if (!crowdsaleClosed) _; }
modifier isCheckDone() { if (checkDone) _; }
function () payable isCrowdsale beforeDeadline {
uint amount = msg.value;
if(amount == 0 ) revert();
else if( amount < 250 finney) {
if (sehrRaised < fundingGoal) {
if(now < startTime + 31 days) revert();
}
}
uint tokenAmount = (amount / price) * 1 ether;
address sehrWallet = SEHR_WALLET_ADDRESS;
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
FundTransfer(msg.sender, amount, true);
}
function checkGoalReached() afterDeadline {
if (sehrRaised >= fundingGoal){
fundingGoalReached = true;
GoalReached(SSOTHEALTH_FUNDS_ADDRESS, amountRaised);
}
crowdsaleClosed = true;
checkDone = true;
}
function safeWithdrawal() afterDeadline isCheckDone{
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
if (fundingGoalReached && SSOTHEALTH_FUNDS_ADDRESS == msg.sender) {
if (SSOTHEALTH_FUNDS_ADDRESS.send(amountRaised)) {
FundTransfer(SSOTHEALTH_FUNDS_ADDRESS, amountRaised, false);
} else {
fundingGoalReached = false;
}
}
}
function hardCapReached() {
if(sehrRaised == hardCap) {
deadline = now;
}
else revert();
}
}