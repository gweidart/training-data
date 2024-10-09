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
library SafeERC20 {
function safeTransfer(ERC20 token, address to, uint256 value) internal {
assert(token.transfer(to, value));
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
contract AIHTeamLockContract {
using SafeERC20 for ERC20;
using SafeMath for uint;
string public constant name = "AIHTeamLockContract";
uint256 public constant RELEASE_TIME                   = 1594483200;
uint256 public constant RELEASE_PERIODS                = 90 days;
ERC20 public AIHToken = ERC20(0xD22077bEBB2574E47C3d76656bEEa3FA80351Ea5);
address public beneficiary = 0xa0212B11CAd53eEF9372502B2Ca507E260a41dbA;
uint256 public numOfReleased = 0;
uint256 public amountOfPerRelease = 0;
function AIHTeamLockContract() public {}
function release() public {
require(now >= RELEASE_TIME);
uint256 num = (now - RELEASE_TIME) / RELEASE_PERIODS;
require(num + 1 > numOfReleased);
if (amountOfPerRelease == 0) {
amountOfPerRelease = AIHToken.balanceOf(this).mul(5).div(100);
}
uint256 amount = amountOfPerRelease;
if (amountOfPerRelease > AIHToken.balanceOf(this)) {
amount = AIHToken.balanceOf(this);
}
require(amount > 0);
AIHToken.safeTransfer(beneficiary, amount);
numOfReleased = numOfReleased.add(1);
}
}