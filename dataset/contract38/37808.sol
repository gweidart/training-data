pragma solidity ^0.4.13;
library Array64Lib {
function sumElements(uint64[] storage self) constant returns(uint64 sum) {
uint256 term;
assembly {
mstore(0x60,self_slot)
for { let i := 0 } lt(i, sload(self_slot)) { i := add(i, 1) } {
term := sload(add(sha3(0x60,0x20),div(i,4)))
switch mod(i,4)
case 1 {
for { let j := 0 } lt(j, 2) { j := add(j, 1) } {
term := div(term,4294967296)
}
}
case 2 {
for { let j := 0 } lt(j, 4) { j := add(j, 1) } {
term := div(term,4294967296)
}
}
case 3 {
for { let j := 0 } lt(j, 6) { j := add(j, 1) } {
term := div(term,4294967296)
}
}
term := and(0x000000000000000000000000000000000000000000000000ffffffffffffffff,term)
sum := add(term,sum)
}
}
}
function getMax(uint64[] storage self) constant returns(uint64 maxValue) {
uint256 term;
assembly {
mstore(0x60,self_slot)
maxValue := 0
for { let i := 0 } lt(i, sload(self_slot)) { i := add(i, 1) } {
term := sload(add(sha3(0x60,0x20),div(i,4)))
switch mod(i,4)
case 1 {
for { let j := 0 } lt(j, 2) { j := add(j, 1) } {
term := div(term,4294967296)
}
}
case 2 {
for { let j := 0 } lt(j, 4) { j := add(j, 1) } {
term := div(term,4294967296)
}
}
case 3 {
for { let j := 0 } lt(j, 6) { j := add(j, 1) } {
term := div(term,4294967296)
}
}
term := and(0x000000000000000000000000000000000000000000000000ffffffffffffffff,term)
switch lt(maxValue, term)
case 1 {
maxValue := term
}
}
}
}
function getMin(uint64[] storage self) constant returns(uint64 minValue) {
uint256 term;
assembly {
mstore(0x60,self_slot)
for { let i := 0 } lt(i, sload(self_slot)) { i := add(i, 1) } {
term := sload(add(sha3(0x60,0x20),div(i,4)))
switch mod(i,4)
case 1 {
for { let j := 0 } lt(j, 2) { j := add(j, 1) } {
term := div(term,4294967296)
}
}
case 2 {
for { let j := 0 } lt(j, 4) { j := add(j, 1) } {
term := div(term,4294967296)
}
}
case 3 {
for { let j := 0 } lt(j, 6) { j := add(j, 1) } {
term := div(term,4294967296)
}
}
term := and(0x000000000000000000000000000000000000000000000000ffffffffffffffff,term)
switch eq(i,0)
case 1 {
minValue := term
}
switch gt(minValue, term)
case 1 {
minValue := term
}
}
}
}
function indexOf(uint64[] storage self, uint64 value, bool isSorted) constant
returns(bool found, uint256 index) {
if (isSorted) {
uint256 high = self.length - 1;
uint256 mid = 0;
uint256 low = 0;
while (low <= high) {
mid = (low+high)/2;
if (self[mid] == value) {
found = true;
index = mid;
low = high + 1;
} else if (self[mid] < value) {
low = mid + 1;
} else {
high = mid - 1;
}
}
} else {
for (uint256 i = 0; i<self.length; i++) {
if (self[i] == value) {
found = true;
index = i;
i = self.length;
}
}
}
}
function getParentI(uint256 index) constant private returns (uint256 pI) {
uint256 i = index - 1;
pI = i/2;
}
function getLeftChildI(uint256 index) constant private returns (uint256 lcI) {
uint256 i = index * 2;
lcI = i + 1;
}
function heapSort(uint64[] storage self) {
uint256 end = self.length - 1;
uint256 start = getParentI(end);
uint256 root = start;
uint256 lChild;
uint256 rChild;
uint256 swap;
uint64 temp;
while(start >= 0){
root = start;
lChild = getLeftChildI(start);
while(lChild <= end){
rChild = lChild + 1;
swap = root;
if(self[swap] < self[lChild])
swap = lChild;
if((rChild <= end) && (self[swap]<self[rChild]))
swap = rChild;
if(swap == root)
lChild = end+1;
else {
temp = self[swap];
self[swap] = self[root];
self[root] = temp;
root = swap;
lChild = getLeftChildI(root);
}
}
if(start == 0)
break;
else
start = start - 1;
}
while(end > 0){
temp = self[end];
self[end] = self[0];
self[0] = temp;
end = end - 1;
root = 0;
lChild = getLeftChildI(0);
while(lChild <= end){
rChild = lChild + 1;
swap = root;
if(self[swap] < self[lChild])
swap = lChild;
if((rChild <= end) && (self[swap]<self[rChild]))
swap = rChild;
if(swap == root)
lChild = end + 1;
else {
temp = self[swap];
self[swap] = self[root];
self[root] = temp;
root = swap;
lChild = getLeftChildI(root);
}
}
}
}
}