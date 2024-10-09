pragma solidity ^0.4.11;
contract AuctionItem {
string public auctionName;
address public owner;
bool auctionEnded = false;
event NewHighestBid(
address newHighBidder,
uint newHighBid,
string squak
);
uint public currentHighestBid = 0;
address public highBidder;
string public squak;
modifier onlyOwner {
require(msg.sender == owner);
_;
}
modifier higherBid {
require(msg.value > currentHighestBid);
_;
}
modifier auctionNotOver {
require(auctionEnded == false);
_;
}
function AuctionItem(string name, uint startingBid) {
auctionName = name;
owner = msg.sender;
currentHighestBid = startingBid;
}
function bid(string _squak) payable higherBid auctionNotOver {
highBidder.transfer(currentHighestBid);
currentHighestBid = msg.value;
highBidder = msg.sender;
squak = _squak;
NewHighestBid(msg.sender, msg.value, _squak);
}
function() payable higherBid auctionNotOver{
highBidder.transfer(currentHighestBid);
currentHighestBid = msg.value;
highBidder = msg.sender;
NewHighestBid(msg.sender, msg.value, '');
}
function endAuction() onlyOwner{
selfdestruct(owner);
auctionEnded = true;
}
}