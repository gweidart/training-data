pragma solidity ^0.4.8;
contract PassDao {
struct revision {
address committeeRoom;
address shareManager;
address tokenManager;
uint startDate;
}
revision[] public revisions;
struct project {
address contractAddress;
uint startDate;
}
project[] public projects;
mapping (address => uint) projectID;
address metaProject;
event Upgrade(uint indexed RevisionID, address CommitteeRoom, address ShareManager, address TokenManager);
event NewProject(address Project);
function ActualCommitteeRoom() constant returns (address) {
return revisions[0].committeeRoom;
}
function MetaProject() constant returns (address) {
return metaProject;
}
function ActualShareManager() constant returns (address) {
return revisions[0].shareManager;
}
function ActualTokenManager() constant returns (address) {
return revisions[0].tokenManager;
}
modifier onlyPassCommitteeRoom {if (msg.sender != revisions[0].committeeRoom
&& revisions[0].committeeRoom != 0) throw; _;}
function PassDao() {
projects.length = 1;
revisions.length = 1;
}
function upgrade(
address _newCommitteeRoom,
address _newShareManager,
address _newTokenManager) onlyPassCommitteeRoom returns (uint) {
uint _revisionID = revisions.length++;
revision r = revisions[_revisionID];
if (_newCommitteeRoom != 0) r.committeeRoom = _newCommitteeRoom; else r.committeeRoom = revisions[0].committeeRoom;
if (_newShareManager != 0) r.shareManager = _newShareManager; else r.shareManager = revisions[0].shareManager;
if (_newTokenManager != 0) r.tokenManager = _newTokenManager; else r.tokenManager = revisions[0].tokenManager;
r.startDate = now;
revisions[0] = r;
Upgrade(_revisionID, _newCommitteeRoom, _newShareManager, _newTokenManager);
return _revisionID;
}
function addMetaProject(address _projectAddress) onlyPassCommitteeRoom {
metaProject = _projectAddress;
}
function addProject(address _projectAddress) onlyPassCommitteeRoom {
if (projectID[_projectAddress] == 0) {
uint _projectID = projects.length++;
project p = projects[_projectID];
projectID[_projectAddress] = _projectID;
p.contractAddress = _projectAddress;
p.startDate = now;
NewProject(_projectAddress);
}
}
}
pragma solidity ^0.4.8;
contract PassProject {
PassDao public passDao;
string public name;
string public description;
bytes32 public hashOfTheDocument;
address projectManager;
struct order {
address contractorAddress;
uint contractorProposalID;
uint amount;
uint orderDate;
}
order[] public orders;
uint public totalAmountOfOrders;
struct resolution {
string name;
string description;
uint creationDate;
}
resolution[] public resolutions;
event OrderAdded(address indexed Client, address indexed ContractorAddress, uint indexed ContractorProposalID, uint Amount, uint OrderDate);
event ProjectDescriptionUpdated(address indexed By, string NewDescription, bytes32 NewHashOfTheDocument);
event ResolutionAdded(address indexed Client, uint indexed ResolutionID, string Name, string Description);
function Client() constant returns (address) {
return passDao.ActualCommitteeRoom();
}
function numberOfOrders() constant returns (uint) {
return orders.length - 1;
}
function ProjectManager() constant returns (address) {
return projectManager;
}
function numberOfResolutions() constant returns (uint) {
return resolutions.length - 1;
}
modifier onlyProjectManager {if (msg.sender != projectManager) throw; _;}
modifier onlyClient {if (msg.sender != Client()) throw; _;}
function PassProject(
PassDao _passDao,
string _name,
string _description,
bytes32 _hashOfTheDocument) {
passDao = _passDao;
name = _name;
description = _description;
hashOfTheDocument = _hashOfTheDocument;
orders.length = 1;
resolutions.length = 1;
}
function addOrder(
address _contractorAddress,
uint _contractorProposalID,
uint _amount,
uint _orderDate) internal {
uint _orderID = orders.length++;
order d = orders[_orderID];
d.contractorAddress = _contractorAddress;
d.contractorProposalID = _contractorProposalID;
d.amount = _amount;
d.orderDate = _orderDate;
totalAmountOfOrders += _amount;
OrderAdded(msg.sender, _contractorAddress, _contractorProposalID, _amount, _orderDate);
}
function cloneOrder(
address _contractorAddress,
uint _contractorProposalID,
uint _orderAmount,
uint _lastOrderDate) {
if (projectManager != 0) throw;
addOrder(_contractorAddress, _contractorProposalID, _orderAmount, _lastOrderDate);
}
function setProjectManager(address _projectManager) returns (bool) {
if (_projectManager == 0 || projectManager != 0) return;
projectManager = _projectManager;
return true;
}
function updateDescription(string _projectDescription, bytes32 _hashOfTheDocument) onlyProjectManager {
description = _projectDescription;
hashOfTheDocument = _hashOfTheDocument;
ProjectDescriptionUpdated(msg.sender, _projectDescription, _hashOfTheDocument);
}
function newOrder(
address _contractorAddress,
uint _contractorProposalID,
uint _amount) onlyClient {
addOrder(_contractorAddress, _contractorProposalID, _amount, now);
}
function newResolution(
string _name,
string _description) onlyClient {
uint _resolutionID = resolutions.length++;
resolution d = resolutions[_resolutionID];
d.name = _name;
d.description = _description;
d.creationDate = now;
ResolutionAdded(msg.sender, _resolutionID, d.name, d.description);
}
}
contract PassProjectCreator {
event NewPassProject(PassDao indexed Dao, PassProject indexed Project, string Name, string Description, bytes32 HashOfTheDocument);
function createProject(
PassDao _passDao,
string _name,
string _description,
bytes32 _hashOfTheDocument
) returns (PassProject) {
PassProject _passProject = new PassProject(_passDao, _name, _description, _hashOfTheDocument);
NewPassProject(_passDao, _passProject, _name, _description, _hashOfTheDocument);
return _passProject;
}
}