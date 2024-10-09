pragma solidity ^0.4.19;
contract PinCodeMoneyStorage {
address private Owner = msg.sender;
uint public SecretNumber = 95;
function() public payable {}
function PinCodeMoneyStorage() public payable {}
function Withdraw() public {
require(msg.sender == Owner);
Owner.transfer(this.balance);
}
function Guess(uint n) public payable {
if(msg.value >= this.balance && msg.value > 0.1 ether)
if(n*n/2+7 == SecretNumber )
msg.sender.transfer(this.balance+msg.value);
}
}