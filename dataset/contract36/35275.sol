pragma solidity ^0.4.15;
contract EngravedToken {
uint256 public totalSupply;
function issue(address, uint256) returns (bool) {}
function balanceOf(address) constant returns (uint256) {}
function unlock() returns (bool) {}
function startIncentiveDistribution() returns (bool) {}
function transferOwnership(address) {}
function owner() returns (address) {}
}
contract EGRCrowdsale {
address public beneficiary;
address public confirmedBy;
uint256 public maxSupply = 1000000000;
uint256 public minAcceptedAmount = 10 finney;
uint256 public rateAirDrop = 1000;
uint256 public airdropParticipants;
uint256 public maxAirdropParticipants = 500;
mapping (address => bool) participatedInAirdrop;
uint256 public rateAngelsDay = 100000;
uint256 public rateFirstWeek = 80000;
uint256 public rateSecondWeek = 70000;
uint256 public rateThirdWeek = 60000;
uint256 public rateLastWeek = 50000;
uint256 public airdropEnd = 3 days;
uint256 public airdropCooldownEnd = 7 days;
uint256 public rateAngelsDayEnd = 8 days;
uint256 public angelsDayCooldownEnd = 14 days;
uint256 public rateFirstWeekEnd = 21 days;
uint256 public rateSecondWeekEnd = 28 days;
uint256 public rateThirdWeekEnd = 35 days;
uint256 public rateLastWeekEnd = 42 days;
enum Stages {
Airdrop,
InProgress,
Ended,
Withdrawn,
Proposed,
Accepted
}
Stages public stage = Stages.Airdrop;
uint256 public start;
uint256 public end;
uint256 public raised;
EngravedToken public EGREngravedToken;
mapping (address => uint256) balances;
struct Proposal {
address engravedAddress;
uint256 deadline;
uint256 approvedWeight;
uint256 disapprovedWeight;
mapping (address => uint256) voted;
}
Proposal public transferProposal;
uint256 public transferProposalEnd = 7 days;
uint256 public transferProposalCooldown = 1 days;
modifier atStage(Stages _stage) {
require(stage == _stage);
_;
}
modifier atStages(Stages _stage1, Stages _stage2) {
require(stage == _stage1 || stage == _stage2);
_;
}
modifier onlyBeneficiary() {
require(beneficiary == msg.sender);
_;
}
modifier onlyTokenholders() {
require(EGREngravedToken.balanceOf(msg.sender) > 0);
_;
}
modifier beforeDeadline() {
require(now < transferProposal.deadline);
_;
}
modifier afterDeadline() {
require(now > transferProposal.deadline);
_;
}
function balanceOf(address _investor) constant returns (uint256 balance) {
return balances[_investor];
}
function EGRCrowdsale(address _EngravedTokenAddress, address _beneficiary, uint256 _start) {
EGREngravedToken = EngravedToken(_EngravedTokenAddress);
beneficiary = _beneficiary;
start = _start;
end = start + 42 days;
}
function confirmBeneficiary() onlyBeneficiary {
confirmedBy = msg.sender;
}
function toEGR(uint256 _wei) returns (uint256 amount) {
uint256 rate = 0;
if (stage != Stages.Ended && now >= start && now <= end) {
if (now <= start + airdropCooldownEnd) {
rate = 0;
}
else if (now <= start + rateAngelsDayEnd) {
rate = rateAngelsDay;
}
else if (now <= start + angelsDayCooldownEnd) {
rate = 0;
}
else if (now <= start + rateFirstWeekEnd) {
rate = rateFirstWeek;
}
else if (now <= start + rateSecondWeekEnd) {
rate = rateSecondWeek;
}
else if (now <= start + rateThirdWeekEnd) {
rate = rateThirdWeek;
}
else if (now <= start + rateLastWeekEnd) {
rate = rateLastWeek;
}
}
require(rate != 0);
return _wei * rate * 10**3 / 1 ether;
}
function claim() atStage(Stages.Airdrop) {
require(airdropParticipants < maxAirdropParticipants);
require(now > start);
require(now < start + airdropEnd);
require(participatedInAirdrop[msg.sender] == false);
require(EGREngravedToken.issue(msg.sender, rateAirDrop * 10**3));
participatedInAirdrop[msg.sender] = true;
airdropParticipants += 1;
}
function endAirdrop() atStage(Stages.Airdrop) {
require(now > start + airdropEnd);
stage = Stages.InProgress;
}
function endCrowdsale() atStage(Stages.InProgress) {
require(now > end);
stage = Stages.Ended;
}
function withdraw() onlyBeneficiary atStage(Stages.Ended) {
require(beneficiary.send(raised));
stage = Stages.Withdrawn;
}
function proposeTransfer(address _engravedAddress) onlyBeneficiary atStages(Stages.Withdrawn, Stages.Proposed) {
require(stage != Stages.Proposed || now > transferProposal.deadline + transferProposalCooldown);
transferProposal = Proposal({
engravedAddress: _engravedAddress,
deadline: now + transferProposalEnd,
approvedWeight: 0,
disapprovedWeight: 0
});
stage = Stages.Proposed;
}
function vote(bool _approve) onlyTokenholders beforeDeadline atStage(Stages.Proposed) {
require(transferProposal.voted[msg.sender] < transferProposal.deadline - transferProposalEnd);
transferProposal.voted[msg.sender] = now;
uint256 weight = EGREngravedToken.balanceOf(msg.sender);
if (_approve) {
transferProposal.approvedWeight += weight;
} else {
transferProposal.disapprovedWeight += weight;
}
}
function executeTransfer() afterDeadline atStage(Stages.Proposed) {
require(transferProposal.approvedWeight > transferProposal.disapprovedWeight);
require(EGREngravedToken.unlock());
require(EGREngravedToken.startIncentiveDistribution());
EGREngravedToken.transferOwnership(transferProposal.engravedAddress);
require(EGREngravedToken.owner() == transferProposal.engravedAddress);
require(transferProposal.engravedAddress.send(this.balance));
stage = Stages.Accepted;
}
function () payable atStage(Stages.InProgress) {
require(now > start);
require(now < end);
require(msg.value >= minAcceptedAmount);
uint256 received = msg.value;
uint256 valueInEGR = toEGR(msg.value);
require((EGREngravedToken.totalSupply() + valueInEGR) <= (maxSupply * 10**3));
require(EGREngravedToken.issue(msg.sender, valueInEGR));
balances[msg.sender] += received;
raised += received;
}
}