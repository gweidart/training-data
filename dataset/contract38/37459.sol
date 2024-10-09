pragma solidity ^0.4.15;
contract Owned {
address public owner;
function owned() {
owner = msg.sender;
}
modifier onlyOwner {
require(msg.sender == owner);
_;
}
function transferOwnership(address _newOwner) onlyOwner {
owner = _newOwner;
}
}
contract SafeMath {
function mul(uint256 a, uint256 b)
internal
constant
returns (uint256) {
uint256 c = a * b;
assert(a == 0 || c / a == b);
return c;
}
function div(uint256 a, uint256 b)
internal
constant
returns (uint256) {
uint256 c = a / b;
return c;
}
function sub(uint256 a, uint256 b)
internal
constant
returns (uint256) {
assert(b <= a);
return a - b;
}
function add(uint256 a, uint256 b)
internal
constant
returns (uint256) {
uint256 c = a + b;
assert(c >= a);
return c;
}
}
contract Random is SafeMath {
function generateRandomNumber(uint blockNumber, uint max)
public
constant
returns(uint) {
return(add(uint(sha3(block.blockhash(blockNumber))) % max, 1));
}
}
contract Fresh is SafeMath {
function expiredBlock()
internal
constant
returns(uint) {
uint256 expired = block.number;
if (expired > 256) {
expired = sub(expired, 256);
}
return expired;
}
}
contract RandomLedger is Owned {
uint256 public cost;
uint8 public defaultWaitTime;
uint256 public defaultMax;
struct RandomNumber {
address requestProxy;
uint256 renderedNumber;
uint256 originBlock;
uint256 max;
uint8 waitTime;
uint256 expired;
}
event EventRandomLedgerRequested(address requestor, uint256 max, uint256 originBlock, uint8 waitTime, address indexed requestProxy);
event EventRandomLedgerRevealed(address requestor, uint256 originBlock, uint256 renderedNumber, uint256 expiredBlock, address indexed requestProxy);
mapping (address => RandomNumber) public randomNumbers;
mapping (address => bool) public whiteList;
function requestNumber(address _requestor, uint256 _max, uint8 _waitTime) payable public;
function revealNumber(address _requestor) payable public;
}
contract RandomLedgerService is RandomLedger, Random, Fresh {
function RandomLedgerService() {
owned();
cost = 20000000000000000;
defaultMax = 15;
defaultWaitTime = 3;
}
function setMax(uint256 _max)
onlyOwner
public
returns (bool) {
defaultMax = _max;
return true;
}
function setWaitTime(uint8 _waitTime)
onlyOwner
public
returns (bool) {
defaultWaitTime = _waitTime;
return true;
}
function setCost(uint256 _cost)
onlyOwner
public
returns (bool) {
cost = _cost;
return true;
}
function enableProxy(address _proxy)
onlyOwner
public
returns (bool) {
whiteList[_proxy] = true;
return whiteList[_proxy];
}
function removeProxy(address _proxy)
onlyOwner
public
returns (bool) {
delete whiteList[_proxy];
return true;
}
function withdraw(address _recipient, uint256 _balance)
onlyOwner
public
returns (bool) {
_recipient.transfer(_balance);
return true;
}
function () payable public {
assert(msg.sender != owner);
requestNumber(msg.sender, defaultMax, defaultWaitTime);
}
function requestNumber(address _requestor, uint256 _max, uint8 _waitTime)
payable
public {
if (!whiteList[msg.sender]) {
require(!(msg.value < cost));
}
assert(!isRequestPending(_requestor));
randomNumbers[_requestor] = RandomNumber({
requestProxy: tx.origin,
renderedNumber: 0,
max: defaultMax,
originBlock: block.number,
expired: 0,
waitTime: defaultWaitTime
});
if (_max > 1) {
randomNumbers[_requestor].max = _max;
}
if (_waitTime > 0 && _waitTime < 250) {
randomNumbers[_requestor].waitTime = _waitTime;
}
EventRandomLedgerRequested(_requestor, randomNumbers[_requestor].max, randomNumbers[_requestor].originBlock, randomNumbers[_requestor].waitTime, randomNumbers[_requestor].requestProxy);
}
function revealNumber(address _requestor)
public
payable {
assert(_canReveal(_requestor, msg.sender));
_revealNumber(_requestor);
}
function _revealNumber(address _requestor)
internal {
uint256 luckyBlock = _revealBlock(_requestor);
randomNumbers[_requestor].expired = expiredBlock();
randomNumbers[_requestor].renderedNumber = generateRandomNumber(luckyBlock, randomNumbers[_requestor].max);
EventRandomLedgerRevealed(_requestor, randomNumbers[_requestor].originBlock, randomNumbers[_requestor].renderedNumber, randomNumbers[_requestor].expired, randomNumbers[_requestor].requestProxy);
randomNumbers[_requestor].waitTime = 0;
}
function canReveal(address _requestor)
public
constant
returns (bool, uint, uint) {
return (_canReveal(_requestor, msg.sender), _remainingBlocks(_requestor), _revealBlock(_requestor));
}
function _canReveal(address _requestor, address _proxy)
internal
constant
returns (bool) {
if (isRequestPending(_requestor)) {
if (_remainingBlocks(_requestor) == 0) {
if (randomNumbers[_requestor].requestProxy == _requestor || randomNumbers[_requestor].requestProxy == _proxy) {
return true;
}
}
}
return false;
}
function _remainingBlocks(address _requestor)
internal
constant
returns (uint) {
uint256 revealBlock = add(randomNumbers[_requestor].originBlock, randomNumbers[_requestor].waitTime);
uint256 remainingBlocks = 0;
if (revealBlock > block.number) {
remainingBlocks = sub(revealBlock, block.number);
}
return remainingBlocks;
}
function _revealBlock(address _requestor)
internal
constant
returns (uint) {
return add(randomNumbers[_requestor].originBlock, randomNumbers[_requestor].waitTime);
}
function getNumber(address _requestor)
public
constant
returns (uint, uint, uint, uint) {
return (randomNumbers[_requestor].renderedNumber, randomNumbers[_requestor].max, randomNumbers[_requestor].originBlock, randomNumbers[_requestor].expired);
}
function isRequestPending(address _requestor)
public
constant
returns (bool) {
if (randomNumbers[_requestor].renderedNumber == 0 && randomNumbers[_requestor].waitTime > 0) {
return true;
}
return false;
}
}