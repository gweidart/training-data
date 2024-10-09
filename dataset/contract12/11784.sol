pragma solidity ^0.4.18;
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
library SafeMath {
function mul(uint256 a, uint256 b) internal pure returns (uint256) {
if (a == 0) {
return 0;
}
uint256 c = a * b;
assert(c / a == b);
return c;
}
function div(uint256 a, uint256 b) internal pure returns (uint256) {
uint256 c = a / b;
return c;
}
function sub(uint256 a, uint256 b) internal pure returns (uint256) {
assert(b <= a);
return a - b;
}
function add(uint256 a, uint256 b) internal pure returns (uint256) {
uint256 c = a + b;
assert(c >= a);
return c;
}
}
contract  HandToken {
function totalSupply() public constant returns (uint256 _totalSupply);
function transfer(address _to, uint256 _value) public returns (bool success) ;
function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
function balanceOf(address _owner) view public returns (uint256 balance) ;
}
contract AirDrop is Ownable {
using SafeMath for uint256;
HandToken public token;
address public tokenAddress;
function AirDrop (address addr)  public {
token = HandToken(addr);
require(token.totalSupply() > 0);
tokenAddress = addr;
}
function () public payable {
}
function drop(address[] dstAddress, uint256 value) public onlyOwner {
require(dstAddress.length <= 100);
for (uint256 i = 0; i < dstAddress.length; i++) {
token.transfer(dstAddress[i], value);
}
}
}