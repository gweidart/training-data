pragma solidity ^0.4.24;
interface BankForwarderInterface {
function deposit() external payable returns(bool);
function status() external view returns(address, address, bool);
function startMigration(address _newCorpBank) external returns(bool);
function cancelMigration() external returns(bool);
function finishMigration() external returns(bool);
function setup(address _firstCorpBank) external;
}
contract TeamManager {
BankForwarderInterface private TipJar = BankForwarderInterface(0x0);
MSFun.Data private msData;
function deleteAnyProposal(bytes32 _whatFunction) onlyDevs() public {MSFun.deleteProposal(msData, _whatFunction);}
function checkData(bytes32 _whatFunction) onlyAdmins() public view returns(bytes32 message_data, uint256 signature_count) {return(MSFun.checkMsgData(msData, _whatFunction), MSFun.checkCount(msData, _whatFunction));}
function checkSignersByName(bytes32 _whatFunction, uint256 _signerA, uint256 _signerB, uint256 _signerC) onlyAdmins() public view returns(bytes32, bytes32, bytes32) {return(this.adminName(MSFun.checkSigner(msData, _whatFunction, _signerA)), this.adminName(MSFun.checkSigner(msData, _whatFunction, _signerB)), this.adminName(MSFun.checkSigner(msData, _whatFunction, _signerC)));}
struct Admin {
bool isAdmin;
bool isDev;
bytes32 name;
}
mapping (address => Admin) admins_;
uint256 adminCount_;
uint256 devCount_;
uint256 requiredSignatures_;
uint256 requiredDevSignatures_;
constructor()
public
{
address alice = 0x0A6065569370BF9Ee13c3A0da1cf6201B1870576;
address bob   = 0x04369d3C731d1016Fae5fa516C964bdE64A2C92F;
address chloe = 0x3aE32614A97b2a7A6e05626856Df82635877ED56;
address david = 0xa7B254eedcbCe806CDbC94C20CDb639E1Ac75630;
address eve   = 0x9490b19a5A0536b99069A629095A24B9129DF0b6;
admins_[alice] = Admin(true, true, "alice");
admins_[bob]   = Admin(true, true, "bob");
admins_[chloe] = Admin(true, true, "chloe");
admins_[david] = Admin(true, true, "david");
admins_[eve]   = Admin(true, true, "eve");
adminCount_ = 5;
devCount_ = 5;
requiredSignatures_ = 1;
requiredDevSignatures_ = 1;
}
function ()
public
payable
{
TipJar.deposit.value(address(this).balance)();
}
function setup(address _addr)
onlyDevs()
public
{
require( address(TipJar) == address(0) );
TipJar = BankForwarderInterface(_addr);
}
modifier onlyDevs()
{
require(admins_[msg.sender].isDev == true, "onlyDevs failed - msg.sender is not a dev");
_;
}
modifier onlyAdmins()
{
require(admins_[msg.sender].isAdmin == true, "onlyAdmins failed - msg.sender is not an admin");
_;
}
function addAdmin(address _who, bytes32 _name, bool _isDev)
public
onlyDevs()
{
if (MSFun.multiSig(msData, requiredDevSignatures_, "addAdmin") == true)
{
MSFun.deleteProposal(msData, "addAdmin");
if (admins_[_who].isAdmin == false)
{
admins_[_who].isAdmin = true;
adminCount_ += 1;
requiredSignatures_ += 1;
}
if (_isDev == true)
{
admins_[_who].isDev = _isDev;
devCount_ += 1;
requiredDevSignatures_ += 1;
}
}
admins_[_who].name = _name;
}
function removeAdmin(address _who)
public
onlyDevs()
{
require(adminCount_ > 1, "removeAdmin failed - cannot have less than 2 admins");
require(adminCount_ >= requiredSignatures_, "removeAdmin failed - cannot have less admins than number of required signatures");
if (admins_[_who].isDev == true)
{
require(devCount_ > 1, "removeAdmin failed - cannot have less than 2 devs");
require(devCount_ >= requiredDevSignatures_, "removeAdmin failed - cannot have less devs than number of required dev signatures");
}
if (MSFun.multiSig(msData, requiredDevSignatures_, "removeAdmin") == true)
{
MSFun.deleteProposal(msData, "removeAdmin");
if (admins_[_who].isAdmin == true) {
admins_[_who].isAdmin = false;
adminCount_ -= 1;
if (requiredSignatures_ > 1)
{
requiredSignatures_ -= 1;
}
}
if (admins_[_who].isDev == true) {
admins_[_who].isDev = false;
devCount_ -= 1;
if (requiredDevSignatures_ > 1)
{
requiredDevSignatures_ -= 1;
}
}
}
}
function changeRequiredSignatures(uint256 _howMany)
public
onlyDevs()
{
require(_howMany > 0 && _howMany <= adminCount_, "changeRequiredSignatures failed - must be between 1 and number of admins");
if (MSFun.multiSig(msData, requiredDevSignatures_, "changeRequiredSignatures") == true)
{
MSFun.deleteProposal(msData, "changeRequiredSignatures");
requiredSignatures_ = _howMany;
}
}
function changeRequiredDevSignatures(uint256 _howMany)
public
onlyDevs()
{
require(_howMany > 0 && _howMany <= devCount_, "changeRequiredDevSignatures failed - must be between 1 and number of devs");
if (MSFun.multiSig(msData, requiredDevSignatures_, "changeRequiredDevSignatures") == true)
{
MSFun.deleteProposal(msData, "changeRequiredDevSignatures");
requiredDevSignatures_ = _howMany;
}
}
function requiredSignatures() external view returns(uint256) {return(requiredSignatures_);}
function requiredDevSignatures() external view returns(uint256) {return(requiredDevSignatures_);}
function adminCount() external view returns(uint256) {return(adminCount_);}
function devCount() external view returns(uint256) {return(devCount_);}
function adminName(address _who) external view returns(bytes32) {return(admins_[_who].name);}
function isAdmin(address _who) external view returns(bool) {return(admins_[_who].isAdmin);}
function isDev(address _who) external view returns(bool) {return(admins_[_who].isDev);}
}
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