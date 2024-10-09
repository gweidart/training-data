pragma solidity ^0.4.2;
library AddressList {
struct Data {
address head;
address tail;
uint    length;
mapping(address => bool)    isContain;
mapping(address => address) nextOf;
mapping(address => address) prevOf;
}
function first(Data storage _data) constant returns (address)
{ return _data.head; }
function last(Data storage _data) constant returns (address)
{ return _data.tail; }
function contains(Data storage _data, address _item) constant returns (bool)
{ return _data.isContain[_item]; }
function next(Data storage _data, address _item) constant returns (address)
{ return _data.nextOf[_item]; }
function prev(Data storage _data, address _item) constant returns (address)
{ return _data.prevOf[_item]; }
function append(Data storage _data, address _item)
{ append(_data, _item, _data.tail); }
function append(Data storage _data, address _item, address _to) {
if (_data.isContain[_item]) throw;
if (_data.head == 0) {
_data.head = _data.tail = _item;
} else {
if (!_data.isContain[_to]) throw;
var nextTo = _data.nextOf[_to];
if (nextTo != 0) {
_data.prevOf[nextTo] = _item;
} else {
_data.tail = _item;
}
_data.nextOf[_to]    = _item;
_data.prevOf[_item]  = _to;
_data.nextOf[_item]  = nextTo;
}
_data.isContain[_item] = true;
++_data.length;
}
function prepend(Data storage _data, address _item)
{ prepend(_data, _item, _data.head); }
function prepend(Data storage _data, address _item, address _to) {
if (_data.isContain[_item]) throw;
if (_data.head == 0) {
_data.head = _data.tail = _item;
} else {
if (!_data.isContain[_to]) throw;
var prevTo = _data.prevOf[_to];
if (prevTo != 0) {
_data.nextOf[prevTo] = _item;
} else {
_data.head = _item;
}
_data.prevOf[_item]  = prevTo;
_data.nextOf[_item]  = _to;
_data.prevOf[_to]    = _item;
}
_data.isContain[_item] = true;
++_data.length;
}
function remove(Data storage _data, address _item) {
if (!_data.isContain[_item]) throw;
var elemPrev = _data.prevOf[_item];
var elemNext = _data.nextOf[_item];
if (elemPrev != 0) {
_data.nextOf[elemPrev] = elemNext;
} else {
_data.head = elemNext;
}
if (elemNext != 0) {
_data.prevOf[elemNext] = elemPrev;
} else {
_data.tail = elemPrev;
}
_data.isContain[_item] = false;
--_data.length;
}
function replace(Data storage _data, address _from, address _to) {
if (!_data.isContain[_from]) throw;
var elemPrev = _data.prevOf[_from];
var elemNext = _data.nextOf[_from];
if (elemPrev != 0) {
_data.nextOf[elemPrev] = _to;
} else {
_data.head = _to;
}
if (elemNext != 0) {
_data.prevOf[elemNext] = _to;
} else {
_data.tail = _to;
}
_data.prevOf[_to] = elemPrev;
_data.nextOf[_to] = elemNext;
_data.isContain[_from] = false;
}
function swap(Data storage _data, address _a, address _b) {
if (!_data.isContain[_a] || !_data.isContain[_b]) throw;
var prevA = _data.prevOf[_a];
remove(_data, _a);
replace(_data, _b, _a);
if (prevA == 0) {
prepend(_data, _b);
} else {
append(_data, _b, prevA);
}
}
}