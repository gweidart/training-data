pragma solidity 0.4.18;
library MathUint8 {
function xorReduce(
uint8[] arr,
uint    len
)
internal
pure
returns (uint8 res)
{
res = arr[0];
for (uint i = 1; i < len; i++) {
res ^= arr[i];
}
}
}
library MathBytes32 {
function xorReduce(
bytes32[]   arr,
uint        len
)
internal
pure
returns (bytes32 res)
{
res = arr[0];
for (uint i = 1; i < len; i++) {
res ^= arr[i];
}
}
}
contract RinghashRegistry {
using MathBytes32   for bytes32[];
using MathUint8     for uint8[];
uint public blocksToLive;
struct Submission {
address ringminer;
uint block;
}
mapping (bytes32 => Submission) submissions;
event RinghashSubmitted(
address indexed _ringminer,
bytes32 indexed _ringhash
);
function RinghashRegistry(uint _blocksToLive)
public
{
require(_blocksToLive > 0);
blocksToLive = _blocksToLive;
}
function () payable public {
revert();
}
function submitRinghash(
address     ringminer,
bytes32     ringhash
)
public
{
require(canSubmit(ringhash, ringminer));
submissions[ringhash] = Submission(ringminer, block.number);
RinghashSubmitted(ringminer, ringhash);
}
function batchSubmitRinghash(
address[]     ringminerList,
bytes32[]     ringhashList
)
external
{
uint size = ringminerList.length;
require(size > 0);
require(size == ringhashList.length);
for (uint i = 0; i < size; i++) {
submitRinghash(ringminerList[i], ringhashList[i]);
}
}
function calculateRinghash(
uint        ringSize,
uint8[]     vList,
bytes32[]   rList,
bytes32[]   sList
)
private
pure
returns (bytes32)
{
require(
ringSize == vList.length - 1 && (
ringSize == rList.length - 1 && (
ringSize == sList.length - 1))
);
return keccak256(
vList.xorReduce(ringSize),
rList.xorReduce(ringSize),
sList.xorReduce(ringSize)
);
}
function computeAndGetRinghashInfo(
uint        ringSize,
address     ringminer,
uint8[]     vList,
bytes32[]   rList,
bytes32[]   sList
)
external
view
returns (bytes32 ringhash, bool[2] attributes)
{
ringhash = calculateRinghash(
ringSize,
vList,
rList,
sList
);
attributes[0] = canSubmit(ringhash, ringminer);
attributes[1] = isReserved(ringhash, ringminer);
}
function canSubmit(
bytes32 ringhash,
address ringminer)
public
view
returns (bool)
{
require(ringminer != 0x0);
Submission memory submission = submissions[ringhash];
address miner = submission.ringminer;
return (
miner == 0x0 || (
submission.block + blocksToLive < block.number) || (
miner == ringminer)
);
}
function isReserved(
bytes32 ringhash,
address ringminer)
public
view
returns (bool)
{
Submission memory submission = submissions[ringhash];
return (
submission.block + blocksToLive >= block.number && (
submission.ringminer == ringminer)
);
}
}