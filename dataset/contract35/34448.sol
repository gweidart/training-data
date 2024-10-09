pragma solidity 0.4.15;
library SafeMath {
function mul(uint a, uint b) internal returns (uint) {
uint c = a * b;
assert(a == 0 || c / a == b);
return c;
}
function div(uint a, uint b) internal returns (uint) {
uint c = a / b;
return c;
}
function sub(uint a, uint b) internal returns (uint) {
assert(b <= a);
return a - b;
}
function add(uint a, uint b) internal returns (uint) {
uint c = a + b;
assert(c >= a);
return c;
}
function max64(uint64 a, uint64 b) internal constant returns (uint64) {
return a >= b ? a : b;
}
function min64(uint64 a, uint64 b) internal constant returns (uint64) {
return a < b ? a : b;
}
function max256(uint256 a, uint256 b) internal constant returns (uint256) {
return a >= b ? a : b;
}
function min256(uint256 a, uint256 b) internal constant returns (uint256) {
return a < b ? a : b;
}
}
contract Owned {
modifier onlyOwner() {
require(msg.sender == owner);
_;
}
address public owner;
function Owned() {
owner = msg.sender;
}
address public newOwner;
function changeOwner(address _newOwner) onlyOwner {
if(msg.sender == owner) {
owner = _newOwner;
}
}
}
contract DynamicCeiling is Owned {
using SafeMath for uint256;
struct Ceiling {
bytes32 hash;
uint256 limit;
uint256 slopeFactor;
uint256 collectMinimum;
}
address public saleAddress;
Ceiling[] public ceilings;
uint256 public currentIndex;
uint256 public revealedCeilings;
bool public allRevealed;
modifier onlySaleAddress {
require(msg.sender == saleAddress);
_;
}
function DynamicCeiling(address _owner, address _saleAddress) {
owner = _owner;
saleAddress = _saleAddress;
}
function setHiddenCeilings(bytes32[] _ceilingHashes) public onlyOwner {
require(ceilings.length == 0);
ceilings.length = _ceilingHashes.length;
for (uint256 i = 0; i < _ceilingHashes.length; i = i.add(1)) {
ceilings[i].hash = _ceilingHashes[i];
}
}
function revealCeiling(
uint256 _limit,
uint256 _slopeFactor,
uint256 _collectMinimum,
bool _last,
bytes32 _salt)
public
{
require(!allRevealed);
require(
ceilings[revealedCeilings].hash ==
calculateHash(
_limit,
_slopeFactor,
_collectMinimum,
_last,
_salt
)
);
require(_limit != 0 && _slopeFactor != 0 && _collectMinimum != 0);
if (revealedCeilings > 0) {
require(_limit >= ceilings[revealedCeilings.sub(1)].limit);
}
ceilings[revealedCeilings].limit = _limit;
ceilings[revealedCeilings].slopeFactor = _slopeFactor;
ceilings[revealedCeilings].collectMinimum = _collectMinimum;
revealedCeilings = revealedCeilings.add(1);
if (_last) {
allRevealed = true;
}
}
function revealMulti(
uint256[] _limits,
uint256[] _slopeFactors,
uint256[] _collectMinimums,
bool[] _lasts,
bytes32[] _salts)
public
{
require(
_limits.length != 0 &&
_limits.length == _slopeFactors.length &&
_limits.length == _collectMinimums.length &&
_limits.length == _lasts.length &&
_limits.length == _salts.length
);
for (uint256 i = 0; i < _limits.length; i = i.add(1)) {
revealCeiling(
_limits[i],
_slopeFactors[i],
_collectMinimums[i],
_lasts[i],
_salts[i]
);
}
}
function moveToNextCeiling() public onlyOwner {
currentIndex = currentIndex.add(1);
}
function availableAmountToCollect(uint256  totallCollected) public onlySaleAddress returns (uint256) {
if (revealedCeilings == 0) {
return 0;
}
if (totallCollected >= ceilings[currentIndex].limit) {
uint256 nextIndex = currentIndex.add(1);
if (nextIndex >= revealedCeilings) {
return 0;
}
currentIndex = nextIndex;
if (totallCollected >= ceilings[currentIndex].limit) {
return 0;
}
}
uint256 remainedFromCurrentCeiling = ceilings[currentIndex].limit.sub(totallCollected);
uint256 reminderWithSlopeFactor = remainedFromCurrentCeiling.div(ceilings[currentIndex].slopeFactor);
if (reminderWithSlopeFactor > ceilings[currentIndex].collectMinimum) {
return reminderWithSlopeFactor;
}
if (remainedFromCurrentCeiling > ceilings[currentIndex].collectMinimum) {
return ceilings[currentIndex].collectMinimum;
} else {
return remainedFromCurrentCeiling;
}
}
function calculateHash(
uint256 _limit,
uint256 _slopeFactor,
uint256 _collectMinimum,
bool _last,
bytes32 _salt)
public
constant
returns (bytes32)
{
return keccak256(
_limit,
_slopeFactor,
_collectMinimum,
_last,
_salt
);
}
function nCeilings() public constant returns (uint256) {
return ceilings.length;
}
}