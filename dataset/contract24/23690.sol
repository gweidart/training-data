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
contract Pausable is Ownable {
event SetPaused(bool paused);
bool public paused = false;
modifier whenNotPaused() {
require(!paused);
_;
}
modifier whenPaused() {
require(paused);
_;
}
function pause() public onlyOwner whenNotPaused returns (bool) {
paused = true;
SetPaused(paused);
return true;
}
function unpause() public onlyOwner whenPaused returns (bool) {
paused = false;
SetPaused(paused);
return true;
}
}
contract EtherbotsPrivileges is Pausable {
event ContractUpgrade(address newContract);
}
contract EtherbotsBase is EtherbotsPrivileges {
function EtherbotsBase() public {
}
event Forge(address owner, uint256 partID, Part part);
event Transfer(address from, address to, uint256 tokenId);
struct Part {
uint32 tokenId;
uint8 partType;
uint8 partSubType;
uint8 rarity;
uint8 element;
uint32 battlesLastDay;
uint32 experience;
uint32 forgeTime;
uint32 battlesLastReset;
}
uint8 constant DEFENCE = 1;
uint8 constant MELEE = 2;
uint8 constant BODY = 3;
uint8 constant TURRET = 4;
uint8 constant STANDARD = 1;
uint8 constant SHADOW = 2;
uint8 constant GOLD = 3;
struct User {
uint32 numShards;
uint32 experience;
uint8[32] perks;
}
mapping ( address => User ) public addressToUser;
Part[] parts;
mapping (uint256 => address) public partIndexToOwner;
mapping (address => uint256) addressToTokensOwned;
mapping (uint256 => address) public partIndexToApproved;
address auction;
address[] approvedBattles;
function getUserByAddress(address _user) public view returns (uint32, uint8[32]) {
return (addressToUser[_user].experience, addressToUser[_user].perks);
}
function _transfer(address _from, address _to, uint256 _tokenId) internal {
addressToTokensOwned[_to]++;
partIndexToOwner[_tokenId] = _to;
if (_from != address(0)) {
addressToTokensOwned[_from]--;
delete partIndexToApproved[_tokenId];
}
Transfer(_from, _to, _tokenId);
}
function getPartById(uint _id) external view returns (
uint32 tokenId,
uint8 partType,
uint8 partSubType,
uint8 rarity,
uint8 element,
uint32 battlesLastDay,
uint32 experience,
uint32 forgeTime,
uint32 battlesLastReset
) {
Part memory p = parts[_id];
return (p.tokenId, p.partType, p.partSubType, p.rarity, p.element, p.battlesLastDay, p.experience, p.forgeTime, p.battlesLastReset);
}
function substring(string str, uint startIndex, uint endIndex) internal pure returns (string) {
bytes memory strBytes = bytes(str);
bytes memory result = new bytes(endIndex-startIndex);
for (uint i = startIndex; i < endIndex; i++) {
result[i-startIndex] = strBytes[i];
}
return string(result);
}
function stringToUint32(string s) internal pure returns (uint32) {
bytes memory b = bytes(s);
uint result = 0;
for (uint i = 0; i < b.length; i++) {
if (b[i] >= 48 && b[i] <= 57) {
result = result * 10 + (uint(b[i]) - 48);
}
}
return uint32(result);
}
function stringToUint8(string s) internal pure returns (uint8) {
return uint8(stringToUint32(s));
}
function uintToString(uint v) internal pure returns (string) {
uint maxlength = 100;
bytes memory reversed = new bytes(maxlength);
uint i = 0;
while (v != 0) {
uint remainder = v % 10;
v = v / 10;
reversed[i++] = byte(48 + remainder);
}
bytes memory s = new bytes(i);
for (uint j = 0; j < i; j++) {
s[j] = reversed[i - j - 1];
}
string memory str = string(s);
return str;
}
}
contract ERC721 {
bytes4 internal constant INTERFACE_SIGNATURE_ERC165 =
bytes4(keccak256("supportsInterface(bytes4)"));
bytes4 internal constant INTERFACE_SIGNATURE_ERC721 =
bytes4(keccak256("ownerOf(uint256)")) ^
bytes4(keccak256("countOfDeeds()")) ^
bytes4(keccak256("countOfDeedsByOwner(address)")) ^
bytes4(keccak256("deedOfOwnerByIndex(address,uint256)")) ^
bytes4(keccak256("approve(address,uint256)")) ^
bytes4(keccak256("takeOwnership(uint256)"));
function supportsInterface(bytes4 _interfaceID) external pure returns (bool);
function ownerOf(uint256 _deedId) public view returns (address _owner);
function countOfDeeds() external view returns (uint256 _count);
function countOfDeedsByOwner(address _owner) external view returns (uint256 _count);
function deedOfOwnerByIndex(address _owner, uint256 _index) external view returns (uint256 _deedId);
event Transfer(address indexed from, address indexed to, uint256 indexed deedId);
event Approval(address indexed owner, address indexed approved, uint256 indexed deedId);
function approve(address _to, uint256 _deedId) external payable;
function takeOwnership(uint256 _deedId) external payable;
}
contract ERC721Metadata is ERC721 {
bytes4 internal constant INTERFACE_SIGNATURE_ERC721Metadata =
bytes4(keccak256("name()")) ^
bytes4(keccak256("symbol()")) ^
bytes4(keccak256("deedUri(uint256)"));
function name() public pure returns (string n);
function symbol() public pure returns (string s);