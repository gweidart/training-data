pragma solidity ^0.4.15;
contract Ownable {
address public owner;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
function Ownable() {
owner = msg.sender;
}
modifier onlyOwner() {
require(msg.sender == owner);
_;
}
function transferOwnership(address newOwner) onlyOwner public {
require(newOwner != address(0));
OwnershipTransferred(owner, newOwner);
owner = newOwner;
}
}
contract HasNoEther is Ownable {
function HasNoEther() payable {
require(msg.value == 0);
}
function() external {
}
function reclaimEther() external onlyOwner {
assert(owner.send(this.balance));
}
}
library SafeMath {
function mul(uint256 a, uint256 b) internal constant returns (uint256) {
uint256 c = a * b;
assert(a == 0 || c / a == b);
return c;
}
function div(uint256 a, uint256 b) internal constant returns (uint256) {
uint256 c = a / b;
return c;
}
function sub(uint256 a, uint256 b) internal constant returns (uint256) {
assert(b <= a);
return a - b;
}
function add(uint256 a, uint256 b) internal constant returns (uint256) {
uint256 c = a + b;
assert(c >= a);
return c;
}
}
contract PricingStrategy is HasNoEther {
using SafeMath for uint;
uint256 public oneTokenInWei;
address public crowdsaleAddress;
function PricingStrategy(address _crowdsale) {
crowdsaleAddress = _crowdsale;
}
modifier onlyCrowdsale() {
require(msg.sender == crowdsaleAddress);
_;
}
function calculatePrice(uint256 _value, uint256 _decimals) public constant returns (uint) {
uint256 multiplier = 10 ** _decimals;
uint256 weiAmount = _value.mul(multiplier);
uint256 tokens = weiAmount.div(oneTokenInWei);
return tokens;
}
function setTokenPriceInWei(uint _oneTokenInWei) onlyCrowdsale public returns (bool) {
oneTokenInWei = _oneTokenInWei;
return true;
}
}