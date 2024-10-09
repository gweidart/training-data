pragma solidity ^0.4.24;
contract owned {
address public owner;
function owned() {
owner = msg.sender;
}
modifier onlyOwner {
require(msg.sender == owner);
_;
}
function transferOwnership(address newOwner) onlyOwner {
owner = newOwner;
}
}
contract ERC20Basic {
uint256 public totalSupply;
function balanceOf(address who) public constant returns (uint256);
function transfer(address to, uint256 value) public returns(bool);
event Transfer(address indexed from, address indexed to, uint256 value);
}
contract game is owned{
address public tokenAddress = 0x340e85491c5F581360811d0cE5CC7476c72900Ba;
mapping (address => uint) readyTime;