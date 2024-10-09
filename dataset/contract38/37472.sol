pragma solidity ^0.4.13;
library SafeMath {
function mul(uint a, uint b) internal returns (uint) {
uint c = a * b;
assert(a == 0 || c / a == b);
return c;
}
function div(uint a, uint b) internal returns (uint) {
uint c = a / b;
return c;
}
function sub(uint a, uint b) internal returns (uint) {
assert(b <= a);
return a - b;
}
function add(uint a, uint b) internal returns (uint) {
uint c = a + b;
assert(c >= a);
return c;
}
function max64(uint64 a, uint64 b) internal constant returns (uint64) {
return a >= b ? a : b;
}
function min64(uint64 a, uint64 b) internal constant returns (uint64) {
return a < b ? a : b;
}
function max256(uint a, uint b) internal constant returns (uint) {
return a >= b ? a : b;
}
function min256(uint a, uint b) internal constant returns (uint) {
return a < b ? a : b;
}
}
contract PricingStrategy {
function isPricingStrategy() public constant returns (bool) {
return true;
}
function calculatePrice(uint value, uint weiRaised, uint tokensSold, address msgSender, uint decimals) public constant returns (uint tokenAmount);
}
contract FlatPricing is PricingStrategy {
using SafeMath for uint;
uint public oneTokenInWei;
function FlatPricing(uint _oneTokenInWei) {
oneTokenInWei = _oneTokenInWei;
}
function calculatePrice(uint value, uint, uint, address, uint decimals) public constant returns (uint) {
uint multiplier = 10 ** decimals;
return value.mul(multiplier).div(oneTokenInWei);
}
}