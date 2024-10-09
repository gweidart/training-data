pragma solidity 0.4.21;
library SafeMath {
function mul(uint256 a, uint256 b) internal pure returns (uint256) {
if (a == 0) {
return 0;
}
uint256 c = a * b;
require(c / a == b);
return c;
}
function div(uint256 a, uint256 b) internal pure returns (uint256) {
require(b > 0);
uint256 c = a / b;
return c;
}
function sub(uint256 a, uint256 b) internal pure returns (uint256) {
require(b <= a);
return a - b;
}
function add(uint256 a, uint256 b) internal pure returns (uint256) {
uint256 c = a + b;
require(c >= a);
return c;
}
}
contract CutdownToken {
function balanceOf(address _who) public view returns (uint256);
function transfer(address _to, uint256 _value) public returns (bool);
function allowance(address _owner, address _spender) public view returns (uint256);
}
contract TokenVesting {
using SafeMath for uint256;
event Released(uint256 amount);
address public beneficiary;
uint256 public cliff;
uint256 public start;
uint256 public duration;
mapping (address => uint256) public released;
function TokenVesting(address _beneficiary, uint256 _start, uint256 _cliffInDays, uint256 _durationInDays) public {
require(_beneficiary != address(0));
require(_cliffInDays <= _durationInDays);
beneficiary = _beneficiary;
duration = _durationInDays * 1 days;
cliff = _start.add(_cliffInDays * 1 days);
start = _start;
}
function release(CutdownToken _token) public {
uint256 unreleased = releasableAmount(_token);
require(unreleased > 0);
released[_token] = released[_token].add(unreleased);
_token.transfer(beneficiary, unreleased);
emit Released(unreleased);
}
function releasableAmount(CutdownToken _token) public view returns (uint256) {
return vestedAmount(_token).sub(released[_token]);
}
function vestedAmount(CutdownToken _token) public view returns (uint256) {
uint256 currentBalance = _token.balanceOf(address(this));
uint256 totalBalance = currentBalance.add(released[_token]);
if (now < cliff) {
return 0;
} else if (now >= start.add(duration)) {
return totalBalance;
} else {
return totalBalance.mul(now.sub(start)).div(duration);
}
}
}