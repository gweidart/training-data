pragma solidity ^0.4.18;
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
OwnershipTransferred(owner, newOwner);
owner = newOwner;
}
}
interface iContract {
function transferOwnership(address _newOwner) external;
function owner() external view returns (address);
}
contract OwnerContract is Ownable {
iContract public ownedContract;
address origOwner;
function setContract(address _contract) public onlyOwner {
require(_contract != address(0));
ownedContract = iContract(_contract);
origOwner = ownedContract.owner();
}
function transferOwnershipBack() public onlyOwner {
ownedContract.transferOwnership(origOwner);
ownedContract = iContract(address(0));
origOwner = address(0);
}
}
interface iReleaseTokenContract {
function releaseWithStage(address _target, address _dest) external returns (bool);
function releaseAccount(address _target) external returns (bool);
function transferAndFreeze(address _target, uint256 _value, uint256 _frozenEndTime, uint256 _releasePeriod) external returns (bool);
function freeze(address _target, uint256 _value, uint256 _frozenEndTime, uint256 _releasePeriod) external returns (bool);
function releaseOldBalanceOf(address _target) external returns (bool);
function releaseByStage(address _target) external returns (bool);
}
contract ReleaseTokenToMulti is OwnerContract {
using SafeMath for uint256;
iReleaseTokenContract iReleaseContract;
function setContract(address _contract) onlyOwner public {
super.setContract(_contract);
iReleaseContract = iReleaseTokenContract(_contract);
}
function releaseMultiAccounts(address[] _targets) onlyOwner public returns (bool) {
require(_targets.length != 0);
bool res = false;
uint256 i = 0;
while (i < _targets.length) {
res = iReleaseContract.releaseAccount(_targets[i]) || res;
i = i.add(1);
}
return res;
}
function releaseMultiWithStage(address[] _targets, address[] _dests) onlyOwner public returns (bool) {
require(_targets.length != 0);
require(_dests.length != 0);
assert(_targets.length == _dests.length);
bool res = false;
uint256 i = 0;
while (i < _targets.length) {
require(_targets[i] != address(0));
require(_dests[i] != address(0));
res = iReleaseContract.releaseWithStage(_targets[i], _dests[i]) || res;
i = i.add(1);
}
return res;
}
function freezeMulti(address[] _targets, uint256[] _values, uint256[] _frozenEndTimes, uint256[] _releasePeriods) onlyOwner public returns (bool) {
require(_targets.length != 0);
require(_values.length != 0);
require(_frozenEndTimes.length != 0);
require(_releasePeriods.length != 0);
require(_targets.length == _values.length && _values.length == _frozenEndTimes.length && _frozenEndTimes.length == _releasePeriods.length);
bool res = true;
for (uint256 i = 0; i < _targets.length; i = i.add(1)) {
require(_targets[i] != address(0));
res = iReleaseContract.freeze(_targets[i], _values[i], _frozenEndTimes[i], _releasePeriods[i]) && res;
}
return res;
}
function transferAndFreezeMulti(address[] _targets, uint256[] _values, uint256[] _frozenEndTimes, uint256[] _releasePeriods) onlyOwner public returns (bool) {
require(_targets.length != 0);
require(_values.length != 0);
require(_frozenEndTimes.length != 0);
require(_releasePeriods.length != 0);
require(_targets.length == _values.length && _values.length == _frozenEndTimes.length && _frozenEndTimes.length == _releasePeriods.length);
bool res = true;
for (uint256 i = 0; i < _targets.length; i = i.add(1)) {
require(_targets[i] != address(0));
res = iReleaseContract.transferAndFreeze(_targets[i], _values[i], _frozenEndTimes[i], _releasePeriods[i]) && res;
}
return res;
}
function releaseAllOldBalanceOf(address[] _targets) onlyOwner public returns (bool) {
require(_targets.length != 0);
bool res = true;
for (uint256 i = 0; i < _targets.length; i = i.add(1)) {
require(_targets[i] != address(0));
res = iReleaseContract.releaseOldBalanceOf(_targets[i]) && res;
}
return res;
}
function releaseMultiByStage(address[] _targets) onlyOwner public returns (bool) {
require(_targets.length != 0);
bool res = false;
for (uint256 i = 0; i < _targets.length; i = i.add(1)) {
require(_targets[i] != address(0));
res = iReleaseContract.releaseByStage(_targets[i]) || res;
}
return res;
}
}