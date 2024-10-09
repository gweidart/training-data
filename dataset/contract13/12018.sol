pragma solidity 0.4.24;
interface BBFarmIface {
event BBFarmInit(bytes4 namespace);
event BallotCreatedWithID(uint ballotId);
function upgradeMe(address newSC) external;
function getNamespace() external view returns (bytes4);
function getVersion() external view returns (uint);
function getBBLibVersion() external view returns (uint256);
function getNBallots() external view returns (uint256);
function initBallot( bytes32 specHash
, uint256 packed
, IxIface ix
, address bbAdmin
, bytes24 extraData
) external returns (uint ballotId);
function sponsor(uint ballotId) external payable;
function submitVote(uint ballotId, bytes32 vote, bytes extra) external;
function submitProxyVote(bytes32[5] proxyReq, bytes extra) external;
function getDetails(uint ballotId, address voter) external view returns
( bool hasVoted
, uint nVotesCast
, bytes32 secKey
, uint16 submissionBits
, uint64 startTime
, uint64 endTime
, bytes32 specHash
, bool deprecated
, address ballotOwner
, bytes16 extraData);
function getVote(uint ballotId, uint voteId) external view returns (bytes32 voteData, address sender, bytes extra);
function getTotalSponsorship(uint ballotId) external view returns (uint);
function getSponsorsN(uint ballotId) external view returns (uint);
function getSponsor(uint ballotId, uint sponsorN) external view returns (address sender, uint amount);
function getCreationTs(uint ballotId) external view returns (uint);
function revealSeckey(uint ballotId, bytes32 sk) external;
function setEndTime(uint ballotId, uint64 newEndTime) external;
function setDeprecated(uint ballotId) external;
function setBallotOwner(uint ballotId, address newOwner) external;
}
library BBLib {
using BytesLib for bytes;
uint256 constant BB_VERSION = 5;
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
function getVersion() external view returns (uint) {
return BB_VERSION;
}
function init(DB storage db, bytes32 _specHash, uint256 _packed, IxIface ix, address ballotOwner, bytes16 extraData) external {
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
require(db.specHash == bytes32(0), "b-exists");
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
function submitProxyVote(DB storage db, bytes32[5] proxyReq, bytes extra) external {
bytes32 r = proxyReq[0];
bytes32 s = proxyReq[1];
uint8 v = uint8(proxyReq[2][0]);
bytes31 proxyReq2 = bytes31(uint248(proxyReq[2]));
bytes32 ballotId = proxyReq[3];
bytes32 voteData = proxyReq[4];
bytes memory signed = abi.encodePacked(proxyReq2, ballotId, voteData, extra);
bytes32 msgHash = keccak256(signed);
address voter = ecrecover(msgHash, v, r, s);
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
interface BallotBoxIface {
function getVersion() external pure returns (uint256);
function getVote(uint256) external view returns (bytes32 voteData, address sender, bytes32 encPK);
function getDetails(address voter) external view returns (
bool hasVoted,
uint nVotesCast,
bytes32 secKey,
uint16 submissionBits,
uint64 startTime,
uint64 endTime,
bytes32 specHash,
bool deprecated,
address ballotOwner);
function getTotalSponsorship() external view returns (uint);
function submitVote(bytes32 voteData, bytes32 encPK) external;
function revealSeckey(bytes32 sk) external;
function setEndTime(uint64 newEndTime) external;
function setDeprecated() external;
function setOwner(address) external;
function getOwner() external view returns (address);
event CreatedBallot(bytes32 specHash, uint64 startTs, uint64 endTs, uint16 submissionBits);
event SuccessfulVote(address indexed voter, uint voteId);
event SeckeyRevealed(bytes32 secretKey);
}
interface BBAuxIface {
function isTesting(BallotBoxIface bb) external view returns (bool);
function isOfficial(BallotBoxIface bb) external view returns (bool);
function isBinding(BallotBoxIface bb) external view returns (bool);
function qualifiesAsCommunityBallot(BallotBoxIface bb) external view returns (bool);
function isDeprecated(BallotBoxIface bb) external view returns (bool);
function getEncSeckey(BallotBoxIface bb) external view returns (bytes32);
function getSpecHash(BallotBoxIface bb) external view returns (bytes32);
function getSubmissionBits(BallotBoxIface bb) external view returns (uint16);
function getStartTime(BallotBoxIface bb) external view returns (uint64);
function getEndTime(BallotBoxIface bb) external view returns (uint64);
function getNVotesCast(BallotBoxIface bb) external view returns (uint256 nVotesCast);
function hasVoted(BallotBoxIface bb, address voter) external view returns (bool hv);
}
interface IxIface {
function doUpgrade(address) external;
function addBBFarm(BBFarmIface bbFarm) external returns (uint8 bbFarmId);
function emergencySetABackend(bytes32 toSet, address newSC) external;
function emergencySetBBFarm(uint8 bbFarmId, address _bbFarm) external;
function emergencySetDAdmin(bytes32 democHash, address newAdmin) external;
function getPayments() external view returns (IxPaymentsIface);
function getBackend() external view returns (IxBackendIface);
function getBBFarm(uint8 bbFarmId) external view returns (BBFarmIface);
function getBBFarmID(bytes4 bbNamespace) external view returns (uint8 bbFarmId);
function getVersion() external view returns (uint256);
function dInit(address defualtErc20) external payable returns (bytes32);
function setDErc20(bytes32 democHash, address newErc20) external;
function dAddCategory(bytes32 democHash, bytes32 categoryName, bool hasParent, uint parent) external returns (uint);
function dDeprecateCategory(bytes32 democHash, uint categoryId) external;
function dUpgradeToPremium(bytes32 democHash) external;
function dDowngradeToBasic(bytes32 democHash) external;
function dSetArbitraryData(bytes32 democHash, bytes key, bytes value) external;
function dAddBallot(bytes32 democHash, uint ballotId, uint256 packed) external;
function dDeployBallot(bytes32 democHash, bytes32 specHash, bytes32 extraData, uint256 packed) external payable returns (uint);
event PaymentMade(uint[2] valAndRemainder);
event Emergency(bytes32 setWhat);
event EmergencyDemocAdmin(bytes32 democHash, address newAdmin);
event EmergencyBBFarm(uint16 bbFarmId);
event AddedBBFarm(uint16 bbFarmId);
event ManuallyAddedBallot(bytes32 democHash, uint256 ballotId, uint256 packed);
event NewBallot(bytes32 indexed democHash, uint ballotN);
event NewDemoc(bytes32 democHash);
event DemocAdminSet(bytes32 indexed democHash, address admin);
event BallotCreatedWithID(uint ballotId);
}
interface IxPaymentsIface {
function upgradeMe(address) external;
function payoutAll() external;
function setPayTo(address) external;
function getPayTo() external view returns (address);
function setMinorEditsAddr(address) external;
function getCommunityBallotCentsPrice() external view returns (uint);
function setCommunityBallotCentsPrice(uint) external;
function getCommunityBallotWeiPrice() external view returns (uint);
function setBasicCentsPricePer30Days(uint amount) external;
function getBasicCentsPricePer30Days() external view returns(uint);
function getBasicExtraBallotFeeWei() external view returns (uint);
function getBasicBallotsPer30Days() external view returns (uint);
function setBasicBallotsPer30Days(uint amount) external;
function setPremiumMultiplier(uint8 amount) external;
function getPremiumMultiplier() external view returns (uint8);
function getPremiumCentsPricePer30Days() external view returns (uint);
function setWeiPerCent(uint) external;
function setFreeExtension(bytes32 democHash, bool hasFreeExt) external;
function getWeiPerCent() external view returns (uint weiPerCent);
function getUsdEthExchangeRate() external view returns (uint centsPerEth);
function weiBuysHowManySeconds(uint amount) external view returns (uint secs);
function downgradeToBasic(bytes32 democHash) external;
function upgradeToPremium(bytes32 democHash) external;
function doFreeExtension(bytes32 democHash) external;
function payForDemocracy(bytes32 democHash) external payable;
function accountInGoodStanding(bytes32 democHash) external view returns (bool);
function getSecondsRemaining(bytes32 democHash) external view returns (uint);
function getPremiumStatus(bytes32 democHash) external view returns (bool);
function getAccount(bytes32 democHash) external view returns (bool isPremium, uint lastPaymentTs, uint paidUpTill, bool hasFreeExtension);
function getFreeExtension(bytes32 democHash) external view returns (bool);
function giveTimeToDemoc(bytes32 democHash, uint additionalSeconds, bytes32 ref) external;
function setDenyPremium(bytes32 democHash, bool isPremiumDenied) external;
function getDenyPremium(bytes32 democHash) external view returns (bool);
function getPaymentLogN() external view returns (uint);
function getPaymentLog(uint n) external view returns (bool _external, bytes32 _democHash, uint _seconds, uint _ethValue);
event UpgradedToPremium(bytes32 indexed democHash);
event GrantedAccountTime(bytes32 indexed democHash, uint additionalSeconds, bytes32 ref);
event AccountPayment(bytes32 indexed democHash, uint additionalSeconds);
event SetCommunityBallotFee(uint amount);
event SetBasicCentsPricePer30Days(uint amount);
event SetPremiumMultiplier(uint8 multiplier);
event DowngradeToBasic(bytes32 indexed democHash);
event UpgradeToPremium(bytes32 indexed democHash);
event SetExchangeRate(uint weiPerCent);
event FreeExtension(bytes32 democHash);
}
interface IxBackendIface {
function upgradeMe(address) external;
function getGDemocsN() external view returns (uint);
function getGDemoc(uint id) external view returns (bytes32);
function getGErc20ToDemocs(address erc20) external view returns (bytes32[] democHashes);
function dInit(address defaultErc20) external returns (bytes32);
function dAddBallot(bytes32 democHash, uint ballotId, uint256 packed, bool recordTowardsBasicLimit) external;
function dAddCategory(bytes32 democHash, bytes32 categoryName, bool hasParent, uint parent) external returns (uint);
function dDeprecateCategory(bytes32 democHash, uint categoryId) external;
function setDAdmin(bytes32 democHash, address newAdmin) external;
function setDErc20(bytes32 democHash, address newErc20) external;
function dSetArbitraryData(bytes32 democHash, bytes key, bytes value) external;
function getDInfo(bytes32 democHash) external view returns (address erc20, address admin, uint256 nBallots);
function getDErc20(bytes32 democHash) external view returns (address);
function getDAdmin(bytes32 democHash) external view returns (address);
function getDArbitraryData(bytes32 democHash, bytes key) external view returns (bytes value);
function getDBallotsN(bytes32 democHash) external view returns (uint256);
function getDBallotID(bytes32 democHash, uint n) external view returns (uint ballotId);
function getDCountedBasicBallotsN(bytes32 democHash) external view returns (uint256);
function getDCountedBasicBallotID(bytes32 democHash, uint256 n) external view returns (uint256);
function getDCategoriesN(bytes32 democHash) external view returns (uint);
function getDCategory(bytes32 democHash, uint categoryId) external view returns (bool deprecated, bytes32 name, bool hasParent, uint parent);
function getDHash(bytes13 prefix) external view returns (bytes32);
event NewBallot(bytes32 indexed democHash, uint ballotN);
event NewDemoc(bytes32 democHash);
event DemocAdminSet(bytes32 indexed democHash, address admin);
}
contract SVBallotConsts {
uint16 constant USE_ETH = 1;
uint16 constant USE_SIGNED = 2;
uint16 constant USE_NO_ENC = 4;
uint16 constant USE_ENC = 8;
uint16 constant IS_BINDING = 8192;
uint16 constant IS_OFFICIAL = 16384;
uint16 constant USE_TESTING = 32768;
}
contract safeSend {
bool private txMutex3847834;
function doSafeSend(address toAddr, uint amount) internal {
doSafeSendWData(toAddr, "", amount);
}
function doSafeSendWData(address toAddr, bytes data, uint amount) internal {
require(txMutex3847834 == false, "ss-guard");
txMutex3847834 = true;
require(toAddr.call.value(amount)(data), "ss-failed");
txMutex3847834 = false;
}
}
contract payoutAllC is safeSend {
address _payTo;
constructor() public {
_payTo = msg.sender;
}
function payoutAll() external {
doSafeSend(_payTo, address(this).balance);
}
}
contract owned {
address public owner;
event OwnerChanged(address newOwner);
modifier only_owner() {
require(msg.sender == owner, "only_owner: forbidden");
_;
}
constructor() public {
owner = msg.sender;
}
function setOwner(address newOwner) only_owner() external {
owner = newOwner;
emit OwnerChanged(newOwner);
}
}
contract hasAdmins is owned {
mapping (uint => mapping (address => bool)) admins;
uint public currAdminEpoch = 0;
bool public adminsDisabledForever = false;
address[] adminLog;
event AdminAdded(address indexed newAdmin);
event AdminRemoved(address indexed oldAdmin);
event AdminEpochInc();
event AdminDisabledForever();
modifier only_admin() {
require(adminsDisabledForever == false, "admins must not be disabled");
require(isAdmin(msg.sender), "only_admin: forbidden");
_;
}
constructor() public {
_setAdmin(msg.sender, true);
}
function isAdmin(address a) view public returns (bool) {
return admins[currAdminEpoch][a];
}
function getAdminLogN() view external returns (uint) {
return adminLog.length;
}
function getAdminLog(uint n) view external returns (address) {
return adminLog[n];
}
function upgradeMeAdmin(address newAdmin) only_admin() external {
require(msg.sender != owner, "owner cannot upgrade self");
_setAdmin(msg.sender, false);
_setAdmin(newAdmin, true);
}
function setAdmin(address a, bool _givePerms) only_admin() external {
require(a != msg.sender && a != owner, "cannot change your own (or owner's) permissions");
_setAdmin(a, _givePerms);
}
function _setAdmin(address a, bool _givePerms) internal {
admins[currAdminEpoch][a] = _givePerms;
if (_givePerms) {
emit AdminAdded(a);
adminLog.push(a);
} else {
emit AdminRemoved(a);
}
}
function incAdminEpoch() only_owner() external {
currAdminEpoch++;
admins[currAdminEpoch][msg.sender] = true;
emit AdminEpochInc();
}
function disableAdminForever() internal {
currAdminEpoch++;
adminsDisabledForever = true;
emit AdminDisabledForever();
}
}
contract permissioned is owned, hasAdmins {
mapping (address => bool) editAllowed;
bool public adminLockdown = false;
event PermissionError(address editAddr);
event PermissionGranted(address editAddr);
event PermissionRevoked(address editAddr);
event PermissionsUpgraded(address oldSC, address newSC);
event SelfUpgrade(address oldSC, address newSC);
event AdminLockdown();
modifier only_editors() {
require(editAllowed[msg.sender], "only_editors: forbidden");
_;
}
modifier no_lockdown() {
require(adminLockdown == false, "no_lockdown: check failed");
_;
}
constructor() owned() hasAdmins() public {
}
function setPermissions(address e, bool _editPerms) no_lockdown() only_admin() external {
editAllowed[e] = _editPerms;
if (_editPerms)
emit PermissionGranted(e);
else
emit PermissionRevoked(e);
}
function upgradePermissionedSC(address oldSC, address newSC) no_lockdown() only_admin() external {
editAllowed[oldSC] = false;
editAllowed[newSC] = true;
emit PermissionsUpgraded(oldSC, newSC);
}
function upgradeMe(address newSC) only_editors() external {
editAllowed[msg.sender] = false;
editAllowed[newSC] = true;
emit SelfUpgrade(msg.sender, newSC);
}
function hasPermissions(address a) public view returns (bool) {
return editAllowed[a];
}
function doLockdown() external only_owner() no_lockdown() {
disableAdminForever();
adminLockdown = true;
emit AdminLockdown();
}
}
contract upgradePtr {
address ptr = address(0);
modifier not_upgraded() {
require(ptr == address(0), "upgrade pointer is non-zero");
_;
}
function getUpgradePointer() view external returns (address) {
return ptr;
}
function doUpgradeInternal(address nextSC) internal {
ptr = nextSC;
}
}
interface ERC20Interface {
function totalSupply() constant external returns (uint256 _totalSupply);
function balanceOf(address _owner) constant external returns (uint256 balance);
function transfer(address _to, uint256 _value) external returns (bool success);
function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);
function approve(address _spender, uint256 _value) external returns (bool success);
function allowance(address _owner, address _spender) constant external returns (uint256 remaining);
event Transfer(address indexed _from, address indexed _to, uint256 _value);
event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}
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
library MemArrApp {
function appendUint256(uint256[] memory arr, uint256 val) internal pure returns (uint256[] memory toRet) {
toRet = new uint256[](arr.length + 1);
for (uint256 i = 0; i < arr.length; i++) {
toRet[i] = arr[i];
}
toRet[arr.length] = val;
}
function appendUint128(uint128[] memory arr, uint128 val) internal pure returns (uint128[] memory toRet) {
toRet = new uint128[](arr.length + 1);
for (uint256 i = 0; i < arr.length; i++) {
toRet[i] = arr[i];
}
toRet[arr.length] = val;
}
function appendUint64(uint64[] memory arr, uint64 val) internal pure returns (uint64[] memory toRet) {
toRet = new uint64[](arr.length + 1);
for (uint256 i = 0; i < arr.length; i++) {
toRet[i] = arr[i];
}
toRet[arr.length] = val;
}
function appendUint32(uint32[] memory arr, uint32 val) internal pure returns (uint32[] memory toRet) {
toRet = new uint32[](arr.length + 1);
for (uint256 i = 0; i < arr.length; i++) {
toRet[i] = arr[i];
}
toRet[arr.length] = val;
}
function appendUint16(uint16[] memory arr, uint16 val) internal pure returns (uint16[] memory toRet) {
toRet = new uint16[](arr.length + 1);
for (uint256 i = 0; i < arr.length; i++) {
toRet[i] = arr[i];
}
toRet[arr.length] = val;
}
function appendBool(bool[] memory arr, bool val) internal pure returns (bool[] memory toRet) {
toRet = new bool[](arr.length + 1);
for (uint256 i = 0; i < arr.length; i++) {
toRet[i] = arr[i];
}
toRet[arr.length] = val;
}
function appendBytes32(bytes32[] memory arr, bytes32 val) internal pure returns (bytes32[] memory toRet) {
toRet = new bytes32[](arr.length + 1);
for (uint256 i = 0; i < arr.length; i++) {
toRet[i] = arr[i];
}
toRet[arr.length] = val;
}
function appendBytes32Pair(bytes32[2][] memory arr, bytes32[2] val) internal pure returns (bytes32[2][] memory toRet) {
toRet = new bytes32[2][](arr.length + 1);
for (uint256 i = 0; i < arr.length; i++) {
toRet[i] = arr[i];
}
toRet[arr.length] = val;
}
function appendBytes(bytes[] memory arr, bytes val) internal pure returns (bytes[] memory toRet) {
toRet = new bytes[](arr.length + 1);
for (uint256 i = 0; i < arr.length; i++) {
toRet[i] = arr[i];
}
toRet[arr.length] = val;
}
function appendAddress(address[] memory arr, address val) internal pure returns (address[] memory toRet) {
toRet = new address[](arr.length + 1);
for (uint256 i = 0; i < arr.length; i++) {
toRet[i] = arr[i];
}
toRet[arr.length] = val;
}
}