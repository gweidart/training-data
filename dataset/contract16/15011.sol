pragma solidity ^0.4.23;
library StringUtils {
struct slice {
uint _len;
uint _ptr;
}
function toSlice(string self) internal pure returns (slice) {
uint ptr;
assembly {
ptr := add(self, 0x20)
}
return slice(bytes(self).length, ptr);
}
function copy(slice self) internal pure returns (slice) {
return slice(self._len, self._ptr);
}
function toString(slice self) internal pure returns (string) {
string memory ret = new string(self._len);
uint retptr;
assembly { retptr := add(ret, 32) }
memcpy(retptr, self._ptr, self._len);
return ret;
}
function lower(string _base) internal pure returns (string) {
bytes memory _baseBytes = bytes(_base);
for (uint i = 0; i < _baseBytes.length; i++) {
_baseBytes[i] = _lower(_baseBytes[i]);
}
return string(_baseBytes);
}
function _lower(bytes1 _b1) internal pure returns (bytes1) {
if (_b1 >= 0x41 && _b1 <= 0x5A) {
return bytes1(uint8(_b1) + 32);
}
return _b1;
}
function memcpy(uint dest, uint src, uint len) private pure {
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
contract Ownable {
address public owner;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
constructor() public {
owner = msg.sender;
}
modifier onlyOwner() {
require(msg.sender == owner);
_;
}
function transferOwnership(address newOwner) public onlyOwner {
require(newOwner != address(0));
emit OwnershipTransferred(owner, newOwner);
owner = newOwner;
}
}
contract ERC20Basic {
function totalSupply() public view returns (uint256);
function balanceOf(address who) public view returns (uint256);
function transfer(address to, uint256 value) public returns (bool);
event Transfer(address indexed from, address indexed to, uint256 value);
}
contract Withdrawable is Ownable {
function withdrawEther(address to) public onlyOwner {
to.transfer(address(this).balance);
}
function withdrawERC20Token(address tokenAddress, address to) public onlyOwner {
ERC20Basic token = ERC20Basic(tokenAddress);
token.transfer(to, token.balanceOf(address(this)));
}
}
contract RaindropClient is Withdrawable {
using StringUtils for string;
using StringUtils for StringUtils.slice;
event UserSignUp(string casedUserName, address userAddress, bool delegated);
event UserDeleted(string casedUserName);
address public hydroTokenAddress;
uint public minimumHydroStakeUser;
uint public minimumHydroStakeDelegatedUser;
struct User {
string casedUserName;
address userAddress;
bool delegated;
bool _initialized;
}
mapping (bytes32 => User) internal userDirectory;
mapping (address => bytes32) internal nameDirectory;
modifier requireStake(address _address, uint stake) {
ERC20Basic hydro = ERC20Basic(hydroTokenAddress);
require(hydro.balanceOf(_address) >= stake);
_;
}
function signUpDelegatedUser(string casedUserName, address userAddress, uint8 v, bytes32 r, bytes32 s)
public
requireStake(msg.sender, minimumHydroStakeDelegatedUser)
{
require(isSigned(userAddress, keccak256("Create RaindropClient Hydro Account"), v, r, s));
_userSignUp(casedUserName, userAddress, true);
}
function signUpUser(string casedUserName) public requireStake(msg.sender, minimumHydroStakeUser) {
return _userSignUp(casedUserName, msg.sender, false);
}
function deleteUser() public {
bytes32 uncasedUserNameHash = nameDirectory[msg.sender];
require(userDirectory[uncasedUserNameHash]._initialized);
string memory casedUserName = userDirectory[uncasedUserNameHash].casedUserName;
delete nameDirectory[msg.sender];
delete userDirectory[uncasedUserNameHash];
emit UserDeleted(casedUserName);
}
function setHydroTokenAddress(address _hydroTokenAddress) public onlyOwner {
hydroTokenAddress = _hydroTokenAddress;
}
function setMinimumHydroStakes(uint newMinimumHydroStakeUser, uint newMinimumHydroStakeDelegatedUser)
public onlyOwner
{
ERC20Basic hydro = ERC20Basic(hydroTokenAddress);
require(newMinimumHydroStakeUser <= (hydro.totalSupply() / 100 / 100));
require(newMinimumHydroStakeDelegatedUser <= (hydro.totalSupply() / 100 / 2));
minimumHydroStakeUser = newMinimumHydroStakeUser;
minimumHydroStakeDelegatedUser = newMinimumHydroStakeDelegatedUser;
}
function userNameTaken(string userName) public view returns (bool taken) {
bytes32 uncasedUserNameHash = keccak256(userName.lower());
return userDirectory[uncasedUserNameHash]._initialized;
}
function getUserByName(string userName) public view
returns (string casedUserName, address userAddress, bool delegated)
{
bytes32 uncasedUserNameHash = keccak256(userName.lower());
User storage _user = userDirectory[uncasedUserNameHash];
require(_user._initialized);
return (_user.casedUserName, _user.userAddress, _user.delegated);
}
function getUserByAddress(address _address) public view returns (string casedUserName, bool delegated) {
bytes32 uncasedUserNameHash = nameDirectory[_address];
User storage _user = userDirectory[uncasedUserNameHash];
require(_user._initialized);
return (_user.casedUserName, _user.delegated);
}
function isSigned(address _address, bytes32 messageHash, uint8 v, bytes32 r, bytes32 s) public pure returns (bool) {
return (_isSigned(_address, messageHash, v, r, s) || _isSignedPrefixed(_address, messageHash, v, r, s));
}
function _isSigned(address _address, bytes32 messageHash, uint8 v, bytes32 r, bytes32 s)
internal
pure
returns (bool)
{
return ecrecover(messageHash, v, r, s) == _address;
}
function _isSignedPrefixed(address _address, bytes32 messageHash, uint8 v, bytes32 r, bytes32 s)
internal
pure
returns (bool)
{
bytes memory prefix = "\x19Ethereum Signed Message:\n32";
bytes32 prefixedMessageHash = keccak256(prefix, messageHash);
return ecrecover(prefixedMessageHash, v, r, s) == _address;
}
function _userSignUp(string casedUserName, address userAddress, bool delegated) internal {
require(bytes(casedUserName).length < 50);
bytes32 uncasedUserNameHash = keccak256(casedUserName.toSlice().copy().toString().lower());
require(!userDirectory[uncasedUserNameHash]._initialized);
userDirectory[uncasedUserNameHash] = User(casedUserName, userAddress, delegated, true);
nameDirectory[userAddress] = uncasedUserNameHash;
emit UserSignUp(casedUserName, userAddress, delegated);
}
}