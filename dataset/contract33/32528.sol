pragma solidity ^0.4.15;
library SafeMath {
function mul(uint256 a, uint256 b) internal constant returns (uint256) {
uint256 c = a * b;
assert(a == 0 || c / a == b);
return c;
}
function div(uint256 a, uint256 b) internal constant returns (uint256) {
uint256 c = a / b;
return c;
}
function sub(uint256 a, uint256 b) internal constant returns (uint256) {
assert(b <= a);
return a - b;
}
function add(uint256 a, uint256 b) internal constant returns (uint256) {
uint256 c = a + b;
assert(c >= a);
return c;
}
}
contract Ownable {
address public owner;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
function Ownable() {
owner = msg.sender;
}
modifier onlyOwner() {
require(msg.sender == owner);
_;
}
function transferOwnership(address newOwner) onlyOwner public {
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
contract ERC20Basic {
uint256 public totalSupply;
function balanceOf(address who) public constant returns (uint256);
function transfer(address to, uint256 value) public returns (bool);
event Transfer(address indexed from, address indexed to, uint256 value);
}
contract ERC20 is ERC20Basic {
function allowance(address owner, address spender) public constant returns (uint256);
function transferFrom(address from, address to, uint256 value) public returns (bool);
function approve(address spender, uint256 value) public returns (bool);
event Approval(address indexed owner, address indexed spender, uint256 value);
}
contract ReleasableToken is ERC20, Claimable {
address public releaseAgent;
bool public released = false;
mapping (address => bool) public transferAgents;
modifier canTransfer(address _sender) {
if(!released) {
assert(transferAgents[_sender]);
}
_;
}
function setReleaseAgent(address addr) onlyOwner inReleaseState(false) public {
require(addr != 0x0);
releaseAgent = addr;
}
function setTransferAgent(address addr, bool state) onlyOwner inReleaseState(false) public {
require(addr != 0x0);
transferAgents[addr] = state;
}
function releaseTokenTransfer() public onlyReleaseAgent {
released = true;
}
modifier inReleaseState(bool releaseState) {
require(releaseState == released);
_;
}
modifier onlyReleaseAgent() {
require(msg.sender == releaseAgent);
_;
}
function transfer(address _to, uint _value) canTransfer(msg.sender) returns (bool success) {
return super.transfer(_to, _value);
}
function transferFrom(address _from, address _to, uint _value) canTransfer(_from) returns (bool success) {
return super.transferFrom(_from, _to, _value);
}
}
contract FinalizeAgent {
function isFinalizeAgent() public constant returns(bool) {
return true;
}
function isSane() public constant returns (bool);
function finalizeCrowdsale();
}
contract FinalizeCrowdsale {
FinalizeAgent public finalizeAgent;
}
contract AlgoryFinalizeAgent is FinalizeAgent {
using SafeMath for uint;
ReleasableToken public token;
FinalizeCrowdsale public crowdsale;
function AlgoryFinalizeAgent(ReleasableToken _token, FinalizeCrowdsale _crowdsale) {
require(address(_token) != 0x0 && address(_crowdsale) != 0x0);
token = _token;
crowdsale = _crowdsale;
}
function isSane() public constant returns (bool) {
return token.releaseAgent() == address(this) && crowdsale.finalizeAgent() == address(this);
}
function finalizeCrowdsale() public {
require(msg.sender == address(crowdsale));
token.releaseTokenTransfer();
}
}