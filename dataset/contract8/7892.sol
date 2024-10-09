pragma solidity ^0.4.21;
interface insChainTokenInterface{
function transfer(address _to, uint256 _value) public returns (bool success);
function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
}
contract ERC20 {
function totalSupply() public view returns (uint supply);
function balanceOf( address who ) public view returns (uint value);
function allowance( address owner, address spender ) public view returns (uint _allowance);
function transfer( address to, uint value) public returns (bool ok);
function transferFrom( address from, address to, uint value) public returns (bool ok);
function approve( address spender, uint value ) public returns (bool ok);
event Transfer( address indexed from, address indexed to, uint value);
event Approval( address indexed owner, address indexed spender, uint value);
}
contract Owned{
address public owner;
address public newOwner;
event OwnerUpdate(address _prevOwner, address _newOwner);
function Owned() public{
owner = msg.sender;
}
modifier onlyOwner {
assert(msg.sender == owner);
_;
}
function transferOwnership(address _newOwner) public onlyOwner {
require(_newOwner != owner);
newOwner = _newOwner;
}
function acceptOwnership() public {
require(msg.sender == newOwner);
emit OwnerUpdate(owner, newOwner);
owner = newOwner;
newOwner = 0x0;
}
event Pause();
event Unpause();
bool public paused = false;
modifier whenNotPaused() {
require(!paused);
_;
}
modifier whenPaused() {
require(paused);
_;
}
function pause() onlyOwner whenNotPaused public {
paused = true;
emit Pause();
}
function unpause() onlyOwner whenPaused public {
paused = false;
emit Unpause();
}
}
contract SafeMath {
function SafeMath() public{
}
function safeAdd(uint256 a, uint256 b) internal pure returns (uint256) {
uint c = a + b;
assert(c >= a && c >= b);
return c;
}
function safeSub(uint256 a, uint256 b) internal pure returns (uint256) {
uint c = a - b;
assert(b <= a && c <= a);
return c;
}
function safeMul(uint256 a, uint256 b) internal pure returns (uint256) {
uint c = a * b;
assert(a == 0 || (c / a) == b);
return c;
}
}
contract PolicyPool is SafeMath, Owned{
insChainTokenInterface public insChainTokenLedger;
address public agent;
uint256 public policyTokenBalance=0;
uint256 public policyTokenBalanceFromEther=0;
uint256 public policyFeeCollector=0;
uint256 public policyCandyBalance=0;
uint256 public policyActiveNum=0;
mapping (uint256 => uint256) policyInternalID;
struct Policy {
uint256 since;
uint256 accumulatedIn;
}
Policy[] public policies;
struct Proposal {
uint256 policyPayload;
address recipient;
uint256 amount;
string description;
bool executed;
bool proposalPassed;
}
Proposal[] public proposals;
uint256 public numProposals;
uint256 public updated_policy_payload;
event PolicyIn(address indexed backer, uint256 indexed amount, uint256 indexed policyExternalID);
event PolicyOut(address indexed backer, uint256 indexed amount, uint256 indexed policyExternalID);
event PolicyValueIn(address indexed backer, uint256 indexed amount,uint256 indexed policyExternalID);
event ProposalAdded(uint indexed proposalID, uint256 indexed policyExternalID, uint256 indexed amount, string description);
event ProposalTallied(uint indexed proposalId, uint256 indexed amount, bool indexed proposalPassed);
modifier onlyAgent {
assert(msg.sender == agent);
_;
}
function PolicyPool(address tokenLedger) public {
insChainTokenLedger=insChainTokenInterface(tokenLedger);
agent=msg.sender;
addPolicy(0,0);
}
function receiveApproval(address from,uint256 weiAmount,address tokenLedger, bytes extraData) whenNotPaused public returns (bool success){
require(insChainTokenInterface(tokenLedger)==insChainTokenLedger);
require(insChainTokenLedger.transferFrom(from, this, weiAmount));
uint payload=0;
for (uint i = 0; i < 32; i++) {
uint b = uint(msg.data[131 - i]);
payload += b * 256**i;
}
updated_policy_payload = payload;
if(!getx2Policy(from, payload, now, weiAmount)){revert();}
policyTokenBalance=safeAdd(policyTokenBalance,weiAmount);
return true;
}
function policyID(uint256 payload) public view returns (uint id){
return policyInternalID[payload];
}
function accumulatedBalanceOf(uint id) public view returns (uint256 balance) {
return policies[id].accumulatedIn;
}
function joinSinceOf(uint id) public view returns (uint256 balance) {
return policies[id].since;
}
function addPolicy(uint256 ticker, uint256 weiAmount) internal returns(uint) {
policies.length++;
policies[policies.length-1].since = ticker;
policies[policies.length-1].accumulatedIn = weiAmount;
return policies.length;
}
function getx2Policy(address from, uint256 payload, uint256 timeStamp, uint256 weiAmount) internal returns(bool success){
uint id = policyInternalID[payload];
if (id == 0) {
id = policies.length;
policyInternalID[payload] = id;
addPolicy(timeStamp,weiAmount);
emit PolicyIn(from, weiAmount, payload);
policyActiveNum++;
}else if (policies[id].accumulatedIn==0){
policies[id].since=timeStamp;
policies[id].accumulatedIn=weiAmount;
emit PolicyIn(from, weiAmount, payload);
policyActiveNum++;
}else{
policies[id].accumulatedIn=safeAdd(policies[id].accumulatedIn,weiAmount);
emit PolicyValueIn(from, weiAmount, payload);
}
return true;
}
function withdrawPolicy(uint256 payload, uint256 weiAmount, uint256 fees, address to) public onlyOwner returns (bool success) {
uint id=policyInternalID[payload];
require(id>0);
require(policies[id].accumulatedIn>0);
require(policies[id].since<now);
require(weiAmount<policyTokenBalance);
if(!insChainTokenLedger.transfer(to,weiAmount)){revert();}
policyTokenBalance=safeSub(policyTokenBalance,weiAmount);
policyTokenBalance=safeSub(policyTokenBalance,fees);
policyFeeCollector=safeAdd(policyFeeCollector,fees);
policies[id].accumulatedIn=0;
policies[id].since=now;
emit PolicyOut(to, weiAmount, payload);
policyActiveNum--;
return true;
}
function kill() public onlyOwner {
if(policyTokenBalance>0){
if(!insChainTokenLedger.transfer(owner,policyTokenBalance)){revert();}
policyTokenBalance=0;
policyTokenBalanceFromEther=0;
}
if(policyFeeCollector>0){
if(!insChainTokenLedger.transfer(owner,policyFeeCollector)){revert();}
policyFeeCollector=0;
}
selfdestruct(owner);
}
function newProposal(uint256 payload, address beneficiary, uint256 weiAmount,string claimDescription) onlyOwner public returns(uint256 proposalID){
require(policyTokenBalance>weiAmount);
proposals.length++;
proposalID = proposals.length-1;
Proposal storage p = proposals[proposalID];
p.policyPayload=payload;
p.recipient = beneficiary;
p.amount = weiAmount;
p.description = claimDescription;
p.executed = false;
p.proposalPassed = false;
emit ProposalAdded(proposalID, p.policyPayload, p.amount, p.description);
numProposals = proposalID+1;
return proposalID;
}
function executeProposal(uint proposalNumber, uint256 refundAmount, uint256 fees) onlyOwner public returns (bool success){
Proposal storage p = proposals[proposalNumber];
require(!p.executed);
require(p.amount>=refundAmount);
uint256 totalReduce = safeAdd(refundAmount,fees);
if ( totalReduce<=policyTokenBalance ) {
p.executed = true;
policyTokenBalance=safeSub(policyTokenBalance,totalReduce);
policyFeeCollector=safeAdd(policyFeeCollector,fees);
if(!insChainTokenLedger.transfer(p.recipient,refundAmount)){revert();}
uint id = policyInternalID[p.policyPayload];
policies[id].accumulatedIn=0;
policies[id].since=now;
p.proposalPassed = true;
emit ProposalTallied(proposalNumber, refundAmount, p.proposalPassed);
emit PolicyOut(p.recipient, refundAmount, p.policyPayload);
policyActiveNum--;
} else {
p.proposalPassed = false;
}
return p.proposalPassed;
}
function joinWithCandy(address signer, uint256 payload, uint256 timeStamp) onlyAgent public returns (bool success){
require(signer!=address(0));
require(timeStamp<now);
require(policyInternalID[payload] == 0);
if(!getx2Policy(signer, payload, timeStamp, 0)){revert();}
return true;
}
function updateAgent(address newAgent) onlyOwner public returns(bool success){
agent=newAgent;
return true;
}
function settleEtherPolicy(address[] froms, uint256[] payloads, uint256[] timeStamps, uint256[] weiAmounts) onlyOwner public returns(bool success){
require(froms.length == payloads.length);
require(payloads.length == weiAmounts.length);
uint i;
for (i=0;i<froms.length;i++){
if(!getx2Policy(froms[i], payloads[i], timeStamps[i], weiAmounts[i])){revert();}
policyTokenBalanceFromEther=safeAdd(policyTokenBalanceFromEther,weiAmounts[i]);
policyTokenBalance=safeAdd(policyTokenBalance,weiAmounts[i]);
if(!insChainTokenLedger.transferFrom(msg.sender, this, weiAmounts[i])){revert();}
}
return true;
}
function settleCandyGetx(uint256 weiAmount) onlyOwner public returns (bool success){
policyCandyBalance=safeAdd(policyCandyBalance,weiAmount);
return true;
}
function retrievePoolFee(uint256 weiAmount) onlyOwner public returns (bool success){
policyFeeCollector=safeSub(policyFeeCollector,weiAmount);
if(!insChainTokenLedger.transfer(msg.sender,weiAmount)){revert();}
return true;
}
function claimTokens(address _token) onlyOwner public {
require(_token != address(0));
require(_token != address(insChainTokenLedger));
ERC20 token = ERC20(_token);
uint balance = token.balanceOf(this);
token.transfer(owner, balance);
}
}