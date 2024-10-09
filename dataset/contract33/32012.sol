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
function JustBalance(address _etherdelta) public {
etherdelta = EtherDelta(_etherdelta);
}
function newEtherdelta(address _etherdelta) public onlyOwner returns (bool) {
etherdelta = EtherDelta(_etherdelta);
return true;
}
function balanceOfEther(address user) public constant returns (uint256, uint256) {
uint256 edBalance = etherdelta.balanceOf(address(0), user);
return (user.balance, edBalance);
}
function balanceOfToken(address token, address user) public constant returns (uint256, uint256) {
uint256 walletTokenBalance = Token(token).balanceOf(user);
uint256 etherdeltaTokenBalance = etherdelta.balanceOf(token, user);
return (walletTokenBalance, etherdeltaTokenBalance);
}
}