pragma solidity ^0.4.24;
library ECRecovery {
function recover(bytes32 hash, bytes sig)
internal
pure
returns (address)
{
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
function toEthSignedMessageHash(bytes32 hash)
internal
pure
returns (bytes32)
{
return keccak256(
abi.encodePacked("\x19Ethereum Signed Message:\n32", hash)
);
}
}
contract AuctionChannel {
uint8 public constant PHASE_OPEN = 0;
uint8 public constant PHASE_CHALLENGE = 1;
uint8 public constant PHASE_CLOSED = 2;
address public auctioneer;
address public assistant;
uint8 public phase;
uint256 public minBidValue;
uint256 public challengePeriod;
uint256 public closingBlock;
bytes public winnerBidder;
uint256 public winnerBidValue;
constructor
(
address _auctioneer,
address _assistant,
uint256 _challengePeriod,
uint256 _minBidValue,
bytes _signatureAuctioneer,
bytes _signatureAssistant
)
public
{
bytes32 _fingerprint = keccak256(
abi.encodePacked(
"openingAuctionChannel",
_auctioneer,
_assistant,
_challengePeriod,
_minBidValue
)
);
_fingerprint = ECRecovery.toEthSignedMessageHash(_fingerprint);
require(_auctioneer == ECRecovery.recover(_fingerprint, _signatureAuctioneer));
require(_assistant == ECRecovery.recover(_fingerprint, _signatureAssistant));
auctioneer = _auctioneer;
assistant = _assistant;
challengePeriod = _challengePeriod;
minBidValue = _minBidValue;
}
function updateWinnerBid(
bool _isAskBid,
bytes _bidder,
uint256 _bidValue,
bytes _previousBidHash,
bytes _signatureAssistant,
bytes _signatureAuctioneer
)
external
{
tryClose();
require(phase != PHASE_CLOSED);
require(!_isAskBid);
require(_bidValue > winnerBidValue);
require(_bidValue >= minBidValue);
bytes32 _fingerprint = keccak256(
abi.encodePacked(
"auctionBid",
_isAskBid,
_bidder,
_bidValue,
_previousBidHash
)
);
_fingerprint = ECRecovery.toEthSignedMessageHash(_fingerprint);
require(auctioneer == ECRecovery.recover(_fingerprint, _signatureAuctioneer));
require(assistant == ECRecovery.recover(_fingerprint, _signatureAssistant));
winnerBidder = _bidder;
winnerBidValue = _bidValue;
closingBlock = block.number + challengePeriod;
phase = PHASE_CHALLENGE;
}
function tryClose() public {
if (phase == PHASE_CHALLENGE && block.number > closingBlock) {
phase = PHASE_CLOSED;
}
}
}