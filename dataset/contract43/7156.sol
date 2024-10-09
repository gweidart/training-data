pragma solidity ^0.4.24;
contract ImplementationStorage {
bytes32 internal constant IMPLEMENTATION_SLOT = 0xa490aab0d89837371982f93f57ffd20c47991f88066ef92475bc8233036969bb;
constructor() public {
assert(IMPLEMENTATION_SLOT == keccak256("cvc.proxy.implementation"));
}
function implementation() public view returns (address impl) {
bytes32 slot = IMPLEMENTATION_SLOT;
assembly {
impl := sload(slot)
}
}
}
library AddressUtils {
function isContract(address addr) internal view returns (bool) {
uint256 size;
assembly { size := extcodesize(addr) }
return size > 0;
}
}
contract CvcProxy is ImplementationStorage {
event Upgraded(address implementation);
event AdminChanged(address previousAdmin, address newAdmin);
bytes32 private constant ADMIN_SLOT = 0x2bbac3e52eee27be250d682577104e2abe776c40160cd3167b24633933100433;
modifier ifAdmin() {
if (msg.sender == currentAdmin()) {
_;
} else {
delegate(implementation());
}
}
constructor() public {
assert(ADMIN_SLOT == keccak256("cvc.proxy.admin"));
setAdmin(msg.sender);
}
function() external payable {
require(msg.sender != currentAdmin(), "Message sender is not contract admin");
delegate(implementation());
}
function changeAdmin(address _newAdmin) external ifAdmin {
require(_newAdmin != address(0), "Cannot change contract admin to zero address");
emit AdminChanged(currentAdmin(), _newAdmin);
setAdmin(_newAdmin);
}
function upgradeTo(address _implementation) external ifAdmin {
upgradeImplementation(_implementation);
}
function upgradeToAndCall(address _implementation, bytes _data) external payable ifAdmin {
upgradeImplementation(_implementation);
require(address(this).call.value(msg.value)(_data), "Upgrade error: initialization method call failed");
}
function admin() external view ifAdmin returns (address) {
return currentAdmin();
}
function upgradeImplementation(address _newImplementation) private {
address currentImplementation = implementation();
require(currentImplementation != _newImplementation, "Upgrade error: proxy contract already uses specified implementation");
setImplementation(_newImplementation);
emit Upgraded(_newImplementation);
}
function delegate(address _implementation) private {
assembly {
calldatacopy(0, 0, calldatasize)
let result := delegatecall(gas, _implementation, 0, calldatasize, 0, 0)
returndatacopy(0, 0, returndatasize)
switch result
case 0 {revert(0, returndatasize)}
default {return (0, returndatasize)}
}
}
function currentAdmin() private view returns (address proxyAdmin) {
bytes32 slot = ADMIN_SLOT;
assembly {
proxyAdmin := sload(slot)
}
}
function setAdmin(address _newAdmin) private {
bytes32 slot = ADMIN_SLOT;
assembly {
sstore(slot, _newAdmin)
}
}
function setImplementation(address _newImplementation) private {
require(
AddressUtils.isContract(_newImplementation),
"Cannot set new implementation: no contract code at contract address"
);
bytes32 slot = IMPLEMENTATION_SLOT;
assembly {
sstore(slot, _newImplementation)
}
}
}
contract Ownable {
address public owner;
event OwnershipRenounced(address indexed previousOwner);
event OwnershipTransferred(
address indexed previousOwner,
address indexed newOwner
);
constructor() public {
owner = msg.sender;
}
modifier onlyOwner() {
require(msg.sender == owner);
_;
}
function renounceOwnership() public onlyOwner {
emit OwnershipRenounced(owner);
owner = address(0);
}
function transferOwnership(address _newOwner) public onlyOwner {
_transferOwnership(_newOwner);
}
function _transferOwnership(address _newOwner) internal {
require(_newOwner != address(0));
emit OwnershipTransferred(owner, _newOwner);
owner = _newOwner;
}
}
contract CvcMigrator is Ownable {
event ProxyCreated(address indexed proxyAddress);
struct Migration {
address proxy;
address implementation;
bytes data;
}
Migration[] public migrations;
function addUpgrade(address _proxy, address _implementation, bytes _data) external onlyOwner {
require(AddressUtils.isContract(_implementation), "Migrator error: no contract code at new implementation address");
require(CvcProxy(_proxy).implementation() != _implementation, "Migrator error: proxy contract already uses specified implementation");
migrations.push(Migration(_proxy, _implementation, _data));
}
function migrate() external onlyOwner {
for (uint256 i = 0; i < migrations.length; i++) {
Migration storage migration = migrations[i];
if (migration.data.length > 0) {
CvcProxy(migration.proxy).upgradeToAndCall(migration.implementation, migration.data);
} else {
CvcProxy(migration.proxy).upgradeTo(migration.implementation);
}
}
delete migrations;
}
function reset() external onlyOwner {
delete migrations;
}
function changeProxyAdmin(address _target, address _newOwner) external onlyOwner {
CvcProxy(_target).changeAdmin(_newOwner);
}
function createProxy() external onlyOwner returns (CvcProxy) {
CvcProxy proxy = new CvcProxy();
emit ProxyCreated(address(proxy));
return proxy;
}
function getMigration(uint256 _index) external view returns (address, address, bytes) {
return (migrations[_index].proxy, migrations[_index].implementation, migrations[_index].data);
}
function getMigrationCount() external view returns (uint256) {
return migrations.length;
}
}