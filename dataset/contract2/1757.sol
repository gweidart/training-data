pragma solidity ^0.4.23;
contract ZTHInterface {
function buyAndSetDivPercentage(address _referredBy, uint8 _divChoice, string providedUnhashedPass) public payable returns (uint);
function balanceOf(address who) public view returns (uint);
function transfer(address _to, uint _value)     public returns (bool);
function transferFrom(address _from, address _toAddress, uint _amountOfTokens) public returns (bool);
function exit() public;
function sell(uint amountOfTokens) public;
function withdraw(address _recipient) public;
function tokensToEthereum_(uint _tokens) public view returns(uint);
}
contract ZethrTokenBankroll {
function zethrBuyIn() public;
function allocateTokens() public;
function addGame(address game, uint allocated) public;
function removeGame(address game) public;
function dumpFreeTokens(address toSendTo) public returns (uint);
}
contract ERC223Receiving {
function tokenFallback(address _from, uint _amountOfTokens, bytes _data) public returns (bool);
}
contract ZethrBankroll is ERC223Receiving {
using SafeMath for uint;
event Confirmation(address indexed sender, uint indexed transactionId);
event Revocation(address indexed sender, uint indexed transactionId);
event Submission(uint indexed transactionId);
event Execution(uint indexed transactionId);
event ExecutionFailure(uint indexed transactionId);
event Deposit(address indexed sender, uint value);
event OwnerAddition(address indexed owner);
event OwnerRemoval(address indexed owner);
event WhiteListAddition(address indexed contractAddress);
event WhiteListRemoval(address indexed contractAddress);
event RequirementChange(uint required);
event DevWithdraw(uint amountTotal, uint amountPerPerson);
event EtherLogged(uint amountReceived, address sender);
event BankrollInvest(uint amountReceived);
event DailyTokenAdmin(address gameContract);
event DailyTokensSent(address gameContract, uint tokens);
event DailyTokensReceived(address gameContract, uint tokens);
uint constant public MAX_OWNER_COUNT = 10;
uint constant public MAX_WITHDRAW_PCT_DAILY = 15;
uint constant public MAX_WITHDRAW_PCT_TX = 5;
uint constant internal resetTimer = 1 days;
address internal zethrAddress;
ZTHInterface public ZTHTKN;
mapping (uint => Transaction) public transactions;
mapping (uint => mapping (address => bool)) public confirmations;
mapping (address => bool) public isOwner;
mapping (address => bool) public isAnAddedGame;
address internal divCardAddress;
address[] public owners;
address[] public games;
uint public required;
uint public transactionCount;
bool internal reEntered = false;
struct Transaction {
address destination;
uint value;
bytes data;
bool executed;
}
struct TKN {
address sender;
uint value;
}
modifier onlyWallet() {
if (msg.sender != address(this))
revert();
_;
}
modifier isOwnerOrWhitelistedGame() {
address caller = msg.sender;
if (!isOwner[caller] || isAnAddedGame[caller])
revert();
_;
}
modifier isAnOwner() {
address caller = msg.sender;
if (!isOwner[caller])
revert();
_;
}
modifier ownerDoesNotExist(address owner) {
if (isOwner[owner])
revert();
_;
}
modifier ownerExists(address owner) {
if (!isOwner[owner])
revert();
_;
}
modifier transactionExists(uint transactionId) {
if (transactions[transactionId].destination == 0)
revert();
_;
}
modifier confirmed(uint transactionId, address owner) {
if (!confirmations[transactionId][owner])
revert();
_;
}
modifier notConfirmed(uint transactionId, address owner) {
if (confirmations[transactionId][owner])
revert();
_;
}
modifier notExecuted(uint transactionId) {
if (transactions[transactionId].executed)
revert();
_;
}
modifier notNull(address _address) {
if (_address == 0)
revert();
_;
}
modifier validRequirement(uint ownerCount, uint _required) {
if (   ownerCount > MAX_OWNER_COUNT
|| _required > ownerCount
|| _required == 0
|| ownerCount == 0)
revert();
_;
}
constructor (address[] _owners, uint _required)
public
validRequirement(_owners.length, _required)
{
for (uint i=0; i<_owners.length; i++) {
if (isOwner[_owners[i]] || _owners[i] == 0)
revert();
isOwner[_owners[i]] = true;
}
owners = _owners;
required = _required;
}
function addZethrAddresses(address _zethr, address _divcards)
public
isAnOwner
{
zethrAddress   = _zethr;
divCardAddress = _divcards;
ZTHTKN = ZTHInterface(zethrAddress);
}
function()
public
payable
{
}
uint NonICOBuyins;
function deposit()
public
payable
{
NonICOBuyins = NonICOBuyins.add(msg.value);
}
function buyTokens()
public
payable
isAnOwner
{
uint savings = address(this).balance;
if (savings > 0.01 ether) {
ZTHTKN.buyAndSetDivPercentage.value(savings)(address(0x0), 33, "");
emit BankrollInvest(savings);
}
else {
emit EtherLogged(msg.value, msg.sender);
}
}
}
function addOwner(address owner)
public
onlyWallet
ownerDoesNotExist(owner)
notNull(owner)
validRequirement(owners.length + 1, required)
{
isOwner[owner] = true;
owners.push(owner);
emit OwnerAddition(owner);
}
function removeOwner(address owner)
public
onlyWallet
ownerExists(owner)
validRequirement(owners.length, required)
{
isOwner[owner] = false;
for (uint i=0; i<owners.length - 1; i++)
if (owners[i] == owner) {
owners[i] = owners[owners.length - 1];
break;
}
owners.length -= 1;
if (required > owners.length)
changeRequirement(owners.length);
emit OwnerRemoval(owner);
}
function replaceOwner(address owner, address newOwner)
public
onlyWallet
ownerExists(owner)
ownerDoesNotExist(newOwner)
{
for (uint i=0; i<owners.length; i++)
if (owners[i] == owner) {
owners[i] = newOwner;
break;
}
isOwner[owner] = false;
isOwner[newOwner] = true;
emit OwnerRemoval(owner);
emit OwnerAddition(newOwner);
}
function changeRequirement(uint _required)
public
onlyWallet
validRequirement(owners.length, _required)
{
required = _required;
emit RequirementChange(_required);
}
function submitTransaction(address destination, uint value, bytes data)
public
returns (uint transactionId)
{
transactionId = addTransaction(destination, value, data);
confirmTransaction(transactionId);
}
function confirmTransaction(uint transactionId)
public
ownerExists(msg.sender)
transactionExists(transactionId)
notConfirmed(transactionId, msg.sender)
{
confirmations[transactionId][msg.sender] = true;
emit Confirmation(msg.sender, transactionId);
executeTransaction(transactionId);
}
function revokeConfirmation(uint transactionId)
public
ownerExists(msg.sender)
confirmed(transactionId, msg.sender)
notExecuted(transactionId)
{
confirmations[transactionId][msg.sender] = false;
emit Revocation(msg.sender, transactionId);
}
function executeTransaction(uint transactionId)
public
notExecuted(transactionId)
{
if (isConfirmed(transactionId)) {
Transaction storage txToExecute = transactions[transactionId];
txToExecute.executed = true;
if (txToExecute.destination.call.value(txToExecute.value)(txToExecute.data))
emit Execution(transactionId);
else {
emit ExecutionFailure(transactionId);
txToExecute.executed = false;
}
}
}
function isConfirmed(uint transactionId)
public
constant
returns (bool)
{
uint count = 0;
for (uint i=0; i<owners.length; i++) {
if (confirmations[transactionId][owners[i]])
count += 1;
if (count == required)
return true;
}
}
function addTransaction(address destination, uint value, bytes data)
internal
notNull(destination)
returns (uint transactionId)
{
transactionId = transactionCount;
transactions[transactionId] = Transaction({
destination: destination,
value: value,
data: data,
executed: false
});
transactionCount += 1;
emit Submission(transactionId);
}
function getConfirmationCount(uint transactionId)
public
constant
returns (uint count)
{
for (uint i=0; i<owners.length; i++)
if (confirmations[transactionId][owners[i]])
count += 1;
}
function getTransactionCount(bool pending, bool executed)
public
constant
returns (uint count)
{
for (uint i=0; i<transactionCount; i++)
if (   pending && !transactions[i].executed
|| executed && transactions[i].executed)
count += 1;
}
function getOwners()
public
constant
returns (address[])
{
return owners;
}
function getConfirmations(uint transactionId)
public
constant
returns (address[] _confirmations)
{
address[] memory confirmationsTemp = new address[](owners.length);
uint count = 0;
uint i;
for (i=0; i<owners.length; i++)
if (confirmations[transactionId][owners[i]]) {
confirmationsTemp[count] = owners[i];
count += 1;
}
_confirmations = new address[](count);
for (i=0; i<count; i++)
_confirmations[i] = confirmationsTemp[i];
}
function getTransactionIds(uint from, uint to, bool pending, bool executed)
public
constant
returns (uint[] _transactionIds)
{
uint[] memory transactionIdsTemp = new uint[](transactionCount);
uint count = 0;
uint i;
for (i=0; i<transactionCount; i++)
if (   pending && !transactions[i].executed
|| executed && transactions[i].executed)
{
transactionIdsTemp[count] = i;
count += 1;
}
_transactionIds = new uint[](to - from);
for (i=from; i<to; i++)
_transactionIds[i - from] = transactionIdsTemp[i];
}
function devTokenWithdraw(uint amount) public
onlyWallet
{
uint amountPerPerson = SafeMath.div(amount, owners.length);
for (uint i=0; i<owners.length; i++) {
ZTHTKN.transfer(owners[i], amountPerPerson);
}
emit DevWithdraw(amount, amountPerPerson);
}
function changeDivCardAddress(address _newDivCardAddress)
public
isAnOwner
{
divCardAddress = _newDivCardAddress;
}
function receiveDividends() public payable {
if (!reEntered) {
uint ActualBalance = (address(this).balance.sub(NonICOBuyins));
if (ActualBalance > 0.01 ether) {
reEntered = true;
ZTHTKN.buyAndSetDivPercentage.value(ActualBalance)(address(0x0), 33, "");
emit BankrollInvest(ActualBalance);
reEntered = false;
}
}
}
function buyInWithAllBalance() public payable onlyWallet {
if (!reEntered) {
uint balance = address(this).balance;
require (balance > 0.01 ether);
ZTHTKN.buyAndSetDivPercentage.value(balance)(address(0x0), 33, "");
}
}
function buyInSaturday() public payable isAnOwner {
if (!reEntered) {
ZTHTKN.withdraw(address(this));
uint balance = address(this).balance;
require (balance > 0.01 ether);
ZTHTKN.buyAndSetDivPercentage.value(balance/2)(address(0x0), 33, "");
}
}
function allocateETH(bool callBuy)
isAnOwner
public
{
ZTHTKN.withdraw(address(this));
_allocateETH(2, callBuy);
_allocateETH(5, callBuy);
_allocateETH(10, callBuy);
_allocateETH(15, callBuy);
_allocateETH(20, callBuy);
_allocateETH(25, callBuy);
_allocateETH(33, callBuy);
}
function _allocateETH(uint8 divRate, bool doBuy)
internal
{
address targetBankroll = tokenBankrollMapping[divRate];
require(targetBankroll != address(0x0));
uint balance = ZTHTKN.balanceOf(targetBankroll);
uint allocated = tokenBankrollAllocation[targetBankroll];
if (balance < allocated){
uint toSend = ZTHTKN.tokensToEthereum_(allocated - balance);
toSend = (toSend * 101)/100;
targetBankroll.transfer(toSend);
}
if (doBuy) {
tokenBankrollBuyIn();
}
}
uint public stakingBonusTokens;
address public stakeAddress;
function setStakeAddress(address anAddress) isAnOwner public {
stakeAddress = anAddress;
}
function collectStakingBonusTokens() isAnOwner public {
require(stakeAddress != address(0x0));
stakingBonusTokens = 0;
stakingBonusTokens += ZethrTokenBankroll(tokenBankrollMapping[2]).dumpFreeTokens(stakeAddress);
stakingBonusTokens += ZethrTokenBankroll(tokenBankrollMapping[5]).dumpFreeTokens(stakeAddress);
stakingBonusTokens += ZethrTokenBankroll(tokenBankrollMapping[10]).dumpFreeTokens(stakeAddress);
stakingBonusTokens += ZethrTokenBankroll(tokenBankrollMapping[15]).dumpFreeTokens(stakeAddress);
stakingBonusTokens += ZethrTokenBankroll(tokenBankrollMapping[20]).dumpFreeTokens(stakeAddress);
stakingBonusTokens += ZethrTokenBankroll(tokenBankrollMapping[25]).dumpFreeTokens(stakeAddress);
stakingBonusTokens += ZethrTokenBankroll(tokenBankrollMapping[33]).dumpFreeTokens(stakeAddress);
}
function tokenBankrollBuyIn()
isAnOwner
public
{
_tokenBankrollBuyIn(2);
_tokenBankrollBuyIn(5);
_tokenBankrollBuyIn(10);
_tokenBankrollBuyIn(15);
_tokenBankrollBuyIn(20);
_tokenBankrollBuyIn(25);
_tokenBankrollBuyIn(33);
}
function _tokenBankrollBuyIn(uint8 divRate)
internal
{
address targetBankroll = tokenBankrollMapping[divRate];
ZethrTokenBankroll(targetBankroll).zethrBuyIn();
}
function tokenAllocate()
isAnOwner
public
{
_tokenAllocate(2);
_tokenAllocate(5);
_tokenAllocate(10);
_tokenAllocate(15);
_tokenAllocate(20);
_tokenAllocate(25);
_tokenAllocate(33);
}
function _tokenAllocate(uint8 divRate)
internal
{
address targetBankroll = tokenBankrollMapping[divRate];
ZethrTokenBankroll(targetBankroll).allocateTokens();
}
function gameGetTokenBankrollList() public view returns (address[7]){
address[7] memory output;
output[0] = tokenBankrollMapping[2];
output[1] = tokenBankrollMapping[5];
output[2] = tokenBankrollMapping[10];
output[3] = tokenBankrollMapping[15];
output[4] = tokenBankrollMapping[20];
output[5] = tokenBankrollMapping[25];
output[6] = tokenBankrollMapping[33];
return output;
}
function addGame(address ctr, uint allocate)
isAnOwner
public
{
require(!isAnAddedGame[ctr]);
isAnAddedGame[ctr] = true;
games.push(ctr);
ZethrTokenBankroll(tokenBankrollMapping[2]).addGame(ctr, allocate);
ZethrTokenBankroll(tokenBankrollMapping[5]).addGame(ctr, allocate);
ZethrTokenBankroll(tokenBankrollMapping[10]).addGame(ctr, allocate);
ZethrTokenBankroll(tokenBankrollMapping[15]).addGame(ctr, allocate);
ZethrTokenBankroll(tokenBankrollMapping[20]).addGame(ctr, allocate);
ZethrTokenBankroll(tokenBankrollMapping[25]).addGame(ctr, allocate);
ZethrTokenBankroll(tokenBankrollMapping[33]).addGame(ctr, allocate);
}
function removeGame(address ctr)
isAnOwner
public
{
require(isAnAddedGame[ctr]);
isAnAddedGame[ctr] = false;
for (uint i=0; i < games.length; i++) {
if (games[i] == ctr) {
games[i] = address(0x0);
if (i != games.length) {
games[i] = games[games.length];
}
games.length = games.length - 1;
break;
}
}
ZethrTokenBankroll(tokenBankrollMapping[2]).removeGame(ctr);
ZethrTokenBankroll(tokenBankrollMapping[5]).removeGame(ctr);
ZethrTokenBankroll(tokenBankrollMapping[10]).removeGame(ctr);
ZethrTokenBankroll(tokenBankrollMapping[15]).removeGame(ctr);
ZethrTokenBankroll(tokenBankrollMapping[20]).removeGame(ctr);
ZethrTokenBankroll(tokenBankrollMapping[25]).removeGame(ctr);
ZethrTokenBankroll(tokenBankrollMapping[33]).removeGame(ctr);
}
mapping(uint8 => address) public tokenBankrollMapping;
mapping(address => uint) public tokenBankrollAllocation;
function setTokenBankrollAddress(uint8 divRate, address where)
isAnOwner
public
{
tokenBankrollMapping[divRate] = where;
}
function setAllocation(address what, uint amount)
isOwnerOrWhitelistedGame
public
{
tokenBankrollAllocation[what] = amount;
}
function changeAllocation(address what, int amount)
isOwnerOrWhitelistedGame
public
{
if (amount < 0) {
require(int(tokenBankrollAllocation[what]) + amount >= 0);
}
tokenBankrollAllocation[what] = uint(int(tokenBankrollAllocation[what]) + amount);
}
function fromHexChar(uint c) public pure returns (uint) {
if (byte(c) >= byte('0') && byte(c) <= byte('9')) {
return c - uint(byte('0'));
}
if (byte(c) >= byte('a') && byte(c) <= byte('f')) {
return 10 + c - uint(byte('a'));
}
if (byte(c) >= byte('A') && byte(c) <= byte('F')) {
return 10 + c - uint(byte('A'));
}
}
function fromHex(string s) public pure returns (bytes) {
bytes memory ss = bytes(s);
require(ss.length%2 == 0);
bytes memory r = new bytes(ss.length/2);
for (uint i=0; i<ss.length/2; ++i) {
r[i] = byte(fromHexChar(uint(ss[2*i])) * 16 +
fromHexChar(uint(ss[2*i+1])));
}
return r;
}
}
library SafeMath {
function mul(uint a, uint b) internal pure returns (uint) {
if (a == 0) {
return 0;
}
uint c = a * b;
assert(c / a == b);
return c;
}
function div(uint a, uint b) internal pure returns (uint) {
uint c = a / b;
return c;
}
function sub(uint a, uint b) internal pure returns (uint) {
assert(b <= a);
return a - b;
}
function add(uint a, uint b) internal pure returns (uint) {
uint c = a + b;
assert(c >= a);
return c;
}
}