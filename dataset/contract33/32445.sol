pragma solidity ^0.4.15;
contract Ownable {
address public owner;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
function Ownable() public {
owner = msg.sender;
}
modifier onlyOwner() {
require(msg.sender == owner);
_;
}
function transferOwnership(address newOwner) public onlyOwner {
require(newOwner != address(0));
OwnershipTransferred(owner, newOwner);
owner = newOwner;
}
}
contract EtherDelta {
function balanceOf(address token, address user) public constant returns (uint256);
}
contract Token {
function balanceOf(address user) public constant returns (uint256);
}
contract JustBalance is Ownable {
EtherDelta public etherdelta;
function JustBalance(address _etherdelta) {
etherdelta = EtherDelta(_etherdelta);
}
function newEtherdelta(address _etherdelta) public onlyOwner returns (bool) {
etherdelta = EtherDelta(_etherdelta);
return true;
}
function balanceOf(address token, address user) constant returns (uint256, uint256) {
uint256 walletBalance = token == 0 ? user.balance : Token(token).balanceOf(user);
uint256 edBalance = etherdelta.balanceOf(token, user);
return (walletBalance, edBalance);
}
}