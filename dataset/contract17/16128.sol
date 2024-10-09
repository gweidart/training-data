pragma solidity ^0.4.4;
contract Deposit {
address public owner;
function Deposit() public {
owner = msg.sender;
}
function() public payable {
_transter(msg.value);
}
function _transter(uint balance) internal {
owner.transfer(balance);
}
}