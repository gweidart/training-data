pragma solidity ^0.4.21;
interface SvEns {
event NewOwner(bytes32 indexed node, bytes32 indexed label, address owner);
event Transfer(bytes32 indexed node, address owner);
event NewResolver(bytes32 indexed node, address resolver);
event NewTTL(bytes32 indexed node, uint64 ttl);
function setSubnodeOwner(bytes32 node, bytes32 label, address owner) external returns (bytes32);
function setResolver(bytes32 node, address resolver) external;
function setOwner(bytes32 node, address owner) external;
function setTTL(bytes32 node, uint64 ttl) external;
function owner(bytes32 node) external view returns (address);
function resolver(bytes32 node) external view returns (address);
function ttl(bytes32 node) external view returns (uint64);
}
interface ENS {
event NewOwner(bytes32 indexed node, bytes32 indexed label, address owner);
event Transfer(bytes32 indexed node, address owner);
event NewResolver(bytes32 indexed node, address resolver);
event NewTTL(bytes32 indexed node, uint64 ttl);
function setSubnodeOwner(bytes32 node, bytes32 label, address owner) external;
function setResolver(bytes32 node, address resolver) external;
function setOwner(bytes32 node, address owner) external;
function setTTL(bytes32 node, uint64 ttl) external;
function owner(bytes32 node) external view returns (address);
function resolver(bytes32 node) external view returns (address);
function ttl(bytes32 node) external view returns (uint64);
}
contract SvEnsRegistry is SvEns {
struct Record {
address owner;
address resolver;
uint64 ttl;
}
mapping (bytes32 => Record) records;
modifier only_owner(bytes32 node) {
require(records[node].owner == msg.sender);
_;
}
function SvEnsRegistry() public {
records[0x0].owner = msg.sender;
}
function setOwner(bytes32 node, address owner) external only_owner(node) {
emit Transfer(node, owner);
records[node].owner = owner;
}
function setSubnodeOwner(bytes32 node, bytes32 label, address owner) external only_owner(node) returns (bytes32) {
bytes32 subnode = keccak256(node, label);
emit NewOwner(node, label, owner);
records[subnode].owner = owner;
return subnode;
}
function setResolver(bytes32 node, address resolver) external only_owner(node) {
emit NewResolver(node, resolver);
records[node].resolver = resolver;
}
function setTTL(bytes32 node, uint64 ttl) external only_owner(node) {
emit NewTTL(node, ttl);
records[node].ttl = ttl;
}
function owner(bytes32 node) external view returns (address) {
return records[node].owner;
}
function resolver(bytes32 node) external view returns (address) {
return records[node].resolver;
}
function ttl(bytes32 node) external view returns (uint64) {
return records[node].ttl;
}
}
contract PublicResolver {
bytes4 constant INTERFACE_META_ID = 0x01ffc9a7;
bytes4 constant ADDR_INTERFACE_ID = 0x3b3b57de;
bytes4 constant CONTENT_INTERFACE_ID = 0xd8389dc5;
bytes4 constant NAME_INTERFACE_ID = 0x691f3431;
bytes4 constant ABI_INTERFACE_ID = 0x2203ab56;
bytes4 constant PUBKEY_INTERFACE_ID = 0xc8690233;
bytes4 constant TEXT_INTERFACE_ID = 0x59d1d43c;
event AddrChanged(bytes32 indexed node, address a);
event ContentChanged(bytes32 indexed node, bytes32 hash);
event NameChanged(bytes32 indexed node, string name);
event ABIChanged(bytes32 indexed node, uint256 indexed contentType);
event PubkeyChanged(bytes32 indexed node, bytes32 x, bytes32 y);
event TextChanged(bytes32 indexed node, string indexedKey, string key);
struct PublicKey {
bytes32 x;
bytes32 y;
}
struct Record {
address addr;
bytes32 content;
string name;
PublicKey pubkey;
mapping(string=>string) text;
mapping(uint256=>bytes) abis;
}
ENS ens;
mapping (bytes32 => Record) records;
modifier only_owner(bytes32 node) {
require(ens.owner(node) == msg.sender);
_;
}
function PublicResolver(ENS ensAddr) public {
ens = ensAddr;
}
function setAddr(bytes32 node, address addr) public only_owner(node) {
records[node].addr = addr;
emit AddrChanged(node, addr);
}
function setContent(bytes32 node, bytes32 hash) public only_owner(node) {
records[node].content = hash;
emit ContentChanged(node, hash);
}
function setName(bytes32 node, string name) public only_owner(node) {
records[node].name = name;
emit NameChanged(node, name);
}
function setABI(bytes32 node, uint256 contentType, bytes data) public only_owner(node) {
require(((contentType - 1) & contentType) == 0);
records[node].abis[contentType] = data;
emit ABIChanged(node, contentType);
}
function setPubkey(bytes32 node, bytes32 x, bytes32 y) public only_owner(node) {
records[node].pubkey = PublicKey(x, y);
emit PubkeyChanged(node, x, y);
}
function setText(bytes32 node, string key, string value) public only_owner(node) {
records[node].text[key] = value;
emit TextChanged(node, key, key);
}
function text(bytes32 node, string key) public view returns (string) {
return records[node].text[key];
}
function pubkey(bytes32 node) public view returns (bytes32 x, bytes32 y) {
return (records[node].pubkey.x, records[node].pubkey.y);
}
function ABI(bytes32 node, uint256 contentTypes) public view returns (uint256 contentType, bytes data) {
Record storage record = records[node];
for (contentType = 1; contentType <= contentTypes; contentType <<= 1) {
if ((contentType & contentTypes) != 0 && record.abis[contentType].length > 0) {
data = record.abis[contentType];
return;
}
}
contentType = 0;
}
function name(bytes32 node) public view returns (string) {
return records[node].name;
}
function content(bytes32 node) public view returns (bytes32) {
return records[node].content;
}
function addr(bytes32 node) public view returns (address) {
return records[node].addr;
}
function supportsInterface(bytes4 interfaceID) public pure returns (bool) {
return interfaceID == ADDR_INTERFACE_ID ||
interfaceID == CONTENT_INTERFACE_ID ||
interfaceID == NAME_INTERFACE_ID ||
interfaceID == ABI_INTERFACE_ID ||
interfaceID == PUBKEY_INTERFACE_ID ||
interfaceID == TEXT_INTERFACE_ID ||
interfaceID == INTERFACE_META_ID;
}
}
contract SvEnsRegistrar {
SvEns public ens;
bytes32 public rootNode;
mapping (bytes32 => bool) knownNodes;
mapping (address => bool) admins;
address public owner;
modifier req(bool c) {
require(c);
_;
}
function SvEnsRegistrar(SvEns ensAddr, bytes32 node) public {
ens = ensAddr;
rootNode = node;
admins[msg.sender] = true;
owner = msg.sender;
}
function addAdmin(address newAdmin) req(admins[msg.sender]) external {
admins[newAdmin] = true;
}
function remAdmin(address oldAdmin) req(admins[msg.sender]) external {
require(oldAdmin != msg.sender && oldAdmin != owner);
admins[oldAdmin] = false;
}
function chOwner(address newOwner, bool remPrevOwnerAsAdmin) req(msg.sender == owner) external {
if (remPrevOwnerAsAdmin) {
admins[owner] = false;
}
owner = newOwner;
admins[newOwner] = true;
}
function register(bytes32 subnode, address _owner) req(admins[msg.sender]) external {
_setSubnodeOwner(subnode, _owner);
}
function registerName(string subnodeStr, address _owner) req(admins[msg.sender]) external {
bytes32 subnode = keccak256(subnodeStr);
_setSubnodeOwner(subnode, _owner);
}
function _setSubnodeOwner(bytes32 subnode, address _owner) internal {
require(!knownNodes[subnode]);
knownNodes[subnode] = true;
ens.setSubnodeOwner(rootNode, subnode, _owner);
}
}
contract SvEnsEverythingPx {
address public owner;
mapping (address => bool) public admins;
address[] public adminLog;
SvEnsRegistrar public registrar;
SvEnsRegistry public registry;
PublicResolver public resolver;
bytes32 public rootNode;
modifier only_admin() {
require(admins[msg.sender]);
_;
}
function SvEnsEverythingPx(SvEnsRegistrar _registrar, SvEnsRegistry _registry, PublicResolver _resolver, bytes32 _rootNode) public {
registrar = _registrar;
registry = _registry;
resolver = _resolver;
rootNode = _rootNode;
owner = msg.sender;
_addAdmin(msg.sender);
}
function _addAdmin(address a) internal {
admins[a] = true;
adminLog.push(a);
}
function addAdmin(address a) only_admin() external {
_addAdmin(a);
}
function remAdmin(address a) only_admin() external {
require(a != owner && a != msg.sender);
admins[a] = false;
}
function regName(string name, address resolveTo) only_admin() external returns (bytes32 node) {
bytes32 labelhash = keccak256(name);
registrar.register(labelhash, this);
node = keccak256(rootNode, labelhash);
registry.setResolver(node, resolver);
resolver.setAddr(node, resolveTo);
registry.setOwner(node, msg.sender);
}
}