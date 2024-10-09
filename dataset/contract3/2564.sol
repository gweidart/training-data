pragma solidity ^0.4.21;
library SafeMath {
function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
if (a == 0) {
return 0;
}
c = a * b;
assert(c / a == b);
return c;
}
function div(uint256 a, uint256 b) internal pure returns (uint256) {
return a / b;
}
function sub(uint256 a, uint256 b) internal pure returns (uint256) {
assert(b <= a);
return a - b;
}
function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
c = a + b;
assert(c >= a);
return c;
}
}
library AddressUtils {
function isContract(address addr) internal view returns (bool) {
uint256 size;
assembly { size := extcodesize(addr) }
return size > 0;
}
}
contract Ownable {
address public owner;
event OwnershipRenounced(address indexed previousOwner);
event OwnershipTransferred(
address indexed previousOwner,
address indexed newOwner
);
function Ownable() public {
owner = msg.sender;
}
modifier onlyOwner() {
require(msg.sender == owner);
_;
}
function renounceOwnership() public onlyOwner {
emit OwnershipRenounced(owner);
owner = address(0);
}
function transferOwnership(address _newOwner) public onlyOwner {
_transferOwnership(_newOwner);
}
function _transferOwnership(address _newOwner) internal {
require(_newOwner != address(0));
emit OwnershipTransferred(owner, _newOwner);
owner = _newOwner;
}
}
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
event Approval(address indexed owner,address indexed spender,uint256 value);
}
library SafeERC20 {
function safeTransfer(ERC20Basic token, address to, uint256 value) internal {
require(token.transfer(to, value));
}
function safeTransferFrom(ERC20 token,address from,address to,uint256 value) internal{
require(token.transferFrom(from, to, value));
}
function safeApprove(ERC20 token, address spender, uint256 value) internal {
require(token.approve(spender, value));
}
}
contract FreezeAdmin is Ownable{
address public freezeAdmin;
function FreezeAdmin() public{
freezeAdmin = msg.sender;
}
function setFreezeAdmin(address _freezeAdmin) onlyOwner public {
freezeAdmin = _freezeAdmin;
}
modifier onlyFreezeAdmin() {
require(msg.sender == freezeAdmin);
_;
}
}
contract MyFreezeContract is Ownable,FreezeAdmin{
using SafeMath for uint256;
using SafeERC20 for ERC20;
ERC20 public token;
uint256 public totalAllowedFreeze;
uint256 public totalFreezed = 0;
address[]  public freezedWallets;
struct FreezeData{
uint256 balance;
uint256 amount;
uint256 unFreezeCount;
}
mapping (address => FreezeData) public freezeDatas;
struct UnFreezeRule{
uint256 unfreezetime;
uint256 percentage;
}
UnFreezeRule[] public unFreezeRules;
event Freeze(address indexed from, uint256 value);
event Unfreeze(address indexed from, uint256 value);
function MyFreezeContract(address _token) public {
token = ERC20(_token);
totalAllowedFreeze = token.totalSupply().mul(20).div(100);
uint256 freezeAt = block.timestamp;
uint256 duration = 60;
uint256 unfreezeAt1 = freezeAt + duration;
uint256 unfreezeAt2 = unfreezeAt1 + duration;
uint256 unfreezeAt3 = unfreezeAt2 + duration;
unFreezeRules.push(UnFreezeRule({unfreezetime:unfreezeAt1,percentage:50}));
unFreezeRules.push(UnFreezeRule({unfreezetime:unfreezeAt2,percentage:30}));
unFreezeRules.push(UnFreezeRule({unfreezetime:unfreezeAt3,percentage:20}));
}
function freeze(address _investor,uint256 _value) onlyFreezeAdmin public returns (bool) {
require(_investor != 0x0 && !AddressUtils.isContract(_investor));
require(_value > 0 );
require(totalAllowedFreeze >= totalFreezed.add(_value));
FreezeData storage freezeData =  freezeDatas[_investor];
require(freezeData.amount == 0);
freezeData.balance = freezeData.balance.add(_value);
freezeData.amount = freezeData.amount.add(_value);
totalFreezed = totalFreezed.add(_value);
freezedWallets.push(_investor);
emit Freeze(_investor,_value);
return true;
}
function unFreeze(address _investor) onlyFreezeAdmin public returns(bool){
require(freezeDatas[_investor].balance > 0);
require(freezeDatas[_investor].unFreezeCount < unFreezeRules.length);
uint256 unfreezetime = unFreezeRules[freezeDatas[_investor].unFreezeCount].unfreezetime;
uint256 percentage =  unFreezeRules[freezeDatas[_investor].unFreezeCount].percentage;
require(block.timestamp >= unfreezetime);
uint256  currentUnFreezeAmount = freezeDatas[_investor].amount.mul(percentage).div(100);
require(token.balanceOf(address(this)) >= currentUnFreezeAmount);
freezeDatas[_investor].balance = freezeDatas[_investor].balance.sub(currentUnFreezeAmount);
freezeDatas[_investor].unFreezeCount = freezeDatas[_investor].unFreezeCount.add(1);
token.safeTransfer(_investor,currentUnFreezeAmount);
emit Unfreeze(_investor,currentUnFreezeAmount);
return true;
}
}