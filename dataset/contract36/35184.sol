pragma solidity ^0.4.14;
library SafeMath {
function mul(uint256 a, uint256 b) internal constant returns (uint256) {
uint256 c = a * b;
assert(a == 0 || c / a == b);
return c;
}
function div(uint256 a, uint256 b) internal constant returns (uint256) {
uint256 c = a / b;
return c;
}
function sub(uint256 a, uint256 b) internal constant returns (uint256) {
assert(b <= a);
return a - b;
}
function add(uint256 a, uint256 b) internal constant returns (uint256) {
uint256 c = a + b;
assert(c >= a);
return c;
}
}
contract ERC20Interface {
uint256 public totalSupply;
function balanceOf(address who) public constant returns (uint256);
function transfer(address to, uint256 value) public returns (bool);
event Transfer(address indexed from, address indexed to, uint256 value);
function allowance(address owner, address spender) public constant returns (uint256);
function transferFrom(address from, address to, uint256 value) public returns (bool);
function approve(address spender, uint256 value) public returns (bool);
event Approval(address indexed owner, address indexed spender, uint256 value);
}
contract ModumToken is ERC20Interface {
using SafeMath for uint256;
address public owner;
mapping(address => mapping (address => uint256)) public allowed;
enum UpdateMode{Wei, Vote, Both}
struct Account {
uint256 lastProposalStartTime;
uint256 lastAirdropWei;
uint256 lastAirdropClaimTime;
uint256 bonusWei;
uint256 valueModVote;
uint256 valueMod;
}
mapping(address => Account) public accounts;
uint256 public totalDropPerUnlockedToken = 0;
uint256 public rounding = 0;
uint256 public lockedTokens = 9 * 1100 * 1000;
uint256 public constant maxTokens = 30 * 1000 * 1000;
bool public mintDone = false;
uint256 public constant redistributionTimeout = 548 days;
string public constant name = "Modum Token";
string public constant symbol = "MOD";
uint8 public constant decimals = 0;
struct Proposal {
string addr;
bytes32 hash;
uint256 valueMod;
uint256 startTime;
uint256 yay;
uint256 nay;
}
Proposal public currentProposal;
uint256 public constant votingDuration = 2 weeks;
uint256 public lastNegativeVoting = 0;
uint256 public constant blockingDuration = 90 days;
event Voted(address _addr, bool option, uint256 votes);
event Payout(uint256 weiPerToken);
function ModumToken() public {
owner = msg.sender;
}
function transferOwnership(address _newOwner) public {
require(msg.sender == owner);
require(_newOwner != address(0));
owner = _newOwner;
}
function votingProposal(string _addr, bytes32 _hash, uint256 _value) public {
require(msg.sender == owner);
require(!isProposalActive());
require(_value <= lockedTokens);
require(_value > 0);
require(_hash != bytes32(0));
require(bytes(_addr).length > 0);
require(mintDone);
require(now >= lastNegativeVoting.add(blockingDuration));
currentProposal = Proposal(_addr, _hash, _value, now, 0, 0);
}
function vote(bool _vote) public returns (uint256) {
require(isVoteOngoing());
Account storage account = updateAccount(msg.sender, UpdateMode.Vote);
uint256 votes = account.valueModVote;
require(votes > 0);
if(_vote) {
currentProposal.yay = currentProposal.yay.add(votes);
}
else {
currentProposal.nay = currentProposal.nay.add(votes);
}
account.valueModVote = 0;
Voted(msg.sender, _vote, votes);
return votes;
}
function showVotes(address _addr) public constant returns (uint256) {
Account memory account = accounts[_addr];
if(account.lastProposalStartTime < currentProposal.startTime ||
(account.lastProposalStartTime == 0 && currentProposal.startTime == 0)) {
return account.valueMod;
}
return account.valueModVote;
}
function claimVotingProposal() public {
require(msg.sender == owner);
require(isProposalActive());
require(isVotingPhaseOver());
if(currentProposal.yay > currentProposal.nay && currentProposal.valueMod > 0) {
Account storage account = updateAccount(owner, UpdateMode.Both);
uint256 valueMod = currentProposal.valueMod;
account.valueMod = account.valueMod.add(valueMod);
totalSupply = totalSupply.add(valueMod);
lockedTokens = lockedTokens.sub(valueMod);
} else if(currentProposal.yay <= currentProposal.nay) {
lastNegativeVoting = currentProposal.startTime.add(votingDuration);
}
delete currentProposal;
}
function isProposalActive() public constant returns (bool)  {
return currentProposal.hash != bytes32(0);
}
function isVoteOngoing() public constant returns (bool)  {
return isProposalActive()
&& now >= currentProposal.startTime
&& now < currentProposal.startTime.add(votingDuration);
}
function isVotingPhaseOver() public constant returns (bool)  {
return now >= currentProposal.startTime.add(votingDuration);
}
function approve(address _spender, uint256 _value) public returns (bool) {
require((_value == 0) || (allowed[msg.sender][_spender] == 0));
allowed[msg.sender][_spender] = _value;
Approval(msg.sender, _spender, _value);
return true;
}
function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
return allowed[_owner][_spender];
}
function increaseApproval(address _spender, uint256 _addedValue) public returns (bool success) {
allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
return true;
}
function decreaseApproval(address _spender, uint256 _subtractedValue) public returns (bool success) {
uint256 oldValue = allowed[msg.sender][_spender];
if(_subtractedValue > oldValue) {
allowed[msg.sender][_spender] = 0;
} else {
allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
}
Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
return true;
}
}