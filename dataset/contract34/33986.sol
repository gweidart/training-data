pragma solidity ^0.4.17;
contract Ownable {
address public owner;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
function Ownable() internal {
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
contract ERC20Basic {
function balanceOf(address who) public constant returns (uint256);
function transfer(address to, uint256 value) public returns (bool);
}
library SafeERC20 {
function safeTransfer(ERC20Basic token, address to, uint256 value) internal {
assert(token.transfer(to, value));
}
}
contract TokenTimelock is Ownable{
using SafeERC20 for ERC20Basic;
ERC20Basic public token;
uint64 public releaseTime;
function TokenTimelock(ERC20Basic _token, uint64 _releaseTime) public {
require(_releaseTime > now);
token = _token;
owner = msg.sender;
releaseTime = _releaseTime;
}
function claim() public onlyOwner {
require(now >= releaseTime);
uint256 amount = token.balanceOf(this);
require(amount > 0);
token.safeTransfer(owner, amount);
}
}