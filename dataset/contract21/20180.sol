pragma solidity ^0.4.18;
contract BeggarBetting {
struct MatchBettingInfo {
address better;
uint256 matchId;
uint homeTeamScore;
uint awayTeamScore;
uint bettingPrice;
}
struct BetterBettingInfo {
uint256 matchId;
uint homeTeamScore;
uint awayTeamScore;
uint bettingPrice;
bool isWinner;
bool hasReceivedPrize;
uint256 winningPrize;
uint numOfWinners;
uint numOfBetters;
}
address public owner;
mapping(uint256 => MatchBettingInfo[]) public matchBettingInfo;
mapping(address => BetterBettingInfo[]) public betterBettingInfo;
mapping(address => uint256) public betterBalance;
mapping(address => uint) public betterNumWinning;
uint numOfPanhandler;
uint numOfVagabond;
uint numOfTramp;
uint numOfMiddleClass;
function BeggarBetting() {
owner = msg.sender;
}
function () payable {}
function placeBet(uint256 _matchId, uint _homeTeamScore, uint _awayTeamScore, uint _bettingPrice) public payable returns (bool) {
require(_bettingPrice == msg.value);
bool result = checkDuplicateMatchId(msg.sender, _matchId, _bettingPrice);
if (result) {
revert();
}
matchBettingInfo[_matchId].push(MatchBettingInfo(msg.sender, _matchId, _homeTeamScore, _awayTeamScore, _bettingPrice));
betterBettingInfo[msg.sender].push(BetterBettingInfo(_matchId, _homeTeamScore, _awayTeamScore, _bettingPrice, false, false, 0, 0, 0));
address(this).transfer(msg.value);
return true;
}
function claimPrizes(uint256 _matchId, uint _homeTeamScore, uint _awayTeamScore, uint _bettingPrice) public returns (bool) {
uint totalNumBetters = matchBettingInfo[_matchId].length;
uint numOfBetters = 0;
uint numOfWinners = 0;
uint256 winningPrize = 0;
uint commissionToOwner = 0;
bool result = checkPrizeAlreadyReceived(msg.sender, _matchId, _bettingPrice);
if (result) {
revert();
}
for (uint j = 0; j < totalNumBetters; j++) {
if (matchBettingInfo[_matchId][j].bettingPrice == _bettingPrice) {
numOfBetters++;
if (matchBettingInfo[_matchId][j].homeTeamScore == _homeTeamScore && matchBettingInfo[_matchId][j].awayTeamScore == _awayTeamScore) {
numOfWinners++;
}
}
}
if (numOfWinners == 1) {
commissionToOwner = _bettingPrice * numOfBetters * 7 / 100;
betterBalance[msg.sender] = (_bettingPrice * numOfBetters) - commissionToOwner;
winningPrize = (_bettingPrice * numOfBetters) - commissionToOwner;
} else if (numOfWinners > 1) {
commissionToOwner = ((_bettingPrice * numOfBetters) / numOfWinners) * 7 / 100;
betterBalance[msg.sender] = ((_bettingPrice * numOfBetters) / numOfWinners) - commissionToOwner;
winningPrize = ((_bettingPrice * numOfBetters) / numOfWinners) - commissionToOwner;
}
sendCommissionToOwner(commissionToOwner);
withdraw();
afterClaim(_matchId, _bettingPrice, winningPrize, numOfWinners, numOfBetters);
return true;
}
function sendCommissionToOwner(uint _commission) private {
require(address(this).balance >= _commission);
owner.transfer(_commission);
}
function withdraw() private {
uint256 balance = betterBalance[msg.sender];
require(address(this).balance >= balance);
betterBalance[msg.sender] -= balance;
msg.sender.transfer(balance);
}
function afterClaim(uint256 _matchId, uint _bettingPrice, uint256 _winningPrize, uint _numOfWinners, uint _numOfBetters) private {
uint numOfBettingInfo = betterBettingInfo[msg.sender].length;
for (uint i = 0; i < numOfBettingInfo; i++) {
if (betterBettingInfo[msg.sender][i].matchId == _matchId && betterBettingInfo[msg.sender][i].bettingPrice == _bettingPrice) {
betterBettingInfo[msg.sender][i].hasReceivedPrize = true;
betterBettingInfo[msg.sender][i].winningPrize = _winningPrize;
betterBettingInfo[msg.sender][i].numOfWinners = _numOfWinners;
betterBettingInfo[msg.sender][i].numOfBetters = _numOfBetters;
}
}
betterNumWinning[msg.sender] += 1;
CheckPrivilegeAccomplishment(betterNumWinning[msg.sender]);
}
function CheckPrivilegeAccomplishment(uint numWinning) public {
if (numWinning == 3) {
numOfPanhandler++;
}
if (numWinning == 8) {
numOfVagabond++;
}
if (numWinning == 15) {
numOfTramp++;
}
if (numWinning == 21) {
numOfMiddleClass++;
}
}
function checkDuplicateMatchId(address _better, uint256 _matchId, uint _bettingPrice) public view returns (bool) {
uint numOfBetterBettingInfo = betterBettingInfo[_better].length;
for (uint i = 0; i < numOfBetterBettingInfo; i++) {
if (betterBettingInfo[_better][i].matchId == _matchId && betterBettingInfo[_better][i].bettingPrice == _bettingPrice) {
return true;
}
}
return false;
}
function checkPrizeAlreadyReceived(address _better, uint256 _matchId, uint _bettingPrice) public view returns (bool) {
uint numOfBetterBettingInfo = betterBettingInfo[_better].length;
for (uint i = 0; i < numOfBetterBettingInfo; i++) {
if (betterBettingInfo[_better][i].matchId == _matchId && betterBettingInfo[_better][i].bettingPrice == _bettingPrice) {
if (betterBettingInfo[_better][i].hasReceivedPrize) {
return true;
}
}
}
return false;
}
function getBetterBettingInfo(address _better) public view returns (uint256[], uint[], uint[], uint[]) {
uint length = betterBettingInfo[_better].length;
uint256[] memory matchId = new uint256[](length);
uint[] memory homeTeamScore = new uint[](length);
uint[] memory awayTeamScore = new uint[](length);
uint[] memory bettingPrice = new uint[](length);
for (uint i = 0; i < length; i++) {
matchId[i] = betterBettingInfo[_better][i].matchId;
homeTeamScore[i] = betterBettingInfo[_better][i].homeTeamScore;
awayTeamScore[i] = betterBettingInfo[_better][i].awayTeamScore;
bettingPrice[i] = betterBettingInfo[_better][i].bettingPrice;
}
return (matchId, homeTeamScore, awayTeamScore, bettingPrice);
}
function getBetterBettingInfo2(address _better) public view returns (bool[], bool[], uint256[], uint[], uint[]) {
uint length = betterBettingInfo[_better].length;
bool[] memory isWinner = new bool[](length);
bool[] memory hasReceivedPrize = new bool[](length);
uint256[] memory winningPrize = new uint256[](length);
uint[] memory numOfWinners = new uint[](length);
uint[] memory numOfBetters = new uint[](length);
for (uint i = 0; i < length; i++) {
isWinner[i] = betterBettingInfo[_better][i].isWinner;
hasReceivedPrize[i] = betterBettingInfo[_better][i].hasReceivedPrize;
winningPrize[i] = betterBettingInfo[_better][i].winningPrize;
numOfWinners[i] = betterBettingInfo[_better][i].numOfWinners;
numOfBetters[i] = betterBettingInfo[_better][i].numOfBetters;
}
return (isWinner, hasReceivedPrize, winningPrize, numOfWinners, numOfBetters);
}
function getNumOfBettersForMatchAndPrice(uint _matchId, uint _bettingPrice) public view returns(uint) {
uint numOfBetters = matchBettingInfo[_matchId].length;
uint count = 0;
for (uint i = 0; i < numOfBetters; i++) {
if (matchBettingInfo[_matchId][i].bettingPrice == _bettingPrice) {
count++;
}
}
return count;
}
function getBetterNumOfWinnings(address _better) public view returns(uint) {
return betterNumWinning[_better];
}
function getInfoPanel() public view returns(uint, uint, uint, uint) {
return (numOfPanhandler, numOfVagabond, numOfTramp, numOfMiddleClass);
}
}