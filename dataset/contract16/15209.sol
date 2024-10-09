pragma solidity ^0.4.23;
contract Owned {
address public owner;
address public newOwner;
event OwnershipTransferred(address indexed _from, address indexed _to);
constructor() public {
owner = msg.sender;
}
modifier onlyOwner {
require(msg.sender == owner);
_;
}
function transferOwnership(address _newOwner) public onlyOwner {
newOwner = _newOwner;
}
function acceptOwnership() public {
require(msg.sender == newOwner);
emit OwnershipTransferred(owner, newOwner);
owner = newOwner;
newOwner = address(0);
}
}
contract TabooDb is Owned {
mapping(bytes32 => address)    private addressStorage;
mapping(bytes32 => bool)       private boolStorage;
mapping(bytes32 => bytes)      private bytesStorage;
mapping(bytes32 => int256)     private intStorage;
mapping(bytes32 => string)     private stringStorage;
mapping(bytes32 => uint256)    private uIntStorage;
modifier onlyAuthByTUN() {
if (msg.sender == owner) {
require(boolStorage[keccak256('owner.auth.disabled')] != true);
} else {
require(boolStorage[keccak256(msg.sender, '.has.auth')] == true);
}
_;
}
function getAddress(bytes32 _key) external view returns (address) {
return addressStorage[_key];
}
function getBool(bytes32 _key) external view returns (bool) {
return boolStorage[_key];
}
function getBytes(bytes32 _key) external view returns (bytes) {
return bytesStorage[_key];
}
function getInt(bytes32 _key) external view returns (int) {
return intStorage[_key];
}
function getString(bytes32 _key) external view returns (string) {
return stringStorage[_key];
}
function getUint(bytes32 _key) external view returns (uint) {
return uIntStorage[_key];
}
function setAddress(bytes32 _key, address _value) onlyAuthByTUN external {
addressStorage[_key] = _value;
}
function setBool(bytes32 _key, bool _value) onlyAuthByTUN external {
boolStorage[_key] = _value;
}
function setBytes(bytes32 _key, bytes _value) onlyAuthByTUN external {
bytesStorage[_key] = _value;
}
function setInt(bytes32 _key, int _value) onlyAuthByTUN external {
intStorage[_key] = _value;
}
function setString(bytes32 _key, string _value) onlyAuthByTUN external {
stringStorage[_key] = _value;
}
function setUint(bytes32 _key, uint _value) onlyAuthByTUN external {
uIntStorage[_key] = _value;
}
function deleteAddress(bytes32 _key) onlyAuthByTUN external {
delete addressStorage[_key];
}
function deleteBool(bytes32 _key) onlyAuthByTUN external {
delete boolStorage[_key];
}
function deleteBytes(bytes32 _key) onlyAuthByTUN external {
delete bytesStorage[_key];
}
function deleteInt(bytes32 _key) onlyAuthByTUN external {
delete intStorage[_key];
}
function deleteString(bytes32 _key) onlyAuthByTUN external {
delete stringStorage[_key];
}
function deleteUint(bytes32 _key) onlyAuthByTUN external {
delete uIntStorage[_key];
}
}