pragma solidity ^0.4.21;
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
emit OwnershipTransferred(owner, newOwner);
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
contract Destroyable is Ownable{
function destroy() public onlyOwner{
selfdestruct(owner);
}
}
interface Token {
function transfer(address _to, uint256 _value) external returns (bool);
function balanceOf(address who) view external returns (uint256);
}
contract TokenVault is Ownable, Destroyable {
using SafeMath for uint256;
Token public token;
function TokenVault(address _token) public{
require(_token != address(0));
token = Token(_token);
}
function Balance() view public returns (uint256 _balance) {
return token.balanceOf(address(this));
}
function BalanceEth() view public returns (uint256 _balance) {
return token.balanceOf(address(this)) / 1 ether;
}
function transferTokens(address _to, uint256 amount) public onlyOwner {
token.transfer(_to, amount);
}
function flushTokens() public onlyOwner {
token.transfer(owner, token.balanceOf(address(this)));
}
function destroy() public onlyOwner {
token.transfer(owner, token.balanceOf(address(this)));
selfdestruct(owner);
}
}