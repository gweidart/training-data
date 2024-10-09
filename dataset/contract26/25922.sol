pragma solidity ^0.4.18;
contract Ownable {
address public owner;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
function Ownable() public {
owner = msg.sender;
}
modifier onlyOwner() {
require(msg.sender == owner);
_;
}
function transferOwnership(address newOwner) public onlyOwner {
require(newOwner != address(0));
OwnershipTransferred(owner, newOwner);
owner = newOwner;
}
}
contract Registry is Ownable {
struct Record {
address contractAddress;
bytes32 ipfsHash;
}
bytes32[] public namelist;
mapping (bytes32 => Record) public registry;
event RegistryUpdated(bytes32 _name, address _address, bytes32 _ipfsHash);
event GetRecord(bytes32 _name, address contractAddress, bytes32 ipfsHash);
function getNamelistLength() public view returns(uint namelistLength) {
return namelist.length;
}
function getAddress(bytes32 _name) public view returns(address) {
Record memory record = registry[keccak256(_name)];
GetRecord(_name, record.contractAddress, record.ipfsHash);
return record.contractAddress;
}
function getIPFSHash(bytes32 _name) public view returns(bytes32) {
Record memory record = registry[keccak256(_name)];
GetRecord(_name, record.contractAddress, record.ipfsHash);
return record.ipfsHash;
}
function updateRegistry(bytes32 _name, address _address, bytes32 _ipfsHash) public onlyOwner {
require(_address != address(0x0));
if (registry[keccak256(_name)].contractAddress == 0) {
namelist.push(_name);
}
registry[keccak256(_name)] = Record(_address, _ipfsHash);
RegistryUpdated(_name, _address, _ipfsHash);
}
}