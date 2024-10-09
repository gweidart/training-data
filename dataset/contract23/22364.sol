pragma solidity ^0.4.15;
interface AbstractENS {
function owner(bytes32 _node) constant returns (address);
function resolver(bytes32 _node) constant returns (address);
function ttl(bytes32 _node) constant returns (uint64);
function setOwner(bytes32 _node, address _owner);
function setSubnodeOwner(bytes32 _node, bytes32 label, address _owner);
function setResolver(bytes32 _node, address _resolver);
function setTTL(bytes32 _node, uint64 _ttl);
event NewOwner(bytes32 indexed _node, bytes32 indexed _label, address _owner);
event Transfer(bytes32 indexed _node, address _owner);
event NewResolver(bytes32 indexed _node, address _resolver);
event NewTTL(bytes32 indexed _node, uint64 _ttl);
}
pragma solidity ^0.4.0;
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
event TextChanged(bytes32 indexed node, string indexed indexedKey, string key);
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
AbstractENS ens;
mapping(bytes32=>Record) records;
modifier only_owner(bytes32 node) {
if (ens.owner(node) != msg.sender) throw;
_;
}
function PublicResolver(AbstractENS ensAddr) {
ens = ensAddr;
}
function supportsInterface(bytes4 interfaceID) constant returns (bool) {
return interfaceID == ADDR_INTERFACE_ID ||
interfaceID == CONTENT_INTERFACE_ID ||
interfaceID == NAME_INTERFACE_ID ||
interfaceID == ABI_INTERFACE_ID ||
interfaceID == PUBKEY_INTERFACE_ID ||
interfaceID == TEXT_INTERFACE_ID ||
interfaceID == INTERFACE_META_ID;
}
function addr(bytes32 node) constant returns (address ret) {
ret = records[node].addr;
}
function setAddr(bytes32 node, address addr) only_owner(node) {
records[node].addr = addr;
AddrChanged(node, addr);
}
function content(bytes32 node) constant returns (bytes32 ret) {
ret = records[node].content;
}
function setContent(bytes32 node, bytes32 hash) only_owner(node) {
records[node].content = hash;
ContentChanged(node, hash);
}
function name(bytes32 node) constant returns (string ret) {
ret = records[node].name;
}
function setName(bytes32 node, string name) only_owner(node) {
records[node].name = name;
NameChanged(node, name);
}
function ABI(bytes32 node, uint256 contentTypes) constant returns (uint256 contentType, bytes data) {
var record = records[node];
for(contentType = 1; contentType <= contentTypes; contentType <<= 1) {
if ((contentType & contentTypes) != 0 && record.abis[contentType].length > 0) {
data = record.abis[contentType];
return;
}
}
contentType = 0;
}
function setABI(bytes32 node, uint256 contentType, bytes data) only_owner(node) {
if (((contentType - 1) & contentType) != 0) throw;
records[node].abis[contentType] = data;
ABIChanged(node, contentType);
}
function pubkey(bytes32 node) constant returns (bytes32 x, bytes32 y) {
return (records[node].pubkey.x, records[node].pubkey.y);
}
function setPubkey(bytes32 node, bytes32 x, bytes32 y) only_owner(node) {
records[node].pubkey = PublicKey(x, y);
PubkeyChanged(node, x, y);
}
function text(bytes32 node, string key) constant returns (string ret) {
ret = records[node].text[key];
}
function setText(bytes32 node, string key, string value) only_owner(node) {
records[node].text[key] = value;
TextChanged(node, key, key);
}
}
pragma solidity ^0.4.18;
contract ENSConstants {
bytes32 constant public ENS_ROOT = bytes32(0);
bytes32 constant public ETH_TLD_LABEL = keccak256("eth");
bytes32 constant public ETH_TLD_NODE = keccak256(ENS_ROOT, ETH_TLD_LABEL);
bytes32 constant public PUBLIC_RESOLVER_LABEL = keccak256("resolver");
bytes32 constant public PUBLIC_RESOLVER_NODE = keccak256(ETH_TLD_NODE, PUBLIC_RESOLVER_LABEL);
}
pragma solidity ^0.4.18;
interface IACL {
function initialize(address permissionsCreator) public;
function hasPermission(address who, address where, bytes32 what, bytes how) public view returns (bool);
}
pragma solidity ^0.4.18;
interface IKernel {
event SetApp(bytes32 indexed namespace, bytes32 indexed name, bytes32 indexed id, address app);
function acl() public view returns (IACL);
function hasPermission(address who, address where, bytes32 what, bytes how) public view returns (bool);
function setApp(bytes32 namespace, bytes32 name, address app) public returns (bytes32 id);
function getApp(bytes32 id) public view returns (address);
}
pragma solidity ^0.4.18;
contract AppStorage {
IKernel public kernel;
bytes32 public appId;
address internal pinnedCode;
uint256 internal initializationBlock;
uint256[95] private storageOffset;
uint256 private offset;
}
pragma solidity ^0.4.18;
contract Initializable is AppStorage {
modifier onlyInit {
require(initializationBlock == 0);
_;
}
function getInitializationBlock() public view returns (uint256) {
return initializationBlock;
}
function initialized() internal onlyInit {
initializationBlock = getBlockNumber();
}
function getBlockNumber() internal view returns (uint256) {
return block.number;
}
}
pragma solidity ^0.4.18;
interface IEVMScriptExecutor {
function execScript(bytes script, bytes input, address[] blacklist) external returns (bytes);
}
pragma solidity 0.4.18;
contract EVMScriptRegistryConstants {
bytes32 constant public EVMSCRIPT_REGISTRY_APP_ID = keccak256("evmreg.aragonpm.eth");
bytes32 constant public EVMSCRIPT_REGISTRY_APP = keccak256(keccak256("app"), EVMSCRIPT_REGISTRY_APP_ID);
}
interface IEVMScriptRegistry {
function addScriptExecutor(address executor) external returns (uint id);
function disableScriptExecutor(uint256 executorId) external;
function getScriptExecutor(bytes script) public view returns (address);
}
pragma solidity 0.4.18;
library ScriptHelpers {
function abiEncode(bytes _a, bytes _b, address[] _c) public pure returns (bytes d) {
return encode(_a, _b, _c);
}
function encode(bytes memory _a, bytes memory _b, address[] memory _c) internal pure returns (bytes memory d) {
uint256 aPosition = 0x60;
uint256 bPosition = aPosition + 32 * abiLength(_a);
uint256 cPosition = bPosition + 32 * abiLength(_b);
uint256 length = cPosition + 32 * abiLength(_c);
d = new bytes(length);
assembly {
mstore(add(d, 0x20), aPosition)
mstore(add(d, 0x40), bPosition)
mstore(add(d, 0x60), cPosition)
}
copy(d, getPtr(_a), aPosition, _a.length);
copy(d, getPtr(_b), bPosition, _b.length);
copy(d, getPtr(_c), cPosition, _c.length * 32);
}
function abiLength(bytes memory _a) internal pure returns (uint256) {
return 1 + (_a.length / 32) + (_a.length % 32 > 0 ? 1 : 0);
}
function abiLength(address[] _a) internal pure returns (uint256) {
return 1 + _a.length;
}
function copy(bytes _d, uint256 _src, uint256 _pos, uint256 _length) internal pure {
uint dest;
assembly {
dest := add(add(_d, 0x20), _pos)
}
memcpy(dest, _src, _length + 32);
}
function getPtr(bytes memory _x) internal pure returns (uint256 ptr) {
assembly {
ptr := _x
}
}
function getPtr(address[] memory _x) internal pure returns (uint256 ptr) {
assembly {
ptr := _x
}
}
function getSpecId(bytes _script) internal pure returns (uint32) {
return uint32At(_script, 0);
}
function uint256At(bytes _data, uint256 _location) internal pure returns (uint256 result) {
assembly {
result := mload(add(_data, add(0x20, _location)))
}
}
function addressAt(bytes _data, uint256 _location) internal pure returns (address result) {
uint256 word = uint256At(_data, _location);
assembly {
result := div(and(word, 0xffffffffffffffffffffffffffffffffffffffff000000000000000000000000),
0x1000000000000000000000000)
}
}
function uint32At(bytes _data, uint256 _location) internal pure returns (uint32 result) {
uint256 word = uint256At(_data, _location);
assembly {
result := div(and(word, 0xffffffff00000000000000000000000000000000000000000000000000000000),
0x100000000000000000000000000000000000000000000000000000000)
}
}
function locationOf(bytes _data, uint256 _location) internal pure returns (uint256 result) {
assembly {
result := add(_data, add(0x20, _location))
}
}
function toBytes(bytes4 _sig) internal pure returns (bytes) {
bytes memory payload = new bytes(4);
payload[0] = bytes1(_sig);
payload[1] = bytes1(_sig << 8);
payload[2] = bytes1(_sig << 16);
payload[3] = bytes1(_sig << 24);
return payload;
}
function memcpy(uint _dest, uint _src, uint _len) public pure {
uint256 src = _src;
uint256 dest = _dest;
uint256 len = _len;
for (; len >= 32; len -= 32) {
assembly {
mstore(dest, mload(src))
}
dest += 32;
src += 32;
}
uint mask = 256 ** (32 - len) - 1;
assembly {
let srcpart := and(mload(src), not(mask))
let destpart := and(mload(dest), mask)
mstore(dest, or(destpart, srcpart))
}
}
}
pragma solidity ^0.4.18;
contract EVMScriptRunner is AppStorage, EVMScriptRegistryConstants {
using ScriptHelpers for bytes;
function runScript(bytes _script, bytes _input, address[] _blacklist) protectState internal returns (bytes output) {
address executorAddr = getExecutor(_script);
require(executorAddr != address(0));
bytes memory calldataArgs = _script.encode(_input, _blacklist);
bytes4 sig = IEVMScriptExecutor(0).execScript.selector;
require(executorAddr.delegatecall(sig, calldataArgs));
return returnedDataDecoded();
}
function getExecutor(bytes _script) public view returns (IEVMScriptExecutor) {
return IEVMScriptExecutor(getExecutorRegistry().getScriptExecutor(_script));
}
function getExecutorRegistry() internal view returns (IEVMScriptRegistry) {
address registryAddr = kernel.getApp(EVMSCRIPT_REGISTRY_APP);
return IEVMScriptRegistry(registryAddr);
}
function returnedDataDecoded() internal view returns (bytes ret) {
assembly {
let size := returndatasize
switch size
case 0 {}
default {
ret := mload(0x40)
mstore(0x40, add(ret, add(size, 0x20)))
returndatacopy(ret, 0x20, sub(size, 0x20))
}
}
return ret;
}
modifier protectState {
address preKernel = kernel;
bytes32 preAppId = appId;
_;
require(kernel == preKernel);
require(appId == preAppId);
}
}
pragma solidity 0.4.18;
contract ACLSyntaxSugar {
function arr() internal pure returns (uint256[] r) {}
function arr(bytes32 _a) internal pure returns (uint256[] r) {
return arr(uint256(_a));
}
function arr(bytes32 _a, bytes32 _b) internal pure returns (uint256[] r) {
return arr(uint256(_a), uint256(_b));
}
function arr(address _a) internal pure returns (uint256[] r) {
return arr(uint256(_a));
}
function arr(address _a, address _b) internal pure returns (uint256[] r) {
return arr(uint256(_a), uint256(_b));
}
function arr(address _a, uint256 _b, uint256 _c) internal pure returns (uint256[] r) {
return arr(uint256(_a), _b, _c);
}
function arr(address _a, uint256 _b) internal pure returns (uint256[] r) {
return arr(uint256(_a), uint256(_b));
}
function arr(address _a, address _b, uint256 _c, uint256 _d, uint256 _e) internal pure returns (uint256[] r) {
return arr(uint256(_a), uint256(_b), _c, _d, _e);
}
function arr(address _a, address _b, address _c) internal pure returns (uint256[] r) {
return arr(uint256(_a), uint256(_b), uint256(_c));
}
function arr(address _a, address _b, uint256 _c) internal pure returns (uint256[] r) {
return arr(uint256(_a), uint256(_b), uint256(_c));
}
function arr(uint256 _a) internal pure returns (uint256[] r) {
r = new uint256[](1);
r[0] = _a;
}
function arr(uint256 _a, uint256 _b) internal pure returns (uint256[] r) {
r = new uint256[](2);
r[0] = _a;
r[1] = _b;
}
function arr(uint256 _a, uint256 _b, uint256 _c) internal pure returns (uint256[] r) {
r = new uint256[](3);
r[0] = _a;
r[1] = _b;
r[2] = _c;
}
function arr(uint256 _a, uint256 _b, uint256 _c, uint256 _d) internal pure returns (uint256[] r) {
r = new uint256[](4);
r[0] = _a;
r[1] = _b;
r[2] = _c;
r[3] = _d;
}
function arr(uint256 _a, uint256 _b, uint256 _c, uint256 _d, uint256 _e) internal pure returns (uint256[] r) {
r = new uint256[](5);
r[0] = _a;
r[1] = _b;
r[2] = _c;
r[3] = _d;
r[4] = _e;
}
}
contract ACLHelpers {
function decodeParamOp(uint256 _x) internal pure returns (uint8 b) {
return uint8(_x >> (8 * 30));
}
function decodeParamId(uint256 _x) internal pure returns (uint8 b) {
return uint8(_x >> (8 * 31));
}
function decodeParamsList(uint256 _x) internal pure returns (uint32 a, uint32 b, uint32 c) {
a = uint32(_x);
b = uint32(_x >> (8 * 4));
c = uint32(_x >> (8 * 8));
}
}
pragma solidity ^0.4.18;
contract AragonApp is AppStorage, Initializable, ACLSyntaxSugar, EVMScriptRunner {
modifier auth(bytes32 _role) {
require(canPerform(msg.sender, _role, new uint256[](0)));
_;
}
modifier authP(bytes32 _role, uint256[] params) {
require(canPerform(msg.sender, _role, params));
_;
}
function canPerform(address _sender, bytes32 _role, uint256[] params) public view returns (bool) {
bytes memory how;
if (params.length > 0) {
uint256 byteLength = params.length * 32;
assembly {
how := params
mstore(how, byteLength)
}
}
return address(kernel) == 0 || kernel.hasPermission(_sender, address(this), _role, how);
}
}
pragma solidity 0.4.18;
contract ENSSubdomainRegistrar is AragonApp, ENSConstants {
bytes32 constant public CREATE_NAME_ROLE = bytes32(1);
bytes32 constant public DELETE_NAME_ROLE = bytes32(2);
bytes32 constant public POINT_ROOTNODE_ROLE = bytes32(3);
AbstractENS public ens;
bytes32 public rootNode;
event NewName(bytes32 indexed node, bytes32 indexed label);
event DeleteName(bytes32 indexed node, bytes32 indexed label);
function initialize(AbstractENS _ens, bytes32 _rootNode) onlyInit public {
initialized();
require(_ens.owner(_rootNode) == address(this));
ens = _ens;
rootNode = _rootNode;
}
function createName(bytes32 _label, address _owner) auth(CREATE_NAME_ROLE) external returns (bytes32 node) {
return _createName(_label, _owner);
}
function createNameAndPoint(bytes32 _label, address _target) auth(CREATE_NAME_ROLE) external returns (bytes32 node) {
node = _createName(_label, this);
_pointToResolverAndResolve(node, _target);
}
function deleteName(bytes32 _label) auth(DELETE_NAME_ROLE) external {
bytes32 node = keccak256(rootNode, _label);
address currentOwner = ens.owner(node);
require(currentOwner != address(0));
if (currentOwner != address(this)) {
ens.setSubnodeOwner(rootNode, _label, this);
}
ens.setResolver(node, address(0));
ens.setOwner(node, address(0));
DeleteName(node, _label);
}
function pointRootNode(address _target) auth(POINT_ROOTNODE_ROLE) external {
_pointToResolverAndResolve(rootNode, _target);
}
function _createName(bytes32 _label, address _owner) internal returns (bytes32 node) {
node = keccak256(rootNode, _label);
require(ens.owner(node) == address(0));
ens.setSubnodeOwner(rootNode, _label, _owner);
NewName(node, _label);
}
function _pointToResolverAndResolve(bytes32 _node, address _target) internal {
address publicResolver = getAddr(PUBLIC_RESOLVER_NODE);
ens.setResolver(_node, publicResolver);
PublicResolver(publicResolver).setAddr(_node, _target);
}
function getAddr(bytes32 node) internal view returns (address) {
address resolver = ens.resolver(node);
return PublicResolver(resolver).addr(node);
}
}