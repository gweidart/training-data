pragma solidity ^0.4.15;
contract ELTCoinToken {
function transfer(address to, uint256 value) public returns (bool);
function balanceOf(address who) public constant returns (uint256);
}
contract Ownable {
address public owner;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
function Ownable() {
owner = msg.sender;
}
modifier onlyOwner() {
require(msg.sender == owner);
_;
}
function transferOwnership(address newOwner) onlyOwner public {
require(newOwner != address(0));
OwnershipTransferred(owner, newOwner);
owner = newOwner;
}
}
contract ELTCOINLock is Ownable {
ELTCoinToken public token;
uint256 public endTime;
function ELTCOINLock(address _contractAddress, uint256 _endTime) {
token = ELTCoinToken(_contractAddress);
endTime = _endTime;
}
function hasEnded() public constant returns (bool) {
return now > endTime;
}
function drainRemainingToken () public onlyOwner {
require(hasEnded());
token.transfer(owner, token.balanceOf(this));
}
}