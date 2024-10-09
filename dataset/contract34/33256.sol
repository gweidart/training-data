pragma solidity ^0.4.11;
contract IPFSEvents {
event HashAdded(address PubKey, string IPFSHash, uint ttl);
event HashRemoved(address PubKey, string IPFSHash);
}
contract Multimember {
struct PendingState {
uint yetNeeded;
uint membersDone;
uint index;
}
event Confirmation(address member, bytes32 operation);
event Revoke(address member, bytes32 operation);
event MemberChanged(address oldMember, address newMember);
event MemberAdded(address newMember);
event MemberRemoved(address oldMember);
event RequirementChanged(uint newRequirement);
modifier onlymember {
if (isMember(msg.sender))
_;
}
modifier onlymanymembers(bytes32 _operation) {
if (confirmAndCheck(_operation))
_;
}
function Multimember(address[] _members, uint _required) public {
m_numMembers = _members.length + 1;
m_members[1] = uint(msg.sender);
m_memberIndex[uint(msg.sender)] = 1;
for (uint i = 0; i < _members.length; ++i) {
m_members[2 + i] = uint(_members[i]);
m_memberIndex[uint(_members[i])] = 2 + i;
}
m_required = _required;
}
function revoke(bytes32 _operation) external {
uint memberIndex = m_memberIndex[uint(msg.sender)];
if (memberIndex == 0)
return;
uint memberIndexBit = 2**memberIndex;
var pending = m_pending[_operation];
if (pending.membersDone & memberIndexBit > 0) {
pending.yetNeeded++;
pending.membersDone -= memberIndexBit;
Revoke(msg.sender, _operation);
}
}
function changeMember(address _from, address _to) onlymanymembers(keccak256(_from,_to)) external {
if (isMember(_to))
return;
uint memberIndex = m_memberIndex[uint(_from)];
if (memberIndex == 0)
return;
clearPending();
m_members[memberIndex] = uint(_to);
m_memberIndex[uint(_from)] = 0;
m_memberIndex[uint(_to)] = memberIndex;
MemberChanged(_from, _to);
}
function addMember(address _member) onlymanymembers(keccak256(_member)) public {
if (isMember(_member))
return;
clearPending();
if (m_numMembers >= c_maxMembers)
reorganizeMembers();
if (m_numMembers >= c_maxMembers)
return;
m_numMembers++;
m_members[m_numMembers] = uint(_member);
m_memberIndex[uint(_member)] = m_numMembers;
MemberAdded(_member);
}
function removeMember(address _member) onlymanymembers(keccak256(_member)) public {
uint memberIndex = m_memberIndex[uint(_member)];
if (memberIndex == 0)
return;
if (m_required > m_numMembers - 1)
return;
m_members[memberIndex] = 0;
m_memberIndex[uint(_member)] = 0;
clearPending();
reorganizeMembers();
MemberRemoved(_member);
}
function changeRequirement(uint _newRequired) onlymanymembers(keccak256(_newRequired)) external {
if (_newRequired > m_numMembers)
return;
m_required = _newRequired;
clearPending();
RequirementChanged(_newRequired);
}
function isMember(address _addr) public constant returns (bool) {
return m_memberIndex[uint(_addr)] > 0;
}
function hasConfirmed(bytes32 _operation, address _member) external constant returns (bool) {
var pending = m_pending[_operation];
uint memberIndex = m_memberIndex[uint(_member)];
if (memberIndex == 0)
return false;
uint memberIndexBit = 2**memberIndex;
return !(pending.membersDone & memberIndexBit == 0);
}
function confirmAndCheck(bytes32 _operation) internal returns (bool) {
uint memberIndex = m_memberIndex[uint(msg.sender)];
if (memberIndex == 0)
return;
var pending = m_pending[_operation];
if (pending.yetNeeded == 0) {
pending.yetNeeded = m_required;
pending.membersDone = 0;
pending.index = m_pendingIndex.length++;
m_pendingIndex[pending.index] = _operation;
}
uint memberIndexBit = 2**memberIndex;
if (pending.membersDone & memberIndexBit == 0) {
Confirmation(msg.sender, _operation);
if (pending.yetNeeded <= 1) {
delete m_pendingIndex[m_pending[_operation].index];
delete m_pending[_operation];
return true;
} else {
pending.yetNeeded--;
pending.membersDone |= memberIndexBit;
}
}
}
function reorganizeMembers() private returns (bool) {
uint free = 1;
while (free < m_numMembers) {
while (free < m_numMembers && m_members[free] != 0) {
free++;
}
while (m_numMembers > 1 && m_members[m_numMembers] == 0) {
m_numMembers--;
}
if (free < m_numMembers && m_members[m_numMembers] != 0 && m_members[free] == 0) {
m_members[free] = m_members[m_numMembers];
m_memberIndex[m_members[free]] = free;
m_members[m_numMembers] = 0;
}
}
}
function clearPending() internal {
uint length = m_pendingIndex.length;
for (uint i = 0; i < length; ++i) {
if (m_pendingIndex[i] != 0) {
delete m_pending[m_pendingIndex[i]];
}
}
delete m_pendingIndex;
}
uint public m_required;
uint public m_numMembers;
uint[256] m_members;
uint constant c_maxMembers = 250;
mapping(uint => uint) m_memberIndex;
mapping(bytes32 => PendingState) m_pending;
bytes32[] m_pendingIndex;
}
contract IPFSProxy is IPFSEvents, Multimember {
mapping(address => mapping( address => bool)) public complained;
mapping(address => uint) public complaint;
uint public banThreshold;
uint public sizeLimit;
address[] members;
modifier onlyValidMembers {
require (isMember(msg.sender));
_;
}
event ContractAdded(address PubKey, uint ttl);
event ContractRemoved(address PubKey);
event Banned(string IPFSHash);
event BanAttempt(address complainer, address _Member, uint complaints );
event PersistLimitChanged(uint Limit);
function IPFSProxy() Multimember (members, 1) public {
addContract(this, 0);
updateBanThreshold(1);
setTotalPersistLimit(10000000000);
}
function addHash(string _IPFSHash, uint _ttl) public onlyValidMembers {
HashAdded(msg.sender,_IPFSHash,_ttl);
}
function removeHash(string _IPFSHash) public onlyValidMembers {
HashRemoved(msg.sender,_IPFSHash);
}
function addContract(address _toWatch, uint _ttl) public onlyValidMembers {
ContractAdded(_toWatch, _ttl);
}
function removeContract(address _contractAddress) public onlyValidMembers {
ContractRemoved(_contractAddress);
}
function banMember (address _Member, string _evidence) public onlyValidMembers {
require(isMember(_Member));
require(!complained[msg.sender][_Member]);
complained[msg.sender][_Member] = true;
complaint[_Member] += 1;
if (complaint[_Member] >= banThreshold) {
removeMember(_Member);
if (!isMember(_Member)) {
Banned(_evidence);
}
} else {
BanAttempt(msg.sender, _Member, complaint[_Member]);
}
}
function updateBanThreshold (uint _banThreshold) public onlymanymembers(keccak256(_banThreshold)) {
banThreshold = _banThreshold;
}
function setTotalPersistLimit (uint _limit) public onlymanymembers(keccak256(_limit)) {
sizeLimit = _limit;
PersistLimitChanged(_limit);
}
}