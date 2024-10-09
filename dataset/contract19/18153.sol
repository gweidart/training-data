pragma solidity ^0.4.19;
contract IPFSEvents {
event HashAdded(string hash, uint ttl);
event HashRemoved(string hash);
event MetadataObjectAdded(string hash);
event MetadataObjectRemoved(string hash);
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
if (m_numMembers >= MAXMEMBERS)
reorganizeMembers();
if (m_numMembers >= MAXMEMBERS)
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
uint constant MAXMEMBERS = 250;
mapping(uint => uint) m_memberIndex;
mapping(bytes32 => PendingState) m_pending;
bytes32[] m_pendingIndex;
}
contract IPFSProxy is IPFSEvents, Multimember {
uint public persistLimit;
event PersistLimitChanged(uint limit);
event ContractAdded(address pubKey,uint startBlock);
event ContractRemoved(address pubKey);
function IPFSProxy(address[] _members,uint _required, uint _persistlimit) Multimember (_members, _required) public {
setTotalPersistLimit(_persistlimit);
for (uint i = 0; i < _members.length; ++i) {
MemberAdded(_members[i]);
}
addContract(this,block.number);
}
function addHash(string _ipfsHash, uint _ttl) public onlymember {
HashAdded(_ipfsHash,_ttl);
}
function removeHash(string _ipfsHash) public onlymember {
HashRemoved(_ipfsHash);
}
function addContract(address _contractAddress,uint _startBlock) public onlymember {
ContractAdded(_contractAddress,_startBlock);
}
function removeContract(address _contractAddress) public onlymember {
require(_contractAddress != address(this));
ContractRemoved(_contractAddress);
}
function addMetadataObject(string _metadataHash) public onlymember {
HashAdded(_metadataHash,0);
MetadataObjectAdded(_metadataHash);
}
function removeMetadataObject(string _metadataHash) public onlymember {
HashRemoved(_metadataHash);
MetadataObjectRemoved(_metadataHash);
}
function setTotalPersistLimit (uint _limit) public onlymanymembers(keccak256(_limit)) {
persistLimit = _limit;
PersistLimitChanged(_limit);
}
}