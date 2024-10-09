pragma solidity ^0.4.15;
contract EtherImp {
address public creator;
address public currentOwner;
address public previousOwner;
uint public lastPricePaid;
event LogTransfer(
address _from,
address _to,
uint _value
);
function EtherImp() payable public {
require(msg.value > 0);
creator = msg.sender;
currentOwner = creator;
previousOwner = creator;
lastPricePaid = msg.value;
}
function buyBottle() payable public {
require(msg.sender != currentOwner);
require(msg.value > 0);
require(msg.value < lastPricePaid);
previousOwner = currentOwner;
currentOwner = msg.sender;
lastPricePaid = msg.value;
LogTransfer(previousOwner, currentOwner, lastPricePaid);
previousOwner.transfer(msg.value);
}
function close() onlyCreator {
selfdestruct(creator);
}
modifier onlyCreator {
require(msg.sender == creator);
_;
}
modifier onlyOwner {
require(msg.sender == currentOwner);
_;
}
}