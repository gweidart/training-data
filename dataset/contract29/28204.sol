pragma solidity ^0.4.15;
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
uint[] public rates;
uint[] public limits;
function PricingStrategy(
uint[] _rates,
uint[] _limits
) public
{
require(_rates.length == _limits.length);
rates = _rates;
limits = _limits;
}
function isPricingStrategy() public view returns (bool) {
return true;
}
function calculateTokenAmount(uint weiAmount, uint weiRaised) public view returns (uint tokenAmount) {
if (weiAmount == 0) {
return 0;
}
var (rate, index) = currentRate(weiRaised);
tokenAmount = weiAmount.mul(rate);
if (weiRaised.add(weiAmount) > limits[index]) {
uint currentSlotWei = limits[index].sub(weiRaised);
uint currentSlotTokens = currentSlotWei.mul(rate);
uint remainingWei = weiAmount.sub(currentSlotWei);
tokenAmount = currentSlotTokens.add(calculateTokenAmount(remainingWei, limits[index]));
}
}
function currentRate(uint weiRaised) public view returns (uint rate, uint8 index) {
rate = rates[0];
index = 0;
while (weiRaised >= limits[index]) {
rate = rates[++index];
}
}
}