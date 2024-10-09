pragma solidity 0.4.24;
library BBLib {
using BytesLib for bytes;
uint256 constant BB_VERSION = 6;
uint16 constant USE_ETH = 1;
uint16 constant USE_SIGNED = 2;
uint16 constant USE_NO_ENC = 4;
uint16 constant USE_ENC = 8;
uint16 constant IS_BINDING = 8192;
uint16 constant IS_OFFICIAL = 16384;
uint16 constant USE_TESTING = 32768;
uint32 constant MAX_UINT32 = 0xFFFFFFFF;
struct Vote {
bytes32 voteData;
bytes32 castTsAndSender;
bytes extra;
}
struct Sponsor {
address sender;
uint amount;
}
event CreatedBallot(bytes32 _specHash, uint64 startTs, uint64 endTs, uint16 submissionBits);
event SuccessfulVote(address indexed voter, uint voteId);
event SeckeyRevealed(bytes32 secretKey);
event TestingEnabled();
event DeprecatedContract();
struct DB {
mapping (uint256 => Vote) votes;
uint256 nVotesCast;
mapping (address => uint32) sequenceNumber;
bytes32 ballotEncryptionSeckey;
uint256 packed;
bytes32 specHash;
bytes16 extraData;
Sponsor[] sponsors;
IxIface index;
bool deprecated;
address ballotOwner;
uint256 creationTs;
}
function requireBallotClosed(DB storage db) internal view {
require(now > BPackedUtils.packedToEndTime(db.packed), "!b-closed");
}
function requireBallotOpen(DB storage db) internal view {
uint64 _n = uint64(now);
uint64 startTs;
uint64 endTs;
(, startTs, endTs) = BPackedUtils.unpackAll(db.packed);
require(_n >= startTs && _n < endTs, "!b-open");
require(db.deprecated == false, "b-deprecated");
}
function requireBallotOwner(DB storage db) internal view {
require(msg.sender == db.ballotOwner, "!b-owner");
}
function requireTesting(DB storage db) internal view {
require(isTesting(BPackedUtils.packedToSubmissionBits(db.packed)), "!testing");
}
function getVersion() external pure returns (uint) {
return BB_VERSION;
}
function init(DB storage db, bytes32 _specHash, uint256 _packed, IxIface ix, address ballotOwner, bytes16 extraData) external {
require(db.specHash == bytes32(0), "b-exists");
db.index = ix;
db.ballotOwner = ballotOwner;
uint64 startTs;
uint64 endTs;
uint16 sb;
(sb, startTs, endTs) = BPackedUtils.unpackAll(_packed);
bool _testing = isTesting(sb);
if (_testing) {
emit TestingEnabled();
} else {
require(endTs > now, "bad-end-time");
require(sb & 0x1ff2 == 0, "bad-sb");
bool okaySubmissionBits = 1 == (isEthNoEnc(sb) ? 1 : 0) + (isEthWithEnc(sb) ? 1 : 0);
require(okaySubmissionBits, "!valid-sb");
startTs = startTs > now ? startTs : uint64(now);
}
require(_specHash != bytes32(0), "null-specHash");
db.specHash = _specHash;
db.packed = BPackedUtils.pack(sb, startTs, endTs);
db.creationTs = now;
if (extraData != bytes16(0)) {
db.extraData = extraData;
}
emit CreatedBallot(db.specHash, startTs, endTs, sb);
}
function logSponsorship(DB storage db, uint value) internal {
db.sponsors.push(Sponsor(msg.sender, value));
}
function getVote(DB storage db, uint id) internal view returns (bytes32 voteData, address sender, bytes extra, uint castTs) {
return (db.votes[id].voteData, address(db.votes[id].castTsAndSender), db.votes[id].extra, uint(db.votes[id].castTsAndSender) >> 160);
}
function getSequenceNumber(DB storage db, address voter) internal view returns (uint32) {
return db.sequenceNumber[voter];
}
function getTotalSponsorship(DB storage db) internal view returns (uint total) {
for (uint i = 0; i < db.sponsors.length; i++) {
total += db.sponsors[i].amount;
}
}
function getSponsor(DB storage db, uint i) external view returns (address sender, uint amount) {
sender = db.sponsors[i].sender;
amount = db.sponsors[i].amount;
}
function submitVote(DB storage db, bytes32 voteData, bytes extra) external {
_addVote(db, voteData, msg.sender, extra);
if (db.sequenceNumber[msg.sender] != MAX_UINT32) {
db.sequenceNumber[msg.sender] = MAX_UINT32;
}
}
function submitProxyVote(DB storage db, bytes32[5] proxyReq, bytes extra) external returns (address voter) {
bytes32 r = proxyReq[0];
bytes32 s = proxyReq[1];
uint8 v = uint8(proxyReq[2][0]);
bytes31 proxyReq2 = bytes31(uint248(proxyReq[2]));
bytes32 ballotId = proxyReq[3];
bytes32 voteData = proxyReq[4];
bytes memory signed = abi.encodePacked(proxyReq2, ballotId, voteData, extra);
bytes32 msgHash = keccak256(signed);
voter = ecrecover(msgHash, v, r, s);
uint32 sequence = uint32(proxyReq2);
_proxyReplayProtection(db, voter, sequence);
_addVote(db, voteData, voter, extra);
}
function _addVote(DB storage db, bytes32 voteData, address sender, bytes extra) internal returns (uint256 id) {
requireBallotOpen(db);
id = db.nVotesCast;
db.votes[id].voteData = voteData;
db.votes[id].castTsAndSender = bytes32(sender) ^ bytes32(now << 160);
if (extra.length > 0) {
db.votes[id].extra = extra;
}
db.nVotesCast += 1;
emit SuccessfulVote(sender, id);
}
function _proxyReplayProtection(DB storage db, address voter, uint32 sequence) internal {
require(db.sequenceNumber[voter] < sequence, "bad-sequence-n");
db.sequenceNumber[voter] = sequence;
}
function setEndTime(DB storage db, uint64 newEndTime) external {
uint16 sb;
uint64 sTs;
(sb, sTs,) = BPackedUtils.unpackAll(db.packed);
db.packed = BPackedUtils.pack(sb, sTs, newEndTime);
}
function revealSeckey(DB storage db, bytes32 sk) internal {
db.ballotEncryptionSeckey = sk;
emit SeckeyRevealed(sk);
}
uint16 constant SETTINGS_MASK = 0xFFFF ^ USE_TESTING ^ IS_OFFICIAL ^ IS_BINDING;
function isEthNoEnc(uint16 submissionBits) pure internal returns (bool) {
return checkFlags(submissionBits, USE_ETH | USE_NO_ENC);
}
function isEthWithEnc(uint16 submissionBits) pure internal returns (bool) {
return checkFlags(submissionBits, USE_ETH | USE_ENC);
}
function isOfficial(uint16 submissionBits) pure internal returns (bool) {
return (submissionBits & IS_OFFICIAL) == IS_OFFICIAL;
}
function isBinding(uint16 submissionBits) pure internal returns (bool) {
return (submissionBits & IS_BINDING) == IS_BINDING;
}
function isTesting(uint16 submissionBits) pure internal returns (bool) {
return (submissionBits & USE_TESTING) == USE_TESTING;
}
function qualifiesAsCommunityBallot(uint16 submissionBits) pure internal returns (bool) {
return (submissionBits & (IS_BINDING | IS_OFFICIAL | USE_ENC)) == 0;
}
function checkFlags(uint16 submissionBits, uint16 expected) pure internal returns (bool) {
uint16 sBitsNoSettings = submissionBits & SETTINGS_MASK;
return sBitsNoSettings == expected;
}
}
library BPackedUtils {
uint256 constant sbMask        = 0xffffffffffffffffffffffffffff0000ffffffffffffffffffffffffffffffff;
uint256 constant startTimeMask = 0xffffffffffffffffffffffffffffffff0000000000000000ffffffffffffffff;
uint256 constant endTimeMask   = 0xffffffffffffffffffffffffffffffffffffffffffffffff0000000000000000;
function packedToSubmissionBits(uint256 packed) internal pure returns (uint16) {
return uint16(packed >> 128);
}
function packedToStartTime(uint256 packed) internal pure returns (uint64) {
return uint64(packed >> 64);
}
function packedToEndTime(uint256 packed) internal pure returns (uint64) {
return uint64(packed);
}
function unpackAll(uint256 packed) internal pure returns (uint16 submissionBits, uint64 startTime, uint64 endTime) {
submissionBits = uint16(packed >> 128);
startTime = uint64(packed >> 64);
endTime = uint64(packed);
}
function pack(uint16 sb, uint64 st, uint64 et) internal pure returns (uint256 packed) {
return uint256(sb) << 128 | uint256(st) << 64 | uint256(et);
}
function setSB(uint256 packed, uint16 newSB) internal pure returns (uint256) {
return (packed & sbMask) | uint256(newSB) << 128;
}
}
interface IxIface {}
library BytesLib {
function concat(bytes memory _preBytes, bytes memory _postBytes) internal pure returns (bytes) {
bytes memory tempBytes;
assembly {
tempBytes := mload(0x40)
let length := mload(_preBytes)
mstore(tempBytes, length)
let mc := add(tempBytes, 0x20)
let end := add(mc, length)
for {
let cc := add(_preBytes, 0x20)
} lt(mc, end) {
mc := add(mc, 0x20)
cc := add(cc, 0x20)
} {
mstore(mc, mload(cc))
}
length := mload(_postBytes)
mstore(tempBytes, add(length, mload(tempBytes)))
mc := end
end := add(mc, length)
for {
let cc := add(_postBytes, 0x20)
} lt(mc, end) {
mc := add(mc, 0x20)
cc := add(cc, 0x20)
} {
mstore(mc, mload(cc))
}
mstore(0x40, and(
add(add(end, iszero(add(length, mload(_preBytes)))), 31),
not(31)
))
}
return tempBytes;
}
function concatStorage(bytes storage _preBytes, bytes memory _postBytes) internal {
assembly {
let fslot := sload(_preBytes_slot)
let slength := div(and(fslot, sub(mul(0x100, iszero(and(fslot, 1))), 1)), 2)
let mlength := mload(_postBytes)
let newlength := add(slength, mlength)
switch add(lt(slength, 32), lt(newlength, 32))
case 2 {
sstore(
_preBytes_slot,
add(
fslot,
add(
mul(
div(
mload(add(_postBytes, 0x20)),
exp(0x100, sub(32, mlength))
),
exp(0x100, sub(32, newlength))
),
mul(mlength, 2)
)
)
)
}
case 1 {
mstore(0x0, _preBytes_slot)
let sc := add(keccak256(0x0, 0x20), div(slength, 32))
sstore(_preBytes_slot, add(mul(newlength, 2), 1))
let submod := sub(32, slength)
let mc := add(_postBytes, submod)
let end := add(_postBytes, mlength)
let mask := sub(exp(0x100, submod), 1)
sstore(
sc,
add(
and(
fslot,
0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff00
),
and(mload(mc), mask)
)
)
for {
mc := add(mc, 0x20)
sc := add(sc, 1)
} lt(mc, end) {
sc := add(sc, 1)
mc := add(mc, 0x20)
} {
sstore(sc, mload(mc))
}
mask := exp(0x100, sub(mc, end))
sstore(sc, mul(div(mload(mc), mask), mask))
}
default {
mstore(0x0, _preBytes_slot)
let sc := add(keccak256(0x0, 0x20), div(slength, 32))
sstore(_preBytes_slot, add(mul(newlength, 2), 1))
let slengthmod := mod(slength, 32)
let mlengthmod := mod(mlength, 32)
let submod := sub(32, slengthmod)
let mc := add(_postBytes, submod)
let end := add(_postBytes, mlength)
let mask := sub(exp(0x100, submod), 1)
sstore(sc, add(sload(sc), and(mload(mc), mask)))
for {
sc := add(sc, 1)
mc := add(mc, 0x20)
} lt(mc, end) {
sc := add(sc, 1)
mc := add(mc, 0x20)
} {
sstore(sc, mload(mc))
}
mask := exp(0x100, sub(mc, end))
sstore(sc, mul(div(mload(mc), mask), mask))
}
}
}
function slice(bytes _bytes, uint _start, uint _length) internal  pure returns (bytes) {
require(_bytes.length >= (_start + _length));
bytes memory tempBytes;
assembly {
switch iszero(_length)
case 0 {
tempBytes := mload(0x40)
let lengthmod := and(_length, 31)
let mc := add(add(tempBytes, lengthmod), mul(0x20, iszero(lengthmod)))
let end := add(mc, _length)
for {
let cc := add(add(add(_bytes, lengthmod), mul(0x20, iszero(lengthmod))), _start)
} lt(mc, end) {
mc := add(mc, 0x20)
cc := add(cc, 0x20)
} {
mstore(mc, mload(cc))
}
mstore(tempBytes, _length)
mstore(0x40, and(add(mc, 31), not(31)))
}
default {
tempBytes := mload(0x40)
mstore(0x40, add(tempBytes, 0x20))
}
}
return tempBytes;
}
function toAddress(bytes _bytes, uint _start) internal  pure returns (address) {
require(_bytes.length >= (_start + 20));
address tempAddress;
assembly {
tempAddress := div(mload(add(add(_bytes, 0x20), _start)), 0x1000000000000000000000000)
}
return tempAddress;
}
function toUint(bytes _bytes, uint _start) internal  pure returns (uint256) {
require(_bytes.length >= (_start + 32));
uint256 tempUint;
assembly {
tempUint := mload(add(add(_bytes, 0x20), _start))
}
return tempUint;
}
function equal(bytes memory _preBytes, bytes memory _postBytes) internal pure returns (bool) {
bool success = true;
assembly {
let length := mload(_preBytes)
switch eq(length, mload(_postBytes))
case 1 {
let cb := 1
let mc := add(_preBytes, 0x20)
let end := add(mc, length)
for {
let cc := add(_postBytes, 0x20)
} eq(add(lt(mc, end), cb), 2) {
mc := add(mc, 0x20)
cc := add(cc, 0x20)
} {
if iszero(eq(mload(mc), mload(cc))) {
success := 0
cb := 0
}
}
}
default {
success := 0
}
}
return success;
}
function equalStorage(bytes storage _preBytes, bytes memory _postBytes) internal view returns (bool) {
bool success = true;
assembly {
let fslot := sload(_preBytes_slot)
let slength := div(and(fslot, sub(mul(0x100, iszero(and(fslot, 1))), 1)), 2)
let mlength := mload(_postBytes)
switch eq(slength, mlength)
case 1 {
if iszero(iszero(slength)) {
switch lt(slength, 32)
case 1 {
fslot := mul(div(fslot, 0x100), 0x100)
if iszero(eq(fslot, mload(add(_postBytes, 0x20)))) {
success := 0
}
}
default {
let cb := 1
mstore(0x0, _preBytes_slot)
let sc := keccak256(0x0, 0x20)
let mc := add(_postBytes, 0x20)
let end := add(mc, mlength)
for {} eq(add(lt(mc, end), cb), 2) {
sc := add(sc, 1)
mc := add(mc, 0x20)
} {
if iszero(eq(sload(sc), mload(mc))) {
success := 0
cb := 0
}
}
}
}
}
default {
success := 0
}
}
return success;
}
}