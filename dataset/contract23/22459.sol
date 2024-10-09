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
contract ERC721 {
event Transfer(address indexed _from, address indexed _to, uint256 _tokenId);
event Approval(address indexed _owner, address indexed _approved, uint256 _tokenId);
function balanceOf(address _owner) public view returns (uint256 _balance);
function ownerOf(uint256 _tokenId) public view returns (address _owner);
function transfer(address _to, uint256 _tokenId) public;
function approve(address _to, uint256 _tokenId) public;
function takeOwnership(uint256 _tokenId) public;
}
contract Marketplace is Ownable {
ERC721 public nft;
mapping (uint256 => Listing) public listings;
uint256 public minListingSeconds;
uint256 public maxListingSeconds;
struct Listing {
address seller;
uint256 startingPrice;
uint256 minimumPrice;
uint256 createdAt;
uint256 durationSeconds;
}
event TokenListed(uint256 indexed _tokenId, uint256 _startingPrice, uint256 _minimumPrice, uint256 _durationSeconds, address _seller);
event TokenUnlisted(uint256 indexed _tokenId, address _unlister);
event TokenSold(uint256 indexed _tokenId, uint256 _price, uint256 _paidAmount, address indexed _seller, address _buyer);
modifier nftOnly() {
require(msg.sender == address(nft));
_;
}
function Marketplace(ERC721 _nft, uint256 _minListingSeconds, uint256 _maxListingSeconds) public {
nft = _nft;
minListingSeconds = _minListingSeconds;
maxListingSeconds = _maxListingSeconds;
}
function list(address _tokenSeller, uint256 _tokenId, uint256 _startingPrice, uint256 _minimumPrice, uint256 _durationSeconds) public nftOnly {
require(_durationSeconds >= minListingSeconds && _durationSeconds <= maxListingSeconds);
require(_startingPrice >= _minimumPrice);
require(! listingActive(_tokenId));
listings[_tokenId] = Listing(_tokenSeller, _startingPrice, _minimumPrice, now, _durationSeconds);
nft.takeOwnership(_tokenId);
TokenListed(_tokenId, _startingPrice, _minimumPrice, _durationSeconds, _tokenSeller);
}
function unlist(address _caller, uint256 _tokenId) public nftOnly {
address _seller = listings[_tokenId].seller;
require(_seller == _caller || address(owner) == _caller);
nft.transfer(_seller, _tokenId);
delete listings[_tokenId];
TokenUnlisted(_tokenId, _caller);
}
function purchase(address _caller, uint256 _tokenId, uint256 _totalPaid) public payable nftOnly {
Listing memory _listing = listings[_tokenId];
address _seller = _listing.seller;
require(_caller != _seller);
require(listingActive(_tokenId));
uint256 _price = currentPrice(_tokenId);
require(_totalPaid >= _price);
delete listings[_tokenId];
nft.transfer(_caller, _tokenId);
_seller.transfer(msg.value);
TokenSold(_tokenId, _price, _totalPaid, _seller, _caller);
}
function currentPrice(uint256 _tokenId) public view returns (uint256) {
Listing memory listing = listings[_tokenId];
require(now >= listing.createdAt);
uint256 _deadline = listing.createdAt + listing.durationSeconds;
require(now <= _deadline);
uint256 _elapsedTime = now - listing.createdAt;
uint256 _progress = (_elapsedTime * 100) / listing.durationSeconds;
uint256 _delta = listing.startingPrice - listing.minimumPrice;
return listing.startingPrice - ((_delta * _progress) / 100);
}
function listingActive(uint256 _tokenId) internal view returns (bool) {
Listing memory listing = listings[_tokenId];
return listing.createdAt + listing.durationSeconds >= now && now >= listing.createdAt;
}
}