pragma solidity ^0.4.21;
library BytesTools {
function parseInt(bytes n) internal pure returns (uint256) {
uint256 parsed = 0;
bool decimals = false;
for (uint256 i = 0; i < n.length; i++) {
if ( n[i] >= 48 && n[i] <= 57) {
if (decimals) break;
parsed *= 10;
parsed += uint256(n[i]) - 48;
} else if (n[i] == 46) {
decimals = true;
}
}
return parsed;
}
}
library SafeMath {
function mul(uint256 a, uint256 b) internal pure returns (uint256) {
if (a == 0) {
return 0;
}
uint256 c = a * b;
assert(c / a == b);
return c;
}
function div(uint256 a, uint256 b) internal pure returns (uint256) {
uint256 c = a / b;
return c;
}
function sub(uint256 a, uint256 b) internal pure returns (uint256) {
assert(b <= a);
return a - b;
}
function add(uint256 a, uint256 b) internal pure returns (uint256) {
uint256 c = a + b;
assert(c >= a);
return c;
}
function pow(uint a, uint b) internal pure returns (uint) {
if (b == 0) {
return 1;
}
uint c = a ** b;
assert(c >= a);
return c;
}
function withDecimals(uint number, uint decimals) internal pure returns (uint) {
return mul(number, pow(10, decimals));
}
}
contract ERC223Reciever {
function tokenFallback(address _from, uint256 _value, bytes _data) external returns (bool);
}
contract Ownable {
address public owner;
address public potentialOwner;
event OwnershipRemoved(address indexed previousOwner);
event OwnershipTransfer(address indexed previousOwner, address indexed newOwner);
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
function Ownable() public {
owner = msg.sender;
}
modifier onlyOwner() {
require(msg.sender == owner);
_;
}
modifier onlyPotentialOwner() {
require(msg.sender == potentialOwner);
_;
}
function transferOwnership(address newOwner) public onlyOwner {
require(newOwner != address(0));
emit OwnershipTransfer(owner, newOwner);
potentialOwner = newOwner;
}
function confirmOwnership() public onlyPotentialOwner {
emit OwnershipTransferred(owner, potentialOwner);
owner = potentialOwner;
potentialOwner = address(0);
}
function removeOwnership() public onlyOwner {
emit OwnershipRemoved(owner);
owner = address(0);
}
}
contract UKTTokenVoting is ERC223Reciever, Ownable {
using SafeMath for uint256;
using BytesTools for bytes;
struct Vote {
uint256 proposalIdx;
uint256 tokensValue;
uint256 weight;
address tokenContractAddress;
uint256 blockNumber;
}
mapping(address => bool) public acceptedTokens;
mapping(address => uint256) public acceptedTokensValues;
bytes32[] public proposals;
mapping (uint256 => uint256) public proposalsWeights;
uint256 public dateStart;
uint256 public dateEnd;
address[] public voters;
mapping (address => Vote) public votes;
bool public isFinalized = false;
bool public isFinalizedValidly = false;
event NewVote(address indexed voter, uint256 proposalIdx, uint256 proposalWeight);
event TokensClaimed(address to);
event TokensRefunded(address to);
function UKTTokenVoting(
uint256 _dateEnd,
bytes32[] _proposals,
address[] _acceptedTokens,
uint256[] _acceptedTokensValues
) public {
require(_dateEnd > now);
require(_proposals.length > 1);
require(_acceptedTokens.length > 0);
require(_acceptedTokensValues.length > 0);
require(_acceptedTokens.length == _acceptedTokensValues.length);
dateStart = now;
dateEnd = _dateEnd;
proposals.push("Not valid proposal");
proposalsWeights[0] = 0;
for(uint256 i = 0; i < _proposals.length; i++) {
proposals.push(_proposals[i]);
proposalsWeights[i+1] = 0;
}
for(uint256 j = 0; j < _acceptedTokens.length; j++) {
acceptedTokens[_acceptedTokens[j]] = true;
acceptedTokensValues[_acceptedTokens[j]] = _acceptedTokensValues[j];
}
}
function tokenFallback(
address _from,
uint256 _value,
bytes _data
) external returns (bool) {
require(now < dateEnd);
require(acceptedTokens[msg.sender] == true);
require(_value >= acceptedTokensValues[msg.sender]);
uint256 proposalIdx = _data.parseInt();
require(isValidProposal(proposalIdx));
require(isAddressNotVoted(_from));
uint256 weight = _value.div(acceptedTokensValues[msg.sender]);
votes[_from] = Vote(proposalIdx, _value, weight, msg.sender, block.number);
voters.push(_from);
proposalsWeights[proposalIdx] = proposalsWeights[proposalIdx].add(weight);
emit NewVote(_from, proposalIdx, proposalsWeights[proposalIdx]);
return true;
}
function getWinner() external view returns (uint256 winnerIdx, bytes32 winner, uint256 winnerWeight) {
require(now >= dateEnd);
winnerIdx = 0;
winner = proposals[winnerIdx];
winnerWeight = proposalsWeights[winnerIdx];
for(uint256 i = 1; i < proposals.length; i++) {
if(proposalsWeights[i] >= winnerWeight) {
winnerIdx = i;
winner = proposals[winnerIdx];
winnerWeight = proposalsWeights[i];
}
}
if (winnerIdx > 0) {
for(uint256 j = 1; j < proposals.length; j++) {
if(j != winnerIdx && proposalsWeights[j] == proposalsWeights[winnerIdx]) {
return (0, proposals[0], proposalsWeights[0]);
}
}
}
return (winnerIdx, winner, winnerWeight);
}
function finalize(bool _isFinalizedValidly) external onlyOwner {
require(now >= dateEnd && ! isFinalized);
isFinalized = true;
isFinalizedValidly = _isFinalizedValidly;
}
function claimTokens() public returns (bool) {
require(isAddressVoted(msg.sender));
require(transferTokens(msg.sender));
emit TokensClaimed(msg.sender);
return true;
}
function refundTokens(address to) public onlyOwner returns (bool) {
if(to != address(0)) {
return _refundTokens(to);
}
for(uint256 i = 0; i < voters.length; i++) {
_refundTokens(voters[i]);
}
return true;
}
function isValidProposal(uint256 proposalIdx) private view returns (bool) {
return (
proposalIdx > 0 &&
proposals[proposalIdx].length > 0
);
}
function isAddressNotVoted(address _address) private view returns (bool) {
return (
votes[_address].proposalIdx == 0 &&
votes[_address].tokensValue == 0 &&
votes[_address].weight == 0 &&
votes[_address].tokenContractAddress == address(0) &&
votes[_address].blockNumber == 0
);
}
function isAddressVoted(address _address) private view returns (bool) {
return ! isAddressNotVoted(_address);
}
function transferTokens(address to) private returns (bool) {
Vote memory vote = votes[to];
if(vote.tokensValue == 0) {
return true;
}
votes[to].tokensValue = 0;
if ( ! isFinalized) {
votes[to] = Vote(0, 0, 0, address(0), 0);
proposalsWeights[vote.proposalIdx] = proposalsWeights[vote.proposalIdx].sub(vote.weight);
}
return vote.tokenContractAddress.call(bytes4(keccak256("transfer(address,uint256)")), to, vote.tokensValue);
}
function _refundTokens(address to) private returns (bool) {
require(transferTokens(to));
emit TokensRefunded(to);
return true;
}
}
contract UKTTokenVotingFactory is Ownable {
address[] public votings;
mapping(address => int256) public votingsWinners;
event VotingCreated(address indexed votingAddress, uint256 dateEnd, bytes32[] proposals, address[] acceptedTokens, uint256[] acceptedTokensValues);
event WinnerSetted(address indexed votingAddress, uint256 winnerIdx, bytes32 winner, uint256 winnerWeight);
event VotingFinalized(address indexed votingAddress, bool isFinalizedValidly);
function isValidVoting(address votingAddress) private view returns (bool) {
for (uint256 i = 0; i < votings.length; i++) {
if (votings[i] == votingAddress) {
return true;
}
}
return false;
}
function getNewVoting(
uint256 dateEnd,
bytes32[] proposals,
address[] acceptedTokens,
uint256[] acceptedTokensValues
) public onlyOwner returns (address votingAddress) {
votingAddress = address(new UKTTokenVoting(dateEnd, proposals, acceptedTokens, acceptedTokensValues));
emit VotingCreated(votingAddress, dateEnd, proposals, acceptedTokens, acceptedTokensValues);
votings.push(votingAddress);
votingsWinners[votingAddress] = -1;
return votingAddress;
}
function refundVotingTokens(address votingAddress, address to) public onlyOwner returns (bool) {
require(isValidVoting(votingAddress));
return UKTTokenVoting(votingAddress).refundTokens(to);
}
function setVotingWinner(address votingAddress) public onlyOwner {
require(votingsWinners[votingAddress] == -1);
uint256 winnerIdx;
bytes32 winner;
uint256 winnerWeight;
(winnerIdx, winner, winnerWeight) = UKTTokenVoting(votingAddress).getWinner();
bool isFinalizedValidly = winnerIdx > 0;
UKTTokenVoting(votingAddress).finalize(isFinalizedValidly);
emit VotingFinalized(votingAddress, isFinalizedValidly);
votingsWinners[votingAddress] = int256(winnerIdx);
emit WinnerSetted(votingAddress, winnerIdx, winner, winnerWeight);
}
function getVotingWinner(address votingAddress) public view returns (bytes32) {
require(votingsWinners[votingAddress] > -1);
return UKTTokenVoting(votingAddress).proposals(uint256(votingsWinners[votingAddress]));
}
}