pragma solidity ^0.4.24;
library MSFun {
struct Data
{
mapping (bytes32 => ProposalData) proposal_;
}
struct ProposalData
{
bytes32 msgData;
uint256 count;
mapping (address => bool) admin;
mapping (uint256 => address) log;
}
function multiSig(Data storage self, uint256 _requiredSignatures, bytes32 _whatFunction)
internal
returns(bool)
{
bytes32 _whatProposal = whatProposal(_whatFunction);
uint256 _currentCount = self.proposal_[_whatProposal].count;
address _whichAdmin = msg.sender;
bytes32 _msgData = keccak256(msg.data);
if (_currentCount == 0)
{
self.proposal_[_whatProposal].msgData = _msgData;
self.proposal_[_whatProposal].admin[_whichAdmin] = true;
self.proposal_[_whatProposal].log[_currentCount] = _whichAdmin;
self.proposal_[_whatProposal].count += 1;
if (self.proposal_[_whatProposal].count == _requiredSignatures) {
return(true);
}
} else if (self.proposal_[_whatProposal].msgData == _msgData) {
if (self.proposal_[_whatProposal].admin[_whichAdmin] == false)
{
self.proposal_[_whatProposal].admin[_whichAdmin] = true;
self.proposal_[_whatProposal].log[_currentCount] = _whichAdmin;
self.proposal_[_whatProposal].count += 1;
}
if (self.proposal_[_whatProposal].count == _requiredSignatures) {
return(true);
}
}
}
function deleteProposal(Data storage self, bytes32 _whatFunction)
internal
{
bytes32 _whatProposal = whatProposal(_whatFunction);
address _whichAdmin;
for (uint256 i=0; i < self.proposal_[_whatProposal].count; i++) {
_whichAdmin = self.proposal_[_whatProposal].log[i];
delete self.proposal_[_whatProposal].admin[_whichAdmin];
delete self.proposal_[_whatProposal].log[i];
}
delete self.proposal_[_whatProposal];
}
function whatProposal(bytes32 _whatFunction)
private
view
returns(bytes32)
{
return(keccak256(abi.encodePacked(_whatFunction,this)));
}
function checkMsgData (Data storage self, bytes32 _whatFunction)
internal
view
returns (bytes32 msg_data)
{
bytes32 _whatProposal = whatProposal(_whatFunction);
return (self.proposal_[_whatProposal].msgData);
}
function checkCount (Data storage self, bytes32 _whatFunction)
internal
view
returns (uint256 signature_count)
{
bytes32 _whatProposal = whatProposal(_whatFunction);
return (self.proposal_[_whatProposal].count);
}
function checkSigner (Data storage self, bytes32 _whatFunction, uint256 _signer)
internal
view
returns (address signer)
{
require(_signer > 0, "MSFun checkSigner failed - 0 not allowed");
bytes32 _whatProposal = whatProposal(_whatFunction);
return (self.proposal_[_whatProposal].log[_signer - 1]);
}
}