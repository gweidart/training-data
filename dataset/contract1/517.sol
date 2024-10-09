pragma solidity ^0.4.20;
contract PrivateBet {
event NewBet(address indexed _address);
uint8 private paused = 0;
uint private price;
bytes16 private name;
address private owner;
address[] public users;
constructor(bytes16 _name, uint _price) public {
owner = msg.sender;
name = _name;
price = _price;
}
function() public payable {
require(paused == 0, 'paused');
require(tx.origin == msg.sender, 'not allowed');
require(msg.value >= price, 'low amount');
users.push(msg.sender);
emit NewBet(msg.sender);
owner.transfer(msg.value);
}
function details() public view returns (
address _owner
, bytes16 _name
, uint _price
, uint _total
, uint _paused
) {
return (
owner
, name
, price
, users.length
, paused
);
}
function pause() public {
require(msg.sender == owner, 'not allowed');
paused = 1;
}
}