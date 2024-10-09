pragma solidity ^0.4.23;
contract Ownable {
address public owner;
event OwnershipTransferred(
address indexed previousOwner,
address indexed newOwner
);
function Ownable() {
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
contract Contactable is Ownable {
string public contactInformation;
function setContactInformation(string info) public onlyOwner {
contactInformation = info;
}
}
contract MonethaUsersClaimStorage is Contactable {
string constant VERSION = "0.1";
mapping(address => uint256) public claimedTokens;
event UpdatedClaim(
address indexed _userAddress,
uint256 _claimedTokens,
bool _isDeleted
);
event DeletedClaim(
address indexed _userAddress,
uint256 _unclaimedTokens,
bool _isDeleted
);
function updateUserClaim(
address _userAddress,
uint256 _tokens
) external onlyOwner returns (bool) {
claimedTokens[_userAddress] = claimedTokens[_userAddress] + _tokens;
emit UpdatedClaim(_userAddress, _tokens, false);
return true;
}
function updateUserClaimInBulk(
address[] _userAddresses,
uint256[] _tokens
) external onlyOwner returns (bool) {
require(_userAddresses.length == _tokens.length);
for (uint16 i = 0; i < _userAddresses.length; i++) {
claimedTokens[_userAddresses[i]] =
claimedTokens[_userAddresses[i]] +
_tokens[i];
emit UpdatedClaim(_userAddresses[i], _tokens[i], false);
}
return true;
}
function deleteUserClaim(
address _userAddress
) external onlyOwner returns (bool) {
delete claimedTokens[_userAddress];
emit DeletedClaim(_userAddress, 0, true);
return true;
}
function deleteUserClaimInBulk(
address[] _userAddresses
) external onlyOwner returns (bool) {
for (uint16 i = 0; i < _userAddresses.length; i++) {
delete claimedTokens[_userAddresses[i]];
emit DeletedClaim(_userAddresses[i], 0, true);
}
return true;
}
}