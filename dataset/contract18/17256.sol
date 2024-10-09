pragma solidity ^0.4.20;
library SafeMath {
function mul(uint256 a, uint256 b) internal pure returns (uint256) {
uint256 c = a * b;
assert(a == 0 || c / a == b);
return c;
}
function div(uint256 a, uint256 b) internal pure returns (uint256) {
uint256 c = a / b;
return c;
}
function add(uint256 a, uint256 b) internal pure returns (uint256) {
uint256 c = a + b;
assert(c >= a);
return c;
}
function sub(uint256 a, uint256 b) internal pure returns (uint256) {
assert(b <= a);
return a - b;
}
}
contract Owned {
address public owner;
event OwnershipTransferred(address indexed _from, address indexed _to);
function Owned() public {
owner = 0xBF2B073fF018F6bF1Caee6cE716B833271C159ee;
}
modifier onlyOwner {
require(msg.sender == owner);
_;
}
function transferOwnership(address _newOwner) public onlyOwner {
require(_newOwner != address(0x0));
emit OwnershipTransferred(owner,_newOwner);
owner = _newOwner;
}
}
contract token {
function balanceOf(address _owner) public constant returns (uint256 balance);
function transfer(address _to, uint256 _value) public returns (bool success);
}
contract ZipFlaxICO is Owned{
using SafeMath for uint256;
enum State {
PrivateSale,
PreICO,
ICO,
Successful
}
uint256 tokenPrice;
State public state;
uint256 public totalRaised;
uint256 public totalDistributed;
token public tokenReward;
event LogFundingReceived(address _addr, uint _amount, uint _currentTotal);
event LogBeneficiaryPaid(address _beneficiaryAddress);
event LogFundingSuccessful(uint _totalRaised);
event LogFunderInitialized(address _creator);
event LogContributorsPayout(address _addr, uint _amount);
modifier notFinished {
require(state != State.Successful);
_;
}
function ZipFlaxICO(token _addressOfTokenUsedAsReward) public {
require(_addressOfTokenUsedAsReward != address(0));
tokenPrice = 20000;
state = State.PrivateSale;
tokenReward = token(_addressOfTokenUsedAsReward);
emit LogFunderInitialized(owner);
}
function() public payable {
contribute();
}
function contribute() public notFinished payable {
uint256 tokenBought;
uint256 bonus;
tokenBought = msg.value.mul(tokenPrice).mul(10 ** 8).div(10 ** 18);
if (state == State.PrivateSale){
bonus = tokenBought.mul(35).div(100);
}
if (state == State.PreICO){
bonus = tokenBought.mul(25).div(100);
}
if (state == State.ICO){
bonus = tokenBought.mul(20).div(100);
}
tokenBought = tokenBought.add(bonus);
require(tokenReward.balanceOf(this) >= tokenBought);
totalRaised = totalRaised.add(msg.value);
totalDistributed = totalDistributed.add(tokenBought);
tokenReward.transfer(msg.sender,tokenBought);
owner.transfer(msg.value);
emit LogBeneficiaryPaid(owner);
emit LogFundingReceived(msg.sender, msg.value, totalRaised);
emit LogContributorsPayout(msg.sender,tokenBought);
}
function nextState() onlyOwner public {
require(state != State.ICO);
state = State(uint(state) + 1);
}
function previousState() onlyOwner public {
require(state != State.PrivateSale);
state = State(uint(state) - 1);
}
function finished() onlyOwner public {
uint256 remainder = tokenReward.balanceOf(this);
if(address(this).balance > 0) {
owner.transfer(address(this).balance);
emit LogBeneficiaryPaid(owner);
}
tokenReward.transfer(owner,remainder);
emit LogContributorsPayout(owner, remainder);
state = State.Successful;
}
function claimTokens(uint256 tokens) onlyOwner public {
require(tokenReward.balanceOf(this) >= tokens);
tokenReward.transfer(owner,tokens);
}
}