pragma solidity ^0.4.16;
contract HashRegistry {
struct StoredIn {
uint storageId;
address storedBy;
}
mapping(uint => StoredIn) storeMap;
string[] storageNames;
function store(uint hash, uint storageId) public {
address storedBy = storeMap[hash].storedBy;
require(storedBy == 0 || storedBy == msg.sender);
require(storageId < storageNames.length);
storeMap[hash] = StoredIn(storageId, msg.sender);
}
function addStorage(string storageName) public {
storageNames.push(storageName);
}
}