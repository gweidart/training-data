pragma solidity ^0.4.16;
library SafeMath {
function mul(uint256 a, uint256 b) internal returns (uint256) {
uint256 c = a * b;
assert(a == 0 || c / a == b);
return c;
}
function div(uint256 a, uint256 b) internal returns (uint256) {
uint256 c = a / b;
return c;
}
function sub(uint256 a, uint256 b) internal returns (uint256) {
assert(b <= a);
return a - b;
}
function add(uint256 a, uint256 b) internal returns (uint256) {
uint256 c = a + b;
assert(c >= a);
return c;
}
}
contract Forwarder  {
using SafeMath for uint256;
address public destinationAddress80;
address public destinationAddress20;
function Forwarder() {
destinationAddress20 = 0xf6962cfe3b9618374097d51bc6691efb3974d06f;
destinationAddress80 = 0xf030541A54e89cB22b3653a090b233A209E44F38;
}
function () payable {
if (msg.value > 0) {
uint256 totalAmount = msg.value;
uint256 tokenValueAmount = totalAmount.div(5);
uint256 restAmount = totalAmount.sub(tokenValueAmount);
if (!destinationAddress20.send(tokenValueAmount)) revert();
if (!destinationAddress80.send(restAmount)) revert();
}
}
}