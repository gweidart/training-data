pragma solidity ^0.4.21;
library StringUtils {
function allLower(string memory _string) internal pure returns (bool) {
bytes memory bytesString = bytes(_string);
for (uint i = 0; i < bytesString.length; i++) {
if ((bytesString[i] >= 65) && (bytesString[i] <= 90)) {
return false;
}
}
return true;
}
}
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
interface HydroToken {
function balanceOf(address _owner) external returns (uint256 balance);
}
contract RaindropClient is Withdrawable {
event UserSignUp(string userName, address userAddress, bool official);
event UserDeleted(string userName, address userAddress, bool official);
event ApplicationSignUp(string applicationName, bool official);
event ApplicationDeleted(string applicationName, bool official);
using StringUtils for string;
uint public unofficialUserSignUpFee;
uint public unofficialApplicationSignUpFee;
address public hydroTokenAddress;
uint public hydroStakingMinimum;
struct User {
string userName;
address userAddress;
bool official;
bool _initialized;
}
struct Application {
string applicationName;
bool official;
bool _initialized;
}
mapping (bytes32 => User) internal userDirectory;
mapping (bytes32 => Application) internal officialApplicationDirectory;
mapping (bytes32 => Application) internal unofficialApplicationDirectory;
function officialUserSignUp(string userName, address userAddress) public onlyOwner {
_userSignUp(userName, userAddress, true);
}
function unofficialUserSignUp(string userName) public payable {
require(bytes(userName).length < 100);
require(msg.value >= unofficialUserSignUpFee);
return _userSignUp(userName, msg.sender, false);
}
function deleteUserForUser(string userName, uint8 v, bytes32 r, bytes32 s) public onlyOwner {
bytes32 userNameHash = keccak256(userName);
require(userNameHashTaken(userNameHash));
address userAddress = userDirectory[userNameHash].userAddress;
require(isSigned(userAddress, keccak256("Delete"), v, r, s));
delete userDirectory[userNameHash];
emit UserDeleted(userName, userAddress, true);
}
function deleteUser(string userName) public {
bytes32 userNameHash = keccak256(userName);
require(userNameHashTaken(userNameHash));
address userAddress = userDirectory[userNameHash].userAddress;
require(userAddress == msg.sender);
delete userDirectory[userNameHash];
emit UserDeleted(userName, userAddress, true);
}
function officialApplicationSignUp(string applicationName) public onlyOwner {
bytes32 applicationNameHash = keccak256(applicationName);
require(!applicationNameHashTaken(applicationNameHash, true));
officialApplicationDirectory[applicationNameHash] = Application(applicationName, true, true);
emit ApplicationSignUp(applicationName, true);
}
function unofficialApplicationSignUp(string applicationName) public payable {
require(bytes(applicationName).length < 100);
require(msg.value >= unofficialApplicationSignUpFee);
require(applicationName.allLower());
HydroToken hydro = HydroToken(hydroTokenAddress);
uint256 hydroBalance = hydro.balanceOf(msg.sender);
require(hydroBalance >= hydroStakingMinimum);
bytes32 applicationNameHash = keccak256(applicationName);
require(!applicationNameHashTaken(applicationNameHash, false));
unofficialApplicationDirectory[applicationNameHash] = Application(applicationName, false, true);
emit ApplicationSignUp(applicationName, false);
}
function deleteApplication(string applicationName, bool official) public onlyOwner {
bytes32 applicationNameHash = keccak256(applicationName);
require(applicationNameHashTaken(applicationNameHash, official));
if (official) {
delete officialApplicationDirectory[applicationNameHash];
} else {
delete unofficialApplicationDirectory[applicationNameHash];
}
emit ApplicationDeleted(applicationName, official);
}
function setUnofficialUserSignUpFee(uint newFee) public onlyOwner {
unofficialUserSignUpFee = newFee;
}
function setUnofficialApplicationSignUpFee(uint newFee) public onlyOwner {
unofficialApplicationSignUpFee = newFee;
}
function setHydroContractAddress(address _hydroTokenAddress) public onlyOwner {
hydroTokenAddress = _hydroTokenAddress;
}
function setHydroStakingMinimum(uint newMinimum) public onlyOwner {
hydroStakingMinimum = newMinimum;
}
function userNameTaken(string userName) public view returns (bool taken) {
bytes32 userNameHash = keccak256(userName);
return userDirectory[userNameHash]._initialized;
}
function applicationNameTaken(string applicationName)
public
view
returns (bool officialTaken, bool unofficialTaken)
{
bytes32 applicationNameHash = keccak256(applicationName);
return (
officialApplicationDirectory[applicationNameHash]._initialized,
unofficialApplicationDirectory[applicationNameHash]._initialized
);
}
function getUserByName(string userName) public view returns (address userAddress, bool official) {
bytes32 userNameHash = keccak256(userName);
require(userNameHashTaken(userNameHash));
User storage _user = userDirectory[userNameHash];
return (_user.userAddress, _user.official);
}
function isSigned(address _address, bytes32 messageHash, uint8 v, bytes32 r, bytes32 s) public pure returns (bool) {
return ecrecover(messageHash, v, r, s) == _address;
}
function _userSignUp(string userName, address userAddress, bool official) internal {
bytes32 userNameHash = keccak256(userName);
require(!userNameHashTaken(userNameHash));
userDirectory[userNameHash] = User(userName, userAddress, official, true);
emit UserSignUp(userName, userAddress, official);
}
function userNameHashTaken(bytes32 userNameHash) internal view returns (bool) {
return userDirectory[userNameHash]._initialized;
}
function applicationNameHashTaken(bytes32 applicationNameHash, bool official) internal view returns (bool) {
if (official) {
return officialApplicationDirectory[applicationNameHash]._initialized;
} else {
return unofficialApplicationDirectory[applicationNameHash]._initialized;
}
}
}