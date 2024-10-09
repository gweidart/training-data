pragma solidity ^0.4.24;
interface itoken {
function approveAndCall(
address _spender,
uint256 _value,
bytes _extraData
) external returns (bool);
}
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
contract Ownable {
address public owner;
event OwnershipRenounced(address indexed previousOwner);
event OwnershipTransferred(
address indexed previousOwner,
address indexed newOwner
);
constructor() public {
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
contract Claimable is Ownable {
address public pendingOwner;
modifier onlyPendingOwner() {
require(msg.sender == pendingOwner);
_;
}
function transferOwnership(address newOwner) public onlyOwner {
pendingOwner = newOwner;
}
function claimOwnership() public onlyPendingOwner {
emit OwnershipTransferred(owner, pendingOwner);
owner = pendingOwner;
pendingOwner = address(0);
}
}
contract FlyDropToken is Claimable {
using SafeMath for uint256;
ERC20 internal erc20tk;
bytes[] internal approveRecords;
event ReceiveApproval(
address _from,
uint256 _value,
address _token,
bytes _extraData
);
function receiveApproval(
address _from,
uint256 _value,
address _token,
bytes _extraData
) public {
erc20tk = ERC20(_token);
require(erc20tk.transferFrom(_from, this, _value));
approveRecords.push(_extraData);
emit ReceiveApproval(_from, _value, _token, _extraData);
}
function multiSend(
address[] _destAddrs,
uint256[] _values
) public onlyOwner returns (uint256) {
require(_destAddrs.length == _values.length);
uint256 i = 0;
for (; i < _destAddrs.length; i = i.add(1)) {
if (!erc20tk.transfer(_destAddrs[i], _values[i])) {
break;
}
}
return (i);
}
function multiSendFrom(
address _from,
address[] _destAddrs,
uint256[] _values
) public onlyOwner returns (uint256) {
require(_destAddrs.length == _values.length);
uint256 i = 0;
for (; i < _destAddrs.length; i = i.add(1)) {
if (!erc20tk.transferFrom(_from, _destAddrs[i], _values[i])) {
break;
}
}
return (i);
}
function getApproveRecord(uint _ind) public view onlyOwner returns (bytes) {
require(_ind < approveRecords.length);
return approveRecords[_ind];
}
}
contract DelayedClaimable is Claimable {
uint256 public end;
uint256 public start;
function setLimits(uint256 _start, uint256 _end) public onlyOwner {
require(_start <= _end);
end = _end;
start = _start;
}
function claimOwnership() public onlyPendingOwner {
require((block.number <= end) && (block.number >= start));
emit OwnershipTransferred(owner, pendingOwner);
owner = pendingOwner;
pendingOwner = address(0);
end = 0;
}
}
contract FlyDropTokenMgr is DelayedClaimable {
using SafeMath for uint256;
address[] dropTokenAddrs;
FlyDropToken currentDropTokenContract;
function prepare(
uint256 _rand,
address _from,
address _token,
uint256 _value,
bytes _extraData
) public onlyOwner returns (bool) {
require(_token != address(0));
require(_from != address(0));
require(_rand > 0);
if (ERC20(_token).allowance(_from, this) < _value) {
return false;
}
if (_rand > dropTokenAddrs.length) {
FlyDropToken dropTokenContract = new FlyDropToken();
dropTokenAddrs.push(address(dropTokenContract));
currentDropTokenContract = dropTokenContract;
} else {
currentDropTokenContract = FlyDropToken(
dropTokenAddrs[_rand.sub(1)]
);
}
ERC20(_token).transferFrom(_from, this, _value);
return
itoken(_token).approveAndCall(
currentDropTokenContract,
_value,
_extraData
);
}
function flyDrop(
address[] _destAddrs,
uint256[] _values
) public onlyOwner returns (uint256) {
require(address(currentDropTokenContract) != address(0));
return currentDropTokenContract.multiSend(_destAddrs, _values);
}
}
contract ERC20Basic {
function totalSupply() public view returns (uint256);
function balanceOf(address who) public view returns (uint256);
function transfer(address to, uint256 value) public returns (bool);
event Transfer(address indexed from, address indexed to, uint256 value);
}
contract ERC20 is ERC20Basic {
function allowance(
address owner,
address spender
) public view returns (uint256);
function transferFrom(
address from,
address to,
uint256 value
) public returns (bool);
function approve(address spender, uint256 value) public returns (bool);
event Approval(
address indexed owner,
address indexed spender,
uint256 value
);
}