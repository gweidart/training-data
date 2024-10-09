pragma solidity ^0.4.18;
contract DonationForwarder {
address owner;
address redirect;
uint lastPrice;
uint startingPrice = 0.01 ether;
modifier onlyOwner {
require (msg.sender == owner);
_;
}
event RedirectChanged (
address _newRedirect,
uint _lastPrice
);
function DonationForwarder() public {
owner = msg.sender;
redirect = owner;
lastPrice = startingPrice;
}
function () payable public {
redirect.transfer(msg.value);
}
function buyRedirect() payable public {
buyRedirectFor(msg.sender);
}
function buyRedirectFor(address newRedirect) payable public {
require(msg.value > lastPrice);
require(newRedirect != redirect);
owner.transfer(msg.value);
redirect = newRedirect;
lastPrice = msg.value;
RedirectChanged(newRedirect, lastPrice);
}
function kill() public onlyOwner {
selfdestruct(owner);
}
}