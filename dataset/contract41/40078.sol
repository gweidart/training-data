pragma solidity ^0.4.4;
contract AbstractBlobStore {
function create(bytes4 flags, bytes contents) external returns (bytes20 blobId);
function createWithNonce(bytes32 flagsNonce, bytes contents) external returns (bytes20 blobId);
function createNewRevision(bytes20 blobId, bytes contents) external returns (uint revisionId);
function updateLatestRevision(bytes20 blobId, bytes contents) external;
function retractLatestRevision(bytes20 blobId) external;
function restart(bytes20 blobId, bytes contents) external;
function retract(bytes20 blobId) external;
function transferEnable(bytes20 blobId) external;
function transferDisable(bytes20 blobId) external;
function transfer(bytes20 blobId, address recipient) external;
function disown(bytes20 blobId) external;
function setNotUpdatable(bytes20 blobId) external;
function setEnforceRevisions(bytes20 blobId) external;
function setNotRetractable(bytes20 blobId) external;
function setNotTransferable(bytes20 blobId) external;
function getContractId() external constant returns (bytes12);
function getExists(bytes20 blobId) external constant returns (bool exists);
function getInfo(bytes20 blobId) external constant returns (bytes4 flags, address owner, uint revisionCount, uint[] blockNumbers);
function getFlags(bytes20 blobId) external constant returns (bytes4 flags);
function getUpdatable(bytes20 blobId) external constant returns (bool updatable);
function getEnforceRevisions(bytes20 blobId) external constant returns (bool enforceRevisions);
function getRetractable(bytes20 blobId) external constant returns (bool retractable);
function getTransferable(bytes20 blobId) external constant returns (bool transferable);
function getOwner(bytes20 blobId) external constant returns (address owner);
function getRevisionCount(bytes20 blobId) external constant returns (uint revisionCount);
function getAllRevisionBlockNumbers(bytes20 blobId) external constant returns (uint[] blockNumbers);
}
contract BlobStoreRegistry {
mapping (bytes12 => address) contractAddresses;
event Register(bytes12 indexed contractId, address indexed contractAddress);
modifier isNotRegistered(bytes12 contractId) {
if (contractAddresses[contractId] != 0) {
throw;
}
_;
}
modifier isRegistered(bytes12 contractId) {
if (contractAddresses[contractId] == 0) {
throw;
}
_;
}
function register(bytes12 contractId) external isNotRegistered(contractId) {
contractAddresses[contractId] = msg.sender;
Register(contractId, msg.sender);
}
function getBlobStore(bytes12 contractId) external constant isRegistered(contractId) returns (AbstractBlobStore blobStore) {
blobStore = AbstractBlobStore(contractAddresses[contractId]);
}
}