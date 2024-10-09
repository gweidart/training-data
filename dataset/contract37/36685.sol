pragma solidity ^0.4.16;
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
contract Presale {
using SafeMath for uint256;
mapping (address => uint256) public balances;
uint256 public minGoal;
uint256 public startTime;
uint256 public endTime;
address public projectWallet;
uint256 private totalRaised;
function Presale() {
minGoal = 83.33 ether;
startTime = 1505248886;
endTime = 1506841199;
projectWallet = address(0x2a00BFd8379786ADfEbb6f2F59011535a4f8d4E4);
}
function transferToProjectWallet() {
require(this.balance > 0);
require(totalRaised >= minGoal);
if(!projectWallet.send(this.balance)) {
revert();
}
}
function refund() {
require(now > endTime);
require(totalRaised < minGoal);
require(now < (endTime + 60 days));
uint256 amount = balances[msg.sender];
require(amount > 0);
balances[msg.sender] = 0;
msg.sender.transfer(amount);
}
function transferRemaining() {
require(totalRaised < minGoal);
require(now >= (endTime + 60 days));
require(this.balance > 0);
projectWallet.transfer(this.balance);
}
function () payable {
require(msg.value > 0);
require(now >= startTime);
require(now <= endTime);
balances[msg.sender] = balances[msg.sender].add(msg.value);
totalRaised = totalRaised.add(msg.value);
}
}