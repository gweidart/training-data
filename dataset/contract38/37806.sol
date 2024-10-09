pragma solidity ^0.4.13;
library Array16Lib {
function sumElements(uint16[] storage self) constant returns(uint16 sum) {
uint256 term;
assembly {
mstore(0x60,self_slot)
for { let i := 0 } lt(i, sload(self_slot)) { i := add(i, 1) } {
term := sload(add(sha3(0x60,0x20),div(i,16)))
switch mod(i,16)
case 1 {
for { let j := 0 } lt(j, 1) { j := add(j, 1) } {
term := div(term,65536)
}
}
case 2 {
for { let j := 0 } lt(j, 2) { j := add(j, 1) } {
term := div(term,65536)
}
}
case 3 {
for { let j := 0 } lt(j, 3) { j := add(j, 1) } {
term := div(term,65536)
}
}
case 4 {
for { let j := 0 } lt(j, 4) { j := add(j, 1) } {
term := div(term,65536)
}
}
case 5 {
for { let j := 0 } lt(j, 5) { j := add(j, 1) } {
term := div(term,65536)
}
}
case 6 {
for { let j := 0 } lt(j, 6) { j := add(j, 1) } {
term := div(term,65536)
}
}
case 7 {
for { let j := 0 } lt(j, 7) { j := add(j, 1) } {
term := div(term,65536)
}
}
case 8 {
for { let j := 0 } lt(j, 8) { j := add(j, 1) } {
term := div(term,65536)
}
}
case 9 {
for { let j := 0 } lt(j, 9) { j := add(j, 1) } {
term := div(term,65536)
}
}
case 10 {
for { let j := 0 } lt(j, 10) { j := add(j, 1) } {
term := div(term,65536)
}
}
case 11 {
for { let j := 0 } lt(j, 11) { j := add(j, 1) } {
term := div(term,65536)
}
}
case 12 {
for { let j := 0 } lt(j, 12) { j := add(j, 1) } {
term := div(term,65536)
}
}
case 13 {
for { let j := 0 } lt(j, 13) { j := add(j, 1) } {
term := div(term,65536)
}
}
case 14 {
for { let j := 0 } lt(j, 14) { j := add(j, 1) } {
term := div(term,65536)
}
}
case 15 {
for { let j := 0 } lt(j, 15) { j := add(j, 1) } {
term := div(term,65536)
}
}
term := and(0x000000000000000000000000000000000000000000000000000000000000ffff,term)
sum := add(term,sum)
}
}
}
function getMax(uint16[] storage self) constant returns(uint16 maxValue) {
uint256 term;
assembly {
mstore(0x60,self_slot)
maxValue := 0
for { let i := 0 } lt(i, sload(self_slot)) { i := add(i, 1) } {
term := sload(add(sha3(0x60,0x20),div(i,16)))
switch mod(i,16)
case 1 {
for { let j := 0 } lt(j, 1) { j := add(j, 1) } {
term := div(term,65536)
}
}
case 2 {
for { let j := 0 } lt(j, 2) { j := add(j, 1) } {
term := div(term,65536)
}
}
case 3 {
for { let j := 0 } lt(j, 3) { j := add(j, 1) } {
term := div(term,65536)
}
}
case 4 {
for { let j := 0 } lt(j, 4) { j := add(j, 1) } {
term := div(term,65536)
}
}
case 5 {
for { let j := 0 } lt(j, 5) { j := add(j, 1) } {
term := div(term,65536)
}
}
case 6 {
for { let j := 0 } lt(j, 6) { j := add(j, 1) } {
term := div(term,65536)
}
}
case 7 {
for { let j := 0 } lt(j, 7) { j := add(j, 1) } {
term := div(term,65536)
}
}
case 8 {
for { let j := 0 } lt(j, 8) { j := add(j, 1) } {
term := div(term,65536)
}
}
case 9 {
for { let j := 0 } lt(j, 9) { j := add(j, 1) } {
term := div(term,65536)
}
}
case 10 {
for { let j := 0 } lt(j, 10) { j := add(j, 1) } {
term := div(term,65536)
}
}
case 11 {
for { let j := 0 } lt(j, 11) { j := add(j, 1) } {
term := div(term,65536)
}
}
case 12 {
for { let j := 0 } lt(j, 12) { j := add(j, 1) } {
term := div(term,65536)
}
}
case 13 {
for { let j := 0 } lt(j, 13) { j := add(j, 1) } {
term := div(term,65536)
}
}
case 14 {
for { let j := 0 } lt(j, 14) { j := add(j, 1) } {
term := div(term,65536)
}
}
case 15 {
for { let j := 0 } lt(j, 15) { j := add(j, 1) } {
term := div(term,65536)
}
}
term := and(0x000000000000000000000000000000000000000000000000000000000000ffff,term)
switch lt(maxValue, term)
case 1 {
maxValue := term
}
}
}
}
function getMin(uint16[] storage self) constant returns(uint16 minValue) {
uint256 term;
assembly {
mstore(0x60,self_slot)
for { let i := 0 } lt(i, sload(self_slot)) { i := add(i, 1) } {
term := sload(add(sha3(0x60,0x20),div(i,16)))
switch mod(i,16)
case 1 {
for { let j := 0 } lt(j, 1) { j := add(j, 1) } {
term := div(term,65536)
}
}
case 2 {
for { let j := 0 } lt(j, 2) { j := add(j, 1) } {
term := div(term,65536)
}
}
case 3 {
for { let j := 0 } lt(j, 3) { j := add(j, 1) } {
term := div(term,65536)
}
}
case 4 {
for { let j := 0 } lt(j, 4) { j := add(j, 1) } {
term := div(term,65536)
}
}
case 5 {
for { let j := 0 } lt(j, 5) { j := add(j, 1) } {
term := div(term,65536)
}
}
case 6 {
for { let j := 0 } lt(j, 6) { j := add(j, 1) } {
term := div(term,65536)
}
}
case 7 {
for { let j := 0 } lt(j, 7) { j := add(j, 1) } {
term := div(term,65536)
}
}
case 8 {
for { let j := 0 } lt(j, 8) { j := add(j, 1) } {
term := div(term,65536)
}
}
case 9 {
for { let j := 0 } lt(j, 9) { j := add(j, 1) } {
term := div(term,65536)
}
}
case 10 {
for { let j := 0 } lt(j, 10) { j := add(j, 1) } {
term := div(term,65536)
}
}
case 11 {
for { let j := 0 } lt(j, 11) { j := add(j, 1) } {
term := div(term,65536)
}
}
case 12 {
for { let j := 0 } lt(j, 12) { j := add(j, 1) } {
term := div(term,65536)
}
}
case 13 {
for { let j := 0 } lt(j, 13) { j := add(j, 1) } {
term := div(term,65536)
}
}
case 14 {
for { let j := 0 } lt(j, 14) { j := add(j, 1) } {
term := div(term,65536)
}
}
case 15 {
for { let j := 0 } lt(j, 15) { j := add(j, 1) } {
term := div(term,65536)
}
}
term := and(0x000000000000000000000000000000000000000000000000000000000000ffff,term)
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
function indexOf(uint16[] storage self, uint16 value, bool isSorted) constant
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
function heapSort(uint16[] storage self) {
uint256 end = self.length - 1;
uint256 start = getParentI(end);
uint256 root = start;
uint256 lChild;
uint256 rChild;
uint256 swap;
uint16 temp;
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