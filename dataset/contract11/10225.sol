pragma solidity ^0.4.19;
contract RocketStorage {
mapping(bytes32 => uint256)    private uIntStorage;
mapping(bytes32 => string)     private stringStorage;
mapping(bytes32 => address)    private addressStorage;
mapping(bytes32 => bytes)      private bytesStorage;
mapping(bytes32 => bool)       private boolStorage;
mapping(bytes32 => int256)     private intStorage;
modifier onlyLatestRocketNetworkContract() {
if (boolStorage[keccak256("contract.storage.initialised")] == true) {
require(addressStorage[keccak256("contract.address", msg.sender)] != 0x0);
}
_;
}
constructor() public {
boolStorage[keccak256("access.role", "owner", msg.sender)] = true;
}
function getAddress(bytes32 _key) external view returns (address) {
return addressStorage[_key];
}
function getUint(bytes32 _key) external view returns (uint) {
return uIntStorage[_key];
}
function getString(bytes32 _key) external view returns (string) {
return stringStorage[_key];
}
function getBytes(bytes32 _key) external view returns (bytes) {
return bytesStorage[_key];
}
function getBool(bytes32 _key) external view returns (bool) {
return boolStorage[_key];
}
function getInt(bytes32 _key) external view returns (int) {
return intStorage[_key];
}
function setAddress(bytes32 _key, address _value) onlyLatestRocketNetworkContract external {
addressStorage[_key] = _value;
}
function setUint(bytes32 _key, uint _value) onlyLatestRocketNetworkContract external {
uIntStorage[_key] = _value;
}
function setString(bytes32 _key, string _value) onlyLatestRocketNetworkContract external {
stringStorage[_key] = _value;
}
function setBytes(bytes32 _key, bytes _value) onlyLatestRocketNetworkContract external {
bytesStorage[_key] = _value;
}
function setBool(bytes32 _key, bool _value) onlyLatestRocketNetworkContract external {
boolStorage[_key] = _value;
}
function setInt(bytes32 _key, int _value) onlyLatestRocketNetworkContract external {
intStorage[_key] = _value;
}
function deleteAddress(bytes32 _key) onlyLatestRocketNetworkContract external {
delete addressStorage[_key];
}
function deleteUint(bytes32 _key) onlyLatestRocketNetworkContract external {
delete uIntStorage[_key];
}
function deleteString(bytes32 _key) onlyLatestRocketNetworkContract external {
delete stringStorage[_key];
}
function deleteBytes(bytes32 _key) onlyLatestRocketNetworkContract external {
delete bytesStorage[_key];
}
function deleteBool(bytes32 _key) onlyLatestRocketNetworkContract external {
delete boolStorage[_key];
}
function deleteInt(bytes32 _key) onlyLatestRocketNetworkContract external {
delete intStorage[_key];
}
function kcck256str(string _key1) external pure returns (bytes32) {
return keccak256(_key1);
}
function kcck256strstr(string _key1, string _key2) external pure returns (bytes32) {
return keccak256(_key1, _key2);
}
function kcck256stradd(string _key1, address _key2) external pure returns (bytes32) {
return keccak256(_key1, _key2);
}
function kcck256straddadd(string _key1, address _key2, address _key3) external pure returns (bytes32) {
return keccak256(_key1, _key2, _key3);
}
}