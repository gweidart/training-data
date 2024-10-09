pragma solidity 0.4.18;
library SafeMath {
function mul(uint256 a, uint256 b) internal pure returns (uint256) {
if (a == 0) {
return 0;
}
uint256 c = a * b;
assert(c / a == b);
return c;
}
function div(uint256 a, uint256 b) internal pure returns (uint256) {
uint256 c = a / b;
return c;
}
function sub(uint256 a, uint256 b) internal pure returns (uint256) {
assert(b <= a);
return a - b;
}
function add(uint256 a, uint256 b) internal pure returns (uint256) {
uint256 c = a + b;
assert(c >= a);
return c;
}
}
library MerkleProof {
function verifyProof(bytes _proof, bytes32 _root, bytes32 _leaf) public pure returns (bool) {
if (_proof.length % 32 != 0) return false;
bytes32 proofElement;
bytes32 computedHash = _leaf;
for (uint256 i = 32; i <= _proof.length; i += 32) {
assembly {
proofElement := mload(add(_proof, i))
}
if (computedHash < proofElement) {
computedHash = keccak256(computedHash, proofElement);
} else {
computedHash = keccak256(proofElement, computedHash);
}
}
return computedHash == _root;
}
}
library ECRecovery {
function recover(bytes32 hash, bytes sig) public pure returns (address) {
bytes32 r;
bytes32 s;
uint8 v;
if (sig.length != 65) {
return (address(0));
}
assembly {
r := mload(add(sig, 32))
s := mload(add(sig, 64))
v := byte(0, mload(add(sig, 96)))
}
if (v < 27) {
v += 27;
}
if (v != 27 && v != 28) {
return (address(0));
} else {
return ecrecover(hash, v, r, s);
}
}
}
library JobLib {
using SafeMath for uint256;
string constant PERSONAL_HASH_PREFIX = "\u0019Ethereum Signed Message:\n32";
uint8 constant VIDEO_PROFILE_SIZE = 8;
function validTranscodingOptions(string _transcodingOptions) public pure returns (bool) {
uint256 transcodingOptionsLength = bytes(_transcodingOptions).length;
return transcodingOptionsLength > 0 && transcodingOptionsLength % VIDEO_PROFILE_SIZE == 0;
}
function calcFees(uint256 _totalSegments, string _transcodingOptions, uint256 _pricePerSegment) public pure returns (uint256) {
uint256 totalProfiles = bytes(_transcodingOptions).length.div(VIDEO_PROFILE_SIZE);
return _totalSegments.mul(totalProfiles).mul(_pricePerSegment);
}
function shouldVerifySegment(
uint256 _segmentNumber,
uint256[2] _segmentRange,
uint256 _challengeBlock,
bytes32 _challengeBlockHash,
uint64 _verificationRate
)
public
pure
returns (bool)
{
if (_segmentNumber < _segmentRange[0] || _segmentNumber > _segmentRange[1]) {
return false;
}
if (uint256(keccak256(_challengeBlock, _challengeBlockHash, _segmentNumber)) % _verificationRate == 0) {
return true;
} else {
return false;
}
}
function validateBroadcasterSig(
string _streamId,
uint256 _segmentNumber,
bytes32 _dataHash,
bytes _broadcasterSig,
address _broadcaster
)
public
pure
returns (bool)
{
return ECRecovery.recover(personalSegmentHash(_streamId, _segmentNumber, _dataHash), _broadcasterSig) == _broadcaster;
}
function validateReceipt(
string _streamId,
uint256 _segmentNumber,
bytes32 _dataHash,
bytes32 _transcodedDataHash,
bytes _broadcasterSig,
bytes _proof,
bytes32 _claimRoot
)
public
pure
returns (bool)
{
return MerkleProof.verifyProof(_proof, _claimRoot, transcodeReceiptHash(_streamId, _segmentNumber, _dataHash, _transcodedDataHash, _broadcasterSig));
}
function segmentHash(string _streamId, uint256 _segmentNumber, bytes32 _dataHash) public pure returns (bytes32) {
return keccak256(_streamId, _segmentNumber, _dataHash);
}
function personalSegmentHash(string _streamId, uint256 _segmentNumber, bytes32 _dataHash) public pure returns (bytes32) {
bytes memory prefixBytes = bytes(PERSONAL_HASH_PREFIX);
return keccak256(prefixBytes, segmentHash(_streamId, _segmentNumber, _dataHash));
}
function transcodeReceiptHash(
string _streamId,
uint256 _segmentNumber,
bytes32 _dataHash,
bytes32 _transcodedDataHash,
bytes _broadcasterSig
)
public
pure
returns (bytes32)
{
return keccak256(_streamId, _segmentNumber, _dataHash, _transcodedDataHash, _broadcasterSig);
}
}