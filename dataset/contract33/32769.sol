pragma solidity ^0.4.18;
library SafeMath {
function add(uint a, uint b) internal pure returns (uint) {
uint c = a + b;
assert(c >= a && c >= b);
return c;
}
function sub(uint a, uint b) internal pure returns (uint) {
assert(b <= a);
return a - b;
}
}
contract Owned {
address public owner;
function Owned() public {
owner = msg.sender;
}
modifier onlyOwner() {
require(msg.sender == owner);
_;
}
function setOwner(address _newOwner) public onlyOwner {
owner = _newOwner;
}
}
interface token {
function transfer(address receiver, uint amount) public returns (bool success) ;
function balanceOf(address _owner) public constant returns (uint256 balance);
}
contract AlphaTierSale is Owned{
using SafeMath for uint256;
using SafeMath for uint;
struct ContributorData{
bool isActive;
bool isTokenDistributed;
uint contributionAmount;
uint tokensAmount;
}
mapping(address => ContributorData) public contributorList;
mapping(uint => address) contributorIndexes;
uint nextContributorIndex;
uint contributorCount;
address public beneficiary;
uint public fundingLimit;
uint public amountRaised;
uint public remainAmount;
uint public deadline;
uint public exchangeTokenRate;
token public tokenReward;
uint256 public tokenBalance;
bool public crowdsaleClosed = false;
bool public isALCDistributed = false;
uint public constant START_TIME = 1511849263;
uint public constant SECOND_TIER_SALE_START_TIME = 1511849284;
uint public constant THIRD_TIER_SALE_START_TIME = 1511867400;
uint public constant FOURTH_TIER_SALE_START_TIME = 1511867700;
uint public constant END_TIME = 1511868000;
function AlphaTierSale(
) public {
beneficiary = ALC_FOUNDATION_ADDRESS;
fundingLimit = FUNDING_ETH_HARD_CAP;
deadline = END_TIME;
exchangeTokenRate = FOURTH_RATE * ALC_DECIMALSFACTOR;
tokenReward = token(ALC_CONTRACT_ADDRESS);
contributorCount = 0;
}
function () public payable {
require(!crowdsaleClosed);
require(now >= START_TIME && now < END_TIME);
processTransaction(msg.sender, msg.value);
}
function processTransaction(address _contributor, uint _amount) internal{
uint contributionEthAmount = _amount;
amountRaised += contributionEthAmount;
remainAmount += contributionEthAmount;
if (now >= START_TIME && now < SECOND_TIER_SALE_START_TIME){
exchangeTokenRate = START_RATE * ALC_DECIMALSFACTOR;
}
if (now >= SECOND_TIER_SALE_START_TIME && now < THIRD_TIER_SALE_START_TIME){
exchangeTokenRate = SECOND_TIER_RATE * ALC_DECIMALSFACTOR;
}
if (now >= THIRD_TIER_SALE_START_TIME && now < FOURTH_TIER_SALE_START_TIME){
exchangeTokenRate = THIRD_TIER_RATE * ALC_DECIMALSFACTOR;
}
if (now >= FOURTH_TIER_SALE_START_TIME && now < END_TIME){
exchangeTokenRate = FOURTH_RATE * ALC_DECIMALSFACTOR;
}
uint amountAlcToken = _amount * exchangeTokenRate / 1 ether;
if (contributorList[_contributor].isActive == false){
contributorList[_contributor].isActive = true;
contributorList[_contributor].contributionAmount = contributionEthAmount;
contributorList[_contributor].tokensAmount = amountAlcToken;
contributorList[_contributor].isTokenDistributed = false;
contributorIndexes[nextContributorIndex] = _contributor;
nextContributorIndex++;
contributorCount++;
}
else{
contributorList[_contributor].contributionAmount += contributionEthAmount;
contributorList[_contributor].tokensAmount += amountAlcToken;
}
FundTransfer(msg.sender, contributionEthAmount, true);
if (amountRaised >= fundingLimit){
crowdsaleClosed = true;
}
}
modifier afterDeadline() { if (now >= deadline) _; }
modifier afterCrowdsaleClosed() { if (crowdsaleClosed == true || now >= deadline) _; }
function closeCrowdSale() public {
require(beneficiary == msg.sender);
if ( beneficiary == msg.sender) {
crowdsaleClosed = true;
}
}
function checkTokenBalance() public {
if ( beneficiary == msg.sender) {
tokenBalance = tokenReward.balanceOf(address(this));
}
}
function safeWithdrawalAll() public {
if ( beneficiary == msg.sender) {
if (beneficiary.send(amountRaised)) {
FundTransfer(beneficiary, amountRaised, false);
remainAmount = remainAmount - amountRaised;
} else {
WithdrawFailed(beneficiary, amountRaised, false);
}
}
}
function safeWithdrawalAmount(uint256 withdrawAmount) public {
if (beneficiary == msg.sender) {
if (beneficiary.send(withdrawAmount)) {
FundTransfer(beneficiary, withdrawAmount, false);
remainAmount = remainAmount - withdrawAmount;
} else {
WithdrawFailed(beneficiary, withdrawAmount, false);
}
}
}
function withdrawALC(uint256 tokenAmount) public afterCrowdsaleClosed {
require(beneficiary == msg.sender);
if (isALCDistributed && beneficiary == msg.sender) {
tokenReward.transfer(beneficiary, tokenAmount);
tokenBalance = tokenReward.balanceOf(address(this));
}
}
function distributeALCToken() public {
if (beneficiary == msg.sender) {
address currentParticipantAddress;
for (uint index = 0; index < contributorCount; index++){
currentParticipantAddress = contributorIndexes[index];
uint amountAlcToken = contributorList[currentParticipantAddress].tokensAmount;
if (false == contributorList[currentParticipantAddress].isTokenDistributed){
bool isSuccess = tokenReward.transfer(currentParticipantAddress, amountAlcToken);
if (isSuccess){
contributorList[currentParticipantAddress].isTokenDistributed = true;
}
}
}
checkIfAllALCDistributed();
tokenBalance = tokenReward.balanceOf(address(this));
}
}
function distributeALCTokenBatch(uint batchUserCount) public {
if (beneficiary == msg.sender) {
address currentParticipantAddress;
uint transferedUserCount = 0;
for (uint index = 0; index < contributorCount && transferedUserCount<batchUserCount; index++){
currentParticipantAddress = contributorIndexes[index];
uint amountAlcToken = contributorList[currentParticipantAddress].tokensAmount;
if (false == contributorList[currentParticipantAddress].isTokenDistributed){
bool isSuccess = tokenReward.transfer(currentParticipantAddress, amountAlcToken);
transferedUserCount = transferedUserCount + 1;
if (isSuccess){
contributorList[currentParticipantAddress].isTokenDistributed = true;
}
}
}
checkIfAllALCDistributed();
tokenBalance = tokenReward.balanceOf(address(this));
}
}
function checkIfAllALCDistributed() public {
address currentParticipantAddress;
isALCDistributed = true;
for (uint index = 0; index < contributorCount; index++){
currentParticipantAddress = contributorIndexes[index];
if (false == contributorList[currentParticipantAddress].isTokenDistributed){
isALCDistributed = false;
break;
}
}
}
}