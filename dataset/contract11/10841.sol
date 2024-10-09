pragma solidity ^0.4.18;
contract ERC20Basic {
function totalSupply() public view returns (uint256);
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
contract TOSERC20  is ERC20 {
function lockBalanceOf(address who) public view returns (uint256);
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
library SafeMath {
function mul(uint256 a, uint256 b) internal pure returns (uint256) {
uint256 c = a * b;
assert(a == 0 || c / a == b);
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
contract TosTeamLockContract {
using SafeERC20 for TOSERC20;
using SafeMath for uint;
string public constant name = "TosTeamLockContract";
uint256 public constant RELEASE_TIME                   = 1623254400;
uint256 public constant RELEASE_PERIODS                = 180 days;
TOSERC20 public tosToken = TOSERC20(0xFb5a551374B656C6e39787B1D3A03fEAb7f3a98E);
address public beneficiary = 0xA24cB9920d882e084Cc29304d1f9c80D288F8054;
uint256 public numOfReleased = 0;
function TosTeamLockContract() public {}
function release() public {
require(now >= RELEASE_TIME);
uint256 num = (now - RELEASE_TIME) / RELEASE_PERIODS;
require(num + 1 > numOfReleased);
uint256 amount = tosToken.balanceOf(this).mul(30).div(100);
require(amount > 0);
tosToken.safeTransfer(beneficiary, amount);
numOfReleased = numOfReleased.add(1);
}
}