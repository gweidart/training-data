pragma solidity 0.4.18;
library MathUint {
function mul(uint a, uint b) internal pure returns (uint c) {
c = a * b;
require(a == 0 || c / a == b);
}
function sub(uint a, uint b) internal pure returns (uint) {
require(b <= a);
return a - b;
}
function add(uint a, uint b) internal pure returns (uint c) {
c = a + b;
require(c >= a);
}
function tolerantSub(uint a, uint b) internal pure returns (uint c) {
return (a >= b) ? a - b : 0;
}
function cvsquare(
uint[] arr,
uint scale
)
internal
pure
returns (uint)
{
uint len = arr.length;
require(len > 1);
require(scale > 0);
uint avg = 0;
for (uint i = 0; i < len; i++) {
avg += arr[i];
}
avg = avg / len;
if (avg == 0) {
return 0;
}
uint cvs = 0;
uint s = 0;
for (i = 0; i < len; i++) {
s = arr[i] > avg ? arr[i] - avg : avg - arr[i];
cvs += mul(s, s);
}
return (mul(mul(cvs, scale) / avg, scale) / avg) / (len - 1);
}
}
contract ERC20 {
uint public totalSupply;
event Transfer(address indexed from, address indexed to, uint256 value);
event Approval(address indexed owner, address indexed spender, uint256 value);
function balanceOf(address who) view public returns (uint256);
function allowance(address owner, address spender) view public returns (uint256);
function transfer(address to, uint256 value) public returns (bool);
function transferFrom(address from, address to, uint256 value) public returns (bool);
function approve(address spender, uint256 value) public returns (bool);
}
contract Ownable {
address public owner;
function Ownable() public {
owner = msg.sender;
}
modifier onlyOwner() {
require(msg.sender == owner);
_;
}
function transferOwnership(address newOwner) onlyOwner public {
if (newOwner != address(0)) {
owner = newOwner;
}
}
}
contract TokenTransferDelegate is Ownable {
using MathUint for uint;
mapping(address => AddressInfo) private addressInfos;
address public latestAddress;
struct AddressInfo {
address previous;
uint32  index;
bool    authorized;
}
modifier onlyAuthorized() {
if (isAddressAuthorized(msg.sender) == false) {
revert();
}
_;
}
event AddressAuthorized(address indexed addr, uint32 number);
event AddressDeauthorized(address indexed addr, uint32 number);
function authorizeAddress(address addr)
onlyOwner
external
{
AddressInfo storage addrInfo = addressInfos[addr];
if (addrInfo.index != 0) {
if (addrInfo.authorized == false) {
addrInfo.authorized = true;
AddressAuthorized(addr, addrInfo.index);
}
} else {
address prev = latestAddress;
if (prev == address(0)) {
addrInfo.index = 1;
addrInfo.authorized = true;
} else {
addrInfo.previous = prev;
addrInfo.index = addressInfos[prev].index + 1;
}
addrInfo.authorized = true;
latestAddress = addr;
AddressAuthorized(addr, addrInfo.index);
}
}
function deauthorizeAddress(address addr)
onlyOwner
external
{
uint32 index = addressInfos[addr].index;
if (index != 0) {
addressInfos[addr].authorized = false;
AddressDeauthorized(addr, index);
}
}
function isAddressAuthorized(address addr)
public
view
returns (bool)
{
return addressInfos[addr].authorized;
}
function getLatestAuthorizedAddresses(uint max)
external
view
returns (address[] addresses)
{
addresses = new address[](max);
address addr = latestAddress;
AddressInfo memory addrInfo;
uint count = 0;
while (addr != address(0) && max < count) {
addrInfo = addressInfos[addr];
if (addrInfo.index == 0) {
break;
}
addresses[count++] = addr;
addr = addrInfo.previous;
}
}
function transferToken(
address token,
address from,
address to,
uint    value)
onlyAuthorized
external
{
if (value > 0 && from != to) {
require(
ERC20(token).transferFrom(from, to, value)
);
}
}
function batchTransferToken(
uint ringSize,
address lrcTokenAddress,
address feeRecipient,
bytes32[] batch)
onlyAuthorized
external
{
require(batch.length == ringSize * 6);
uint p = ringSize * 2;
var lrc = ERC20(lrcTokenAddress);
for (uint i = 0; i < ringSize; i++) {
uint prev = ((i + ringSize - 1) % ringSize);
address tokenS = address(batch[i]);
address owner = address(batch[ringSize + i]);
address prevOwner = address(batch[ringSize + prev]);
ERC20 _tokenS;
if (owner != prevOwner || owner != feeRecipient && batch[p+1] != 0) {
_tokenS = ERC20(tokenS);
}
if (owner != prevOwner) {
require(
_tokenS.transferFrom(owner, prevOwner, uint(batch[p]))
);
}
if (owner != feeRecipient) {
if (batch[p+1] != 0) {
require(
_tokenS.transferFrom(owner, feeRecipient, uint(batch[p+1]))
);
}
if (batch[p+2] != 0) {
require(
lrc.transferFrom(feeRecipient, owner, uint(batch[p+2]))
);
}
if (batch[p+3] != 0) {
require(
lrc.transferFrom(owner, feeRecipient, uint(batch[p+3]))
);
}
}
p += 4;
}
}
}