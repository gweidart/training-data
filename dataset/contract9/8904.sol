pragma solidity ^0.4.21;
contract IOwned {
function owner() public view returns (address) {}
function transferOwnership(address _newOwner) public;
function acceptOwnership() public;
}
contract IContractRegistry {
function getAddress(bytes32 _contractName) public view returns (address);
}
contract Utils {
function Utils() public {
}
modifier greaterThanZero(uint256 _amount) {
require(_amount > 0);
_;
}
modifier validAddress(address _address) {
require(_address != address(0));
_;
}
modifier notThis(address _address) {
require(_address != address(this));
_;
}
function safeAdd(uint256 _x, uint256 _y) internal pure returns (uint256) {
uint256 z = _x + _y;
assert(z >= _x);
return z;
}
function safeSub(uint256 _x, uint256 _y) internal pure returns (uint256) {
assert(_x >= _y);
return _x - _y;
}
function safeMul(uint256 _x, uint256 _y) internal pure returns (uint256) {
uint256 z = _x * _y;
assert(_x == 0 || z / _x == _y);
return z;
}
}
contract Owned is IOwned {
address public owner;
address public newOwner;
event OwnerUpdate(address indexed _prevOwner, address indexed _newOwner);
function Owned() public {
owner = msg.sender;
}
modifier ownerOnly {
assert(msg.sender == owner);
_;
}
function transferOwnership(address _newOwner) public ownerOnly {
require(_newOwner != owner);
newOwner = _newOwner;
}
function acceptOwnership() public {
require(msg.sender == newOwner);
emit OwnerUpdate(owner, newOwner);
owner = newOwner;
newOwner = address(0);
}
}
contract ContractRegistry is IContractRegistry, Owned, Utils {
struct RegistryItem {
address contractAddress;
uint256 nameIndex;
bool isSet;
}
mapping (bytes32 => RegistryItem) private items;
bytes32[] public names;
event AddressUpdate(bytes32 indexed _contractName, address _contractAddress);
function ContractRegistry() public {
}
function getAddress(bytes32 _contractName) public view returns (address) {
return items[_contractName].contractAddress;
}
function registerAddress(bytes32 _contractName, address _contractAddress)
public
ownerOnly
validAddress(_contractAddress)
{
require(_contractName.length > 0);
items[_contractName].contractAddress = _contractAddress;
if (!items[_contractName].isSet) {
items[_contractName].isSet = true;
items[_contractName].nameIndex = names.push(_contractName) - 1;
}
emit AddressUpdate(_contractName, _contractAddress);
}
function unregisterAddress(bytes32 _contractName) public ownerOnly {
require(_contractName.length > 0);
items[_contractName].contractAddress = address(0);
if (items[_contractName].isSet) {
items[_contractName].isSet = false;
names[items[_contractName].nameIndex] = names[names.length - 1];
names.length--;
items[_contractName].nameIndex = 0;
}
emit AddressUpdate(_contractName, address(0));
}
}