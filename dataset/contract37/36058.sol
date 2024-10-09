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
library UintLib {
using SafeMath  for uint;
function tolerantSub(uint x, uint y) constant returns (uint z) {
if (x >= y) z = x - y;
else z = 0;
}
function next(uint i, uint size) internal constant returns (uint) {
return (i + 1) % size;
}
function prev(uint i, uint size) internal constant returns (uint) {
return (i + size - 1) % size;
}
function cvsquare(
uint[] arr,
uint scale
)
internal
constant
returns (uint) {
uint len = arr.length;
require(len > 1);
require(scale > 0);
uint avg = 0;
for (uint i = 0; i < len; i++) {
avg += arr[i];
}
avg = avg.div(len);
if (avg == 0) {
return 0;
}
uint cvs = 0;
for (i = 0; i < len; i++) {
uint sub = 0;
if (arr[i] > avg) {
sub = arr[i] - avg;
} else {
sub = avg - arr[i];
}
cvs += sub.mul(sub);
}
return cvs
.mul(scale)
.div(avg)
.mul(scale)
.div(avg)
.div(len - 1);
}
}