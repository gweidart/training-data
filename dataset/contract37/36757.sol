pragma solidity ^0.4.15;
library TreeLib {
using IntervalLib for IntervalLib.Interval;
using ListLib for ListLib.List;
uint8 constant SEARCH_DONE = 0x00;
uint8 constant SEARCH_EARLIER = 0x01;
uint8 constant SEARCH_LATER = 0x10;
bool constant TRAVERSED_EARLIER = false;
bool constant TRAVERSED_LATER = true;
struct Tree {
mapping (uint => IntervalLib.Interval) intervals;
uint numIntervals;
mapping (uint => Node) nodes;
uint numNodes;
uint rootNode;
}
struct Node {
uint earlier;
uint later;
ListLib.List intervals;
}
function addInterval(Tree storage tree,
uint begin,
uint end,
bytes32 data)
internal
{
uint intervalID = _createInterval(tree, begin, end, data);
if (tree.rootNode == 0) {
var nodeID = _createNode(tree);
tree.rootNode = nodeID;
tree.nodes[nodeID].intervals.add(begin, end, intervalID);
return;
}
uint curID = tree.rootNode;
bool found = false;
do {
Node storage curNode = tree.nodes[curID];
bool recurseDirection;
if (end <= curNode.intervals.center) {
curID = curNode.earlier;
recurseDirection = TRAVERSED_EARLIER;
} else if (begin > curNode.intervals.center) {
curID = curNode.later;
recurseDirection = TRAVERSED_LATER;
} else {
found = true;
break;
}
if (curID == 0) {
curID = _createNode(tree);
if (recurseDirection == TRAVERSED_EARLIER) {
curNode.earlier = curID;
} else {
curNode.later = curID;
}
found = true;
}
} while (!found);
tree.nodes[curID].intervals.add(begin, end, intervalID);
}
function getInterval(Tree storage tree, uint intervalID)
constant
internal
returns (uint begin, uint end, bytes32 data)
{
require(intervalID > 0 && intervalID <= tree.numIntervals);
var interval = tree.intervals[intervalID];
return (interval.begin, interval.end, interval.data);
}
function search(Tree storage tree, uint point)
constant
internal
returns (uint[] memory intervalIDs)
{
require(tree.rootNode != 0x0);
intervalIDs = new uint[](0);
uint[] memory tempIDs;
uint[] memory matchingIDs;
uint i;
uint curID = tree.rootNode;
uint8 searchNext;
do {
Node storage curNode = tree.nodes[curID];
(matchingIDs, searchNext) = curNode.intervals.matching(point);
if (matchingIDs.length > 0) {
tempIDs = new uint[](intervalIDs.length + matchingIDs.length);
for (i = 0; i < intervalIDs.length; i++) {
tempIDs[i] = intervalIDs[i];
}
for (i = 0; i < matchingIDs.length; i++) {
tempIDs[i + intervalIDs.length] = matchingIDs[i];
}
intervalIDs = tempIDs;
}
if (searchNext == SEARCH_EARLIER) {
curID = curNode.earlier;
} else if (searchNext == SEARCH_LATER) {
curID = curNode.later;
}
} while (searchNext != SEARCH_DONE && curID != 0x0);
}
function _createInterval(Tree storage tree, uint begin, uint end, bytes32 data)
internal
returns (uint intervalID)
{
intervalID = ++tree.numIntervals;
tree.intervals[intervalID] = IntervalLib.Interval({
begin: begin,
end: end,
data: data
});
}
function _createNode(Tree storage tree) returns (uint nodeID) {
nodeID = ++tree.numNodes;
tree.nodes[nodeID] = Node({
earlier: 0,
later: 0,
intervals: ListLib.createNew(nodeID)
});
}
}
library IntervalLib {
struct Interval {
uint begin;
uint end;
bytes32 data;
}
}
library GroveLib {
struct Index {
bytes32 root;
mapping (bytes32 => Node) nodes;
}
struct Node {
bytes32 id;
int value;
bytes32 parent;
bytes32 left;
bytes32 right;
uint height;
}
function max(uint a, uint b) internal returns (uint) {
if (a >= b) {
return a;
}
return b;
}
function getNodeId(Index storage index, bytes32 id) constant returns (bytes32) {
return index.nodes[id].id;
}
function getNodeValue(Index storage index, bytes32 id) constant returns (int) {
return index.nodes[id].value;
}
function getNodeHeight(Index storage index, bytes32 id) constant returns (uint) {
return index.nodes[id].height;
}
function getNodeParent(Index storage index, bytes32 id) constant returns (bytes32) {
return index.nodes[id].parent;
}
function getNodeLeftChild(Index storage index, bytes32 id) constant returns (bytes32) {
return index.nodes[id].left;
}
function getNodeRightChild(Index storage index, bytes32 id) constant returns (bytes32) {
return index.nodes[id].right;
}
function getPreviousNode(Index storage index, bytes32 id) constant returns (bytes32) {
Node storage currentNode = index.nodes[id];
if (currentNode.id == 0x0) {
return 0x0;
}
Node memory child;
if (currentNode.left != 0x0) {
child = index.nodes[currentNode.left];
while (child.right != 0) {
child = index.nodes[child.right];
}
return child.id;
}
if (currentNode.parent != 0x0) {
Node storage parent = index.nodes[currentNode.parent];
child = currentNode;
while (true) {
if (parent.right == child.id) {
return parent.id;
}
if (parent.parent == 0x0) {
break;
}
child = parent;
parent = index.nodes[parent.parent];
}
}
return 0x0;
}
function getNextNode(Index storage index, bytes32 id) constant returns (bytes32) {
Node storage currentNode = index.nodes[id];
if (currentNode.id == 0x0) {
return 0x0;
}
Node memory child;
if (currentNode.right != 0x0) {
child = index.nodes[currentNode.right];
while (child.left != 0) {
child = index.nodes[child.left];
}
return child.id;
}
if (currentNode.parent != 0x0) {
Node storage parent = index.nodes[currentNode.parent];
child = currentNode;
while (true) {
if (parent.left == child.id) {
return parent.id;
}
if (parent.parent == 0x0) {
break;
}
child = parent;
parent = index.nodes[parent.parent];
}
}
return 0x0;
}
function insert(Index storage index, bytes32 id, int value) public {
if (index.nodes[id].id == id) {
if (index.nodes[id].value == value) {
return;
}
remove(index, id);
}
bytes32 previousNodeId = 0x0;
if (index.root == 0x0) {
index.root = id;
}
Node storage currentNode = index.nodes[index.root];
while (true) {
if (currentNode.id == 0x0) {
currentNode.id = id;
currentNode.parent = previousNodeId;
currentNode.value = value;
break;
}
previousNodeId = currentNode.id;
if (value >= currentNode.value) {
if (currentNode.right == 0x0) {
currentNode.right = id;
}
currentNode = index.nodes[currentNode.right];
continue;
}
if (currentNode.left == 0x0) {
currentNode.left = id;
}
currentNode = index.nodes[currentNode.left];
}
_rebalanceTree(index, currentNode.id);
}
function exists(Index storage index, bytes32 id) constant returns (bool) {
return (index.nodes[id].height > 0);
}
function remove(Index storage index, bytes32 id) public {
bytes32 rebalanceOrigin;
Node storage nodeToDelete = index.nodes[id];
if (nodeToDelete.id != id) {
return;
}
if (nodeToDelete.left != 0x0 || nodeToDelete.right != 0x0) {
if (nodeToDelete.left != 0x0) {
Node storage replacementNode = index.nodes[getPreviousNode(index, nodeToDelete.id)];
}
else {
replacementNode = index.nodes[getNextNode(index, nodeToDelete.id)];
}
Node storage parent = index.nodes[replacementNode.parent];
rebalanceOrigin = replacementNode.id;
if (parent.left == replacementNode.id) {
parent.left = replacementNode.right;
if (replacementNode.right != 0x0) {
Node storage child = index.nodes[replacementNode.right];
child.parent = parent.id;
}
}
if (parent.right == replacementNode.id) {
parent.right = replacementNode.left;
if (replacementNode.left != 0x0) {
child = index.nodes[replacementNode.left];
child.parent = parent.id;
}
}
replacementNode.parent = nodeToDelete.parent;
if (nodeToDelete.parent != 0x0) {
parent = index.nodes[nodeToDelete.parent];
if (parent.left == nodeToDelete.id) {
parent.left = replacementNode.id;
}
if (parent.right == nodeToDelete.id) {
parent.right = replacementNode.id;
}
}
else {
index.root = replacementNode.id;
}
replacementNode.left = nodeToDelete.left;
if (nodeToDelete.left != 0x0) {
child = index.nodes[nodeToDelete.left];
child.parent = replacementNode.id;
}
replacementNode.right = nodeToDelete.right;
if (nodeToDelete.right != 0x0) {
child = index.nodes[nodeToDelete.right];
child.parent = replacementNode.id;
}
}
else if (nodeToDelete.parent != 0x0) {
parent = index.nodes[nodeToDelete.parent];
if (parent.left == nodeToDelete.id) {
parent.left = 0x0;
}
if (parent.right == nodeToDelete.id) {
parent.right = 0x0;
}
rebalanceOrigin = parent.id;
}
else {
index.root = 0x0;
}
nodeToDelete.id = 0x0;
nodeToDelete.value = 0;
nodeToDelete.parent = 0x0;
nodeToDelete.left = 0x0;
nodeToDelete.right = 0x0;
nodeToDelete.height = 0;
if (rebalanceOrigin != 0x0) {
_rebalanceTree(index, rebalanceOrigin);
}
}
bytes2 constant GT = ">";
bytes2 constant LT = "<";
bytes2 constant GTE = ">=";
bytes2 constant LTE = "<=";
bytes2 constant EQ = "==";
function _compare(int left, bytes2 operator, int right) internal returns (bool) {
require(
operator == GT || operator == LT || operator == GTE ||
operator == LTE || operator == EQ
);
if (operator == GT) {
return (left > right);
}
if (operator == LT) {
return (left < right);
}
if (operator == GTE) {
return (left >= right);
}
if (operator == LTE) {
return (left <= right);
}
if (operator == EQ) {
return (left == right);
}
}
function _getMaximum(Index storage index, bytes32 id) internal returns (int) {
Node storage currentNode = index.nodes[id];
while (true) {
if (currentNode.right == 0x0) {
return currentNode.value;
}
currentNode = index.nodes[currentNode.right];
}
}
function _getMinimum(Index storage index, bytes32 id) internal returns (int) {
Node storage currentNode = index.nodes[id];
while (true) {
if (currentNode.left == 0x0) {
return currentNode.value;
}
currentNode = index.nodes[currentNode.left];
}
}
function query(Index storage index, bytes2 operator, int value) public returns (bytes32) {
bytes32 rootNodeId = index.root;
if (rootNodeId == 0x0) {
return 0x0;
}
Node storage currentNode = index.nodes[rootNodeId];
while (true) {
if (_compare(currentNode.value, operator, value)) {
if ((operator == LT) || (operator == LTE)) {
if (currentNode.right == 0x0) {
return currentNode.id;
}
if (_compare(_getMinimum(index, currentNode.right), operator, value)) {
currentNode = index.nodes[currentNode.right];
continue;
}
return currentNode.id;
}
if ((operator == GT) || (operator == GTE) || (operator == EQ)) {
if (currentNode.left == 0x0) {
return currentNode.id;
}
if (_compare(_getMaximum(index, currentNode.left), operator, value)) {
currentNode = index.nodes[currentNode.left];
continue;
}
return currentNode.id;
}
}
if ((operator == LT) || (operator == LTE)) {
if (currentNode.left == 0x0) {
return 0x0;
}
currentNode = index.nodes[currentNode.left];
continue;
}
if ((operator == GT) || (operator == GTE)) {
if (currentNode.right == 0x0) {
return 0x0;
}
currentNode = index.nodes[currentNode.right];
continue;
}
if (operator == EQ) {
if (currentNode.value < value) {
if (currentNode.right == 0x0) {
return 0x0;
}
currentNode = index.nodes[currentNode.right];
continue;
}
if (currentNode.value > value) {
if (currentNode.left == 0x0) {
return 0x0;
}
currentNode = index.nodes[currentNode.left];
continue;
}
}
}
}
function _rebalanceTree(Index storage index, bytes32 id) internal {
Node storage currentNode = index.nodes[id];
while (true) {
int balanceFactor = _getBalanceFactor(index, currentNode.id);
if (balanceFactor == 2) {
if (_getBalanceFactor(index, currentNode.left) == -1) {
_rotateLeft(index, currentNode.left);
}
_rotateRight(index, currentNode.id);
}
if (balanceFactor == -2) {
if (_getBalanceFactor(index, currentNode.right) == 1) {
_rotateRight(index, currentNode.right);
}
_rotateLeft(index, currentNode.id);
}
if ((-1 <= balanceFactor) && (balanceFactor <= 1)) {
_updateNodeHeight(index, currentNode.id);
}
if (currentNode.parent == 0x0) {
break;
}
currentNode = index.nodes[currentNode.parent];
}
}
function _getBalanceFactor(Index storage index, bytes32 id) internal returns (int) {
Node storage node = index.nodes[id];
return int(index.nodes[node.left].height) - int(index.nodes[node.right].height);
}
function _updateNodeHeight(Index storage index, bytes32 id) internal {
Node storage node = index.nodes[id];
node.height = max(index.nodes[node.left].height, index.nodes[node.right].height) + 1;
}
function _rotateLeft(Index storage index, bytes32 id) internal {
Node storage originalRoot = index.nodes[id];
assert(originalRoot.right != 0x0);
Node storage newRoot = index.nodes[originalRoot.right];
newRoot.parent = originalRoot.parent;
originalRoot.right = 0x0;
if (originalRoot.parent != 0x0) {
Node storage parent = index.nodes[originalRoot.parent];
if (parent.left == originalRoot.id) {
parent.left = newRoot.id;
}
if (parent.right == originalRoot.id) {
parent.right = newRoot.id;
}
}
if (newRoot.left != 0) {
Node storage leftChild = index.nodes[newRoot.left];
originalRoot.right = leftChild.id;
leftChild.parent = originalRoot.id;
}
originalRoot.parent = newRoot.id;
newRoot.left = originalRoot.id;
if (newRoot.parent == 0x0) {
index.root = newRoot.id;
}
_updateNodeHeight(index, originalRoot.id);
_updateNodeHeight(index, newRoot.id);
}
function _rotateRight(Index storage index, bytes32 id) internal {
Node storage originalRoot = index.nodes[id];
assert(originalRoot.left != 0x0);
Node storage newRoot = index.nodes[originalRoot.left];
newRoot.parent = originalRoot.parent;
originalRoot.left = 0x0;
if (originalRoot.parent != 0x0) {
Node storage parent = index.nodes[originalRoot.parent];
if (parent.left == originalRoot.id) {
parent.left = newRoot.id;
}
if (parent.right == originalRoot.id) {
parent.right = newRoot.id;
}
}
if (newRoot.right != 0x0) {
Node storage rightChild = index.nodes[newRoot.right];
originalRoot.left = newRoot.right;
rightChild.parent = originalRoot.id;
}
originalRoot.parent = newRoot.id;
newRoot.right = originalRoot.id;
if (newRoot.parent == 0x0) {
index.root = newRoot.id;
}
_updateNodeHeight(index, originalRoot.id);
_updateNodeHeight(index, newRoot.id);
}
}
library ListLib {
uint8 constant SEARCH_DONE = 0x00;
uint8 constant SEARCH_EARLIER = 0x01;
uint8 constant SEARCH_LATER = 0x10;
using GroveLib for GroveLib.Index;
using IntervalLib for IntervalLib.Interval;
struct List {
uint length;
uint center;
mapping (uint => IntervalLib.Interval) items;
GroveLib.Index beginIndex;
GroveLib.Index endIndex;
bytes32 lowestBegin;
bytes32 highestEnd;
}
function createNew()
internal
returns (List)
{
return createNew(block.number);
}
function createNew(uint id)
internal
returns (List)
{
return List({
length: 0,
center: 0xDEADBEEF,
lowestBegin: 0x0,
highestEnd: 0x0,
beginIndex: GroveLib.Index(sha3(this, bytes32(id * 2))),
endIndex: GroveLib.Index(sha3(this, bytes32(id * 2 + 1)))
});
}
function add(List storage list, uint begin, uint end, uint intervalID) internal {
var _intervalID = bytes32(intervalID);
var _begin = _getBeginIndexKey(begin);
var _end = _getEndIndexKey(end);
list.beginIndex.insert(_intervalID, _begin);
list.endIndex.insert(_intervalID, _end);
list.length++;
if (list.length == 1) {
list.lowestBegin = list.beginIndex.root;
list.highestEnd = list.endIndex.root;
list.center = begin + (end - begin) / 2;
return;
}
var newLowest = list.beginIndex.getPreviousNode(list.lowestBegin);
if (newLowest != 0x0) {
list.lowestBegin = newLowest;
}
var newHighest = list.endIndex.getNextNode(list.highestEnd);
if (newHighest != 0x0) {
list.highestEnd = newHighest;
}
}
function matching(List storage list, uint point)
constant
internal
returns (uint[] memory intervalIDs, uint8 searchNext)
{
uint[] memory _intervalIDs = new uint[](list.length);
uint num = 0;
bytes32 cur;
if (point == list.center) {
cur = list.lowestBegin;
while (cur != 0x0) {
_intervalIDs[num] = uint(list.beginIndex.getNodeId(cur));
num++;
cur = _next(list, cur);
}
searchNext = SEARCH_DONE;
} else if (point < list.center) {
cur = list.lowestBegin;
while (cur != 0x0) {
uint begin = _begin(list, cur);
if (begin > point) {
break;
}
_intervalIDs[num] = uint(list.beginIndex.getNodeId(cur));
num++;
cur = _next(list, cur);
}
searchNext = SEARCH_EARLIER;
} else if (point > list.center) {
cur = list.highestEnd;
while (cur != 0x0) {
uint end = _end(list, cur);
if (end <= point) {
break;
}
_intervalIDs[num] = uint(list.endIndex.getNodeId(cur));
num++;
cur = _previous(list, cur);
}
searchNext = SEARCH_LATER;
}
if (num == _intervalIDs.length) {
intervalIDs = _intervalIDs;
} else {
intervalIDs = new uint[](num);
for (uint i = 0; i < num; i++) {
intervalIDs[i] = _intervalIDs[i];
}
}
}
function _begin(List storage list, bytes32 indexNode) constant internal returns (uint) {
return _getBegin(list.beginIndex.getNodeValue(indexNode));
}
function _end(List storage list, bytes32 indexNode) constant internal returns (uint) {
return _getEnd(list.endIndex.getNodeValue(indexNode));
}
function _next(List storage list, bytes32 cur) constant internal returns (bytes32) {
return list.beginIndex.getNextNode(cur);
}
function _previous(List storage list, bytes32 cur) constant internal returns (bytes32) {
return list.endIndex.getPreviousNode(cur);
}
function _getBeginIndexKey(uint begin) constant internal returns (int) {
return int(begin - 0x8000000000000000000000000000000000000000000000000000000000000000);
}
function _getEndIndexKey(uint end) constant internal returns (int) {
return int(end - 0x8000000000000000000000000000000000000000000000000000000000000000);
}
function _getBegin(int beginIndexKey) constant internal returns (uint) {
return uint(beginIndexKey) + 0x8000000000000000000000000000000000000000000000000000000000000000;
}
function _getEnd(int endIndexKey) constant internal returns (uint) {
return uint(endIndexKey) + 0x8000000000000000000000000000000000000000000000000000000000000000;
}
}