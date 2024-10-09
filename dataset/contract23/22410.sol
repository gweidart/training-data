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
pragma solidity 0.4.18;
contract KernelConstants {
bytes32 constant public CORE_NAMESPACE = keccak256("core");
bytes32 constant public APP_BASES_NAMESPACE = keccak256("base");
bytes32 constant public APP_ADDR_NAMESPACE = keccak256("app");
bytes32 constant public KERNEL_APP_ID = keccak256("kernel.aragonpm.eth");
bytes32 constant public KERNEL_APP = keccak256(CORE_NAMESPACE, KERNEL_APP_ID);
bytes32 constant public ACL_APP_ID = keccak256("acl.aragonpm.eth");
bytes32 constant public ACL_APP = keccak256(APP_ADDR_NAMESPACE, ACL_APP_ID);
}
contract KernelStorage is KernelConstants {
mapping (bytes32 => address) public apps;
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
pragma solidity 0.4.18;
interface IAppProxy {
function isUpgradeable() public pure returns (bool);
function getCode() public view returns (address);
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
pragma solidity 0.4.18;
contract DelegateProxy {
function delegatedFwd(address _dst, bytes _calldata) internal {
require(isContract(_dst));
assembly {
let result := delegatecall(sub(gas, 10000), _dst, add(_calldata, 0x20), mload(_calldata), 0, 0)
let size := returndatasize
let ptr := mload(0x40)
returndatacopy(ptr, 0, size)
switch result case 0 { revert(ptr, size) }
default { return(ptr, size) }
}
}
function isContract(address _target) internal view returns (bool) {
uint256 size;
assembly { size := extcodesize(_target) }
return size > 0;
}
}
pragma solidity 0.4.18;
contract AppProxyBase is IAppProxy, AppStorage, DelegateProxy, KernelConstants {
function AppProxyBase(IKernel _kernel, bytes32 _appId, bytes _initializePayload) public {
kernel = _kernel;
appId = _appId;
address appCode = getAppBase(appId);
if (_initializePayload.length > 0) {
require(isContract(appCode));
require(appCode.delegatecall(_initializePayload));
}
}
function getAppBase(bytes32 _appId) internal view returns (address) {
return kernel.getApp(keccak256(APP_BASES_NAMESPACE, _appId));
}
function () payable public {
address target = getCode();
require(target != 0);
delegatedFwd(target, msg.data);
}
}
pragma solidity 0.4.18;
contract AppProxyUpgradeable is AppProxyBase {
address public pinnedCode;
function AppProxyUpgradeable(IKernel _kernel, bytes32 _appId, bytes _initializePayload)
AppProxyBase(_kernel, _appId, _initializePayload) public
{
}
function getCode() public view returns (address) {
return getAppBase(appId);
}
function isUpgradeable() public pure returns (bool) {
return true;
}
}
pragma solidity 0.4.18;
contract AppProxyPinned is AppProxyBase {
function AppProxyPinned(IKernel _kernel, bytes32 _appId, bytes _initializePayload)
AppProxyBase(_kernel, _appId, _initializePayload) public
{
pinnedCode = getAppBase(appId);
require(pinnedCode != address(0));
}
function getCode() public view returns (address) {
return pinnedCode;
}
function isUpgradeable() public pure returns (bool) {
return false;
}
function () payable public {
delegatedFwd(getCode(), msg.data);
}
}
pragma solidity 0.4.18;
contract AppProxyFactory {
event NewAppProxy(address proxy);
function newAppProxy(IKernel _kernel, bytes32 _appId) public returns (AppProxyUpgradeable) {
return newAppProxy(_kernel, _appId, new bytes(0));
}
function newAppProxy(IKernel _kernel, bytes32 _appId, bytes _initializePayload) public returns (AppProxyUpgradeable) {
AppProxyUpgradeable proxy = new AppProxyUpgradeable(_kernel, _appId, _initializePayload);
NewAppProxy(address(proxy));
return proxy;
}
function newAppProxyPinned(IKernel _kernel, bytes32 _appId) public returns (AppProxyPinned) {
return newAppProxyPinned(_kernel, _appId, new bytes(0));
}
function newAppProxyPinned(IKernel _kernel, bytes32 _appId, bytes _initializePayload) public returns (AppProxyPinned) {
AppProxyPinned proxy = new AppProxyPinned(_kernel, _appId, _initializePayload);
NewAppProxy(address(proxy));
return proxy;
}
}
pragma solidity 0.4.18;
contract Kernel is IKernel, KernelStorage, Initializable, AppProxyFactory, ACLSyntaxSugar {
bytes32 constant public APP_MANAGER_ROLE = keccak256("APP_MANAGER_ROLE");
function initialize(address _baseAcl, address _permissionsCreator) onlyInit public {
initialized();
IACL acl = IACL(newAppProxy(this, ACL_APP_ID));
_setApp(APP_BASES_NAMESPACE, ACL_APP_ID, _baseAcl);
_setApp(APP_ADDR_NAMESPACE, ACL_APP_ID, acl);
acl.initialize(_permissionsCreator);
}
function newAppInstance(bytes32 _name, address _appBase) auth(APP_MANAGER_ROLE, arr(APP_BASES_NAMESPACE, _name)) public returns (IAppProxy appProxy) {
_setAppIfNew(APP_BASES_NAMESPACE, _name, _appBase);
appProxy = newAppProxy(this, _name);
}
function newPinnedAppInstance(bytes32 _name, address _appBase) auth(APP_MANAGER_ROLE, arr(APP_BASES_NAMESPACE, _name)) public returns (IAppProxy appProxy) {
_setAppIfNew(APP_BASES_NAMESPACE, _name, _appBase);
appProxy = newAppProxyPinned(this, _name);
}
function setApp(bytes32 _namespace, bytes32 _name, address _app) auth(APP_MANAGER_ROLE, arr(_namespace, _name)) kernelIntegrity public returns (bytes32 id) {
return _setApp(_namespace, _name, _app);
}
function getApp(bytes32 _id) public view returns (address) {
return apps[_id];
}
function acl() public view returns (IACL) {
return IACL(getApp(ACL_APP));
}
function hasPermission(address _who, address _where, bytes32 _what, bytes _how) public view returns (bool) {
return acl().hasPermission(_who, _where, _what, _how);
}
function _setApp(bytes32 _namespace, bytes32 _name, address _app) internal returns (bytes32 id) {
id = keccak256(_namespace, _name);
apps[id] = _app;
SetApp(_namespace, _name, id, _app);
}
function _setAppIfNew(bytes32 _namespace, bytes32 _name, address _app) internal returns (bytes32 id) {
id = keccak256(_namespace, _name);
if (_app != address(0)) {
address app = getApp(id);
if (app != address(0)) {
require(app == _app);
} else {
apps[id] = _app;
SetApp(_namespace, _name, id, _app);
}
}
}
modifier auth(bytes32 _role, uint256[] memory params) {
bytes memory how;
uint256 byteLength = params.length * 32;
assembly {
how := params
mstore(how, byteLength)
}
require(hasPermission(msg.sender, address(this), _role, how));
_;
}
modifier kernelIntegrity {
_;
address kernel = getApp(KERNEL_APP);
uint256 size;
assembly { size := extcodesize(kernel) }
require(size > 0);
}
}