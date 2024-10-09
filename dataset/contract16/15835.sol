pragma solidity ^0.4.21;
contract ERC721 {
function totalSupply() public view returns (uint256 total);
function balanceOf(address _owner) public view returns (uint256 balance);
function ownerOf(uint256 _tokenId) external view returns (address owner);
function approve(address _to, uint256 _tokenId) external;
function transfer(address _to, uint256 _tokenId) external;
function transferFrom(address _from, address _to, uint256 _tokenId) external;
event Transfer(address from, address to, uint256 tokenId);
event Approval(address owner, address approved, uint256 tokenId);
function supportsInterface(bytes4 _interfaceID) external view returns (bool);
}
contract Ownable {
address public owner;
event OwnershipTransferred(address previousOwner, address newOwner);
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
contract StorageBase is Ownable {
function withdrawBalance() external onlyOwner returns (bool) {
bool res = msg.sender.send(address(this).balance);
return res;
}
}
contract ClockAuctionStorage is StorageBase {
struct Auction {
address seller;
uint128 startingPrice;
uint128 endingPrice;
uint64 duration;
uint64 startedAt;
}
mapping (uint256 => Auction) tokenIdToAuction;
function addAuction(
uint256 _tokenId,
address _seller,
uint128 _startingPrice,
uint128 _endingPrice,
uint64 _duration,
uint64 _startedAt
)
external
onlyOwner
{
tokenIdToAuction[_tokenId] = Auction(
_seller,
_startingPrice,
_endingPrice,
_duration,
_startedAt
);
}
function removeAuction(uint256 _tokenId) public onlyOwner {
delete tokenIdToAuction[_tokenId];
}
function getAuction(uint256 _tokenId)
external
view
returns (
address seller,
uint128 startingPrice,
uint128 endingPrice,
uint64 duration,
uint64 startedAt
)
{
Auction storage auction = tokenIdToAuction[_tokenId];
return (
auction.seller,
auction.startingPrice,
auction.endingPrice,
auction.duration,
auction.startedAt
);
}
function isOnAuction(uint256 _tokenId) external view returns (bool) {
return (tokenIdToAuction[_tokenId].startedAt > 0);
}
function getSeller(uint256 _tokenId) external view returns (address) {
return tokenIdToAuction[_tokenId].seller;
}
function transfer(ERC721 _nonFungibleContract, address _receiver, uint256 _tokenId) external onlyOwner {
_nonFungibleContract.transfer(_receiver, _tokenId);
}
}
contract SaleClockAuctionStorage is ClockAuctionStorage {
bool public isSaleClockAuctionStorage = true;
uint256 public totalSoldCount;
uint256[3] public lastSoldPrices;
uint256 public systemOnSaleCount;
mapping (uint256 => bool) systemOnSaleTokens;
function removeAuction(uint256 _tokenId) public onlyOwner {
super.removeAuction(_tokenId);
if (systemOnSaleTokens[_tokenId]) {
delete systemOnSaleTokens[_tokenId];
if (systemOnSaleCount > 0) {
systemOnSaleCount--;
}
}
}
function recordSystemOnSaleToken(uint256 _tokenId) external onlyOwner {
if (!systemOnSaleTokens[_tokenId]) {
systemOnSaleTokens[_tokenId] = true;
systemOnSaleCount++;
}
}
function recordSoldPrice(uint256 _price) external onlyOwner {
lastSoldPrices[totalSoldCount % 3] = _price;
totalSoldCount++;
}
function averageSoldPrice() external view returns (uint256) {
if (totalSoldCount == 0) return 0;
uint256 sum = 0;
uint256 len = (totalSoldCount < 3 ? totalSoldCount : 3);
for (uint256 i = 0; i < len; i++) {
sum += lastSoldPrices[i];
}
return sum / len;
}
}