pragma solidity ^0.4.17;
library ECVerify {
function ecverify(bytes32 hash, bytes signature) internal pure returns (address signature_address) {
require(signature.length == 65);
bytes32 r;
bytes32 s;
uint8 v;
assembly {
r := mload(add(signature, 32))
s := mload(add(signature, 64))
v := byte(0, mload(add(signature, 96)))
}
if (v < 27) {
v += 27;
}
require(v == 27 || v == 28);
signature_address = ecrecover(hash, v, r, s);
require(signature_address != 0x0);
return signature_address;
}
}
contract Token {
uint256 public totalSupply;
string public name;
uint8 public decimals;
string public symbol;
function balanceOf(address _owner) public constant returns (uint256 balance);
function transfer(address _to, uint256 _value, bytes _data) public returns (bool success);
function transfer(address _to, uint256 _value) public returns (bool success);
function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
function approve(address _spender, uint256 _value) public returns (bool success);
function allowance(address _owner, address _spender) public constant returns (uint256 remaining);
event Transfer(address indexed _from, address indexed _to, uint256 _value);
event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}
contract RaidenMicroTransferChannels {
address public owner_address;
uint32 public challenge_period;
string public constant version = '0.2.0';
uint256 public constant channel_deposit_bugbounty_limit = 10 ** 18 * 100;
Token public token;
mapping (bytes32 => Channel) public channels;
mapping (bytes32 => ClosingRequest) public closing_requests;
mapping (address => bool) public trusted_contracts;
mapping (bytes32 => uint192) public withdrawn_balances;
struct Channel {
uint192 deposit;
uint32 open_block_number;
}
struct ClosingRequest {
uint192 closing_balance;
uint32 settle_block_number;
}
modifier isOwner() {
require(msg.sender == owner_address);
_;
}
modifier isTrustedContract() {
require(trusted_contracts[msg.sender]);
_;
}
event ChannelCreated(
address indexed _sender_address,
address indexed _receiver_address,
uint192 _deposit);
event ChannelToppedUp (
address indexed _sender_address,
address indexed _receiver_address,
uint32 indexed _open_block_number,
uint192 _added_deposit);
event ChannelCloseRequested(
address indexed _sender_address,
address indexed _receiver_address,
uint32 indexed _open_block_number,
uint192 _balance);
event ChannelSettled(
address indexed _sender_address,
address indexed _receiver_address,
uint32 indexed _open_block_number,
uint192 _balance,
uint192 _receiver_tokens);
event ChannelWithdraw(
address indexed _sender_address,
address indexed _receiver_address,
uint32 indexed _open_block_number,
uint192 _withdrawn_balance);
event TrustedContract(
address indexed _trusted_contract_address,
bool _trusted_status);
function RaidenMicroTransferChannels(
address _token_address,
uint32 _challenge_period,
address[] _trusted_contracts)
public
{
require(_token_address != 0x0);
require(addressHasCode(_token_address));
require(_challenge_period >= 500);
token = Token(_token_address);
require(token.totalSupply() > 0);
challenge_period = _challenge_period;
owner_address = msg.sender;
addTrustedContracts(_trusted_contracts);
}
function tokenFallback(address _sender_address, uint256 _deposit, bytes _data) external {
require(msg.sender == address(token));
uint192 deposit = uint192(_deposit);
require(deposit == _deposit);
uint length = _data.length;
require(length == 40 || length == 44);
address channel_sender_address = address(addressFromBytes(_data, 0x20));
require(_sender_address == channel_sender_address || trusted_contracts[_sender_address]);
address channel_receiver_address = address(addressFromBytes(_data, 0x34));
if (length == 40) {
createChannelPrivate(channel_sender_address, channel_receiver_address, deposit);
} else {
uint32 open_block_number = uint32(blockNumberFromBytes(_data, 0x48));
updateInternalBalanceStructs(
channel_sender_address,
channel_receiver_address,
open_block_number,
deposit
);
}
}
function createChannel(address _receiver_address, uint192 _deposit) external {
createChannelPrivate(msg.sender, _receiver_address, _deposit);
require(token.transferFrom(msg.sender, address(this), _deposit));
}
function createChannelDelegate(
address _sender_address,
address _receiver_address,
uint192 _deposit)
isTrustedContract
external
{
createChannelPrivate(_sender_address, _receiver_address, _deposit);
require(token.transferFrom(msg.sender, address(this), _deposit));
}
function topUp(
address _receiver_address,
uint32 _open_block_number,
uint192 _added_deposit)
external
{
updateInternalBalanceStructs(
msg.sender,
_receiver_address,
_open_block_number,
_added_deposit
);
require(token.transferFrom(msg.sender, address(this), _added_deposit));
}
function topUpDelegate(
address _sender_address,
address _receiver_address,
uint32 _open_block_number,
uint192 _added_deposit)
isTrustedContract
external
{
updateInternalBalanceStructs(
_sender_address,
_receiver_address,
_open_block_number,
_added_deposit
);
require(token.transferFrom(msg.sender, address(this), _added_deposit));
}
function withdraw(
uint32 _open_block_number,
uint192 _balance,
bytes _balance_msg_sig)
external
{
require(_balance > 0);
address sender_address = extractBalanceProofSignature(
msg.sender,
_open_block_number,
_balance,
_balance_msg_sig
);
bytes32 key = getKey(sender_address, msg.sender, _open_block_number);
require(channels[key].open_block_number > 0);
require(closing_requests[key].settle_block_number == 0);
require(_balance <= channels[key].deposit);
require(withdrawn_balances[key] < _balance);
uint192 remaining_balance = _balance - withdrawn_balances[key];
withdrawn_balances[key] = _balance;
require(token.transfer(msg.sender, remaining_balance));
ChannelWithdraw(sender_address, msg.sender, _open_block_number, remaining_balance);
}
function cooperativeClose(
address _receiver_address,
uint32 _open_block_number,
uint192 _balance,
bytes _balance_msg_sig,
bytes _closing_sig)
external
{
address sender = extractBalanceProofSignature(
_receiver_address,
_open_block_number,
_balance,
_balance_msg_sig
);
address receiver = extractClosingSignature(
sender,
_open_block_number,
_balance,
_closing_sig
);
require(receiver == _receiver_address);
settleChannel(sender, receiver, _open_block_number, _balance);
}
function uncooperativeClose(
address _receiver_address,
uint32 _open_block_number,
uint192 _balance)
external
{
bytes32 key = getKey(msg.sender, _receiver_address, _open_block_number);
require(channels[key].open_block_number > 0);
require(closing_requests[key].settle_block_number == 0);
require(_balance <= channels[key].deposit);
closing_requests[key].settle_block_number = uint32(block.number) + challenge_period;
require(closing_requests[key].settle_block_number > block.number);
closing_requests[key].closing_balance = _balance;
ChannelCloseRequested(msg.sender, _receiver_address, _open_block_number, _balance);
}
function settle(address _receiver_address, uint32 _open_block_number) external {
bytes32 key = getKey(msg.sender, _receiver_address, _open_block_number);
require(closing_requests[key].settle_block_number > 0);
require(block.number > closing_requests[key].settle_block_number);
settleChannel(msg.sender, _receiver_address, _open_block_number,
closing_requests[key].closing_balance
);
}
function getChannelInfo(
address _sender_address,
address _receiver_address,
uint32 _open_block_number)
external
view
returns (bytes32, uint192, uint32, uint192, uint192)
{
bytes32 key = getKey(_sender_address, _receiver_address, _open_block_number);
require(channels[key].open_block_number > 0);
return (
key,
channels[key].deposit,
closing_requests[key].settle_block_number,
closing_requests[key].closing_balance,
withdrawn_balances[key]
);
}
function addTrustedContracts(address[] _trusted_contracts) isOwner public {
for (uint256 i = 0; i < _trusted_contracts.length; i++) {
if (addressHasCode(_trusted_contracts[i])) {
trusted_contracts[_trusted_contracts[i]] = true;
TrustedContract(_trusted_contracts[i], true);
}
}
}
function removeTrustedContracts(address[] _trusted_contracts) isOwner public {
for (uint256 i = 0; i < _trusted_contracts.length; i++) {
if (trusted_contracts[_trusted_contracts[i]]) {
trusted_contracts[_trusted_contracts[i]] = false;
TrustedContract(_trusted_contracts[i], false);
}
}
}
function extractBalanceProofSignature(
address _receiver_address,
uint32 _open_block_number,
uint192 _balance,
bytes _balance_msg_sig)
public
view
returns (address)
{
bytes32 message_hash = keccak256(
keccak256(
'string message_id',
'address receiver',
'uint32 block_created',
'uint192 balance',
'address contract'
),
keccak256(
'Sender balance proof signature',
_receiver_address,
_open_block_number,
_balance,
address(this)
)
);
address signer = ECVerify.ecverify(message_hash, _balance_msg_sig);
return signer;
}
function extractClosingSignature(
address _sender_address,
uint32 _open_block_number,
uint192 _balance,
bytes _closing_sig)
public
view
returns (address)
{
bytes32 message_hash = keccak256(
keccak256(
'string message_id',
'address sender',
'uint32 block_created',
'uint192 balance',
'address contract'
),
keccak256(
'Receiver closing signature',
_sender_address,
_open_block_number,
_balance,
address(this)
)
);
address signer = ECVerify.ecverify(message_hash, _closing_sig);
return signer;
}
function getKey(
address _sender_address,
address _receiver_address,
uint32 _open_block_number)
public
pure
returns (bytes32 data)
{
return keccak256(_sender_address, _receiver_address, _open_block_number);
}
function createChannelPrivate(
address _sender_address,
address _receiver_address,
uint192 _deposit)
private
{
require(_deposit <= channel_deposit_bugbounty_limit);
uint32 open_block_number = uint32(block.number);
bytes32 key = getKey(_sender_address, _receiver_address, open_block_number);
require(channels[key].deposit == 0);
require(channels[key].open_block_number == 0);
require(closing_requests[key].settle_block_number == 0);
channels[key] = Channel({deposit: _deposit, open_block_number: open_block_number});
ChannelCreated(_sender_address, _receiver_address, _deposit);
}
function updateInternalBalanceStructs(
address _sender_address,
address _receiver_address,
uint32 _open_block_number,
uint192 _added_deposit)
private
{
require(_added_deposit > 0);
require(_open_block_number > 0);
bytes32 key = getKey(_sender_address, _receiver_address, _open_block_number);
require(channels[key].open_block_number > 0);
require(closing_requests[key].settle_block_number == 0);
require(channels[key].deposit + _added_deposit <= channel_deposit_bugbounty_limit);
channels[key].deposit += _added_deposit;
assert(channels[key].deposit >= _added_deposit);
ChannelToppedUp(_sender_address, _receiver_address, _open_block_number, _added_deposit);
}
function settleChannel(
address _sender_address,
address _receiver_address,
uint32 _open_block_number,
uint192 _balance)
private
{
bytes32 key = getKey(_sender_address, _receiver_address, _open_block_number);
Channel memory channel = channels[key];
require(channel.open_block_number > 0);
require(_balance <= channel.deposit);
require(withdrawn_balances[key] <= _balance);
delete channels[key];
delete closing_requests[key];
uint192 receiver_remaining_tokens = _balance - withdrawn_balances[key];
require(token.transfer(_receiver_address, receiver_remaining_tokens));
require(token.transfer(_sender_address, channel.deposit - _balance));
ChannelSettled(
_sender_address,
_receiver_address,
_open_block_number,
_balance,
receiver_remaining_tokens
);
}
function addressFromBytes (bytes data, uint256 offset) internal pure returns (address) {
bytes20 extracted_address;
assembly {
extracted_address := mload(add(data, offset))
}
return address(extracted_address);
}
function blockNumberFromBytes(bytes data, uint256 offset) internal pure returns (uint32) {
bytes4 block_number;
assembly {
block_number := mload(add(data, offset))
}
return uint32(block_number);
}
function addressHasCode(address _contract) internal view returns (bool) {
uint size;
assembly {
size := extcodesize(_contract)
}
return size > 0;
}
}