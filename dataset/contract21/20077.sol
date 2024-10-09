pragma solidity 0.4.21;
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
function toTimestamp(uint16 year, uint8 month, uint8 day, uint8 hour, uint8 minute) public constant returns (uint timestamp);
}
contract ICO {
DateTimeAPI dateTimeContract = DateTimeAPI(0x1a6184CD4C5Bea62B0116de7962EE7315B7bcBce);
using SafeMath for uint256;
enum State {
preSale,
stage1a,
stage1b,
stage2a,
stage2b,
stage3a,
stage3b,
stage4a,
stage4b,
finishing,
Successful
}
State public state = State.preSale;
uint256 public startTime = dateTimeContract.toTimestamp(2018,4,1,0,0);
uint256 public totalRaised;
uint256 public totalDistributed;
uint256 public stageDistributed;
uint256[10] public rates = [2500,1250,1000,833,714,625,556,500,417,250];
uint256 public ICOdeadline;
uint256 public completedAt;
token public tokenReward;
address public creator;
address public beneficiary;
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
event LogStageDistributed(uint256 _amount, State _stage);
modifier notFinished() {
require(state != State.Successful);
_;
}
function ICO ( token _addressOfTokenUsedAsReward, address _beneficiary ) public {
creator = msg.sender;
tokenReward = _addressOfTokenUsedAsReward;
beneficiary = _beneficiary;
ICOdeadline = dateTimeContract.toTimestamp(2018,6,30,23,59);
emit LogFunderInitialized(
creator,
campaignUrl,
ICOdeadline);
}
function contribute() public notFinished payable {
require(now >= startTime);
uint256 tokenBought = 0;
totalRaised = totalRaised.add(msg.value);
if (state == State.preSale){
tokenBought = msg.value.mul(rates[0]);
require(stageDistributed.add(tokenBought) <= 2000000 * (10**18));
} else if (state == State.stage1a){
tokenBought = msg.value.mul(rates[1]);
require(stageDistributed.add(tokenBought) <= 1500000 * (10**18));
} else if (state == State.stage1b){
tokenBought = msg.value.mul(rates[2]);
require(stageDistributed.add(tokenBought) <= 1500000 * (10**18));
} else if (state == State.stage2a){
tokenBought = msg.value.mul(rates[3]);
require(stageDistributed.add(tokenBought) <= 1500000 * (10**18));
} else if (state == State.stage2b){
tokenBought = msg.value.mul(rates[4]);
require(stageDistributed.add(tokenBought) <= 1500000 * (10**18));
} else if (state == State.stage3a){
tokenBought = msg.value.mul(rates[5]);
require(stageDistributed.add(tokenBought) <= 1500000 * (10**18));
} else if (state == State.stage3b){
tokenBought = msg.value.mul(rates[6]);
require(stageDistributed.add(tokenBought) <= 1500000 * (10**18));
} else if (state == State.stage4a){
tokenBought = msg.value.mul(rates[7]);
require(stageDistributed.add(tokenBought) <= 1500000 * (10**18));
} else if (state == State.stage4b){
tokenBought = msg.value.mul(rates[8]);
require(stageDistributed.add(tokenBought) <= 1500000 * (10**18));
} else if (state == State.finishing){
tokenBought = msg.value.mul(rates[9]);
}
stageDistributed = stageDistributed.add(tokenBought);
totalDistributed = totalDistributed.add(tokenBought);
tokenReward.transfer(msg.sender, tokenBought);
emit LogFundingReceived(msg.sender, msg.value, totalRaised);
emit LogContributorsPayout(msg.sender, tokenBought);
checkIfFundingCompleteOrExpired();
}
function checkIfFundingCompleteOrExpired() public {
if(state == State.preSale && now > dateTimeContract.toTimestamp(2018,4,30,23,59)){
emit LogStageDistributed(stageDistributed,state);
state = State.stage1a;
stageDistributed = 0;
} else if(state == State.stage1a && now > dateTimeContract.toTimestamp(2018,5,7,23,59)){
emit LogStageDistributed(stageDistributed,state);
state = State.stage1b;
stageDistributed = 0;
} else if(state == State.stage1b && now > dateTimeContract.toTimestamp(2018,5,14,23,59)){
emit LogStageDistributed(stageDistributed,state);
state = State.stage2a;
stageDistributed = 0;
} else if(state == State.stage2a && now > dateTimeContract.toTimestamp(2018,5,21,23,59)){
emit LogStageDistributed(stageDistributed,state);
state = State.stage2b;
stageDistributed = 0;
} else if(state == State.stage2b && now > dateTimeContract.toTimestamp(2018,5,28,23,59)){
emit LogStageDistributed(stageDistributed,state);
state = State.stage3a;
stageDistributed = 0;
} else if(state == State.stage3a && now > dateTimeContract.toTimestamp(2018,6,4,23,59)){
emit LogStageDistributed(stageDistributed,state);
state = State.stage3b;
stageDistributed = 0;
} else if(state == State.stage3b && now > dateTimeContract.toTimestamp(2018,6,11,23,59)){
emit LogStageDistributed(stageDistributed,state);
state = State.stage4a;
stageDistributed = 0;
} else if(state == State.stage4a && now > dateTimeContract.toTimestamp(2018,6,18,23,59)){
emit LogStageDistributed(stageDistributed,state);
state = State.stage4b;
stageDistributed = 0;
} else if(state == State.stage4b && now > dateTimeContract.toTimestamp(2018,6,25,23,59)){
emit LogStageDistributed(stageDistributed,state);
state = State.finishing;
stageDistributed = 0;
} else if(state == State.finishing && now > ICOdeadline && state!=State.Successful){
emit LogStageDistributed(stageDistributed,state);
state = State.Successful;
completedAt = now;
emit LogFundingSuccessful(totalRaised);
finished();
}
}
function finished() public {
require(state == State.Successful);
uint256 remanent = tokenReward.balanceOf(this);
require(beneficiary.send(address(this).balance));
tokenReward.transfer(beneficiary,remanent);
emit LogBeneficiaryPaid(beneficiary);
emit LogContributorsPayout(beneficiary, remanent);
}
function () public payable {
contribute();
}
}