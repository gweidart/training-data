pragma solidity ^0.4.21;
library Maths {
function plus(
uint256 addendA,
uint256 addendB
) public pure returns (uint256 sum) {
sum = addendA + addendB;
}
function minus(
uint256 minuend,
uint256 subtrahend
) public pure returns (uint256 difference) {
assert(minuend >= subtrahend);
difference = minuend - subtrahend;
}
function mul(
uint256 factorA,
uint256 factorB
) public pure returns (uint256 product) {
if (factorA == 0 || factorB == 0) return 0;
product = factorA * factorB;
assert(product / factorA == factorB);
}
function times(
uint256 factorA,
uint256 factorB
) public pure returns (uint256 product) {
return mul(factorA, factorB);
}
function div(
uint256 dividend,
uint256 divisor
) public pure returns (uint256 quotient) {
quotient = dividend / divisor;
assert(quotient * divisor == dividend);
}
function dividedBy(
uint256 dividend,
uint256 divisor
) public pure returns (uint256 quotient) {
return div(dividend, divisor);
}
function divideSafely(
uint256 dividend,
uint256 divisor
) public pure returns (uint256 quotient, uint256 remainder) {
quotient = div(dividend, divisor);
remainder = dividend % divisor;
}
function min(
uint256 a,
uint256 b
) public pure returns (uint256 result) {
result = a <= b ? a : b;
}
function max(
uint256 a,
uint256 b
) public pure returns (uint256 result) {
result = a >= b ? a : b;
}
function isLessThan(uint256 a, uint256 b) public pure returns (bool isTrue) {
isTrue = a < b;
}
function isAtMost(uint256 a, uint256 b) public pure returns (bool isTrue) {
isTrue = a <= b;
}
function isGreaterThan(uint256 a, uint256 b) public pure returns (bool isTrue) {
isTrue = a > b;
}
function isAtLeast(uint256 a, uint256 b) public pure returns (bool isTrue) {
isTrue = a >= b;
}
}