pragma solidity ^0.4.19;
contract exToken {
function transfer(address, uint256) pure public returns (bool) {  }
function balanceOf(address) pure public returns (uint256) {  }
}
contract TeamTimeLock {
uint constant public year = 2023;
address public owner;
uint public lockTime = 1782 days;
uint public startTime;
uint256 lockedAmount;
exToken public tokenAddress;
modifier onlyBy(address _account){
require(msg.sender == _account);
_;
}
function () public payable {}
function TeamTimeLock() public {
owner = 0xd0b4b0165320f9Eeaf683174A5A3Ac93309c37d7;
startTime = now;
tokenAddress = exToken(0x08d32b0da63e2C3bcF8019c9c5d849d7a9d791e6);
}
function withdraw() onlyBy(owner) public {
lockedAmount = tokenAddress.balanceOf(this);
require((startTime + lockTime) < now);
tokenAddress.transfer(owner, lockedAmount);
}
}