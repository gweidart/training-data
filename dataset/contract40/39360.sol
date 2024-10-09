pragma solidity ^0.4.0;
contract AbstractENS {
function owner(bytes32 node) constant returns(address);
function resolver(bytes32 node) constant returns(address);
function ttl(bytes32 node) constant returns(uint64);
function setOwner(bytes32 node, address owner);
function setSubnodeOwner(bytes32 node, bytes32 label, address owner);
function setResolver(bytes32 node, address resolver);
function setTTL(bytes32 node, uint64 ttl);
event NewOwner(bytes32 indexed node, bytes32 indexed label, address owner);
event Transfer(bytes32 indexed node, address owner);
event NewResolver(bytes32 indexed node, address resolver);
event NewTTL(bytes32 indexed node, uint64 ttl);
}
contract PublicResolver {
bytes4 constant ADDR_INTERFACE_ID = 0x3b3b57de;
bytes4 constant CONTENT_INTERFACE_ID = 0xd8389dc5;
bytes4 constant ABI_INTERFACE_ID = 0x2203ab56;
bytes4 constant PUBKEY_INTERFACE_ID = 0xc8690233;
struct PublicKey {
bytes32 x;
bytes32 y;
}
struct Record {
address addr;
bytes32 content;
PublicKey pubkey;
mapping(uint256=>bytes) abis;
}
AbstractENS ens;
mapping(bytes32=>Record) records;
modifier only_owner(bytes32 node) {
if(ens.owner(node) != msg.sender) throw;
_;
}
function PublicResolver(AbstractENS ensAddr) {
ens = ensAddr;
}
function supportsInterface(bytes4 interfaceID) constant returns (bool) {
return interfaceID == ADDR_INTERFACE_ID ||
interfaceID == CONTENT_INTERFACE_ID ||
interfaceID == ABI_INTERFACE_ID ||
interfaceID == PUBKEY_INTERFACE_ID;
}
function addr(bytes32 node) constant returns (address ret) {
ret = records[node].addr;
}
function setAddr(bytes32 node, address addr) only_owner(node) {
records[node].addr = addr;
}
function content(bytes32 node) constant returns (bytes32 ret) {
ret = records[node].content;
}
function setContent(bytes32 node, bytes32 hash) only_owner(node) {
records[node].content = hash;
}
function ABI(bytes32 node, uint256 contentTypes) constant returns (uint256 contentType, bytes data) {
var record = records[node];
for(contentType = 1; contentType <= contentTypes; contentType <<= 1) {
if((contentType & contentTypes) != 0 && record.abis[contentType].length > 0) {
data = record.abis[contentType];
return;
}
}
contentType = 0;
}
function setABI(bytes32 node, uint256 contentType, bytes data) only_owner(node) {
if(((contentType - 1) & contentType) != 0) throw;
records[node].abis[contentType] = data;
}
function pubkey(bytes32 node) constant returns (bytes32 x, bytes32 y) {
return (records[node].pubkey.x, records[node].pubkey.y);
}
function setPubkey(bytes32 node, bytes32 x, bytes32 y) only_owner(node) {
records[node].pubkey = PublicKey(x, y);
}
}