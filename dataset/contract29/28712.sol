pragma solidity ^0.4.18;
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
contract ERC20Interface {
function balanceOf(address _owner) public constant returns (uint balance) {}
function transfer(address _to, uint _value) public returns (bool success) {}
function transferFrom(address _from, address _to, uint _value) public returns (bool success) {}
}
contract Exchanger {
using SafeMath for uint;
ERC20Interface dai = ERC20Interface(0x89d24a6b4ccb1b6faa2625fe562bdd9a23260359);
ERC20Interface usdt = ERC20Interface(0xdac17f958d2ee523a2206206994597c13d831ec7);
function getDAI(uint _amountInDollars) public returns (bool) {
usdt.transferFrom(msg.sender, this, _amountInDollars * (10 ** 6));
dai.transfer(msg.sender, _amountInDollars.mul(((10 ** 18))));
return true;
}
function getUSDT(uint _amountInDollars) public returns (bool) {
dai.transferFrom(msg.sender, this, _amountInDollars * (10 ** 18));
usdt.transfer(msg.sender, _amountInDollars.mul(((10 ** 6))));
return true;
}
}