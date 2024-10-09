pragma solidity ^0.4.11;
contract TokenStorage {
function balances(address account) public returns(uint balance);
}
contract PresalerVoting {
string public constant VERSION = "0.0.8";
uint public VOTING_START_BLOCKNR  = 0;
uint public VOTING_END_TIME       = 0;
TokenStorage PRESALE_CONTRACT = TokenStorage(0x4Fd997Ed7c10DbD04e95d3730cd77D79513076F2);
string[3] private stateNames = ["BEFORE_START",  "VOTING_RUNNING", "CLOSED" ];
enum State { BEFORE_START,  VOTING_RUNNING, CLOSED }
mapping (address => uint) public rawVotes;
uint private constant MAX_AMOUNT_EQU_0_PERCENT   = 10 finney;
uint private constant MIN_AMOUNT_EQU_100_PERCENT = 1 ether ;
uint public constant TOTAL_BONUS_SUPPLY_ETH = 12000;
address public owner;
address[] public voters;
uint16 public stakeVoted_Eth;
uint16 public stakeRemainingToVote_Eth;
uint16 public stakeWaived_Eth;
uint16 public stakeConfirmed_Eth;
function PresalerVoting () {
owner = msg.sender;
}
function ()
onlyState(State.VOTING_RUNNING)
payable {
uint bonusVoted;
uint bonus = PRESALE_CONTRACT.balances(msg.sender);
assert (bonus > 0);
if (msg.value > 1 ether || !msg.sender.send(msg.value)) throw;
if (rawVotes[msg.sender] == 0) {
voters.push(msg.sender);
stakeVoted_Eth += uint16(bonus / 1 ether);
} else {
bonusVoted           = votedPerCent(msg.sender) * bonus / 100;
stakeWaived_Eth     -= uint16((bonus - bonusVoted) / 1 ether);
stakeConfirmed_Eth  -= uint16(bonusVoted / 1 ether);
}
rawVotes[msg.sender] = msg.value > 0 ? msg.value : 1 wei;
bonusVoted           = votedPerCent(msg.sender) * bonus / 100;
stakeWaived_Eth     += uint16((bonus - bonusVoted) / 1 ether);
stakeConfirmed_Eth  += uint16(bonusVoted / 1 ether);
stakeRemainingToVote_Eth = uint16((TOTAL_BONUS_SUPPLY_ETH - stakeConfirmed_Eth)/1 ether);
}
function votersLen() external returns (uint) { return voters.length; }
function startVoting(uint startBlockNr, uint durationHrs) onlyOwner {
VOTING_START_BLOCKNR = max(block.number, startBlockNr);
VOTING_END_TIME = now + max(durationHrs,1) * 1 hours;
}
function setOwner(address newOwner) onlyOwner { owner = newOwner; }
function votedPerCent(address voter) constant public returns (uint) {
var rawVote = rawVotes[voter];
if (rawVote < MAX_AMOUNT_EQU_0_PERCENT) return 0;
else if (rawVote >= MIN_AMOUNT_EQU_100_PERCENT) return 100;
else return rawVote * 100 / 1 ether;
}
function votingEndsInHHMM() constant returns (uint8, uint8) {
var tsec = VOTING_END_TIME - now;
return VOTING_END_TIME==0 ? (0,0) : (uint8(tsec / 1 hours), uint8(tsec % 1 hours / 1 minutes));
}
function currentState() internal constant returns (State) {
if (VOTING_START_BLOCKNR == 0 || block.number < VOTING_START_BLOCKNR) {
return State.BEFORE_START;
} else if (now <= VOTING_END_TIME) {
return State.VOTING_RUNNING;
} else {
return State.CLOSED;
}
}
function state() public constant returns(string) {
return stateNames[uint(currentState())];
}
function max(uint a, uint b) internal constant returns (uint maxValue) { return a>b ? a : b; }
modifier onlyState(State state) {
if (currentState()!=state) throw;
_;
}
modifier onlyOwner() {
if (msg.sender!=owner) throw;
_;
}
}