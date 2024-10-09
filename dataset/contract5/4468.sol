pragma solidity 0.4.24;
interface ERC820ImplementerInterface {
function canImplementInterfaceForAddress(address addr, bytes32 interfaceHash) view public returns(bytes32);
}
contract ERC820Registry {
bytes4 constant InvalidID = 0xffffffff;
bytes4 constant ERC165ID = 0x01ffc9a7;
bytes32 constant ERC820_ACCEPT_MAGIC = keccak256("ERC820_ACCEPT_MAGIC");
mapping (address => mapping(bytes32 => address)) interfaces;
mapping (address => address) managers;
mapping (address => mapping(bytes4 => bool)) erc165Cache;
event InterfaceImplementerSet(address indexed addr, bytes32 indexed interfaceHash, address indexed implementer);
event ManagerChanged(address indexed addr, address indexed newManager);
function interfaceHash(string interfaceName) public pure returns(bytes32) {
return keccak256(interfaceName);
}
function getManager(address addr) public view returns(address) {
if (managers[addr] == 0) {
return addr;
} else {
return managers[addr];
}
}
function setManager(address _addr, address newManager) public {
address addr = _addr == 0 ? msg.sender : _addr;
require(getManager(addr) == msg.sender);
managers[addr] = newManager == addr ? 0 : newManager;
ManagerChanged(addr, newManager);
}
function getInterfaceImplementer(address _addr, bytes32 iHash) constant public returns (address) {
address addr = _addr == 0 ? msg.sender : _addr;
if (isERC165Interface(iHash)) {
bytes4 i165Hash = bytes4(iHash);
return erc165InterfaceSupported(addr, i165Hash) ? addr : 0;
}
return interfaces[addr][iHash];
}
function setInterfaceImplementer(address _addr, bytes32 iHash, address implementer) public  {
address addr = _addr == 0 ? msg.sender : _addr;
require(getManager(addr) == msg.sender);
require(!isERC165Interface(iHash));
if ((implementer != 0) && (implementer!=msg.sender)) {
require(ERC820ImplementerInterface(implementer).canImplementInterfaceForAddress(addr, iHash)
== ERC820_ACCEPT_MAGIC);
}
interfaces[addr][iHash] = implementer;
InterfaceImplementerSet(addr, iHash, implementer);
}
function isERC165Interface(bytes32 iHash) internal pure returns (bool) {
return iHash & 0x00000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF == 0;
}
function erc165InterfaceSupported(address _contract, bytes4 _interfaceId) constant public returns (bool) {
if (!erc165Cache[_contract][_interfaceId]) {
erc165UpdateCache(_contract, _interfaceId);
}
return interfaces[_contract][_interfaceId] != 0;
}
function erc165UpdateCache(address _contract, bytes4 _interfaceId) public {
interfaces[_contract][_interfaceId] =
erc165InterfaceSupported_NoCache(_contract, _interfaceId) ? _contract : 0;
erc165Cache[_contract][_interfaceId] = true;
}
function erc165InterfaceSupported_NoCache(address _contract, bytes4 _interfaceId) public constant returns (bool) {
uint256 success;
uint256 result;
(success, result) = noThrowCall(_contract, ERC165ID);
if ((success==0)||(result==0)) {
return false;
}
(success, result) = noThrowCall(_contract, InvalidID);
if ((success==0)||(result!=0)) {
return false;
}
(success, result) = noThrowCall(_contract, _interfaceId);
if ((success==1)&&(result==1)) {
return true;
}
return false;
}
function noThrowCall(address _contract, bytes4 _interfaceId) constant internal returns (uint256 success, uint256 result) {
bytes4 erc165ID = ERC165ID;
assembly {
let x := mload(0x40)
mstore(x, erc165ID)
mstore(add(x, 0x04), _interfaceId)
success := staticcall(
30000,
_contract,
x,
0x08,
x,
0x20)
result := mload(x)
}
}
}