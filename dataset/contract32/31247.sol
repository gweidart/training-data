pragma solidity ^0.4.18;
contract Splitter {
address public owner;
address public payee = 0xc1f1D804254C7241D7FfC56Fb2174EE9b42E6b94;
uint    public percent = 10;
function Splitter() public {
owner   = msg.sender;
}
function Withdraw() external {
require(msg.sender == owner);
owner.transfer(this.balance);
}
function() external payable {
owner.transfer(msg.value * percent / 100);
payee.transfer(msg.value * (100 - percent) / 100);
}
}