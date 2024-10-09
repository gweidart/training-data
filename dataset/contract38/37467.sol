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
contract CeilingStrategy {
function isCeilingStrategy() public constant returns (bool) {
return true;
}
function weiAllowedToReceive(uint _value, uint _weiRaised, uint _weiInvestedBySender, uint _weiFundingCap) public constant returns (uint amount);
function isCrowdsaleFull(uint _weiRaised, uint _weiFundingCap) public constant returns (bool);
function relaxFundingCap(uint _newCap, uint _weiRaised) public constant returns (uint);
}
contract FixedCeiling is CeilingStrategy {
using SafeMath for uint;
uint public chunkedWeiMultiple;
uint public weiLimitPerAddress;
function FixedCeiling(uint multiple, uint limit) {
chunkedWeiMultiple = multiple;
weiLimitPerAddress = limit;
}
function weiAllowedToReceive(uint tentativeAmount, uint weiRaised, uint weiInvestedBySender, uint weiFundingCap) public constant returns (uint) {
uint totalOfSender = tentativeAmount.add(weiInvestedBySender);
if (totalOfSender > weiLimitPerAddress) tentativeAmount = weiLimitPerAddress.sub(weiInvestedBySender);
if (weiFundingCap == 0) return tentativeAmount;
uint total = tentativeAmount.add(weiRaised);
if (total < weiFundingCap) return tentativeAmount;
else return weiFundingCap.sub(weiRaised);
}
function isCrowdsaleFull(uint weiRaised, uint weiFundingCap) public constant returns (bool) {
return weiFundingCap > 0 && weiRaised >= weiFundingCap;
}
function relaxFundingCap(uint newCap, uint weiRaised) public constant returns (uint) {
if (newCap > weiRaised) return newCap;
else return weiRaised.div(chunkedWeiMultiple).add(1).mul(chunkedWeiMultiple);
}
}