pragma solidity ^0.4.11;
library Math {
function max64(uint64 a, uint64 b) internal constant returns (uint64) {
return a >= b ? a : b;
}
function min64(uint64 a, uint64 b) internal constant returns (uint64) {
return a < b ? a : b;
}
function max256(uint256 a, uint256 b) internal constant returns (uint256) {
return a >= b ? a : b;
}
function min256(uint256 a, uint256 b) internal constant returns (uint256) {
return a < b ? a : b;
}
}
contract ERC20Basic {
uint256 public totalSupply;
function balanceOf(address who) constant returns (uint256);
function transfer(address to, uint256 value) returns (bool);
event Transfer(address indexed from, address indexed to, uint256 value);
}
contract ERC20 is ERC20Basic {
function allowance(address owner, address spender) constant returns (uint256);
function transferFrom(address from, address to, uint256 value) returns (bool);
function approve(address spender, uint256 value) returns (bool);
event Approval(address indexed owner, address indexed spender, uint256 value);
}
contract Ownable {
address public owner;
function Ownable() {
owner = msg.sender;
}
modifier onlyOwner() {
require(msg.sender == owner);
_;
}
function transferOwnership(address newOwner) onlyOwner {
if (newOwner != address(0)) {
owner = newOwner;
}
}
}
contract TokenTransferDelegate is Ownable {
using Math for uint;
uint lastVersion = 0;
address[] public versions;
mapping (address => uint) public versioned;
modifier isVersioned(address addr) {
if (versioned[addr] == 0) {
revert();
}
_;
}
modifier notVersioned(address addr) {
if (versioned[addr] > 0) {
revert();
}
_;
}
event VersionAdded(address indexed addr, uint version);
event VersionRemoved(address indexed addr, uint version);
function addVersion(address addr)
onlyOwner
notVersioned(addr)
{
versioned[addr] = ++lastVersion;
versions.push(addr);
VersionAdded(addr, lastVersion);
}
function removeVersion(address addr)
onlyOwner
isVersioned(addr)
{
uint version = versioned[addr];
delete versioned[addr];
uint length = versions.length;
for (uint i = 0; i < length; i++) {
if (versions[i] == addr) {
versions[i] = versions[length - 1];
versions.length -= 1;
break;
}
}
VersionRemoved(addr, version);
}
function getSpendable(
address tokenAddress,
address _owner
)
isVersioned(msg.sender)
constant
returns (uint) {
var token = ERC20(tokenAddress);
return token
.allowance(_owner, address(this))
.min256(token.balanceOf(_owner));
}
function transferToken(
address token,
address from,
address to,
uint value)
isVersioned(msg.sender)
returns (bool) {
return ERC20(token).transferFrom(from, to, value);
}
function getVersions()
constant
returns (address[]) {
return versions;
}
}