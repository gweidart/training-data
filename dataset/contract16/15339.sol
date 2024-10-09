pragma solidity ^0.4.21;
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
contract ERC20 {
uint256 public totalSupply;
function balanceOf(address who) public view returns (uint256);
function transfer(address to, uint256 value) public returns (bool);
event Transfer(address indexed from, address indexed to, uint256 value);
function allowance(address owner, address spender) public view returns (uint256);
function transferFrom(address from, address to, uint256 value) public returns (bool);
function approve(address spender, uint256 value) public returns (bool);
event Approval(address indexed owner, address indexed spender, uint256 value);
}
library SafeERC20 {
function safeTransfer(ERC20 token, address to, uint256 value) internal {
assert(token.transfer(to, value));
}
function safeTransferFrom(
ERC20 token,
address from,
address to,
uint256 value
)
internal
{
assert(token.transferFrom(from, to, value));
}
function safeApprove(ERC20 token, address spender, uint256 value) internal {
assert(token.approve(spender, value));
}
}
contract TokenTimelock is Ownable {
using SafeERC20 for ERC20;
ERC20 public token;
address public beneficiary;
uint256 public releaseTime;
function TokenTimelock(ERC20 _token, address _beneficiary) public {
token = _token;
beneficiary = _beneficiary;
releaseTime = now + 365 days;
}
function release() public {
require(now >= releaseTime);
uint256 amount = token.balanceOf(this);
require(amount > 0);
token.safeTransfer(beneficiary, amount);
}
function setReleaseTime(uint256 _releaseTime) onlyOwner external {
require(_releaseTime > releaseTime);
releaseTime = _releaseTime;
}
}