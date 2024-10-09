pragma solidity ^0.4.24;
contract ERC820Registry {
function getManager(address addr) public view returns(address);
function setManager(address addr, address newManager) public;
function getInterfaceImplementer(address addr, bytes32 iHash) public constant returns (address);
function setInterfaceImplementer(address addr, bytes32 iHash, address implementer) public;
}
contract ERC820Implementer {
ERC820Registry erc820Registry = ERC820Registry(0x991a1bcb077599290d7305493c9A630c20f8b798);
function setInterfaceImplementation(string ifaceLabel, address impl) internal {
bytes32 ifaceHash = keccak256(abi.encodePacked(ifaceLabel));
erc820Registry.setInterfaceImplementer(this, ifaceHash, impl);
}
function interfaceAddr(address addr, string ifaceLabel) internal constant returns(address) {
bytes32 ifaceHash = keccak256(abi.encodePacked(ifaceLabel));
return erc820Registry.getInterfaceImplementer(addr, ifaceHash);
}
function delegateManagement(address newManager) internal {
erc820Registry.setManager(this, newManager);
}
}
contract ERC777Token {
function name() public view returns (string);
function symbol() public view returns (string);
function totalSupply() public view returns (uint256);
function balanceOf(address owner) public view returns (uint256);
function granularity() public view returns (uint256);
function defaultOperators() public view returns (address[]);
function isOperatorFor(address operator, address tokenHolder) public view returns (bool);
function authorizeOperator(address operator) public;
function revokeOperator(address operator) public;
function send(address to, uint256 amount, bytes holderData) public;
function operatorSend(address from, address to, uint256 amount, bytes holderData, bytes operatorData) public;
function burn(uint256 amount, bytes holderData) public;
function operatorBurn(address from, uint256 amount, bytes holderData, bytes operatorData) public;
event Sent(
address indexed operator,
address indexed from,
address indexed to,
uint256 amount,
bytes holderData,
bytes operatorData
);
event Minted(address indexed operator, address indexed to, uint256 amount, bytes operatorData);
event Burned(address indexed operator, address indexed from, uint256 amount, bytes holderData, bytes operatorData);
event AuthorizedOperator(address indexed operator, address indexed tokenHolder);
event RevokedOperator(address indexed operator, address indexed tokenHolder);
}
contract ERC777TokensRecipient {
function tokensReceived(
address operator,
address from,
address to,
uint amount,
bytes userData,
bytes operatorData
) public;
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
contract ERC777TokenScheduledTimelock is ERC820Implementer, ERC777TokensRecipient, Ownable {
using SafeMath for uint256;
ERC777Token public token;
uint256 public totalVested;
struct Timelock {
uint256 till;
uint256 amount;
}
mapping(address => Timelock[]) public schedule;
event Released(address to, uint256 amount);
constructor(address _token) public {
setInterfaceImplementation("ERC777TokensRecipient", this);
address tokenAddress = interfaceAddr(_token, "ERC777Token");
require(tokenAddress != address(0));
token = ERC777Token(tokenAddress);
}
function scheduleTimelock(address _beneficiary, uint256 _lockTokenAmount, uint256 _lockTill) public onlyOwner {
require(_beneficiary != address(0));
require(_lockTill > getNow());
require(token.balanceOf(address(this)) >= totalVested.add(_lockTokenAmount));
totalVested = totalVested.add(_lockTokenAmount);
schedule[_beneficiary].push(Timelock({ till: _lockTill, amount: _lockTokenAmount }));
}
function release(address _to) public {
Timelock[] storage timelocks = schedule[_to];
uint256 tokens = 0;
uint256 till;
uint256 n = timelocks.length;
uint256 timestamp = getNow();
for (uint256 i = 0; i < n; i++) {
Timelock storage timelock = timelocks[i];
till = timelock.till;
if (till > 0 && till <= timestamp) {
tokens = tokens.add(timelock.amount);
timelock.amount = 0;
timelock.till = 0;
}
}
if (tokens > 0) {
totalVested = totalVested.sub(tokens);
token.send(_to, tokens, '');
emit Released(_to, tokens);
}
}
function releaseBatch(address[] _to) public {
require(_to.length > 0 && _to.length < 100);
for (uint256 i = 0; i < _to.length; i++) {
release(_to[i]);
}
}
function tokensReceived(address, address, address, uint256, bytes, bytes) public {}
function getScheduledTimelockCount(address _beneficiary) public view returns (uint256) {
return schedule[_beneficiary].length;
}
function getNow() internal view returns (uint256) {
return now;
}
}