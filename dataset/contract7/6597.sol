pragma solidity 0.4.24;
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
contract ERC20Basic {
function totalSupply() public view returns (uint256);
function balanceOf(address who) public view returns (uint256);
function transfer(address to, uint256 value) public returns (bool);
function transferFrom(address from, address to, uint256 value) public returns (bool);
event Transfer(address indexed from, address indexed to, uint256 value);
}
contract admined {
mapping(address => uint8) public level;
constructor() internal {
level[msg.sender] = 2;
emit AdminshipUpdated(msg.sender,2);
}
modifier onlyAdmin(uint8 _level) {
require(level[msg.sender] >= _level );
_;
}
function adminshipLevel(address _newAdmin, uint8 _level) onlyAdmin(2) public {
require(_newAdmin != address(0));
level[_newAdmin] = _level;
emit AdminshipUpdated(_newAdmin,_level);
}
event AdminshipUpdated(address _newAdmin, uint8 _level);
}
contract TECHICO is admined {
using SafeMath for uint256;
enum State {
MainSale,
Paused,
Successful
}
State public state = State.MainSale;
uint256 constant public SaleStart = 1527879600;
uint256 public SaleDeadline = 1535569200;
uint256 public completedAt;
uint256 public totalRaised;
uint256 public totalDistributed;
ERC20Basic public tokenReward;
uint256 public hardCap = 31200000 * (10 ** 18);
mapping(address => uint256) public pending;
address public creator;
string public version = '2';
uint256 bonus1Remain = 1440000*10**18;
uint256 bonus2Remain = 2380000*10**18;
uint256 bonus3Remain = 3420000*10**18;
uint256 bonus4Remain = 5225000*10**18;
uint256 remainingActualState;
State laststate;
mapping (address => bool) public whiteList;
uint256 rate = 3000;
event LogFundrisingInitialized(address _creator);
event LogFundingReceived(address _addr, uint _amount, uint _currentTotal);
event LogBeneficiaryPaid(address _beneficiaryAddress);
event LogContributorsPayout(address _addr, uint _amount);
event LogFundingSuccessful(uint _totalRaised);
event LogSalePaused(bool _paused);
modifier notFinished() {
require(state != State.Successful && state != State.Paused);
_;
}
constructor(ERC20Basic _addressOfTokenUsedAsReward ) public {
creator = msg.sender;
tokenReward = _addressOfTokenUsedAsReward;
emit LogFundrisingInitialized(creator);
pending[0x8eBBcb4c4177941428E9E9E68C4914fb5A89650E] = 4720047000000000000002000;
totalDistributed = 4720047000000000000002000;
}
function remainingTokensAndCost() public view returns (uint256[2]){
uint256 remaining = hardCap.sub(totalDistributed);
uint256 cost = remaining.sub((bonus1Remain.mul(2)).div(10));
cost = cost.sub((bonus2Remain.mul(15)).div(100));
cost = cost.sub(bonus3Remain.div(10));
cost = cost.sub((bonus4Remain.mul(5)).div(100));
cost = cost.div(3000);
return [remaining,cost];
}
function whitelistAddress(address _user, bool _flag) public onlyAdmin(1) {
whiteList[_user] = _flag;
}
function pauseSale(bool _flag) onlyAdmin(2) public {
require(state != State.Successful);
if(_flag == true){
require(state != State.Paused);
laststate = state;
remainingActualState = SaleDeadline.sub(now);
state = State.Paused;
emit LogSalePaused(true);
} else {
require(state == State.Paused);
state = laststate;
SaleDeadline = now.add(remainingActualState);
emit LogSalePaused(false);
}
}
function contribute(address _target) public notFinished payable {
require(now > SaleStart);
address user;
if(_target != address(0) && level[msg.sender] >= 1){
user = _target;
} else {
user = msg.sender;
}
require(whiteList[user] == true);
totalRaised = totalRaised.add(msg.value);
uint256 tokenBought = msg.value.mul(rate);
uint256 bonus = 0;
uint256 buyHelper = tokenBought;
if(bonus1Remain > 0){
if(buyHelper <= bonus1Remain){
bonus1Remain = bonus1Remain.sub(buyHelper);
bonus = bonus.add((buyHelper.mul(2)).div(10));
buyHelper = 0;
}else{
buyHelper = buyHelper.sub(bonus1Remain);
bonus = bonus.add((bonus1Remain.mul(2)).div(10));
bonus1Remain = 0;
}
}
if(bonus2Remain > 0 && buyHelper > 0){
if(buyHelper <= bonus2Remain){
bonus2Remain = bonus2Remain.sub(buyHelper);
bonus = bonus.add((buyHelper.mul(15)).div(100));
buyHelper = 0;
}else{
buyHelper = buyHelper.sub(bonus2Remain);
bonus = bonus.add((bonus2Remain.mul(15)).div(100));
bonus2Remain = 0;
}
}
if(bonus3Remain > 0 && buyHelper > 0){
if(buyHelper <= bonus3Remain){
bonus3Remain = bonus3Remain.sub(buyHelper);
bonus = bonus.add(buyHelper.div(10));
buyHelper = 0;
}else{
buyHelper = buyHelper.sub(bonus3Remain);
bonus = bonus.add(bonus3Remain.div(10));
bonus3Remain = 0;
}
}
if(bonus4Remain > 0 && buyHelper > 0){
if(buyHelper <= bonus4Remain){
bonus4Remain = bonus4Remain.sub(buyHelper);
bonus = bonus.add((buyHelper.mul(5)).div(100));
buyHelper = 0;
}else{
buyHelper = buyHelper.sub(bonus4Remain);
bonus = bonus.add((bonus4Remain.mul(5)).div(100));
bonus4Remain = 0;
}
}
tokenBought = tokenBought.add(bonus);
require(totalDistributed.add(tokenBought) <= hardCap);
pending[user] = pending[user].add(tokenBought);
totalDistributed = totalDistributed.add(tokenBought);
emit LogFundingReceived(user, msg.value, totalRaised);
checkIfFundingCompleteOrExpired();
}
function claimTokensByUser() public{
require(state == State.Successful);
uint256 temp = pending[msg.sender];
pending[msg.sender] = 0;
require(tokenReward.transfer(msg.sender,temp));
emit LogContributorsPayout(msg.sender,temp);
}
function claimTokensByAdmin(address _user) onlyAdmin(1) public{
require(state == State.Successful);
uint256 temp = pending[_user];
pending[_user] = 0;
require(tokenReward.transfer(_user,temp));
emit LogContributorsPayout(_user,temp);
}
function checkIfFundingCompleteOrExpired() public {
if ( (totalDistributed == hardCap || now > SaleDeadline)
&& state != State.Successful
&& state != State.Paused) {
pending[creator] = tokenReward.balanceOf(address(this)).sub(totalDistributed);
state = State.Successful;
completedAt = now;
emit LogFundingSuccessful(totalRaised);
successful();
}
}
function successful() public {
require(state == State.Successful);
uint256 temp = pending[creator];
pending[creator] = 0;
require(tokenReward.transfer(creator,temp));
emit LogContributorsPayout(creator,temp);
creator.transfer(address(this).balance);
emit LogBeneficiaryPaid(creator);
}
function externalTokensRecovery(ERC20Basic _address) onlyAdmin(2) public{
require(state == State.Successful);
require(_address != address(tokenReward));
uint256 remainder = _address.balanceOf(this);
_address.transfer(msg.sender,remainder);
}
function () public payable {
contribute(address(0));
}
}