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
contract Claimable is Ownable {
address public pendingOwner;
modifier onlyPendingOwner() {
require(msg.sender == pendingOwner);
_;
}
function transferOwnership(address newOwner) onlyOwner public {
pendingOwner = newOwner;
}
function claimOwnership() onlyPendingOwner public {
OwnershipTransferred(owner, pendingOwner);
owner = pendingOwner;
pendingOwner = address(0);
}
}
contract Pausable is Ownable {
event Pause();
event Unpause();
bool public paused = false;
modifier whenNotPaused() {
require(!paused);
_;
}
modifier whenPaused() {
require(paused);
_;
}
function pause() onlyOwner whenNotPaused public {
paused = true;
Pause();
}
function unpause() onlyOwner whenPaused public {
paused = false;
Unpause();
}
}
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
contract CanReclaimToken is Ownable {
using SafeERC20 for ERC20Basic;
function reclaimToken(ERC20Basic token) external onlyOwner {
uint256 balance = token.balanceOf(this);
token.safeTransfer(owner, balance);
}
}
interface ERC721 {
function supportsInterface(bytes4 _interfaceID) external pure returns (bool);
function ownerOf(uint256 _deedId) external view returns (address _owner);
function countOfDeeds() public view returns (uint256 _count);
function countOfDeedsByOwner(address _owner) public view returns (uint256 _count);
function deedOfOwnerByIndex(address _owner, uint256 _index) external view returns (uint256 _deedId);
event Transfer(address indexed from, address indexed to, uint256 indexed deedId);
event Approval(address indexed owner, address indexed approved, uint256 indexed deedId);
function approve(address _to, uint256 _deedId) external;
function takeOwnership(uint256 _deedId) external;
function transfer(address _to, uint256 _deedId) external;
}
interface ERC721Metadata {
function name() public pure returns (string _deedName);
function symbol() public pure returns (string _deedSymbol);