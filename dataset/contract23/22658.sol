pragma solidity ^0.4.19;
contract BdpBaseData {
address public ownerAddress;
address public managerAddress;
address[16] public contracts;
bool public paused = false;
bool public setupComplete = false;
bytes8 public version;
}
library BdpContracts {
function getBdpEntryPoint(address[16] _contracts) pure internal returns (address) {
return _contracts[0];
}
function getBdpController(address[16] _contracts) pure internal returns (address) {
return _contracts[1];
}
function getBdpControllerHelper(address[16] _contracts) pure internal returns (address) {
return _contracts[3];
}
function getBdpDataStorage(address[16] _contracts) pure internal returns (address) {
return _contracts[4];
}
function getBdpImageStorage(address[16] _contracts) pure internal returns (address) {
return _contracts[5];
}
function getBdpOwnershipStorage(address[16] _contracts) pure internal returns (address) {
return _contracts[6];
}
function getBdpPriceStorage(address[16] _contracts) pure internal returns (address) {
return _contracts[7];
}
}
contract BdpBase is BdpBaseData {
modifier onlyOwner() {
require(msg.sender == ownerAddress);
_;
}
modifier onlyAuthorized() {
require(msg.sender == ownerAddress || msg.sender == managerAddress);
_;
}
modifier whenContractActive() {
require(!paused && setupComplete);
_;
}
modifier storageAccessControl() {
require(
(! setupComplete && (msg.sender == ownerAddress || msg.sender == managerAddress))
|| (setupComplete && !paused && (msg.sender == BdpContracts.getBdpEntryPoint(contracts)))
);
_;
}
function setOwner(address _newOwner) external onlyOwner {
require(_newOwner != address(0));
ownerAddress = _newOwner;
}
function setManager(address _newManager) external onlyOwner {
require(_newManager != address(0));
managerAddress = _newManager;
}
function setContracts(address[16] _contracts) external onlyOwner {
contracts = _contracts;
}
function pause() external onlyAuthorized {
paused = true;
}
function unpause() external onlyOwner {
paused = false;
}
function setSetupComplete() external onlyOwner {
setupComplete = true;
}
function kill() public onlyOwner {
selfdestruct(ownerAddress);
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
contract BdpDataStorage is BdpBase {
using SafeMath for uint256;
struct Region {
uint256 x1;
uint256 y1;
uint256 x2;
uint256 y2;
uint256 currentImageId;
uint256 nextImageId;
uint8[128] url;
uint256 currentPixelPrice;
uint256 blockUpdatedAt;
uint256 updatedAt;
uint256 purchasedAt;
uint256 purchasedPixelPrice;
}
uint256 public lastRegionId = 0;
mapping (uint256 => Region) public data;
function getLastRegionId() view public returns (uint256) {
return lastRegionId;
}
function getNextRegionId() public storageAccessControl returns (uint256) {
lastRegionId = lastRegionId.add(1);
return lastRegionId;
}
function deleteRegionData(uint256 _id) public storageAccessControl {
delete data[_id];
}
function getRegionCoordinates(uint256 _id) view public returns (uint256, uint256, uint256, uint256) {
return (data[_id].x1, data[_id].y1, data[_id].x2, data[_id].y2);
}
function setRegionCoordinates(uint256 _id, uint256 _x1, uint256 _y1, uint256 _x2, uint256 _y2) public storageAccessControl {
data[_id].x1 = _x1;
data[_id].y1 = _y1;
data[_id].x2 = _x2;
data[_id].y2 = _y2;
}
function getRegionCurrentImageId(uint256 _id) view public returns (uint256) {
return data[_id].currentImageId;
}
function setRegionCurrentImageId(uint256 _id, uint256 _currentImageId) public storageAccessControl {
data[_id].currentImageId = _currentImageId;
}
function getRegionNextImageId(uint256 _id) view public returns (uint256) {
return data[_id].nextImageId;
}
function setRegionNextImageId(uint256 _id, uint256 _nextImageId) public storageAccessControl {
data[_id].nextImageId = _nextImageId;
}
function getRegionUrl(uint256 _id) view public returns (uint8[128]) {
return data[_id].url;
}
function setRegionUrl(uint256 _id, uint8[128] _url) public storageAccessControl {
data[_id].url = _url;
}
function getRegionCurrentPixelPrice(uint256 _id) view public returns (uint256) {
return data[_id].currentPixelPrice;
}
function setRegionCurrentPixelPrice(uint256 _id, uint256 _currentPixelPrice) public storageAccessControl {
data[_id].currentPixelPrice = _currentPixelPrice;
}
function getRegionBlockUpdatedAt(uint256 _id) view public returns (uint256) {
return data[_id].blockUpdatedAt;
}
function setRegionBlockUpdatedAt(uint256 _id, uint256 _blockUpdatedAt) public storageAccessControl {
data[_id].blockUpdatedAt = _blockUpdatedAt;
}
function getRegionUpdatedAt(uint256 _id) view public returns (uint256) {
return data[_id].updatedAt;
}
function setRegionUpdatedAt(uint256 _id, uint256 _updatedAt) public storageAccessControl {
data[_id].updatedAt = _updatedAt;
}
function getRegionPurchasedAt(uint256 _id) view public returns (uint256) {
return data[_id].purchasedAt;
}
function setRegionPurchasedAt(uint256 _id, uint256 _purchasedAt) public storageAccessControl {
data[_id].purchasedAt = _purchasedAt;
}
function getRegionUpdatedAtPurchasedAt(uint256 _id) view public returns (uint256 _updatedAt, uint256 _purchasedAt) {
return (data[_id].updatedAt, data[_id].purchasedAt);
}
function getRegionPurchasePixelPrice(uint256 _id) view public returns (uint256) {
return data[_id].purchasedPixelPrice;
}
function setRegionPurchasedPixelPrice(uint256 _id, uint256 _purchasedPixelPrice) public storageAccessControl {
data[_id].purchasedPixelPrice = _purchasedPixelPrice;
}
function BdpDataStorage(bytes8 _version) public {
ownerAddress = msg.sender;
managerAddress = msg.sender;
version = _version;
}
}
contract BdpPriceStorage is BdpBase {
uint64[1001] public pricePoints;
uint256 public pricePointsLength = 0;
address public forwardPurchaseFeesTo = address(0);
address public forwardUpdateFeesTo = address(0);
function getPricePointsLength() view public returns (uint256) {
return pricePointsLength;
}
function getPricePoint(uint256 _i) view public returns (uint256) {
return pricePoints[_i];
}
function setPricePoints(uint64[] _pricePoints) public storageAccessControl {
pricePointsLength = 0;
appendPricePoints(_pricePoints);
}
function appendPricePoints(uint64[] _pricePoints) public storageAccessControl {
for (uint i = 0; i < _pricePoints.length; i++) {
pricePoints[pricePointsLength++] = _pricePoints[i];
}
}
function getForwardPurchaseFeesTo() view public returns (address) {
return forwardPurchaseFeesTo;
}
function setForwardPurchaseFeesTo(address _forwardPurchaseFeesTo) public storageAccessControl {
forwardPurchaseFeesTo = _forwardPurchaseFeesTo;
}
function getForwardUpdateFeesTo() view public returns (address) {
return forwardUpdateFeesTo;
}
function setForwardUpdateFeesTo(address _forwardUpdateFeesTo) public storageAccessControl {
forwardUpdateFeesTo = _forwardUpdateFeesTo;
}
function BdpPriceStorage(bytes8 _version) public {
ownerAddress = msg.sender;
managerAddress = msg.sender;
version = _version;
}
}
library BdpCalculator {
using SafeMath for uint256;
function calculateArea(address[16] _contracts, uint256 _regionId) view public returns (uint256 _area, uint256 _width, uint256 _height) {
var (x1, y1, x2, y2) = BdpDataStorage(BdpContracts.getBdpDataStorage(_contracts)).getRegionCoordinates(_regionId);
_width = x2 - x1 + 1;
_height = y2 - y1 + 1;
_area = _width * _height;
}
function countPurchasedPixels(address[16] _contracts) view public returns (uint256 _count) {
var lastRegionId = BdpDataStorage(BdpContracts.getBdpDataStorage(_contracts)).getLastRegionId();
for (uint256 i = 0; i <= lastRegionId; i++) {
if(BdpDataStorage(BdpContracts.getBdpDataStorage(_contracts)).getRegionPurchasedAt(i) > 0) {
var (area,,) = calculateArea(_contracts, i);
_count += area;
}
}
}
function calculateCurrentMarketPixelPrice(address[16] _contracts) view public returns(uint) {
return calculateMarketPixelPrice(_contracts, countPurchasedPixels(_contracts));
}
function calculateMarketPixelPrice(address[16] _contracts, uint _pixelsSold) view public returns(uint) {
var pricePointsLength = BdpPriceStorage(BdpContracts.getBdpPriceStorage(_contracts)).getPricePointsLength();
uint mod = _pixelsSold % (1000000 / (pricePointsLength - 1));
uint div = _pixelsSold * (pricePointsLength - 1) / 1000000;
var divPoint = BdpPriceStorage(BdpContracts.getBdpPriceStorage(_contracts)).getPricePoint(div);
if(mod == 0) return divPoint;
return divPoint + mod * (BdpPriceStorage(BdpContracts.getBdpPriceStorage(_contracts)).getPricePoint(div+1) - divPoint) * (pricePointsLength - 1) / 1000000;
}
function calculateAveragePixelPrice(address[16] _contracts, uint _a, uint _b) view public returns (uint _price) {
_price = (calculateMarketPixelPrice(_contracts, _a) + calculateMarketPixelPrice(_contracts, _b)) / 2;
}
function calculateRegionInitialSalePixelPrice(address[16] _contracts, uint256 _regionId) view public returns (uint256) {
require(BdpDataStorage(BdpContracts.getBdpDataStorage(_contracts)).getRegionUpdatedAt(_regionId) > 0);
var purchasedPixels = countPurchasedPixels(_contracts);
var (area,,) = calculateArea(_contracts, _regionId);
return calculateAveragePixelPrice(_contracts, purchasedPixels, purchasedPixels + area);
}
function calculateRegionSalePixelPrice(address[16] _contracts, uint256 _regionId) view public returns (uint256) {
var pixelPrice = BdpDataStorage(BdpContracts.getBdpDataStorage(_contracts)).getRegionCurrentPixelPrice(_regionId);
if(pixelPrice > 0) {
return pixelPrice * 3;
} else {
return calculateRegionInitialSalePixelPrice(_contracts, _regionId);
}
}
function calculateSetupAllowedUntil(address[16] _contracts, uint256 _regionId) view public returns (uint256) {
var (updatedAt, purchasedAt) = BdpDataStorage(BdpContracts.getBdpDataStorage(_contracts)).getRegionUpdatedAtPurchasedAt(_regionId);
if(updatedAt != purchasedAt) {
return 0;
} else {
return purchasedAt + 1 days;
}
}
}
contract BdpOwnershipStorage is BdpBase {
using SafeMath for uint256;
mapping (uint256 => address) public tokenOwner;
mapping (uint256 => address) public tokenApprovals;
mapping (address => uint256) public ownedArea;
mapping (address => uint256[]) public ownedTokens;
mapping(uint256 => uint256) public ownedTokensIndex;
uint256[] public tokenIds;
mapping (uint256 => uint256) public tokenIdsIndex;
function getTokenOwner(uint256 _tokenId) view public returns (address) {
return tokenOwner[_tokenId];
}
function setTokenOwner(uint256 _tokenId, address _owner) public storageAccessControl {
tokenOwner[_tokenId] = _owner;
}
function getTokenApproval(uint256 _tokenId) view public returns (address) {
return tokenApprovals[_tokenId];
}
function setTokenApproval(uint256 _tokenId, address _to) public storageAccessControl {
tokenApprovals[_tokenId] = _to;
}
function getOwnedArea(address _owner) view public returns (uint256) {
return ownedArea[_owner];
}
function setOwnedArea(address _owner, uint256 _area) public storageAccessControl {
ownedArea[_owner] = _area;
}
function incrementOwnedArea(address _owner, uint256 _area) public storageAccessControl returns (uint256) {
ownedArea[_owner] = ownedArea[_owner].add(_area);
return ownedArea[_owner];
}
function decrementOwnedArea(address _owner, uint256 _area) public storageAccessControl returns (uint256) {
ownedArea[_owner] = ownedArea[_owner].sub(_area);
return ownedArea[_owner];
}
function getOwnedTokensLength(address _owner) view public returns (uint256) {
return ownedTokens[_owner].length;
}
function getOwnedToken(address _owner, uint256 _index) view public returns (uint256) {
return ownedTokens[_owner][_index];
}
function setOwnedToken(address _owner, uint256 _index, uint256 _tokenId) public storageAccessControl {
ownedTokens[_owner][_index] = _tokenId;
}
function pushOwnedToken(address _owner, uint256 _tokenId) public storageAccessControl returns (uint256) {
ownedTokens[_owner].push(_tokenId);
return ownedTokens[_owner].length;
}
function decrementOwnedTokensLength(address _owner) public storageAccessControl {
ownedTokens[_owner].length--;
}
function getOwnedTokensIndex(uint256 _tokenId) view public returns (uint256) {
return ownedTokensIndex[_tokenId];
}
function setOwnedTokensIndex(uint256 _tokenId, uint256 _tokenIndex) public storageAccessControl {
ownedTokensIndex[_tokenId] = _tokenIndex;
}
function getTokenIdsLength() view public returns (uint256) {
return tokenIds.length;
}
function getTokenIdByIndex(uint256 _index) view public returns (uint256) {
return tokenIds[_index];
}
function setTokenIdByIndex(uint256 _index, uint256 _tokenId) public storageAccessControl {
tokenIds[_index] = _tokenId;
}
function pushTokenId(uint256 _tokenId) public storageAccessControl returns (uint256) {
tokenIds.push(_tokenId);
return tokenIds.length;
}
function decrementTokenIdsLength() public storageAccessControl {
tokenIds.length--;
}
function getTokenIdsIndex(uint256 _tokenId) view public returns (uint256) {
return tokenIdsIndex[_tokenId];
}
function setTokenIdsIndex(uint256 _tokenId, uint256 _tokenIdIndex) public storageAccessControl {
tokenIdsIndex[_tokenId] = _tokenIdIndex;
}
function BdpOwnershipStorage(bytes8 _version) public {
ownerAddress = msg.sender;
managerAddress = msg.sender;
version = _version;
}
}
library BdpOwnership {
using SafeMath for uint256;
event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
function ownerOf(address[16] _contracts, uint256 _tokenId) public view returns (address) {
var owner = BdpOwnershipStorage(BdpContracts.getBdpOwnershipStorage(_contracts)).getTokenOwner(_tokenId);
require(owner != address(0));
return owner;
}
function balanceOf(address[16] _contracts, address _owner) public view returns (uint256) {
return BdpOwnershipStorage(BdpContracts.getBdpOwnershipStorage(_contracts)).getOwnedTokensLength(_owner);
}
function approve(address[16] _contracts, address _to, uint256 _tokenId) public {
var ownStorage = BdpOwnershipStorage(BdpContracts.getBdpOwnershipStorage(_contracts));
address owner = ownerOf(_contracts, _tokenId);
require(_to != owner);
if (ownStorage.getTokenApproval(_tokenId) != 0 || _to != 0) {
ownStorage.setTokenApproval(_tokenId, _to);
Approval(owner, _to, _tokenId);
}
}
function clearApproval(address[16] _contracts, address _owner, uint256 _tokenId) public {
var ownStorage = BdpOwnershipStorage(BdpContracts.getBdpOwnershipStorage(_contracts));
require(ownerOf(_contracts, _tokenId) == _owner);
if (ownStorage.getTokenApproval(_tokenId) != 0) {
BdpOwnershipStorage(BdpContracts.getBdpOwnershipStorage(_contracts)).setTokenApproval(_tokenId, 0);
Approval(_owner, 0, _tokenId);
}
}
function clearApprovalAndTransfer(address[16] _contracts, address _from, address _to, uint256 _tokenId) public {
require(_to != address(0));
require(_to != ownerOf(_contracts, _tokenId));
require(ownerOf(_contracts, _tokenId) == _from);
clearApproval(_contracts, _from, _tokenId);
removeToken(_contracts, _from, _tokenId);
addToken(_contracts, _to, _tokenId);
Transfer(_from, _to, _tokenId);
}
function addToken(address[16] _contracts, address _to, uint256 _tokenId) private {
var ownStorage = BdpOwnershipStorage(BdpContracts.getBdpOwnershipStorage(_contracts));
require(ownStorage.getTokenOwner(_tokenId) == address(0));
ownStorage.setTokenOwner(_tokenId, _to);
var tokenIdsLength = ownStorage.pushTokenId(_tokenId);
ownStorage.setTokenIdsIndex(_tokenId, tokenIdsLength.sub(1));
uint256 ownedTokensLength = ownStorage.getOwnedTokensLength(_to);
ownStorage.pushOwnedToken(_to, _tokenId);
ownStorage.setOwnedTokensIndex(_tokenId, ownedTokensLength);
var (area,,) = BdpCalculator.calculateArea(_contracts, _tokenId);
ownStorage.incrementOwnedArea(_to, area);
}
function removeToken(address[16] _contracts, address _from, uint256 _tokenId) private {
var ownStorage = BdpOwnershipStorage(BdpContracts.getBdpOwnershipStorage(_contracts));
require(ownerOf(_contracts, _tokenId) == _from);
ownStorage.setTokenOwner(_tokenId, 0);
removeFromTokenIds(ownStorage, _tokenId);
removeFromOwnedToken(ownStorage, _from, _tokenId);
var (area,,) = BdpCalculator.calculateArea(_contracts, _tokenId);
ownStorage.decrementOwnedArea(_from, area);
}
function removeFromOwnedToken(BdpOwnershipStorage _ownStorage, address _from, uint256 _tokenId) private {
var ownedTokenIndex = _ownStorage.getOwnedTokensIndex(_tokenId);
var lastOwnedTokenIndex = _ownStorage.getOwnedTokensLength(_from).sub(1);
var lastOwnedToken = _ownStorage.getOwnedToken(_from, lastOwnedTokenIndex);
_ownStorage.setOwnedToken(_from, ownedTokenIndex, lastOwnedToken);
_ownStorage.setOwnedToken(_from, lastOwnedTokenIndex, 0);
_ownStorage.decrementOwnedTokensLength(_from);
_ownStorage.setOwnedTokensIndex(_tokenId, 0);
_ownStorage.setOwnedTokensIndex(lastOwnedToken, ownedTokenIndex);
}
function removeFromTokenIds(BdpOwnershipStorage _ownStorage, uint256 _tokenId) private {
var tokenIndex = _ownStorage.getTokenIdsIndex(_tokenId);
var lastTokenIdIndex = _ownStorage.getTokenIdsLength().sub(1);
var lastTokenId = _ownStorage.getTokenIdByIndex(lastTokenIdIndex);
_ownStorage.setTokenIdByIndex(tokenIndex, lastTokenId);
_ownStorage.setTokenIdByIndex(lastTokenIdIndex, 0);
_ownStorage.decrementTokenIdsLength();
_ownStorage.setTokenIdsIndex(_tokenId, 0);
_ownStorage.setTokenIdsIndex(lastTokenId, tokenIndex);
}
function mint(address[16] _contracts, address _to, uint256 _tokenId) public {
require(_to != address(0));
addToken(_contracts, _to, _tokenId);
Transfer(address(0), _to, _tokenId);
}
function burn(address[16] _contracts, uint256 _tokenId) public {
address owner = BdpOwnershipStorage(BdpContracts.getBdpOwnershipStorage(_contracts)).getTokenOwner(_tokenId);
clearApproval(_contracts, owner, _tokenId);
removeToken(_contracts, owner, _tokenId);
Transfer(owner, address(0), _tokenId);
}
}