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
AbstractENS ens;
mapping(bytes32=>address) addresses;
mapping(bytes32=>bytes32) hashes;
modifier only_owner(bytes32 node) {
if(ens.owner(node) != msg.sender) throw;
_;
}
function PublicResolver(AbstractENS ensAddr) {
ens = ensAddr;
}
function() {
throw;
}
function has(bytes32 node, bytes32 kind) constant returns (bool) {
return (kind == "addr" && addresses[node] != 0) || (kind == "hash" && hashes[node] != 0);
}
function supportsInterface(bytes4 interfaceID) constant returns (bool) {
return interfaceID == 0x3b3b57de || interfaceID == 0xd8389dc5;
}
function addr(bytes32 node) constant returns (address ret) {
ret = addresses[node];
}
function setAddr(bytes32 node, address addr) only_owner(node) {
addresses[node] = addr;
}
function content(bytes32 node) constant returns (bytes32 ret) {
ret = hashes[node];
}
function setContent(bytes32 node, bytes32 hash) only_owner(node) {
hashes[node] = hash;
}
}