pragma solidity ^0.4.18;
contract Ownable {
address public owner;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
function Ownable() public {
owner = msg.sender;
}
modifier onlyOwner() {
require(msg.sender == owner);
_;
}
function transferOwnership(address newOwner) onlyOwner public {
require(newOwner != address(0));
OwnershipTransferred(owner, newOwner);
owner = newOwner;
}
}
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
function sub(uint256 a, uint256 b) internal pure returns (uint256) {
assert(b <= a);
return a - b;
}
function add(uint256 a, uint256 b) internal pure returns (uint256) {
uint256 c = a + b;
assert(c >= a);
return c;
}
}
contract TempusToken {
function mint(address receiver, uint256 amount) public returns (bool success);
}
contract TempusIco is Ownable {
using SafeMath for uint256;
uint public startTime = 1519916400;
uint public price0 = 0.005 ether / 1000;
uint public price1 = price0 * 2;
uint public price2 = price1 * 2;
uint public price3 = price2 * 2;
uint public price4 = price3 * 2;
uint public price5 = price4 * 2;
uint public hardCap = 1000000000 * 1000;
uint public tokensSold = 0;
uint[6] public tokensSoldInPeriod;
uint public periodDuration = 30 days;
uint public period0End = startTime + 31 days;
uint public period1End = period0End + 30 days;
uint public period2End = period1End + 31 days;
uint public period3End = period2End + 30 days;
uint public period4End = period3End + 31 days;
bool public paused = false;
address withdrawAddress1;
address withdrawAddress2;
TempusToken token;
mapping(address => bool) public sellers;
modifier onlySellers() {
require(sellers[msg.sender]);
_;
}
function TempusIco (address tokenAddress, address _withdrawAddress1,
address _withdrawAddress2) public {
token = TempusToken(tokenAddress);
withdrawAddress1 = _withdrawAddress1;
withdrawAddress2 = _withdrawAddress2;
}
function periodByDate() public view returns (uint periodNum) {
if(now < period0End) {
return 0;
}
if(now < period1End) {
return 1;
}
if(now < period2End) {
return 2;
}
if(now < period3End) {
return 3;
}
if(now < period4End) {
return 4;
}
return 5;
}
function priceByPeriod() public view returns (uint price) {
uint periodNum = periodByDate();
if(periodNum == 0) {
return price0;
}
if(periodNum == 1) {
return price1;
}
if(periodNum == 2) {
return price2;
}
if(periodNum == 3) {
return price3;
}
if(periodNum == 4) {
return price4;
}
return price5;
}
function isActive() public view returns (bool active) {
bool withinPeriod = now >= startTime;
bool capIsNotMet = tokensSold < hardCap;
return capIsNotMet && withinPeriod && !paused;
}
function() external payable {
buyFor(msg.sender);
}
function buyFor(address beneficiary) public payable {
require(msg.value != 0);
uint amount = msg.value;
require(amount >= 0.1 ether);
uint price = priceByPeriod();
uint tokenAmount = amount.div(price);
makePurchase(beneficiary, tokenAmount);
}
function externalPurchase(address beneficiary, uint amount) external onlySellers {
makePurchase(beneficiary, amount);
}
function makePurchase(address beneficiary, uint amount) private {
require(beneficiary != 0x0);
require(isActive());
uint minimumTokens = 1000;
if(tokensSold < hardCap.sub(minimumTokens)) {
require(amount >= minimumTokens);
}
require(amount.add(tokensSold) <= hardCap);
tokensSold = tokensSold.add(amount);
token.mint(beneficiary, amount);
updatePeriodStat(amount);
}
function updatePeriodStat(uint amount) private {
uint periodNum = periodByDate();
tokensSoldInPeriod[periodNum] = tokensSoldInPeriod[periodNum] + amount;
if(periodNum == 5) {
return;
}
uint amountOnStart = hardCap - tokensSold + tokensSoldInPeriod[periodNum];
uint percentSold = (tokensSoldInPeriod[periodNum] * 100) / amountOnStart;
if(percentSold >= 20) {
resetPeriodDates(periodNum);
}
}
function resetPeriodDates(uint periodNum) private {
if(periodNum == 0) {
period0End = now;
period1End = period0End + periodDuration;
period2End = period1End + periodDuration;
period3End = period2End + periodDuration;
period4End = period3End + periodDuration;
return;
}
if(periodNum == 1) {
period1End = now;
period2End = period1End + periodDuration;
period3End = period2End + periodDuration;
period4End = period3End + periodDuration;
return;
}
if(periodNum == 2) {
period2End = now;
period3End = period2End + periodDuration;
period4End = period3End + periodDuration;
return;
}
if(periodNum == 3) {
period3End = now;
period4End = period3End + periodDuration;
return;
}
if(periodNum == 4) {
period4End = now;
return;
}
}
function setPaused(bool isPaused) external onlyOwner {
paused = isPaused;
}
function setAsSeller(address seller, bool isSeller) external onlyOwner {
sellers[seller] = isSeller;
}
function setStartTime(uint _startTime) external onlyOwner {
startTime = _startTime;
}
function withdrawEther(uint amount) external onlyOwner {
withdrawAddress1.transfer(amount / 2);
withdrawAddress2.transfer(amount / 2);
}
}