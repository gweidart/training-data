pragma solidity 0.4.18;
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
library SortedDoublyLL {
using SafeMath for uint256;
struct Node {
uint256 key;
address nextId;
address prevId;
}
struct Data {
address head;
address tail;
uint256 maxSize;
uint256 size;
mapping (address => Node) nodes;
}
function setMaxSize(Data storage self, uint256 _size) public {
require(_size > self.maxSize);
self.maxSize = _size;
}
function insert(Data storage self, address _id, uint256 _key, address _prevId, address _nextId) public {
require(!isFull(self));
require(!contains(self, _id));
require(_id != address(0));
require(_key > 0);
address prevId = _prevId;
address nextId = _nextId;
if (!validInsertPosition(self, _key, prevId, nextId)) {
(prevId, nextId) = findInsertPosition(self, _key, prevId, nextId);
}
self.nodes[_id].key = _key;
if (prevId == address(0) && nextId == address(0)) {
self.head = _id;
self.tail = _id;
} else if (prevId == address(0)) {
self.nodes[_id].nextId = self.head;
self.nodes[self.head].prevId = _id;
self.head = _id;
} else if (nextId == address(0)) {
self.nodes[_id].prevId = self.tail;
self.nodes[self.tail].nextId = _id;
self.tail = _id;
} else {
self.nodes[_id].nextId = nextId;
self.nodes[_id].prevId = prevId;
self.nodes[prevId].nextId = _id;
self.nodes[nextId].prevId = _id;
}
self.size = self.size.add(1);
}
function remove(Data storage self, address _id) public {
require(contains(self, _id));
if (self.size > 1) {
if (_id == self.head) {
self.head = self.nodes[_id].nextId;
self.nodes[self.head].prevId = address(0);
} else if (_id == self.tail) {
self.tail = self.nodes[_id].prevId;
self.nodes[self.tail].nextId = address(0);
} else {
self.nodes[self.nodes[_id].prevId].nextId = self.nodes[_id].nextId;
self.nodes[self.nodes[_id].nextId].prevId = self.nodes[_id].prevId;
}
} else {
self.head = address(0);
self.tail = address(0);
}
delete self.nodes[_id];
self.size = self.size.sub(1);
}
function updateKey(Data storage self, address _id, uint256 _newKey, address _prevId, address _nextId) public {
require(contains(self, _id));
remove(self, _id);
if (_newKey > 0) {
insert(self, _id, _newKey, _prevId, _nextId);
}
}
function contains(Data storage self, address _id) public view returns (bool) {
return self.nodes[_id].key > 0;
}
function isFull(Data storage self) public view returns (bool) {
return self.size == self.maxSize;
}
function isEmpty(Data storage self) public view returns (bool) {
return self.size == 0;
}
function getSize(Data storage self) public view returns (uint256) {
return self.size;
}
function getMaxSize(Data storage self) public view returns (uint256) {
return self.maxSize;
}
function getKey(Data storage self, address _id) public view returns (uint256) {
return self.nodes[_id].key;
}
function getFirst(Data storage self) public view returns (address) {
return self.head;
}
function getLast(Data storage self) public view returns (address) {
return self.tail;
}
function getNext(Data storage self, address _id) public view returns (address) {
return self.nodes[_id].nextId;
}
function getPrev(Data storage self, address _id) public view returns (address) {
return self.nodes[_id].prevId;
}
function validInsertPosition(Data storage self, uint256 _key, address _prevId, address _nextId) public view returns (bool) {
if (_prevId == address(0) && _nextId == address(0)) {
return isEmpty(self);
} else if (_prevId == address(0)) {
return self.head == _nextId && _key >= self.nodes[_nextId].key;
} else if (_nextId == address(0)) {
return self.tail == _prevId && _key <= self.nodes[_prevId].key;
} else {
return self.nodes[_prevId].nextId == _nextId && self.nodes[_prevId].key >= _key && _key >= self.nodes[_nextId].key;
}
}
function descendList(Data storage self, uint256 _key, address _startId) private view returns (address, address) {
if (self.head == _startId && _key >= self.nodes[_startId].key) {
return (address(0), _startId);
}
address prevId = _startId;
address nextId = self.nodes[prevId].nextId;
while (prevId != address(0) && !validInsertPosition(self, _key, prevId, nextId)) {
prevId = self.nodes[prevId].nextId;
nextId = self.nodes[prevId].nextId;
}
return (prevId, nextId);
}
function ascendList(Data storage self, uint256 _key, address _startId) private view returns (address, address) {
if (self.tail == _startId && _key <= self.nodes[_startId].key) {
return (_startId, address(0));
}
address nextId = _startId;
address prevId = self.nodes[nextId].prevId;
while (nextId != address(0) && !validInsertPosition(self, _key, prevId, nextId)) {
nextId = self.nodes[nextId].prevId;
prevId = self.nodes[nextId].prevId;
}
return (prevId, nextId);
}
function findInsertPosition(Data storage self, uint256 _key, address _prevId, address _nextId) private view returns (address, address) {
address prevId = _prevId;
address nextId = _nextId;
if (prevId != address(0)) {
if (!contains(self, prevId) || _key > self.nodes[prevId].key) {
prevId = address(0);
}
}
if (nextId != address(0)) {
if (!contains(self, nextId) || _key < self.nodes[nextId].key) {
nextId = address(0);
}
}
if (prevId == address(0) && nextId == address(0)) {
return descendList(self, _key, self.head);
} else if (prevId == address(0)) {
return ascendList(self, _key, nextId);
} else if (nextId == address(0)) {
return descendList(self, _key, prevId);
} else {
return descendList(self, _key, prevId);
}
}
}