pragma solidity ^0.4.18;
contract IterableSet {
struct Element {
uint256 value;
uint256 next;
uint256 previous;
}
mapping(uint => Element) elements;
uint256 public first;
uint256 public last;
uint256 public size;
function add(uint256 value) public {
if (!contains(value)) {
size += 1;
Element memory element = Element({
value: value,
next: first,
previous: value
});
first = value;
if (size == 1) {
last = value;
} else {
elements[element.next].previous = value;
}
elements[value] = element;
}
}
function remove(uint256 value) public {
if (contains(value)) {
Element storage element = elements[value];
if (first == value) {
first = element.next;
} else {
elements[element.previous].next = element.next;
}
if (last == value) {
last = element.previous;
} else {
elements[element.next].previous = element.previous;
}
size -= 1;
delete elements[value];
}
}
function contains(uint256 value) public view returns (bool) {
return size > 0 && (first == value || last == value || elements[value].next != 0 || elements[value].previous != 0);
}
function values() public view returns (uint256[]) {
uint256[] memory result = new uint256[](size);
Element storage position = elements[first];
uint256 i;
for (i = 0; i < size; i++) {
result[i] = position.value;
position = elements[position.next];
}
return result;
}
function next(uint256 value) public view returns (uint256) {
require(contains(value));
require(value != last);
return elements[value].next;
}
function previous(uint256 value) public view returns (uint256) {
require(contains(value));
require(value != first);
return elements[value].previous;
}
}