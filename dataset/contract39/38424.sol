pragma solidity ^0.4.11;
library ArrayUtilsLib {
function sumElements(uint256[] storage self) constant returns(uint256 sum){
assembly { mstore(0x60,self_slot) }
for (uint256 i = 0; i < self.length; i++) {
assembly {
sum := add(sload(add(sha3(0x60,0x20),i)),sum)
}
}
}
function getMax(uint256[] storage self) constant returns(uint256 maxValue) {
assembly { mstore(0x60,self_slot) }
for (uint256 i = 1; i < self.length; i++) {
assembly {
maxValue := sload(sha3(0x60,0x20))
jumpi(skip, lt(sload(add(sha3(0x60,0x20),i)), maxValue))
maxValue := sload(add(sha3(0x60,0x20),i))
skip:
}
}
}
function indexOf(uint256[] storage self, uint256 value, bool isSorted) constant
returns(bool found, uint256 index) {
assembly{
mstore(0x60,self_slot)
let low := 0
let high := sub(sload(self_slot),1)
let mid := 0
jumpi(unsorted, iszero(isSorted))
sorted:
jumpi(done, gt(low,high))
mid := div(add(low,high),2)
jumpi(setH, lt(value,sload(add(sha3(0x60,0x20),mid))))
jumpi(setL, gt(value,sload(add(sha3(0x60,0x20),mid))))
found := 1
index := mid
jump(done)
setH:
high := sub(mid,1)
jump(sorted)
setL:
low := add(mid,1)
jump(sorted)
unsorted:
jumpi(loop, iszero(eq(sload(add(sha3(0x60,0x20),low)), value)))
found := 1
index := low
jump(done)
loop:
low := add(low,1)
jumpi(unsorted, lt(low, sload(self_slot)))
done:
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
function heapSort(uint256[] storage self) {
uint256 end = self.length - 1;
uint256 start = getParentI(end);
uint256 root = start;
uint256 lChild;
uint256 rChild;
uint256 swap;
uint256 temp;
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