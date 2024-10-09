pragma solidity ^0.4.11;
interface IEthIdentity {
function addProof(address, bytes32) public returns(bool);
function removeProof(address, bytes32) public returns(bool);
function checkOwner(address) public constant returns(bool);
function getIdentityName() public constant returns(bytes32);
}
contract eSignature {
struct DocStruct {
bytes32 hash;
IEthIdentity issuerIdentity;
uint nbSignatories;
mapping(address => bool) signatoryAddresses;
mapping(uint => IEthIdentity) signatories;
}
uint public count;
mapping(bytes20 => DocStruct) docs;
event DocCreated(bytes20 key);
event DocSigned(bytes20 key, IEthIdentity identity);
function newDoc(bytes32 hash, IEthIdentity issuerId) public returns (bytes20 docKey) {
require(issuerId.checkOwner.gas(800)(msg.sender));
count++;
docKey = ripemd160(issuerId, count);
assert(checkExists(docKey) == false);
docs[docKey].issuerIdentity = issuerId;
docs[docKey].hash = hash;
DocCreated(docKey);
}
function newSignedDoc(bytes32 hash, IEthIdentity ethIdentity) public returns (bytes20 docKey) {
docKey = newDoc(hash, ethIdentity);
require(docs[docKey].signatoryAddresses[ethIdentity] == false);
docs[docKey].signatoryAddresses[ethIdentity] = true;
docs[docKey].signatories[docs[docKey].nbSignatories] = ethIdentity;
docs[docKey].nbSignatories++;
DocSigned(docKey, ethIdentity);
}
function signDoc(bytes20 docKey, IEthIdentity ethIdentity) public {
require(ethIdentity.checkOwner.gas(800)(msg.sender));
require(docs[docKey].signatoryAddresses[ethIdentity] == false);
docs[docKey].signatoryAddresses[ethIdentity] = true;
docs[docKey].signatories[docs[docKey].nbSignatories] = ethIdentity;
docs[docKey].nbSignatories++;
DocSigned(docKey, ethIdentity);
}
function getDoc(bytes20 docKey) public constant returns (bytes32 hash, IEthIdentity issuer, uint nbSignatories) {
if (checkExists(docKey))
return (docs[docKey].hash, docs[docKey].issuerIdentity, docs[docKey].nbSignatories);
else
return ("No a valid key", IEthIdentity(0x0), 0);
}
function getSignatory(bytes20 docKey, uint index) public constant returns (IEthIdentity identity, string identityName) {
if (checkExists(docKey)) {
require(index < docs[docKey].nbSignatories);
identity = docs[docKey].signatories[index];
identityName = bytes32ToString(identity.getIdentityName());
return (identity, identityName);
} else {
return (IEthIdentity(0x0), "");
}
}
function checkExists(bytes20 docKey) public constant returns(bool) {
return docs[docKey].issuerIdentity != address(0x0);
}
function bytes32ToString (bytes32 data) internal pure returns (string) {
bytes memory bytesString = new bytes(32);
for (uint j=0; j<32; j++){
if (data[j] != 0) {
bytesString[j] = data[j];
}
}
return string(bytesString);
}
}