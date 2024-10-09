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
library MathUtils {
using SafeMath for uint256;
uint256 public constant PERC_DIVISOR = 1000000;
function validPerc(uint256 _amount) internal pure returns (bool) {
return _amount <= PERC_DIVISOR;
}
function percOf(uint256 _amount, uint256 _fracNum, uint256 _fracDenom) internal pure returns (uint256) {
return _amount.mul(percPoints(_fracNum, _fracDenom)).div(PERC_DIVISOR);
}
function percOf(uint256 _amount, uint256 _fracNum) internal pure returns (uint256) {
return _amount.mul(_fracNum).div(PERC_DIVISOR);
}
function percPoints(uint256 _fracNum, uint256 _fracDenom) internal pure returns (uint256) {
return _fracNum.mul(PERC_DIVISOR).div(_fracDenom);
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
contract Ownable {
address public owner;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
function Ownable() public {
owner = msg.sender;
}
modifier onlyOwner() {
require(msg.sender == owner);
_;
}
function transferOwnership(address newOwner) public onlyOwner {
require(newOwner != address(0));
OwnershipTransferred(owner, newOwner);
owner = newOwner;
}
}
contract Pausable is Ownable {
event Pause();
event Unpause();
bool public paused = false;
modifier whenNotPaused() {
require(!paused);
_;
}
modifier whenPaused() {
require(paused);
_;
}
function pause() onlyOwner whenNotPaused public {
paused = true;
Pause();
}
function unpause() onlyOwner whenPaused public {
paused = false;
Unpause();
}
}
contract IController is Pausable {
event SetContractInfo(bytes32 id, address contractAddress, bytes20 gitCommitHash);
function setContractInfo(bytes32 _id, address _contractAddress, bytes20 _gitCommitHash) external;
function updateController(bytes32 _id, address _controller) external;
function getContract(bytes32 _id) public view returns (address);
}
contract IManager {
event SetController(address controller);
event ParameterUpdate(string param);
function setController(address _controller) external;
}
contract Manager is IManager {
IController public controller;
modifier onlyController() {
require(msg.sender == address(controller));
_;
}
modifier onlyControllerOwner() {
require(msg.sender == controller.owner());
_;
}
modifier whenSystemNotPaused() {
require(!controller.paused());
_;
}
modifier whenSystemPaused() {
require(controller.paused());
_;
}
function Manager(address _controller) public {
controller = IController(_controller);
}
function setController(address _controller) external onlyController {
controller = IController(_controller);
SetController(_controller);
}
}
contract ManagerProxyTarget is Manager {
bytes32 public targetContractId;
}
contract IMinter {
event SetCurrentRewardTokens(uint256 currentMintableTokens, uint256 currentInflation);
function createReward(uint256 _fracNum, uint256 _fracDenom) external returns (uint256);
function trustedTransferTokens(address _to, uint256 _amount) external;
function trustedBurnTokens(uint256 _amount) external;
function trustedWithdrawETH(address _to, uint256 _amount) external;
function depositETH() external payable returns (bool);
function setCurrentRewardTokens() external;
function getController() public view returns (IController);
}
contract IVerifier {
function verify(
uint256 _jobId,
uint256 _claimId,
uint256 _segmentNumber,
string _transcodingOptions,
string _dataStorageHash,
bytes32[2] _dataHashes
)
external
payable;
function getPrice() public view returns (uint256);
}
contract IRoundsManager {
event NewRound(uint256 round);
function initializeRound() external;
function blockNum() public view returns (uint256);
function blockHash(uint256 _block) public view returns (bytes32);
function currentRound() public view returns (uint256);
function currentRoundStartBlock() public view returns (uint256);
function currentRoundInitialized() public view returns (bool);
function currentRoundLocked() public view returns (bool);
}
contract IBondingManager {
event TranscoderUpdate(address indexed transcoder, uint256 pendingRewardCut, uint256 pendingFeeShare, uint256 pendingPricePerSegment, bool registered);
event TranscoderEvicted(address indexed transcoder);
event TranscoderResigned(address indexed transcoder);
event TranscoderSlashed(address indexed transcoder, address finder, uint256 penalty, uint256 finderReward);
event Reward(address indexed transcoder, uint256 amount);
event Bond(address indexed delegate, address indexed delegator);
event Unbond(address indexed delegate, address indexed delegator);
event WithdrawStake(address indexed delegator);
event WithdrawFees(address indexed delegator);
function setActiveTranscoders() external;
function updateTranscoderWithFees(address _transcoder, uint256 _fees, uint256 _round) external;
function slashTranscoder(address _transcoder, address _finder, uint256 _slashAmount, uint256 _finderFee) external;
function electActiveTranscoder(uint256 _maxPricePerSegment, bytes32 _blockHash, uint256 _round) external view returns (address);
function transcoderTotalStake(address _transcoder) public view returns (uint256);
function activeTranscoderTotalStake(address _transcoder, uint256 _round) public view returns (uint256);
function isRegisteredTranscoder(address _transcoder) public view returns (bool);
function getTotalBonded() public view returns (uint256);
}
contract IVerifiable {
function receiveVerification(uint256 _jobId, uint256 _claimId, uint256 _segmentNumber, bool _result) external;
}
contract IJobsManager {
event Deposit(address indexed broadcaster, uint256 amount);
event Withdraw(address indexed broadcaster);
event NewJob(address indexed broadcaster, uint256 jobId, string streamId, string transcodingOptions, uint256 maxPricePerSegment, uint256 creationBlock);
event NewClaim(address indexed transcoder, uint256 indexed jobId, uint256 claimId);
event Verify(address indexed transcoder, uint256 indexed jobId, uint256 indexed claimId, uint256 segmentNumber);
event DistributeFees(address indexed transcoder, uint256 indexed jobId, uint256 indexed claimId, uint256 fees);
event PassedVerification(address indexed transcoder, uint256 indexed jobId, uint256 indexed claimId, uint256 segmentNumber);
event FailedVerification(address indexed transcoder, uint256 indexed jobId, uint256 indexed claimId, uint256 segmentNumber);
}
contract JobsManager is ManagerProxyTarget, IVerifiable, IJobsManager {
using SafeMath for uint256;
uint64 public verificationRate;
uint256 public verificationPeriod;
uint256 public verificationSlashingPeriod;
uint256 public failedVerificationSlashAmount;
uint256 public missedVerificationSlashAmount;
uint256 public doubleClaimSegmentSlashAmount;
uint256 public finderFee;
struct Broadcaster {
uint256 deposit;
uint256 withdrawBlock;
}
mapping (address => Broadcaster) public broadcasters;
struct Job {
uint256 jobId;
string streamId;
string transcodingOptions;
uint256 maxPricePerSegment;
address broadcasterAddress;
address transcoderAddress;
uint256 creationRound;
uint256 creationBlock;
uint256 endBlock;
Claim[] claims;
uint256 escrow;
}
enum JobStatus { Inactive, Active }
struct Claim {
uint256 claimId;
uint256[2] segmentRange;
bytes32 claimRoot;
uint256 claimBlock;
uint256 endVerificationBlock;
uint256 endVerificationSlashingBlock;
mapping (uint256 => bool) segmentVerifications;
ClaimStatus status;
}
enum ClaimStatus { Pending, Slashed, Complete }
mapping (uint256 => Job) public jobs;
uint256 public numJobs;
modifier onlyVerifier() {
require(msg.sender == controller.getContract(keccak256("Verifier")));
_;
}
modifier jobExists(uint256 _jobId) {
require(_jobId < numJobs);
_;
}
modifier sufficientPayment() {
require(msg.value >= verifier().getPrice());
_;
}
function JobsManager(address _controller) public Manager(_controller) {}
function setVerificationRate(uint64 _verificationRate) external onlyControllerOwner {
require(_verificationRate > 0);
verificationRate = _verificationRate;
ParameterUpdate("verificationRate");
}
function setVerificationPeriod(uint256 _verificationPeriod) external onlyControllerOwner {
require(_verificationPeriod.add(verificationSlashingPeriod) <= 256);
verificationPeriod = _verificationPeriod;
ParameterUpdate("verificationPeriod");
}
function setVerificationSlashingPeriod(uint256 _verificationSlashingPeriod) external onlyControllerOwner {
require(verificationPeriod.add(_verificationSlashingPeriod) <= 256);
verificationSlashingPeriod = _verificationSlashingPeriod;
ParameterUpdate("verificationSlashingPeriod");
}
function setFailedVerificationSlashAmount(uint256 _failedVerificationSlashAmount) external onlyControllerOwner {
require(MathUtils.validPerc(_failedVerificationSlashAmount));
failedVerificationSlashAmount = _failedVerificationSlashAmount;
ParameterUpdate("failedVerificationSlashAmount");
}
function setMissedVerificationSlashAmount(uint256 _missedVerificationSlashAmount) external onlyControllerOwner {
require(MathUtils.validPerc(_missedVerificationSlashAmount));
missedVerificationSlashAmount = _missedVerificationSlashAmount;
ParameterUpdate("missedVerificationSlashAmount");
}
function setDoubleClaimSegmentSlashAmount(uint256 _doubleClaimSegmentSlashAmount) external onlyControllerOwner {
require(MathUtils.validPerc(_doubleClaimSegmentSlashAmount));
doubleClaimSegmentSlashAmount = _doubleClaimSegmentSlashAmount;
ParameterUpdate("doubleClaimSegmentSlashAmount");
}
function setFinderFee(uint256 _finderFee) external onlyControllerOwner {
require(MathUtils.validPerc(_finderFee));
finderFee = _finderFee;
}
function deposit() external payable whenSystemNotPaused {
broadcasters[msg.sender].deposit = broadcasters[msg.sender].deposit.add(msg.value);
minter().depositETH.value(msg.value)();
Deposit(msg.sender, msg.value);
}
function withdraw() external whenSystemNotPaused {
require(broadcasters[msg.sender].withdrawBlock <= roundsManager().blockNum());
uint256 amount = broadcasters[msg.sender].deposit;
delete broadcasters[msg.sender];
minter().trustedWithdrawETH(msg.sender, amount);
Withdraw(msg.sender);
}
function job(string _streamId, string _transcodingOptions, uint256 _maxPricePerSegment, uint256 _endBlock)
external
whenSystemNotPaused
{
uint256 blockNum = roundsManager().blockNum();
require(_endBlock > blockNum);
require(JobLib.validTranscodingOptions(_transcodingOptions));
Job storage job = jobs[numJobs];
job.jobId = numJobs;
job.streamId = _streamId;
job.transcodingOptions = _transcodingOptions;
job.maxPricePerSegment = _maxPricePerSegment;
job.broadcasterAddress = msg.sender;
job.creationRound = roundsManager().currentRound();
job.creationBlock = blockNum;
job.endBlock = _endBlock;
NewJob(
msg.sender,
numJobs,
_streamId,
_transcodingOptions,
_maxPricePerSegment,
blockNum
);
numJobs = numJobs.add(1);
if (_endBlock > broadcasters[msg.sender].withdrawBlock) {
broadcasters[msg.sender].withdrawBlock = _endBlock;
}
}
function claimWork(uint256 _jobId, uint256[2] _segmentRange, bytes32 _claimRoot)
external
whenSystemNotPaused
jobExists(_jobId)
{
Job storage job = jobs[_jobId];
require(jobStatus(_jobId) != JobStatus.Inactive);
require(_segmentRange[1] >= _segmentRange[0]);
require(bondingManager().isRegisteredTranscoder(msg.sender));
uint256 blockNum = roundsManager().blockNum();
if (job.transcoderAddress != address(0)) {
require(job.transcoderAddress == msg.sender);
} else {
require(bondingManager().electActiveTranscoder(job.maxPricePerSegment, roundsManager().blockHash(job.creationBlock), job.creationRound) == msg.sender);
job.transcoderAddress = msg.sender;
}
uint256 fees = JobLib.calcFees(_segmentRange[1].sub(_segmentRange[0]).add(1), job.transcodingOptions, job.maxPricePerSegment);
broadcasters[job.broadcasterAddress].deposit = broadcasters[job.broadcasterAddress].deposit.sub(fees);
job.escrow = job.escrow.add(fees);
uint256 endVerificationBlock = blockNum.add(verificationPeriod);
uint256 endVerificationSlashingBlock = endVerificationBlock.add(verificationSlashingPeriod);
job.claims.push(
Claim({
claimId: job.claims.length,
segmentRange: _segmentRange,
claimRoot: _claimRoot,
claimBlock: blockNum,
endVerificationBlock: endVerificationBlock,
endVerificationSlashingBlock: endVerificationSlashingBlock,
status: ClaimStatus.Pending
})
);
NewClaim(job.transcoderAddress, _jobId, job.claims.length - 1);
}
function verify(
uint256 _jobId,
uint256 _claimId,
uint256 _segmentNumber,
string _dataStorageHash,
bytes32[2] _dataHashes,
bytes _broadcasterSig,
bytes _proof
)
external
payable
whenSystemNotPaused
sufficientPayment
jobExists(_jobId)
{
Job storage job = jobs[_jobId];
Claim storage claim = job.claims[_claimId];
require(job.transcoderAddress == msg.sender);
uint256 challengeBlock = claim.claimBlock + 1;
require(JobLib.shouldVerifySegment(_segmentNumber, claim.segmentRange, challengeBlock, roundsManager().blockHash(challengeBlock), verificationRate));
require(
JobLib.validateBroadcasterSig(
job.streamId,
_segmentNumber,
_dataHashes[0],
_broadcasterSig,
job.broadcasterAddress
)
);
require(
JobLib.validateReceipt(
job.streamId,
_segmentNumber,
_dataHashes[0],
_dataHashes[1],
_broadcasterSig,
_proof,
claim.claimRoot
)
);
claim.segmentVerifications[_segmentNumber] = true;
invokeVerification(_jobId, _claimId, _segmentNumber, _dataStorageHash, _dataHashes);
Verify(msg.sender, _jobId, _claimId, _segmentNumber);
}
function invokeVerification(
uint256 _jobId,
uint256 _claimId,
uint256 _segmentNumber,
string _dataStorageHash,
bytes32[2] _dataHashes
)
internal
{
IVerifier verifierContract = verifier();
uint256 price = verifierContract.getPrice();
if (price > 0) {
verifierContract.verify.value(price)(
_jobId,
_claimId,
_segmentNumber,
jobs[_jobId].transcodingOptions,
_dataStorageHash,
_dataHashes
);
} else {
require(msg.value == 0);
verifierContract.verify(
_jobId,
_claimId,
_segmentNumber,
jobs[_jobId].transcodingOptions,
_dataStorageHash,
_dataHashes
);
}
}
function receiveVerification(uint256 _jobId, uint256 _claimId, uint256 _segmentNumber, bool _result)
external
whenSystemNotPaused
onlyVerifier
jobExists(_jobId)
{
Job storage job = jobs[_jobId];
Claim storage claim = job.claims[_claimId];
require(claim.status != ClaimStatus.Slashed);
require(claim.segmentVerifications[_segmentNumber]);
address transcoder = job.transcoderAddress;
if (!_result) {
refundBroadcaster(_jobId);
claim.status = ClaimStatus.Slashed;
bondingManager().slashTranscoder(transcoder, address(0), failedVerificationSlashAmount, 0);
FailedVerification(transcoder, _jobId, _claimId, _segmentNumber);
} else {
PassedVerification(transcoder, _jobId, _claimId, _segmentNumber);
}
}
function batchDistributeFees(uint256 _jobId, uint256[] _claimIds)
external
whenSystemNotPaused
{
for (uint256 i = 0; i < _claimIds.length; i++) {
distributeFees(_jobId, _claimIds[i]);
}
}
function missedVerificationSlash(uint256 _jobId, uint256 _claimId, uint256 _segmentNumber)
external
whenSystemNotPaused
jobExists(_jobId)
{
Job storage job = jobs[_jobId];
Claim storage claim = job.claims[_claimId];
uint256 blockNum = roundsManager().blockNum();
uint256 challengeBlock = claim.claimBlock + 1;
require(blockNum >= claim.endVerificationBlock);
require(blockNum < claim.endVerificationSlashingBlock);
require(claim.status == ClaimStatus.Pending);
require(JobLib.shouldVerifySegment(_segmentNumber, claim.segmentRange, challengeBlock, roundsManager().blockHash(challengeBlock), verificationRate));
require(!claim.segmentVerifications[_segmentNumber]);
refundBroadcaster(_jobId);
bondingManager().slashTranscoder(job.transcoderAddress, msg.sender, missedVerificationSlashAmount, finderFee);
claim.status = ClaimStatus.Slashed;
}
function doubleClaimSegmentSlash(
uint256 _jobId,
uint256 _claimId1,
uint256 _claimId2,
uint256 _segmentNumber
)
external
whenSystemNotPaused
jobExists(_jobId)
{
Job storage job = jobs[_jobId];
Claim storage claim1 = job.claims[_claimId1];
Claim storage claim2 = job.claims[_claimId2];
require(claim1.status != ClaimStatus.Slashed);
require(claim2.status != ClaimStatus.Slashed);
require(_segmentNumber >= claim1.segmentRange[0] && _segmentNumber <= claim1.segmentRange[1]);
require(_segmentNumber >= claim2.segmentRange[0] && _segmentNumber <= claim2.segmentRange[1]);
bondingManager().slashTranscoder(job.transcoderAddress, msg.sender, doubleClaimSegmentSlashAmount, finderFee);
refundBroadcaster(_jobId);
claim1.status = ClaimStatus.Slashed;
claim2.status = ClaimStatus.Slashed;
}
function distributeFees(uint256 _jobId, uint256 _claimId)
public
whenSystemNotPaused
jobExists(_jobId)
{
Job storage job = jobs[_jobId];
Claim storage claim = job.claims[_claimId];
require(job.transcoderAddress == msg.sender);
require(claim.status == ClaimStatus.Pending);
require(claim.endVerificationSlashingBlock <= roundsManager().blockNum());
uint256 fees = JobLib.calcFees(claim.segmentRange[1].sub(claim.segmentRange[0]).add(1), job.transcodingOptions, job.maxPricePerSegment);
job.escrow = job.escrow.sub(fees);
bondingManager().updateTranscoderWithFees(msg.sender, fees, job.creationRound);
claim.status = ClaimStatus.Complete;
DistributeFees(msg.sender, _jobId, _claimId, fees);
}
function jobStatus(uint256 _jobId) public view returns (JobStatus) {
if (jobs[_jobId].endBlock <= roundsManager().blockNum()) {
return JobStatus.Inactive;
} else {
return JobStatus.Active;
}
}
function getJob(
uint256 _jobId
)
public
view
returns (string streamId, string transcodingOptions, uint256 maxPricePerSegment, address broadcasterAddress, address transcoderAddress, uint256 creationRound, uint256 creationBlock, uint256 endBlock, uint256 escrow, uint256 totalClaims)
{
Job storage job = jobs[_jobId];
streamId = job.streamId;
transcodingOptions = job.transcodingOptions;
maxPricePerSegment = job.maxPricePerSegment;
broadcasterAddress = job.broadcasterAddress;
transcoderAddress = job.transcoderAddress;
creationRound = job.creationRound;
creationBlock = job.creationBlock;
endBlock = job.endBlock;
escrow = job.escrow;
totalClaims = job.claims.length;
}
function getClaim(
uint256 _jobId,
uint256 _claimId
)
public
view
returns (uint256[2] segmentRange, bytes32 claimRoot, uint256 claimBlock, uint256 endVerificationBlock, uint256 endVerificationSlashingBlock, ClaimStatus status)
{
Claim storage claim = jobs[_jobId].claims[_claimId];
segmentRange = claim.segmentRange;
claimRoot = claim.claimRoot;
claimBlock = claim.claimBlock;
endVerificationBlock = claim.endVerificationBlock;
endVerificationSlashingBlock = claim.endVerificationSlashingBlock;
status = claim.status;
}
function isClaimSegmentVerified(
uint256 _jobId,
uint256 _claimId,
uint256 _segmentNumber
)
public
view
returns (bool)
{
return jobs[_jobId].claims[_claimId].segmentVerifications[_segmentNumber];
}
function refundBroadcaster(uint256 _jobId) internal {
Job storage job = jobs[_jobId];
uint256 fees = job.escrow;
job.escrow = job.escrow.sub(fees);
broadcasters[job.broadcasterAddress].deposit = broadcasters[job.broadcasterAddress].deposit.add(fees);
job.endBlock = roundsManager().blockNum();
}
function minter() internal view returns (IMinter) {
return IMinter(controller.getContract(keccak256("Minter")));
}
function bondingManager() internal view returns (IBondingManager) {
return IBondingManager(controller.getContract(keccak256("BondingManager")));
}
function roundsManager() internal view returns (IRoundsManager) {
return IRoundsManager(controller.getContract(keccak256("RoundsManager")));
}
function verifier() internal view returns (IVerifier) {
return IVerifier(controller.getContract(keccak256("Verifier")));
}
}