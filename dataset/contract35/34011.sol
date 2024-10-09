pragma solidity ^0.4.11;
interface Token {
function totalSupply() constant returns (uint256 supply);
function balanceOf(address _owner) constant returns (uint256 balance);
function transfer(address _to, uint256 _value) returns (bool success);
function transferFrom(address _from, address _to, uint256 _value) returns (bool success);
function approve(address _spender, uint256 _value) returns (bool success);
function allowance(address _owner, address _spender) constant returns (uint256 remaining);
event Transfer(address indexed _from, address indexed _to, uint256 _value);
event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}
library NettingChannelLibrary {
string constant public contract_version = "0.1._";
struct Participant
{
address node_address;
uint256 balance;
bytes32 locksroot;
uint256 transferred_amount;
uint64 nonce;
mapping(bytes32 => bool) withdrawn_locks;
}
struct Data {
uint settle_timeout;
uint opened;
uint closed;
uint settled;
address closing_address;
Token token;
Participant[2] participants;
mapping(address => uint8) participant_index;
bool updated;
}
modifier notSettledButClosed(Data storage self) {
require(self.settled <= 0 && self.closed > 0);
_;
}
modifier stillTimeout(Data storage self) {
require(self.closed + self.settle_timeout >= block.number);
_;
}
modifier timeoutOver(Data storage self) {
require(self.closed + self.settle_timeout <= block.number);
_;
}
modifier channelSettled(Data storage self) {
require(self.settled != 0);
_;
}
function deposit(Data storage self, uint256 amount)
returns (bool success, uint256 balance)
{
uint8 index;
require(self.opened > 0);
require(self.closed == 0);
require(self.token.balanceOf(msg.sender) >= amount);
index = index_or_throw(self, msg.sender);
Participant storage participant = self.participants[index];
success = self.token.transferFrom(msg.sender, this, amount);
if (success == true) {
balance = participant.balance;
balance += amount;
participant.balance = balance;
return (true, balance);
}
return (false, 0);
}
function close(
Data storage self,
uint64 nonce,
uint256 transferred_amount,
bytes32 locksroot,
bytes32 extra_hash,
bytes signature
) {
address transfer_address;
uint closer_index;
uint counterparty_index;
require(self.closed == 0);
self.closed = block.number;
closer_index = index_or_throw(self, msg.sender);
self.closing_address = msg.sender;
if (signature.length == 65) {
transfer_address = recoverAddressFromSignature(
nonce,
transferred_amount,
locksroot,
extra_hash,
signature
);
counterparty_index = index_or_throw(self, transfer_address);
require(closer_index != counterparty_index);
Participant storage counterparty = self.participants[counterparty_index];
counterparty.nonce = uint64(nonce);
counterparty.locksroot = locksroot;
counterparty.transferred_amount = transferred_amount;
}
}
function updateTransfer(
Data storage self,
uint64 nonce,
uint256 transferred_amount,
bytes32 locksroot,
bytes32 extra_hash,
bytes signature
)
notSettledButClosed(self)
stillTimeout(self)
{
address transfer_address;
uint8 caller_index;
uint8 closer_index;
require(!self.updated);
self.updated = true;
caller_index = index_or_throw(self, msg.sender);
require(self.closing_address != msg.sender);
transfer_address = recoverAddressFromSignature(
nonce,
transferred_amount,
locksroot,
extra_hash,
signature
);
require(transfer_address == self.closing_address);
closer_index = 1 - caller_index;
self.participants[closer_index].nonce = nonce;
self.participants[closer_index].locksroot = locksroot;
self.participants[closer_index].transferred_amount = transferred_amount;
}
function recoverAddressFromSignature(
uint64 nonce,
uint256 transferred_amount,
bytes32 locksroot,
bytes32 extra_hash,
bytes signature
)
constant internal returns (address)
{
bytes32 signed_hash;
require(signature.length == 65);
signed_hash = sha3(
nonce,
transferred_amount,
locksroot,
this,
extra_hash
);
var (r, s, v) = signatureSplit(signature);
return ecrecover(signed_hash, v, r, s);
}
function withdraw(Data storage self, bytes locked_encoded, bytes merkle_proof, bytes32 secret)
notSettledButClosed(self)
{
uint amount;
uint8 index;
uint64 expiration;
bytes32 h;
bytes32 hashlock;
index = 1 - index_or_throw(self, msg.sender);
Participant storage counterparty = self.participants[index];
require(counterparty.locksroot != 0);
(expiration, amount, hashlock) = decodeLock(locked_encoded);
require(!counterparty.withdrawn_locks[hashlock]);
counterparty.withdrawn_locks[hashlock] = true;
require(expiration >= block.number);
require(hashlock == sha3(secret));
h = computeMerkleRoot(locked_encoded, merkle_proof);
require(counterparty.locksroot == h);
counterparty.transferred_amount += amount;
}
function computeMerkleRoot(bytes lock, bytes merkle_proof)
internal
constant
returns (bytes32)
{
require(merkle_proof.length % 32 == 0);
uint i;
bytes32 h;
bytes32 el;
h = sha3(lock);
for (i = 32; i <= merkle_proof.length; i += 32) {
assembly {
el := mload(add(merkle_proof, i))
}
if (h < el) {
h = sha3(h, el);
} else {
h = sha3(el, h);
}
}
return h;
}
function settle(Data storage self)
notSettledButClosed(self)
timeoutOver(self)
{
uint8 closing_index;
uint8 counter_index;
uint256 total_deposit;
uint256 counter_net;
uint256 closer_amount;
uint256 counter_amount;
self.settled = block.number;
closing_index = index_or_throw(self, self.closing_address);
counter_index = 1 - closing_index;
Participant storage closing_party = self.participants[closing_index];
Participant storage counter_party = self.participants[counter_index];
counter_net = (
counter_party.balance
+ closing_party.transferred_amount
- counter_party.transferred_amount
);
total_deposit = closing_party.balance + counter_party.balance;
counter_amount = min(counter_net, total_deposit);
counter_amount = max(counter_amount, 0);
closer_amount = total_deposit - counter_amount;
if (counter_amount > 0) {
require(self.token.transfer(counter_party.node_address, counter_amount));
}
if (closer_amount > 0) {
require(self.token.transfer(closing_party.node_address, closer_amount));
}
kill(self);
}
function decodeLock(bytes lock) internal returns (uint64 expiration, uint amount, bytes32 hashlock) {
require(lock.length == 72);
assembly {
expiration := mload(add(lock, 8))
amount := mload(add(lock, 40))
hashlock := mload(add(lock, 72))
}
}
function signatureSplit(bytes signature) internal returns (bytes32 r, bytes32 s, uint8 v) {
assembly {
r := mload(add(signature, 32))
s := mload(add(signature, 64))
v := and(mload(add(signature, 65)), 0xff)
}
require(v == 27 || v == 28);
}
function index_or_throw(Data storage self, address participant_address) private returns (uint8) {
uint8 n;
n = self.participant_index[participant_address];
assert(n != 0);
return n - 1;
}
function min(uint a, uint b) constant internal returns (uint) {
return a > b ? b : a;
}
function max(uint a, uint b) constant internal returns (uint) {
return a > b ? a : b;
}
function kill(Data storage self) channelSettled(self) {
selfdestruct(0x00000000000000000000);
}
}