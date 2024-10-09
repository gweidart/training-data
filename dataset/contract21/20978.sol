pragma solidity ^0.4.11;
interface IEthIdentity {
function addProof(address, bytes32) public returns(bool);
function removeProof(address, bytes32) public returns(bool);
function checkOwner(address) public constant returns(bool);
function getIdentityName() public constant returns(bytes32);
}
contract EthIdentity is IEthIdentity {
address public owner;
address private override;
bytes32 private identityName;
function EthIdentity(bytes32 _name) public {
owner = msg.sender;
override = msg.sender;
identityName = _name;
}
uint constant ERROR_EVENT = 119;
uint constant INFO_EVENT = 115;
event EventNotification(address indexed sender, uint indexed status, bytes32 message);
mapping(bytes32 => address) proofList;
function addProof(address _source, bytes32 _attribute) public onlyBy(owner) returns(bool) {
require(_source != address(0x0));
bool existed = checkProof(_attribute);
if (existed == true) {
EventNotification(msg.sender, ERROR_EVENT, "Proof already exist");
return false;
}
proofList[_attribute] = _source;
EventNotification(msg.sender, INFO_EVENT, "New proof added");
return true;
}
function removeProof(address _source, bytes32 _attribute) public onlyBy(owner) returns(bool) {
bool existed = checkProof(_attribute);
if (existed == false) {
EventNotification(msg.sender, ERROR_EVENT, "Proof not found");
return false;
}
if (proofList[_attribute] != _source) {
EventNotification(msg.sender, ERROR_EVENT, "Incorrect source");
return false;
}
delete proofList[_attribute];
EventNotification(msg.sender, INFO_EVENT, "Proof removed");
return true;
}
function checkProof(bytes32 _attribute) public constant returns(bool) {
var source = proofList[_attribute];
if (source != address(0x0))
return true;
return false;
}
function checkOwner(address _check) public constant returns(bool) {
return _check == owner;
}
function getIdentityName() public constant returns(bytes32) {
return identityName;
}
function nameOfIdentity() public constant returns(string) {
return bytes32ToString(identityName);
}
function getIdentityInfo() public constant returns(address, address, string) {
return (override, owner, bytes32ToString(identityName));
}
function setIdentityName(bytes32 _newName) public onlyBy(owner) returns(bool) {
identityName = _newName;
EventNotification(msg.sender, INFO_EVENT, "Set owner name");
return true;
}
function setOwner(address _newOwner) public onlyBy(override) returns(bool) {
owner = _newOwner;
EventNotification(msg.sender, INFO_EVENT, "Set new owner");
return true;
}
function setOverride(address _newOverride) public onlyBy(override) returns(bool) {
override = _newOverride;
EventNotification(msg.sender, INFO_EVENT, "Set new override");
return true;
}
function bytes32ToString(bytes32 data) internal pure returns (string) {
bytes memory bytesString = new bytes(32);
for (uint j=0; j<32; j++){
if (data[j] != 0) {
bytesString[j] = data[j];
}
}
return string(bytesString);
}
modifier onlyBy(address _authorized) {
assert(msg.sender == _authorized);
_;
}
}