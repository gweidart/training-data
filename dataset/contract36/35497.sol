pragma solidity ^0.4.16;
contract EtherFundMeIssueTokensCrowdfunding {
string public name;
string public symbol;
uint public decimals;
uint public totalSupply;
mapping (address => mapping (address => uint)) allowed;
mapping(address => uint) balances;
string public projectName;
string public projectDescription;
string public teamEmail;
uint public startsAt;
uint public endsAt;
address public teamWallet;
address public feeReceiverWallet;
address public deployAgentWallet;
uint teamTokensAmount;
uint tokensForSale = totalSupply - teamTokensAmount;
uint public tokenPrice;
uint public fundingGoal;
uint public investorCount = 0;
bool public finalized;
bool public halted;
mapping (address => uint256) public investedAmountOf;
mapping (address => uint256) public tokenAmountOf;
uint public constant ETHERFUNDME_FEE = 3;
uint public constant ETHERFUNDME_ONLINE_FEE = 1;
uint public constant GOAL_REACHED_CRITERION = 80;
struct Milestone {
uint start;
uint end;
uint bonus;
}
struct Investment {
address source;
uint tokensAmount;
}
Milestone[] public milestones;
uint public investmentsCount;
Investment[] public investments;
enum State { Unknown, Preparing, Funding, Success, Failure, Finalized, Refunding }
event Invested(address investor, uint weiAmount);
event Withdraw(address receiver, uint weiAmount);
event Refund(address receiver, uint weiAmount);
event Transfer(address indexed from, address indexed to, uint value);
event Approval(address indexed owner, address indexed spender, uint value);
modifier inState(State state) {
require(getState() == state);
_;
}
modifier canTransfer() {
require(finalized);
_;
}
modifier onlyDeployAgent() {
require(msg.sender == deployAgentWallet);
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
modifier onlyPayloadSize(uint size) {
require(msg.data.length >= size + 4);
_;
}
function EtherFundMeIssueTokensCrowdfunding(
string _projectName,
string _projectDescription,
string _teamEmail,
uint _startsAt,
uint _endsAt,
uint _fundingGoal,
address _teamWallet,
address _feeReceiverWallet,
string _name,
string _symbol,
uint _decimals,
uint _totalSupply,
uint _tokenPrice,
uint _teamTokensAmount) {
require(_startsAt != 0);
require(_endsAt != 0);
require(_fundingGoal != 0);
require(_teamWallet != 0);
require(_feeReceiverWallet != 0);
require(_decimals >= 2);
require(_totalSupply > 0);
require(_tokenPrice > 0);
deployAgentWallet = msg.sender;
projectName = _projectName;
projectDescription = _projectDescription;
teamEmail = _teamEmail;
startsAt = _startsAt;
endsAt = _endsAt;
fundingGoal = _fundingGoal;
teamWallet = _teamWallet;
feeReceiverWallet = _feeReceiverWallet;
name = _name;
symbol = _symbol;
decimals = _decimals;
totalSupply = _totalSupply;
tokenPrice = _tokenPrice;
teamTokensAmount = _teamTokensAmount;
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
uint multiplier = 10 ** decimals;
uint tokensAmount = (weiAmount * multiplier) / tokenPrice;
assert(tokensAmount > 0);
if(getCurrentMilestone().bonus > 0) {
tokensAmount += (tokensAmount * getCurrentMilestone().bonus) / 100;
}
assert(tokensForSale - tokensAmount >= 0);
tokensForSale -= tokensAmount;
investments.push(Investment(investor, tokensAmount));
investmentsCount++;
tokenAmountOf[investor] += tokensAmount;
uint onlineFeeAmount = (weiAmount * ETHERFUNDME_ONLINE_FEE) / 100;
Withdraw(feeReceiverWallet, onlineFeeAmount);
feeReceiverWallet.transfer(onlineFeeAmount);
uint investedAmount = weiAmount - onlineFeeAmount;
investedAmountOf[investor] += investedAmount;
Invested(investor, investedAmount);
}
function finalize() public inState(State.Success) stopInEmergency  {
require(msg.sender == deployAgentWallet || msg.sender == teamWallet);
require(!finalized);
finalized = true;
uint feeAmount = (this.balance * ETHERFUNDME_FEE) / 100;
uint teamAmount = this.balance - feeAmount;
Withdraw(teamWallet, teamAmount);
teamWallet.transfer(teamAmount);
Withdraw(feeReceiverWallet, feeAmount);
feeReceiverWallet.transfer(feeAmount);
balances[teamWallet] += (teamTokensAmount + tokensForSale);
for (uint i = 0; i < investments.length; i++) {
balances[investments[i].source] += investments[i].tokensAmount;
Transfer(0, investments[i].source, investments[i].tokensAmount);
}
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
function addMilestone(uint _start, uint _end, uint _bonus) public onlyDeployAgent {
require(_bonus > 0 && _end > _start);
milestones.push(Milestone(_start, _end, _bonus));
}
function getCurrentMilestone() private constant returns (Milestone) {
for (uint i = 0; i < milestones.length; i++) {
if (milestones[i].start <= now && milestones[i].end > now) {
return milestones[i];
}
}
}
function balanceOf(address _owner) constant returns (uint balance) {
return balances[_owner];
}
function transfer(address _to, uint _value) onlyPayloadSize(2 * 32) canTransfer returns (bool success) {
require((_to != 0) && (_to != address(this)));
require(balances[msg.sender] >= _value);
balances[msg.sender] -= _value;
balances[_to] += _value;
Transfer(msg.sender, _to, _value);
return true;
}
function transferFrom(address _from, address _to, uint _value) onlyPayloadSize(2 * 32) canTransfer returns (bool success) {
require(balances[_from] >= _value && allowed[_from][msg.sender] >= _value);
balances[_to] += _value;
balances[_from] -= _value;
allowed[_from][msg.sender] -= _value;
Transfer(_from, _to, _value);
return true;
}
function approve(address _spender, uint _value) returns (bool success) {
require ((_value == 0) || (allowed[msg.sender][_spender] == 0));
allowed[msg.sender][_spender] = _value;
Approval(msg.sender, _spender, _value);
return true;
}
function allowance(address _owner, address _spender) constant returns (uint remaining) {
return allowed[_owner][_spender];
}
}