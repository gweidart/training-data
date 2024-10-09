pragma solidity ^0.4.13;
contract ERC20Basic {
uint256 public totalSupply;
function balanceOf(address who) public view returns (uint256);
function transfer(address to, uint256 value) public returns (bool);
event Transfer(address indexed from, address indexed to, uint256 value);
}
contract ERC20 is ERC20Basic {
function allowance(address owner, address spender) public view returns (uint256);
function transferFrom(address from, address to, uint256 value) public returns (bool);
function approve(address spender, uint256 value) public returns (bool);
event Approval(address indexed owner, address indexed spender, uint256 value);
}
contract TokenLocker {
address public owner;
ERC20 public token;
function TokenLocker (ERC20 tokenAddr) public {
owner = msg.sender;
token = tokenAddr;
}
function transfer(address dest, uint amount) public returns (bool) {
require(msg.sender == owner);
return token.transfer(dest, amount);
}
}