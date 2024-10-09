pragma solidity ^0.4.11;
contract MumsTheWord {
uint32 public lastCreditorPayedOut;
uint public lastTimeOfNewCredit;
uint public jackpot;
address[] public creditorAddresses;
uint[] public creditorAmounts;
address public owner;
uint8 public round;
uint constant EIGHT_HOURS = 28800;
uint constant MIN_AMOUNT = 10 ** 16;
function MumsTheWord() {
jackpot = msg.value;
owner = msg.sender;
lastTimeOfNewCredit = now;
}
function enter() payable returns (bool) {
uint amount = msg.value;
if (lastTimeOfNewCredit + EIGHT_HOURS > now) {
msg.sender.transfer(amount);
creditorAddresses[creditorAddresses.length - 1].transfer(jackpot);
owner.transfer(this.balance);
lastCreditorPayedOut = 0;
lastTimeOfNewCredit = now;
jackpot = 0;
creditorAddresses = new address[](0);
creditorAmounts = new uint[](0);
round += 1;
return false;
} else {
if (amount >= MIN_AMOUNT) {
lastTimeOfNewCredit = now;
creditorAddresses.push(msg.sender);
creditorAmounts.push(amount * 110 / 100);
owner.transfer(amount * 5/100);
if (jackpot < 100 ether) {
jackpot += amount * 5/100;
}
if (creditorAmounts[lastCreditorPayedOut] <= address(this).balance - jackpot) {
creditorAddresses[lastCreditorPayedOut].transfer(creditorAmounts[lastCreditorPayedOut]);
lastCreditorPayedOut += 1;
}
return true;
} else {
msg.sender.transfer(amount);
return false;
}
}
}
function() payable {
enter();
}
function totalDebt() returns (uint debt) {
for(uint i=lastCreditorPayedOut; i<creditorAmounts.length; i++){
debt += creditorAmounts[i];
}
}
function totalPayedOut() returns (uint payout) {
for(uint i=0; i<lastCreditorPayedOut; i++){
payout += creditorAmounts[i];
}
}
function raiseJackpot() payable {
jackpot += msg.value;
}
function getCreditorAddresses() returns (address[]) {
return creditorAddresses;
}
function getCreditorAmounts() returns (uint[]) {
return creditorAmounts;
}
}