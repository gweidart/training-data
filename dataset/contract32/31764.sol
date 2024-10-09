pragma solidity ^0.4.16;
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
contract admined {
address public admin;
function admined() internal {
admin = msg.sender;
Admined(admin);
}
modifier onlyAdmin() {
require(msg.sender == admin);
_;
}
function transferAdminship(address _newAdmin) onlyAdmin public {
admin = _newAdmin;
TransferAdminship(admin);
}
event TransferAdminship(address newAdminister);
event Admined(address administer);
}
contract UNRICO is admined {
using SafeMath for uint256;
enum State {
Ongoin,
Successful
}
uint256 public priceOfEthOnUSD;
State public state = State.Ongoin;
uint256 public startTime = now;
uint256[5] public price;
uint256 public HardCap;
uint256 public totalRaised;
uint256 public totalDistributed;
uint256 public ICOdeadline = startTime.add(27 days);
uint256 public completedAt;
token public tokenReward;
address public creator;
address public beneficiary;
string public campaignUrl;
uint8 constant version = 1;
event LogFundingReceived(address _addr, uint _amount, uint _currentTotal);
event LogBeneficiaryPaid(address _beneficiaryAddress);
event LogFundingSuccessful(uint _totalRaised);
event LogFunderInitialized(
address _creator,
address _beneficiary,
string _url,
uint256 _ICOdeadline);
event LogContributorsPayout(address _addr, uint _amount);
event PriceUpdate(uint256 _newPrice);
modifier notFinished() {
require(state != State.Successful);
_;
}
function UNRICO (string _campaignUrl, token _addressOfTokenUsedAsReward, uint256 _initialUsdPriceOfEth) public {
creator = msg.sender;
beneficiary = msg.sender;
campaignUrl = _campaignUrl;
tokenReward = token(_addressOfTokenUsedAsReward);
priceOfEthOnUSD = _initialUsdPriceOfEth;
HardCap = SafeMath.div(7260000*10**18,priceOfEthOnUSD);
price[0] = SafeMath.div(1 * 10 ** 15, priceOfEthOnUSD.mul(1666666));
price[1] = SafeMath.div(1 * 10 ** 11, priceOfEthOnUSD.mul(125));
price[2] = SafeMath.div(1 * 10 ** 15, priceOfEthOnUSD.mul(1111111));
price[3] = SafeMath.div(1 * 10 ** 15, priceOfEthOnUSD.mul(1052631));
price[4] = SafeMath.div(1 * 10 ** 10, priceOfEthOnUSD.mul(10));
LogFunderInitialized(
creator,
beneficiary,
campaignUrl,
ICOdeadline);
PriceUpdate(priceOfEthOnUSD);
}
function updatePriceOfEth(uint256 _newPrice) onlyAdmin public {
priceOfEthOnUSD = _newPrice;
price[0] = SafeMath.div(1 * 10 ** 15, priceOfEthOnUSD.mul(1666666));
price[1] = SafeMath.div(1 * 10 ** 11, priceOfEthOnUSD.mul(125));
price[2] = SafeMath.div(1 * 10 ** 15, priceOfEthOnUSD.mul(1111111));
price[3] = SafeMath.div(1 * 10 ** 15, priceOfEthOnUSD.mul(1052631));
price[4] = SafeMath.div(1 * 10 ** 10, priceOfEthOnUSD.mul(10));
HardCap = SafeMath.div(7260000*10**18,priceOfEthOnUSD);
PriceUpdate(_newPrice);
}
function contribute() public notFinished payable {
uint256 tokenBought;
uint256 required;
totalRaised = totalRaised.add(msg.value);
if(totalDistributed < 2000000 * (10 ** 8)){
tokenBought = msg.value.div(price[0]);
required = SafeMath.div(10000,6);
require(tokenBought >= required);
}
else if (totalDistributed < 20000000 * (10 ** 8)){
tokenBought = msg.value.div(price[1]);
required = SafeMath.div(10000,8);
require(tokenBought >= required);
}
else if (totalDistributed < 40000000 * (10 ** 8)){
tokenBought = msg.value.div(price[2]);
required = SafeMath.div(10000,9);
require(tokenBought >= required);
}
else if (totalDistributed < 60000000 * (10 ** 8)){
tokenBought = msg.value.div(price[3]);
required = SafeMath.div(100000,95);
require(tokenBought >= required);
}
else if (totalDistributed < 80000000 * (10 ** 8)){
tokenBought = msg.value.div(price[4]);
required = 1000;
require(tokenBought >= required);
}
totalDistributed = totalDistributed.add(tokenBought);
tokenReward.transfer(msg.sender, tokenBought);
LogFundingReceived(msg.sender, msg.value, totalRaised);
LogContributorsPayout(msg.sender, tokenBought);
checkIfFundingCompleteOrExpired();
}
function checkIfFundingCompleteOrExpired() public {
if(now < ICOdeadline && state!=State.Successful){
if(state == State.Ongoin && totalRaised >= HardCap){
state = State.Successful;
completedAt = now;
}
}
else if(now > ICOdeadline && state!=State.Successful ) {
state = State.Successful;
completedAt = now;
LogFundingSuccessful(totalRaised);
finished();
}
}
function payOut() public {
require(msg.sender == beneficiary);
require(beneficiary.send(this.balance));
LogBeneficiaryPaid(beneficiary);
}
function finished() public {
require(state == State.Successful);
uint256 remanent = tokenReward.balanceOf(this);
require(beneficiary.send(this.balance));
tokenReward.transfer(beneficiary,remanent);
LogBeneficiaryPaid(beneficiary);
LogContributorsPayout(beneficiary, remanent);
}
function () public payable {
contribute();
}
}