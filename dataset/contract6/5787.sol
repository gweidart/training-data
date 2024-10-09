pragma solidity ^0.4.21;
contract Lottery
{
event Bid(address sender);
function bid() public
{
emit Bid(msg.sender);
}
}