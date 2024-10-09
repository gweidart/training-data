pragma solidity ^0.4.18;
interface IPricingStrategy {
function isPricingStrategy() public view returns (bool);
function calculateTokenAmount(uint weiAmount, uint tokensSold) public view returns (uint tokenAmount);
}
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
contract PresalePricingStrategy is IPricingStrategy {
using SafeMath for uint;
uint public rate;
function PresalePricingStrategy(
uint _rate
) public
{
require(_rate >= 0);
rate = _rate;
}
function isPricingStrategy() public view returns (bool) {
return true;
}
function calculateTokenAmount(uint weiAmount, uint weiRaised) public view returns (uint tokenAmount) {
return weiAmount.mul(rate);
}
}