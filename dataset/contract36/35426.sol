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
contract PricingStrategy2 {
using SafeMath for uint;
uint public rate;
function PricingStrategy2(uint _rate) {
require(_rate > 0);
rate = _rate;
}
function isPricingStrategy() public constant returns (bool) {
return true;
}
function calculateTokenAmount(uint weiAmount) public constant returns (uint tokenAmount) {
return weiAmount.mul(rate);
}
}