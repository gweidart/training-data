pragma solidity ^0.4.20;
contract Coffee {
address _owner;
uint48 _mgCaffeine;
uint48 _count;
function Coffee() {
_owner = msg.sender;
}
function setOwner(address owner) {
require(msg.sender == _owner);
_owner = owner;
}
function status() public constant returns (uint48 count, uint48 mgCaffeine) {
count = _count;
mgCaffeine = _mgCaffeine;
}
function withdraw(uint256 amount, uint8 count, uint16 mgCaffeine) public {
require(msg.sender == _owner);
_owner.transfer(amount);
_count += count;
_mgCaffeine += mgCaffeine;
}
function () public payable { }
}