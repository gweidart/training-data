pragma solidity ^0.4.16;
contract EtherFundMeCrowdfunding {
string public name;
string public description;
string public teamContact;
uint public startsAt;
uint public endsAt;
address public team;
address public feeReceiver;
address public deployAgent;
uint public fundingGoal;
uint public investorCount = 0;
bool public finalized;
bool public halted;
mapping (address => uint256) public investedAmountOf;
uint public constant ETHERFUNDME_FEE = 2;
uint public constant ETHERFUNDME_ONLINE_FEE = 1;
uint public constant GOAL_REACHED_CRITERION = 60;
enum State { Unknown, Preparing, Funding, Success, Failure, Finalized, Refunding }
event Invested(address investor, uint weiAmount);
event Withdraw(address receiver, uint weiAmount);
event Refund(address receiver, uint weiAmount);
modifier inState(State state) {
require(getState() == state);
_;
}
modifier onlyDeployAgent() {
require(msg.sender == deployAgent);
_;
}
modifier stopInEmergency {
require(!halted);
_;
}
modifier onlyInEmergency {
require(halted);
_;
}
function EtherFundMeCrowdfunding(string _name, string _description, string _teamContact, uint _startsAt, uint _endsAt, uint _fundingGoal, address _team, address _feeReceiver) {
require(_startsAt != 0);
require(_endsAt != 0);
require(_fundingGoal != 0);
require(_team != 0);
require(_feeReceiver != 0);
deployAgent = msg.sender;
name = _name;
description = _description;
teamContact = _teamContact;
startsAt = _startsAt;
endsAt = _endsAt;
fundingGoal = _fundingGoal;
team = _team;
feeReceiver = _feeReceiver;
}
function getState() public constant returns (State) {
if (finalized)
return State.Finalized;
if (startsAt > now)
return State.Preparing;
if (now >= startsAt && now < endsAt)
return State.Funding;
if (isGoalReached())
return State.Success;
if (!isGoalReached() && this.balance > 0)
return State.Refunding;
return State.Failure;
}
function isGoalReached() public constant returns (bool reached) {
return this.balance >= (fundingGoal * GOAL_REACHED_CRITERION) / 100;
}
function() payable {
invest();
}
function invest() public payable stopInEmergency  {
require(getState() == State.Funding);
require(msg.value > 0);
uint weiAmount = msg.value;
address investor = msg.sender;
if(investedAmountOf[investor] == 0) {
investorCount++;
}
uint onlineFeeAmount = (weiAmount * ETHERFUNDME_ONLINE_FEE) / 100;
Withdraw(feeReceiver, onlineFeeAmount);
feeReceiver.transfer(onlineFeeAmount);
uint investedAmount = weiAmount - onlineFeeAmount;
investedAmountOf[investor] += investedAmount;
Invested(investor, investedAmount);
}
function finalize() public inState(State.Success) stopInEmergency  {
require(msg.sender == deployAgent || msg.sender == team);
require(!finalized);
finalized = true;
uint feeAmount = (this.balance * ETHERFUNDME_FEE) / 100;
uint teamAmount = this.balance - feeAmount;
Withdraw(team, teamAmount);
team.transfer(teamAmount);
Withdraw(feeReceiver, feeAmount);
feeReceiver.transfer(feeAmount);
}
function refund() public inState(State.Refunding) {
uint weiValue = investedAmountOf[msg.sender];
if (weiValue == 0) revert();
investedAmountOf[msg.sender] = 0;
Refund(msg.sender, weiValue);
msg.sender.transfer(weiValue);
}
function halt() public onlyDeployAgent {
halted = true;
}
function unhalt() public onlyDeployAgent onlyInEmergency {
halted = false;
}
}