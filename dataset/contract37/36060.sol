pragma solidity ^0.4.15;
library Uint8Lib {
function xorReduce(
uint8[] arr,
uint    len
)
public
constant
returns (uint8 res) {
res = arr[0];
for (uint i = 1; i < len; i++) {
res ^= arr[i];
}
}
}
library ErrorLib {
event Error(string message);
function orThrow(bool condition, string message) public constant {
if (!condition) {
error(message);
}
}
function error(string message) public constant {
Error(message);
revert();
}
}
library Bytes32Lib {
function xorReduce(
bytes32[]   arr,
uint        len
)
public
constant
returns (bytes32 res) {
res = arr[0];
for (uint i = 1; i < len; i++) {
res = _xor(res, arr[i]);
}
}
function _xor(
bytes32 bs1,
bytes32 bs2
)
public
constant
returns (bytes32 res) {
bytes memory temp = new bytes(32);
for (uint i = 0; i < 32; i++) {
temp[i] = bs1[i] ^ bs2[i];
}
string memory str = string(temp);
assembly {
res := mload(add(str, 32))
}
}
}
contract RinghashRegistry {
using Bytes32Lib    for bytes32[];
using ErrorLib      for bool;
using Uint8Lib      for uint8[];
uint public blocksToLive;
struct Submission {
address feeRecepient;
uint block;
}
mapping (bytes32 => Submission) submissions;
function RinghashRegistry(uint _blocksToLive) public {
require(_blocksToLive > 0);
blocksToLive = _blocksToLive;
}
function submitRinghash(
uint        ringSize,
address     feeRecepient,
uint8[]     vList,
bytes32[]   rList,
bytes32[]   sList)
public {
bytes32 ringhash = calculateRinghash(
ringSize,
vList,
rList,
sList);
canSubmit(ringhash, feeRecepient)
.orThrow("Ringhash submitted");
submissions[ringhash] = Submission(feeRecepient, block.number);
}
function canSubmit(
bytes32 ringhash,
address feeRecepient
)
public
constant
returns (bool) {
var submission = submissions[ringhash];
return (submission.feeRecepient == address(0)
|| submission.block + blocksToLive < block.number
|| submission.feeRecepient == feeRecepient);
}
function ringhashFound(bytes32 ringhash)
public
constant
returns (bool) {
return submissions[ringhash].feeRecepient != address(0);
}
function calculateRinghash(
uint        ringSize,
uint8[]     vList,
bytes32[]   rList,
bytes32[]   sList
)
public
constant
returns (bytes32) {
(ringSize == vList.length - 1
&& ringSize == rList.length - 1
&& ringSize == sList.length - 1)
.orThrow("invalid ring data");
return keccak256(
vList.xorReduce(ringSize),
rList.xorReduce(ringSize),
sList.xorReduce(ringSize));
}
}