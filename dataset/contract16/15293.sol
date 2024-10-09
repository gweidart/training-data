pragma solidity ^0.4.15;
contract token {
function transferFrom(address sender, address receiver, uint amount) returns(bool success) {}
function burn() {}
}
library SafeMath {
function mul(uint a, uint b) internal returns (uint) {
uint c = a * b;
assert(a == 0 || c / a == b);
return c;
}
function sub(uint a, uint b) internal returns (uint) {
assert(b <= a);
return a - b;
}
function add(uint a, uint b) internal returns (uint) {
uint c = a + b;
assert(c >= a && c >= b);
return c;
}
}
contract NcICO {
using SafeMath for uint;
uint public prices;
uint public start;
uint public end;
mapping(address => uint) public balances;
bool public crowdsaleEnded = false;
address public tokenOwner;
token public tokenReward;
address wallet;
uint public amountRaised;
uint public deadline;
event Finalize(address _tokenOwner, uint _amountRaised);
event FundTransfer(address backer, uint amount, bool isContribution, uint _amountRaised);
uint _current = 0;
function current() public returns (uint) {
if(_current == 0) {
return now;
}
return _current;
}
function setCurrent(uint __current) {
_current = __current;
}
function NcICO(
address tokenAddr,
address walletAddr,
address tokenOwnerAddr,
uint durationInMinutes,
uint etherCostOfEachToken
) {
tokenReward = token(tokenAddr);
wallet = walletAddr;
tokenOwner = tokenOwnerAddr;
deadline = now + durationInMinutes * 1 minutes;
prices = etherCostOfEachToken * 0.0000001 ether;
}
function() payable {
if (msg.sender != wallet)
exchange(msg.sender);
}
function exchange(address receiver) payable {
uint amount = msg.value;
uint price = getPrice();
uint numTokens = amount.mul(price);
require(numTokens > 0);
wallet.transfer(amount);
balances[receiver] = balances[receiver].add(amount);
amountRaised = amountRaised.add(amount);
assert(tokenReward.transferFrom(tokenOwner, receiver, numTokens));
FundTransfer(receiver, amount, true, amountRaised);
}
function manualExchange(address receiver, uint value) {
require(msg.sender == tokenOwner);
assert(tokenReward.transferFrom(tokenOwner, receiver, value));
}
function getPrice() constant returns (uint price) {
return prices;
}
modifier afterDeadline() { if (current() >= end) _; }
function finalize() afterDeadline {
require(!crowdsaleEnded);
tokenReward.burn();
Finalize(tokenOwner, amountRaised);
crowdsaleEnded = true;
}
function safeWithdrawal() afterDeadline {
uint amount = balances[msg.sender];
if (address(this).balance >= amount) {
balances[msg.sender] = 0;
if (amount > 0) {
msg.sender.transfer(amount);
FundTransfer(msg.sender, amount, false, amountRaised);
}
}
}
}