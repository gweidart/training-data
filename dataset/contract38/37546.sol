pragma solidity ^0.4.11;
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
contract PricingStrategy {
using SafeMath for uint;
uint public rate0;
uint public rate1;
uint public rate2;
uint public threshold1;
uint public threshold2;
uint public minimumWeiAmount;
function PricingStrategy(
uint _rate0,
uint _rate1,
uint _rate2,
uint _minimumWeiAmount,
uint _threshold1,
uint _threshold2
) {
require(_rate0 > 0);
require(_rate1 > 0);
require(_rate2 > 0);
require(_minimumWeiAmount > 0);
require(_threshold1 > 0);
require(_threshold2 > 0);
rate0 = _rate0;
rate1 = _rate1;
rate2 = _rate2;
minimumWeiAmount = _minimumWeiAmount;
threshold1 = _threshold1;
threshold2 = _threshold2;
}
function isPricingStrategy() public constant returns (bool) {
return true;
}
function calculateTokenAmount(uint weiAmount) public constant returns (uint tokenAmount) {
uint bonusRate = 0;
if (weiAmount >= minimumWeiAmount) {
bonusRate = rate0;
}
if (weiAmount >= threshold1) {
bonusRate = rate1;
}
if (weiAmount >= threshold2) {
bonusRate = rate2;
}
return weiAmount.mul(bonusRate);
}
}