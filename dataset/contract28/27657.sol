pragma solidity ^0.4.19;
contract PlsDontPress {
address public feePayee;
address public lastPresser;
uint public currentPot;
uint public currentExpiryInterval = 1 days;
uint public expiryEpoch;
uint expiryIntervalCap = 60;
uint public startingCostToPress = 1000000000000000;
uint public currentCostToPress = 1000000000000000;
uint public lastAmountSent = startingCostToPress;
uint public minPotSum = 10000000000000000;
bool private locked;
modifier noReentrancy() {
require(!locked);
locked = true;
_;
locked = false;
}
function PlsDontPress() {
feePayee = msg.sender;
}
function press() public payable noReentrancy {
require(msg.value >= startingCostToPress);
uint currAmt = startingCostToPress;
if(!isExpired()){
require(msg.value >= currentCostToPress);
currAmt = msg.value;
}
setNextExpiry(currAmt);
lastPresser = msg.sender;
lastAmountSent = currAmt;
currentPot = this.balance;
}
function isExpired() internal returns(bool) {
if(now > expiryEpoch && expiryEpoch != 0){
payout();
currentCostToPress = startingCostToPress;
currentExpiryInterval = 1 days;
if(msg.value > startingCostToPress){
uint refundAmt = msg.value - startingCostToPress;
msg.sender.transfer(refundAmt);
}
return true;
}
else{
return false;
}
}
function payout() internal {
uint amtToPay;
uint fees = currentPot/1000;
feePayee.transfer(fees);
if(currentPot <= minPotSum * 2){
amtToPay = currentPot / 2;
} else {
amtToPay = currentPot - minPotSum;
}
lastPresser.transfer(amtToPay);
}
function setNextExpiry(uint _amtSent) internal {
if(_amtSent > lastAmountSent){
uint epochExpiryReductionPercentage =(lastAmountSent * 100)/ _amtSent;
uint reducedEpochExpiry = (currentExpiryInterval * epochExpiryReductionPercentage) / 100;
currentCostToPress = _amtSent;
if(reducedEpochExpiry < expiryIntervalCap){
currentExpiryInterval = expiryIntervalCap;
}else {
currentExpiryInterval = reducedEpochExpiry;
}
}
expiryEpoch = now + currentExpiryInterval;
}
function() external payable {
press();
}
}