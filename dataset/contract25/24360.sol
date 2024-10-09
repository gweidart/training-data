pragma solidity ^0.4.19;
contract token {
function transfer(address receiver, uint256 amount);
function balanceOf(address _owner) constant returns (uint256 balance);
}
library SafeMath {
function mul(uint256 a, uint256 b) internal constant returns (uint256) {
uint256 c = a * b;
assert(a == 0 || c / a == b);
return c;
}
function div(uint256 a, uint256 b) internal constant returns (uint256) {
uint256 c = a / b;
return c;
}
function sub(uint256 a, uint256 b) internal constant returns (uint256) {
assert(b <= a);
return a - b;
}
function add(uint256 a, uint256 b) internal constant returns (uint256) {
uint256 c = a + b;
assert(c >= a);
return c;
}
}
contract bkfkCrowdsale {
using SafeMath for uint256;
address public beneficiary;
uint256 public fundingGoal;
uint256 public amountRaised;
uint256 public preSaleStartdate;
uint256 public preSaleDeadline;
uint256 public mainSaleStartdate;
uint256 public mainSaleDeadline;
uint256 public preSaleprice;
uint256 public mainSaleprice;
uint256 public fundTransferred;
token public tokenReward;
mapping(address => uint256) public balanceOf;
bool fundingGoalReached = false;
bool crowdsaleClosed = false;
function bkfkCrowdsale() {
beneficiary = 0x007FB3e94dCd7C441CAA5b87621F275d199Dff81;
fundingGoal = 5720 ether;
preSaleStartdate = 1522972800;
preSaleDeadline = 1524268800;
mainSaleStartdate = 1524787200;
mainSaleDeadline = 1528502400;
preSaleprice = 0.00001 ether;
mainSaleprice = 0.00003 ether;
tokenReward = token(0xE6AcB21DE14c12086663b442120F8504093635D9);
}
function () payable {
require(!crowdsaleClosed);
uint256 bonus;
uint256 amount = msg.value;
balanceOf[msg.sender] = balanceOf[msg.sender].add(amount);
amountRaised = amountRaised.add(amount);
if(now >= preSaleStartdate && now <= preSaleDeadline ){
amount =  amount.div(preSaleprice);
}
else if(now >= mainSaleStartdate && now <= mainSaleStartdate + 24 hours ){
amount =  amount.div(mainSaleprice);
bonus = amount.mul(40).div(100);
amount = amount.add(bonus);
}
else if(now > mainSaleStartdate + 24 hours && now <= mainSaleStartdate + 24 hours + 1 weeks ){
amount =  amount.div(mainSaleprice);
bonus = amount.mul(30).div(100);
amount = amount.add(bonus);
}
else if(now > mainSaleStartdate + 24 hours + 1 weeks && now <= mainSaleStartdate + 24 hours + 2 weeks ){
amount =  amount.div(mainSaleprice);
bonus = amount.mul(25).div(100);
amount = amount.add(bonus);
}
else if(now > mainSaleStartdate + 24 hours + 2 weeks && now <= mainSaleStartdate + 24 hours + 3 weeks ){
amount =  amount.div(mainSaleprice);
bonus = amount.mul(20).div(100);
amount = amount.add(bonus);
}
else if(now > mainSaleStartdate + 24 hours + 3 weeks && now <= mainSaleStartdate + 24 hours + 4 weeks ){
amount =  amount.div(mainSaleprice);
bonus = amount.mul(15).div(100);
amount = amount.add(bonus);
}
else if(now > mainSaleStartdate + 24 hours + 4 weeks && now <= mainSaleStartdate + 24 hours + 5 weeks ){
amount =  amount.div(mainSaleprice);
bonus = amount.mul(10).div(100);
amount = amount.add(bonus);
} else {
amount =  amount.div(mainSaleprice);
bonus = amount.mul(5).div(100);
amount = amount.add(bonus);
}
amount = amount.mul(100000000);
tokenReward.transfer(msg.sender, amount);
}
modifier afterDeadline() { if (now >= mainSaleDeadline) _; }
function endCrowdsale() afterDeadline {
crowdsaleClosed = true;
}
function getTokensBack() {
uint256 remaining = tokenReward.balanceOf(this);
if(msg.sender == beneficiary){
tokenReward.transfer(beneficiary, remaining);
}
}
function safeWithdrawal() {
if (beneficiary == msg.sender) {
if(fundTransferred != amountRaised){
uint256 transferfund;
transferfund = amountRaised.sub(fundTransferred);
fundTransferred = fundTransferred.add(transferfund);
beneficiary.send(transferfund);
}
}
}
}