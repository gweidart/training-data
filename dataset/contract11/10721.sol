pragma solidity ^0.4.24;
library SafeMath {
function mul(uint256 a, uint256 b) internal pure returns (uint256) {
if (a == 0) {
return 0;
}
uint256 c = a * b;
assert(c / a == b);
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
contract Ownable {
address public owner;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
constructor() public {
owner = 0xD8F2FCbeDC3a1434a4B82b330765ff0Ada9d0D10;
}
modifier onlyOwner() {
require(msg.sender == owner);
_;
}
function transferOwnership(address newOwner) public onlyOwner {
require(newOwner != address(0));
emit OwnershipTransferred(owner, newOwner);
owner = newOwner;
}
}
contract Pausable is Ownable {
event Pause();
event Unpause();
bool public paused = false;
modifier whenNotPaused() {
require(!paused);
_;
}
modifier whenPaused() {
require(paused);
_;
}
function pause() onlyOwner whenNotPaused public {
paused = true;
emit Pause();
}
function unpause() onlyOwner whenPaused public {
paused = false;
emit Unpause();
}
}
contract ERC20Basic {
function totalSupply() public view returns (uint256);
function balanceOf(address who) public view returns (uint256);
function transfer(address to, uint256 value) public returns (bool);
event Transfer(address indexed from, address indexed to, uint256 value);
}
contract ERC20 is ERC20Basic {
function allowance(address owner, address spender) public view returns (uint256);
function transferFrom(address from, address to, uint256 value) public returns (bool);
function approve(address spender, uint256 value) public returns (bool);
event Approval(address indexed owner, address indexed spender, uint256 value);
}
contract HODL_ICO is Pausable {
using SafeMath for uint256;
ERC20 public token;
address public wallet;
uint256 public supply;
uint256 public rate;
uint256 public weiRaised;
uint256 public minInvest;
uint256 public openingTime;
uint256 public closingTime;
uint256 public duration;
event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);
constructor() public {
rate = 1000;
wallet = owner;
token = ERC20(0x2F21116ABbb4A91D916bE8c665B461AEa00eb568);
minInvest = 0.1 * 1 ether;
duration = 45 days;
openingTime = 1591920321;
closingTime = openingTime + duration;
}
function start() public onlyOwner {
openingTime = now;
closingTime =  now + duration;
}
function getCurrentRate() public view returns (uint256) {
if (now <= openingTime.add(15 days)) return rate.add(rate);
if (now > openingTime.add(15 days) && now <= openingTime.add(18 days)) return rate.add(rate*3/4);
if (now > openingTime.add(18 days) && now <= openingTime.add(21 days)) return rate.add(rate*7/10);
if (now > openingTime.add(21 days) && now <= openingTime.add(24 days)) return rate.add(rate*13/20);
if (now > openingTime.add(24 days) && now <= openingTime.add(27 days)) return rate.add(rate*3/5);
if (now > openingTime.add(27 days) && now <= openingTime.add(30 days)) return rate.add(rate*11/20);
if (now > openingTime.add(30 days) && now <= openingTime.add(33 days)) return rate.add(rate/2);
if (now > openingTime.add(33 days) && now <= openingTime.add(36 days)) return rate.add(rate*9/20);
if (now > openingTime.add(36 days) && now <= openingTime.add(39 days)) return rate.add(rate*2/5);
if (now > openingTime.add(39 days) && now <= openingTime.add(42 days)) return rate.add(rate*7/20);
if (now > openingTime.add(42 days)) return rate.add(rate*3/10);
}
function () external payable {
buyTokens(msg.sender);
}
function buyTokens(address _beneficiary) public payable {
uint256 weiAmount = msg.value;
_preValidatePurchase(_beneficiary, weiAmount);
uint256 tokens = _getTokenAmount(weiAmount);
weiRaised = weiRaised.add(weiAmount);
_processPurchase(_beneficiary, tokens);
emit TokenPurchase(msg.sender, _beneficiary, weiAmount, tokens);
_forwardFunds();
}
function _preValidatePurchase(address _beneficiary, uint256 _weiAmount) internal whenNotPaused {
require(_beneficiary != address(0));
require(_weiAmount >= minInvest);
require(now >= openingTime && now <= closingTime);
}
function _deliverTokens(address _beneficiary, uint256 _tokenAmount) internal {
token.transfer(_beneficiary, _tokenAmount);
}
function _processPurchase(address _beneficiary, uint256 _tokenAmount) internal {
_deliverTokens(_beneficiary, _tokenAmount);
}
function _getTokenAmount(uint256 _weiAmount) internal view returns (uint256) {
uint256 currentRate = getCurrentRate();
return currentRate.mul(_weiAmount);
}
function _forwardFunds() internal {
wallet.transfer(msg.value);
}
function hasClosed() public view returns (bool) {
return now > closingTime;
}
function withdrawTokens() public onlyOwner {
uint256 unsold = token.balanceOf(this);
token.transfer(owner, unsold);
}
}