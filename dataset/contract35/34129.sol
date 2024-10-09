pragma solidity ^0.4.16;
library SafeMath {
function mul(uint256 a, uint256 b) internal pure returns (uint256) {
uint256 c = a * b;
assert(a == 0 || c / a == b);
return c;
}
function add(uint256 a, uint256 b) internal pure returns (uint256) {
uint256 c = a + b;
assert(c >= a);
return c;
}
}
contract ERC20Token {
function transfer(address _to, uint256 _value) public returns (bool success);
function balanceOf(address _owner) public constant returns (uint256 balance);
}
contract PAXCHANGEICO {
using SafeMath for uint256;
enum State {
PreSale,
ICO,
Successful
}
State public state = State.PreSale;
uint256 public startTime = now;
uint256 public totalRaised;
uint256 public currentBalance;
uint256 public preSaledeadline;
uint256 public ICOdeadline;
uint256 public completedAt;
ERC20Token public tokenReward;
address public creator;
string public campaignUrl;
uint256 public constant version = 1;
uint256[4] public prices = [
7800,
7200,
6600,
3000
];
event LogFundingReceived(address _addr, uint _amount, uint _currentTotal);
event LogBeneficiaryPaid(address _beneficiaryAddress);
event LogFundingSuccessful(uint _totalRaised);
event LogICOInitialized(
address _creator,
string _url,
uint256 _PreSaledeadline,
uint256 _ICOdeadline);
event LogContributorsPayout(address _addr, uint _amount);
modifier notFinished() {
require(state != State.Successful);
_;
}
function PAXCHANGEICO (
string _campaignUrl,
ERC20Token _addressOfTokenUsedAsReward)
public
{
creator = msg.sender;
campaignUrl = _campaignUrl;
preSaledeadline = startTime.add(3 weeks);
ICOdeadline = preSaledeadline.add(3 weeks);
currentBalance = 0;
tokenReward = ERC20Token(_addressOfTokenUsedAsReward);
LogICOInitialized(
creator,
campaignUrl,
preSaledeadline,
ICOdeadline);
}
function contribute() public notFinished payable {
uint256 tokenBought;
totalRaised = totalRaised.add(msg.value);
currentBalance = totalRaised;
if (state == State.PreSale && now < startTime + 1 weeks){
tokenBought = uint256(msg.value).mul(prices[0]);
if (totalRaised.add(tokenBought) > 10000000 * (10**18)){
revert();
}
}
else if (state == State.PreSale && now < startTime + 2 weeks){
tokenBought = uint256(msg.value).mul(prices[1]);
if (totalRaised.add(tokenBought) > 10000000 * (10**18)){
revert();
}
}
else if (state == State.PreSale && now < startTime + 3 weeks){
tokenBought = uint256(msg.value).mul(prices[2]);
if (totalRaised.add(tokenBought) > 10000000 * (10**18)){
revert();
}
}
else if (state == State.ICO) {
tokenBought = uint256(msg.value).mul(prices[3]);
}
else {revert();}
tokenReward.transfer(msg.sender, tokenBought);
LogFundingReceived(msg.sender, msg.value, totalRaised);
LogContributorsPayout(msg.sender, tokenBought);
checkIfFundingCompleteOrExpired();
}
function checkIfFundingCompleteOrExpired() public {
if(now > preSaledeadline && now < ICOdeadline){
state = State.ICO;
}
else if(now > ICOdeadline && state==State.ICO){
state = State.Successful;
completedAt = now;
LogFundingSuccessful(totalRaised);
finished();
}
}
function finished() public {
require(state == State.Successful);
uint remanent;
remanent =  tokenReward.balanceOf(this);
currentBalance = 0;
tokenReward.transfer(creator,remanent);
require(creator.send(this.balance));
LogBeneficiaryPaid(creator);
LogContributorsPayout(creator, remanent);
}
function () public payable {
require(msg.value > 1 finney);
contribute();
}
}