pragma solidity ^0.4.18;
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
}
contract token {
function balanceOf(address _owner) public constant returns (uint256 balance);
function transfer(address _to, uint256 _value) public returns (bool success);
}
contract DateTimeAPI {
function toTimestamp(uint16 year, uint8 month, uint8 day, uint8 hour, uint8 minute) constant returns (uint timestamp);
}
contract FiatContract {
function USD(uint _id) constant returns (uint256);
}
contract ICO {
DateTimeAPI dateTimeContract = DateTimeAPI(0x1a6184CD4C5Bea62B0116de7962EE7315B7bcBce);
FiatContract price = FiatContract(0x8055d0504666e2B6942BeB8D6014c964658Ca591);
using SafeMath for uint256;
enum State {
stage1,
stage2,
stage3,
Successful
}
State public state = State.stage1;
uint256 public startTime = now;
uint256 public totalRaised;
uint256 public totalDistributed;
uint256 public ICOdeadline;
uint256 public completedAt;
token public tokenReward;
address public creator;
string public campaignUrl;
string public version = '1';
event LogFundingReceived(address _addr, uint _amount, uint _currentTotal);
event LogBeneficiaryPaid(address _beneficiaryAddress);
event LogFundingSuccessful(uint _totalRaised);
event LogFunderInitialized(
address _creator,
string _url,
uint256 _ICOdeadline);
event LogContributorsPayout(address _addr, uint _amount);
modifier notFinished() {
require(state != State.Successful);
_;
}
function ICO ( string _campaignUrl, token _addressOfTokenUsedAsReward ) public {
creator = msg.sender;
campaignUrl = _campaignUrl;
tokenReward = _addressOfTokenUsedAsReward;
ICOdeadline = dateTimeContract.toTimestamp(2018,7,31,23,59);
LogFunderInitialized(
creator,
campaignUrl,
ICOdeadline);
}
function contribute() public notFinished payable {
uint256 tokenBought = 0;
uint256 usdCentInWei = price.USD(0);
uint baseCalc = usdCentInWei.div(10 ** 2);
totalRaised = totalRaised.add(msg.value);
if (state == State.stage1){
baseCalc = baseCalc.mul(15);
tokenBought = msg.value.div(baseCalc);
} else if (state == State.stage2){
baseCalc = baseCalc.mul(27);
tokenBought = msg.value.div(baseCalc);
} else if (state == State.stage3){
baseCalc = baseCalc.mul(35);
tokenBought = msg.value.div(baseCalc);
}
if(msg.value >= usdCentInWei.mul(5000000)){
tokenBought = tokenBought.mul(2);
} else if(msg.value >= usdCentInWei.mul(2000000)){
tokenBought = tokenBought.mul(18);
tokenBought = tokenBought.div(10);
} else if(msg.value >= usdCentInWei.mul(1000000)){
tokenBought = tokenBought.mul(16);
tokenBought = tokenBought.div(10);
} else if(msg.value >= usdCentInWei.mul(500000)){
tokenBought = tokenBought.mul(14);
tokenBought = tokenBought.div(10);
} else if(msg.value >= usdCentInWei.mul(100000)){
tokenBought = tokenBought.mul(12);
tokenBought = tokenBought.div(10);
}
totalDistributed = totalDistributed.add(tokenBought);
tokenReward.transfer(msg.sender, tokenBought);
LogFundingReceived(msg.sender, msg.value, totalRaised);
LogContributorsPayout(msg.sender, tokenBought);
checkIfFundingCompleteOrExpired();
}
function checkIfFundingCompleteOrExpired() public {
if(state == State.stage1 && now > dateTimeContract.toTimestamp(2018,5,31,23,59)){
state = State.stage2;
} else if(state == State.stage2 && now > dateTimeContract.toTimestamp(2018,6,30,23,59)){
state = State.stage3;
} else if(state == State.stage3 && now > ICOdeadline && state!=State.Successful){
state = State.Successful;
completedAt = now;
LogFundingSuccessful(totalRaised);
finished();
}
}
function finished() public {
require(state == State.Successful);
uint256 remanent = tokenReward.balanceOf(this);
require(creator.send(this.balance));
tokenReward.transfer(creator,remanent);
LogBeneficiaryPaid(creator);
LogContributorsPayout(creator, remanent);
}
function () public payable {
contribute();
}
}