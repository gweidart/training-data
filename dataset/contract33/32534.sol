pragma solidity ^0.4.15;
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
contract PricingStrategy {
uint public presaleMaxValue = 0;
function isPricingStrategy() external constant returns (bool) {
return true;
}
function getPresaleMaxValue() public constant returns (uint) {
return presaleMaxValue;
}
function isPresaleFull(uint weiRaised) public constant returns (bool);
function getAmountOfTokens(uint value, uint weiRaised) public constant returns (uint tokensAmount);
}
contract AlgoryPricingStrategy is PricingStrategy, Ownable {
using SafeMath for uint;
struct Tranche {
uint amount;
uint rate;
}
Tranche[4] public tranches;
uint public trancheCount = 4;
function AlgoryPricingStrategy() {
tranches[0].amount = 0;
tranches[0].rate = 1200;
tranches[1].amount = 10000 ether;
tranches[1].rate = 1100;
tranches[2].amount = 24000 ether;
tranches[2].rate = 1050;
tranches[3].amount = 40000 ether;
tranches[3].rate = 1000;
trancheCount = tranches.length;
presaleMaxValue = 300 ether;
}
function() public payable {
revert();
}
function getTranche(uint n) public constant returns (uint amount, uint rate) {
require(n < trancheCount);
return (tranches[n].amount, tranches[n].rate);
}
function isPresaleFull(uint presaleWeiRaised) public constant returns (bool) {
return presaleWeiRaised > tranches[1].amount;
}
function getCurrentRate(uint weiRaised) public constant returns (uint) {
return getCurrentTranche(weiRaised).rate;
}
function getAmountOfTokens(uint value, uint weiRaised) public constant returns (uint tokensAmount) {
require(value > 0);
uint rate = getCurrentRate(weiRaised);
return value.mul(rate);
}
function getCurrentTranche(uint weiRaised) private constant returns (Tranche) {
for(uint i=1; i < tranches.length; i++) {
if(weiRaised <= tranches[i].amount) {
return tranches[i-1];
}
}
return tranches[tranches.length-1];
}
}