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
contract AccessAdmin is Ownable {
mapping (address => bool) adminContracts;
mapping (address => bool) actionContracts;
function setAdminContract(address _addr, bool _useful) public onlyOwner {
require(_addr != address(0));
adminContracts[_addr] = _useful;
}
modifier onlyAdmin {
require(adminContracts[msg.sender]);
_;
}
function setActionContract(address _actionAddr, bool _useful) public onlyAdmin {
actionContracts[_actionAddr] = _useful;
}
modifier onlyAccess() {
require(actionContracts[msg.sender]);
_;
}
}
bytes4 retval = ERC721TokenReceiver(_to).onERC721Received(_from, _tokenId, data);
require(retval == 0xf0b9e5ba);
}
function transferFrom(address _from, address _to, uint256 _tokenId)
external
isValidToken(_tokenId)
onlyOwnerOf(_tokenId)
payable
{
address owner = IndexToOwner[_tokenId];
require(owner != address(0) && owner == _from);
require(_to != address(0));
_transfer(_from, _to, _tokenId);
}
function approve(address _approved, uint256 _tokenId)
external
isValidToken(_tokenId)
onlyOwnerOf(_tokenId)
payable
{
address owner = IndexToOwner[_tokenId];
require(operatorToApprovals[owner][msg.sender]);
IndexToApproved[_tokenId] = _approved;
Approval(owner, _approved, _tokenId);
}
function setApprovalForAll(address _operator, bool _approved)
external
{
operatorToApprovals[msg.sender][_operator] = _approved;
ApprovalForAll(msg.sender, _operator, _approved);
}
function getApproved(uint256 _tokenId) external view isValidToken(_tokenId) returns (address) {
return IndexToApproved[_tokenId];
}
function isApprovedForAll(address _owner, address _operator) external view returns (bool) {
return operatorToApprovals[_owner][_operator];
}
function totalSupply() external view returns (uint256) {
return rareArray.length -1;
}
function tokenByIndex(uint256 _index) external view returns (uint256) {
require(_index <= (rareArray.length - 1));
return _index;
}
function tokenOfOwnerByIndex(address _owner, uint256 _index) external view returns (uint256) {
require(_index < ownerToRareArray[_owner].length);
if (_owner != address(0)) {
uint256 tokenId = ownerToRareArray[_owner][_index];
return tokenId;
}
}
function tokensOfOwner(address _owner) external view returns(uint256[]) {
uint256 tokenCount = ownerToRareArray[_owner].length;
if (tokenCount == 0) {
return new uint256[](0);
} else {
uint256[] memory result = new uint256[](tokenCount);
uint256 totalRare = rareArray.length - 1;
uint256 resultIndex = 0;
uint256 tokenId;
for (tokenId = 0; tokenId <= totalRare; tokenId++) {
if (IndexToOwner[tokenId] == _owner) {
result[resultIndex] = tokenId;
resultIndex++;
}
}
return result;
}
}
function transferToken(address _from, address _to, uint256 _tokenId) external onlyAccess {
_transfer(_from,  _to, _tokenId);
}
function transferTokenByContract(uint256 _tokenId,address _to) external onlyAccess {
_transfer(thisAddress,  _to, _tokenId);
}
function getRareItemInfo() external view returns (address[], uint256[], uint256[]) {
address[] memory itemOwners = new address[](rareArray.length-1);
uint256[] memory itemPrices = new uint256[](rareArray.length-1);
uint256[] memory itemPlatPrices = new uint256[](rareArray.length-1);
uint256 startId = 1;
uint256 endId = rareArray.length-1;
uint256 i;
while (startId <= endId) {
itemOwners[i] = IndexToOwner[startId];
itemPrices[i] = IndexToPrice[startId];
itemPlatPrices[i] = SafeMath.mul(IndexToPrice[startId],PLATPrice);
i++;
startId++;
}
return (itemOwners, itemPrices, itemPlatPrices);
}
}
library SafeMath {
function mul(uint256 a, uint256 b) internal pure returns (uint256) {
if (a == 0) {
return 0;
}
uint256 c = a * b;
assert(c / a == b);
return c;
}
function div(uint256 a, uint256 b) internal pure returns (uint256) {
uint256 c = a / b;
return c;
}
function sub(uint256 a, uint256 b) internal pure returns (uint256) {
assert(b <= a);
return a - b;
}
function add(uint256 a, uint256 b) internal pure returns (uint256) {
uint256 c = a + b;
assert(c >= a);
return c;
}
}