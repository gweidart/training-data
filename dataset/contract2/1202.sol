pragma solidity 0.4.19;
contract ERC20Basic {
uint256 public totalSupply;
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
function safeTransfer(ERC20Basic token, address to, uint256 value) internal {
assert(token.transfer(to, value));
}
function safeTransferFrom(ERC20 token, address from, address to, uint256 value) internal {
assert(token.transferFrom(from, to, value));
}
function safeApprove(ERC20 token, address spender, uint256 value) internal {
assert(token.approve(spender, value));
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
contract TokenVesting is Ownable {
using SafeMath for uint256;
using SafeERC20 for ERC20Basic;
event Released(uint256 amount);
event Revoked();
address public beneficiary;
uint256 public cliff;
uint256 public start;
uint256 public duration;
bool public revocable;
mapping (address => uint256) public released;
mapping (address => bool) public revoked;
function TokenVesting(address _beneficiary, uint256 _start, uint256 _cliff, uint256 _duration, bool _revocable) public {
require(_beneficiary != address(0));
require(_cliff <= _duration);
beneficiary = _beneficiary;
revocable = _revocable;
duration = _duration;
cliff = _start.add(_cliff);
start = _start;
}
function release(ERC20Basic token) public {
uint256 unreleased = releasableAmount(token);
require(unreleased > 0);
released[token] = released[token].add(unreleased);
token.safeTransfer(beneficiary, unreleased);
Released(unreleased);
}
function revoke(ERC20Basic token) public onlyOwner {
require(revocable);
require(!revoked[token]);
uint256 balance = token.balanceOf(this);
uint256 unreleased = releasableAmount(token);
uint256 refund = balance.sub(unreleased);
revoked[token] = true;
token.safeTransfer(owner, refund);
Revoked();
}
function releasableAmount(ERC20Basic token) public view returns (uint256) {
return vestedAmount(token).sub(released[token]);
}
function vestedAmount(ERC20Basic token) public view returns (uint256) {
uint256 currentBalance = token.balanceOf(this);
uint256 totalBalance = currentBalance.add(released[token]);
if (now < cliff) {
return 0;
} else if (now >= start.add(duration) || revoked[token]) {
return totalBalance;
} else {
return totalBalance.mul(now.sub(start)).div(duration);
}
}
}
contract PeriodicTokenVesting is TokenVesting {
address public unreleasedHolder;
uint256 public periods;
function PeriodicTokenVesting(
address _beneficiary,
uint256 _start,
uint256 _cliff,
uint256 _duration,
uint256 _periods,
bool _revocable,
address _unreleasedHolder
)
public TokenVesting(_beneficiary, _start, _cliff, _duration, _revocable)
{
require(_revocable == false || _unreleasedHolder != address(0));
periods = _periods;
unreleasedHolder = _unreleasedHolder;
}
function vestedAmount(ERC20Basic token) public view returns (uint256) {
uint256 currentBalance = token.balanceOf(this);
uint256 totalBalance = currentBalance.add(released[token]);
if (now < cliff) {
return 0;
} else if (now >= start.add(duration * periods) || revoked[token]) {
return totalBalance;
} else {
uint256 periodTokens = totalBalance.div(periods);
uint256 periodsOver = now.sub(start).div(duration);
if (periodsOver >= periods) {
return totalBalance;
}
return periodTokens.mul(periodsOver);
}
}
function revoke(ERC20Basic token) public onlyOwner {
require(revocable);
require(!revoked[token]);
uint256 balance = token.balanceOf(this);
uint256 unreleased = releasableAmount(token);
uint256 refund = balance.sub(unreleased);
revoked[token] = true;
token.safeTransfer(unreleasedHolder, refund);
Revoked();
}
}
contract LinaAllocation is Ownable {
using SafeERC20 for ERC20Basic;
using SafeMath for uint256;
address[] public vestings;
event VestingCreated(
address _vesting,
address _beneficiary,
uint256 _start,
uint256 _cliff,
uint256 _duration,
uint256 _periods,
bool _revocable
);
event VestingRevoked(address _vesting);
function LinaAllocation(
address _beneficiary,
uint256 _startingAt
) public {
require(_beneficiary != address(0) && _startingAt > 0);
initVesting(_beneficiary, _startingAt);
}
function initVesting(
address _beneficiary,
uint256 _startingAt
) public onlyOwner {
createVesting(
_beneficiary,
_startingAt,
0,
2629746,
120,
true,
msg.sender
);
}
function createVesting(
address _beneficiary, uint256 _start, uint256 _cliff, uint256 _duration, uint256 _periods, bool _revocable, address _unreleasedHolder
) public onlyOwner returns (PeriodicTokenVesting) {
PeriodicTokenVesting vesting = new PeriodicTokenVesting(
_beneficiary, _start, _cliff, _duration, _periods, _revocable, _unreleasedHolder
);
vestings.push(vesting);
VestingCreated(vesting, _beneficiary, _start, _cliff, _duration, _periods, _revocable);
return vesting;
}
function revokeVesting(PeriodicTokenVesting _vesting, ERC20Basic token) public onlyOwner() {
_vesting.revoke(token);
VestingRevoked(_vesting);
}
}