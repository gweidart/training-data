pragma solidity ^0.4.19;
contract Ownable {
address  owner;
function Ownable() {
owner = msg.sender;
}
}