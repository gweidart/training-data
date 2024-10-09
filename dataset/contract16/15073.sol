pragma solidity ^0.4.23;
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
contract Acceptable is Ownable {
address public sender;
modifier onlyAcceptable {
require(msg.sender == sender);
_;
}
function setAcceptable(address _sender) public onlyOwner {
sender = _sender;
}
}
contract ERC721Basic {
event Transfer(address indexed _from, address indexed _to, uint256 _tokenId);
event Approval(address indexed _owner, address indexed _approved, uint256 _tokenId);
event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);
function balanceOf(address _owner) public view returns (uint256 _balance);
function ownerOf(uint256 _tokenId) public view returns (address _owner);
function exists(uint256 _tokenId) public view returns (bool _exists);
function approve(address _to, uint256 _tokenId) public;
function getApproved(uint256 _tokenId) public view returns (address _operator);
function setApprovalForAll(address _operator, bool _approved) public;
function isApprovedForAll(address _owner, address _operator) public view returns (bool);
function transferFrom(address _from, address _to, uint256 _tokenId) public;
function safeTransferFrom(address _from, address _to, uint256 _tokenId) public;
function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes _data) public;
}
contract ERC721Enumerable is ERC721Basic {
function totalSupply() public view returns (uint256);
function tokenOfOwnerByIndex(address _owner, uint256 _index) public view returns (uint256 _tokenId);
function tokenByIndex(uint256 _index) public view returns (uint256);
}
contract ERC721Metadata is ERC721Basic {
function name() public view returns (string _name);
function symbol() public view returns (string _symbol);
function tokenURI(uint256 _tokenId) public view returns (string);
}
contract ERC721 is ERC721Basic, ERC721Enumerable, ERC721Metadata {
}
contract DeprecatedERC721 is ERC721 {
function takeOwnership(uint256 _tokenId) public;
function transfer(address _to, uint256 _tokenId) public;
function tokensOf(address _owner) public view returns (uint256[]);
}
library AddressUtils {
function isContract(address addr) internal view returns (bool) {
uint256 size;
assembly { size := extcodesize(addr) }
return size > 0;
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
contract ERC721Receiver {
bytes4 constant ERC721_RECEIVED = 0xf0b9e5ba;
function onERC721Received(address _from, uint256 _tokenId, bytes _data) public returns(bytes4);
}
contract ERC721BasicToken is ERC721Basic {
using SafeMath for uint256;
using AddressUtils for address;
bytes4 constant ERC721_RECEIVED = 0xf0b9e5ba;
mapping (uint256 => address) internal tokenOwner;
mapping (uint256 => address) internal tokenApprovals;
mapping (address => uint256) internal ownedTokensCount;
mapping (address => mapping (address => bool)) internal operatorApprovals;
modifier onlyOwnerOf(uint256 _tokenId) {
require(ownerOf(_tokenId) == msg.sender);
_;
}
modifier canTransfer(uint256 _tokenId) {
require(isApprovedOrOwner(msg.sender, _tokenId));
_;
}
function balanceOf(address _owner) public view returns (uint256) {
require(_owner != address(0));
return ownedTokensCount[_owner];
}
function ownerOf(uint256 _tokenId) public view returns (address) {
address owner = tokenOwner[_tokenId];
require(owner != address(0));
return owner;
}
function exists(uint256 _tokenId) public view returns (bool) {
address owner = tokenOwner[_tokenId];
return owner != address(0);
}
function approve(address _to, uint256 _tokenId) public {
address owner = ownerOf(_tokenId);
require(_to != owner);
require(msg.sender == owner || isApprovedForAll(owner, msg.sender));
if (getApproved(_tokenId) != address(0) || _to != address(0)) {
tokenApprovals[_tokenId] = _to;
Approval(owner, _to, _tokenId);
}
}
function getApproved(uint256 _tokenId) public view returns (address) {
return tokenApprovals[_tokenId];
}
function setApprovalForAll(address _to, bool _approved) public {
require(_to != msg.sender);
operatorApprovals[msg.sender][_to] = _approved;
ApprovalForAll(msg.sender, _to, _approved);
}
function isApprovedForAll(address _owner, address _operator) public view returns (bool) {
return operatorApprovals[_owner][_operator];
}
function transferFrom(address _from, address _to, uint256 _tokenId) public canTransfer(_tokenId) {
require(_from != address(0));
require(_to != address(0));
clearApproval(_from, _tokenId);
removeTokenFrom(_from, _tokenId);
addTokenTo(_to, _tokenId);
Transfer(_from, _to, _tokenId);
}
function safeTransferFrom(address _from, address _to, uint256 _tokenId) public canTransfer(_tokenId) {
safeTransferFrom(_from, _to, _tokenId, "");
}
function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes _data) public canTransfer(_tokenId) {
transferFrom(_from, _to, _tokenId);
require(checkAndCallSafeTransfer(_from, _to, _tokenId, _data));
}
function isApprovedOrOwner(address _spender, uint256 _tokenId) internal view returns (bool) {
address owner = ownerOf(_tokenId);
return _spender == owner || getApproved(_tokenId) == _spender || isApprovedForAll(owner, _spender);
}
function _mint(address _to, uint256 _tokenId) internal {
require(_to != address(0));
addTokenTo(_to, _tokenId);
Transfer(address(0), _to, _tokenId);
}
function _burn(address _owner, uint256 _tokenId) internal {
clearApproval(_owner, _tokenId);
removeTokenFrom(_owner, _tokenId);
Transfer(_owner, address(0), _tokenId);
}
function clearApproval(address _owner, uint256 _tokenId) internal {
require(ownerOf(_tokenId) == _owner);
if (tokenApprovals[_tokenId] != address(0)) {
tokenApprovals[_tokenId] = address(0);
Approval(_owner, address(0), _tokenId);
}
}
function addTokenTo(address _to, uint256 _tokenId) internal {
require(tokenOwner[_tokenId] == address(0));
tokenOwner[_tokenId] = _to;
ownedTokensCount[_to] = ownedTokensCount[_to].add(1);
}
function removeTokenFrom(address _from, uint256 _tokenId) internal {
require(ownerOf(_tokenId) == _from);
ownedTokensCount[_from] = ownedTokensCount[_from].sub(1);
tokenOwner[_tokenId] = address(0);
}
function checkAndCallSafeTransfer(address _from, address _to, uint256 _tokenId, bytes _data) internal returns (bool) {
if (!_to.isContract()) {
return true;
}
bytes4 retval = ERC721Receiver(_to).onERC721Received(_from, _tokenId, _data);
return (retval == ERC721_RECEIVED);
}
}
contract ERC721Token is ERC721, ERC721BasicToken {
string internal name_;
string internal symbol_;
mapping (address => uint256[]) internal ownedTokens;
mapping(uint256 => uint256) internal ownedTokensIndex;
uint256[] internal allTokens;
mapping(uint256 => uint256) internal allTokensIndex;
mapping(uint256 => string) internal tokenURIs;
function ERC721Token(string _name, string _symbol) public {
name_ = _name;
symbol_ = _symbol;
}
function name() public view returns (string) {
return name_;
}
function symbol() public view returns (string) {
return symbol_;
}
function tokenURI(uint256 _tokenId) public view returns (string) {
require(exists(_tokenId));
return tokenURIs[_tokenId];
}
function _setTokenURI(uint256 _tokenId, string _uri) internal {
require(exists(_tokenId));
tokenURIs[_tokenId] = _uri;
}
function tokenOfOwnerByIndex(address _owner, uint256 _index) public view returns (uint256) {
require(_index < balanceOf(_owner));
return ownedTokens[_owner][_index];
}
function totalSupply() public view returns (uint256) {
return allTokens.length;
}
function tokenByIndex(uint256 _index) public view returns (uint256) {
require(_index < totalSupply());
return allTokens[_index];
}
function addTokenTo(address _to, uint256 _tokenId) internal {
super.addTokenTo(_to, _tokenId);
uint256 length = ownedTokens[_to].length;
ownedTokens[_to].push(_tokenId);
ownedTokensIndex[_tokenId] = length;
}
function removeTokenFrom(address _from, uint256 _tokenId) internal {
super.removeTokenFrom(_from, _tokenId);
uint256 tokenIndex = ownedTokensIndex[_tokenId];
uint256 lastTokenIndex = ownedTokens[_from].length.sub(1);
uint256 lastToken = ownedTokens[_from][lastTokenIndex];
ownedTokens[_from][tokenIndex] = lastToken;
ownedTokens[_from][lastTokenIndex] = 0;
ownedTokens[_from].length--;
ownedTokensIndex[_tokenId] = 0;
ownedTokensIndex[lastToken] = tokenIndex;
}
function _mint(address _to, uint256 _tokenId) internal {
super._mint(_to, _tokenId);
allTokensIndex[_tokenId] = allTokens.length;
allTokens.push(_tokenId);
}
function _burn(address _owner, uint256 _tokenId) internal {
super._burn(_owner, _tokenId);
if (bytes(tokenURIs[_tokenId]).length != 0) {
delete tokenURIs[_tokenId];
}
uint256 tokenIndex = allTokensIndex[_tokenId];
uint256 lastTokenIndex = allTokens.length.sub(1);
uint256 lastToken = allTokens[lastTokenIndex];
allTokens[tokenIndex] = lastToken;
allTokens[lastTokenIndex] = 0;
allTokens.length--;
allTokensIndex[_tokenId] = 0;
allTokensIndex[lastToken] = tokenIndex;
}
}
contract CrystalBase is Acceptable, ERC721Token {
struct Crystal {
uint256 tokenId;
uint256 gene;
uint8 kind;
uint128 weight;
uint64 mintedAt;
}
mapping(uint256 => Crystal) internal tokenIdToCrystal;
event CrystalBurned(address indexed owner, uint256 tokenId);
event CrystalMinted(address indexed owner, uint256 tokenId, uint256 gene, uint256 kind, uint256 weight);
uint256 currentTokenId = 1;
constructor() ERC721Token("CryptoCrystal", "CC") public {
}
function mint(
address _owner,
uint256 _gene,
uint256 _kind,
uint256 _weight
) public onlyAcceptable returns(uint256) {
require(_gene > 0);
require(_weight > 0);
uint256 _tokenId = currentTokenId;
currentTokenId++;
super._mint(_owner, _tokenId);
Crystal memory _crystal = Crystal({
tokenId: _tokenId,
gene: _gene,
kind: uint8(_kind),
weight: uint128(_weight),
mintedAt: uint64(now)
});
tokenIdToCrystal[_tokenId] = _crystal;
emit CrystalMinted(_owner, _tokenId, _gene, _kind, _weight);
return _tokenId;
}
function burn(address _owner, uint256 _tokenId) public onlyAcceptable {
require(ownerOf(_tokenId) == _owner);
delete tokenIdToCrystal[_tokenId];
super._burn(_owner, _tokenId);
emit CrystalBurned(_owner, _tokenId);
}
function _transferFrom(address _from, address _to, uint256 _tokenId) public onlyAcceptable {
require(ownerOf(_tokenId) == _from);
require(_to != address(0));
clearApproval(_from, _tokenId);
removeTokenFrom(_from, _tokenId);
addTokenTo(_to, _tokenId);
emit Transfer(_from, _to, _tokenId);
}
function getCrystalKindWeight(uint256 _tokenId) public onlyAcceptable view returns(
uint256 kind,
uint256 weight
) {
require(exists(_tokenId));
Crystal memory _crystal = tokenIdToCrystal[_tokenId];
kind = _crystal.kind;
weight = _crystal.weight;
}
function getCrystalGeneKindWeight(uint256 _tokenId) public onlyAcceptable view returns(
uint256 gene,
uint256 kind,
uint256 weight
) {
require(exists(_tokenId));
Crystal memory _crystal = tokenIdToCrystal[_tokenId];
gene = _crystal.gene;
kind = _crystal.kind;
weight = _crystal.weight;
}
function getCrystal(uint256 _tokenId) external view returns(
address owner,
uint256 gene,
uint256 kind,
uint256 weight,
uint256 mintedAt
) {
require(exists(_tokenId));
Crystal memory _crystal = tokenIdToCrystal[_tokenId];
owner = ownerOf(_tokenId);
gene = _crystal.gene;
kind = _crystal.kind;
weight = _crystal.weight;
mintedAt = _crystal.mintedAt;
}
function getCrystalsSummary(address _owner) external view returns(
uint256[] amounts,
uint256[] weights
) {
amounts = new uint256[](100);
weights = new uint256[](100);
uint256 _tokenCount = ownedTokensCount[_owner];
for (uint256 i = 0; i < _tokenCount; i++) {
uint256 _tokenId = ownedTokens[_owner][i];
Crystal memory _crystal = tokenIdToCrystal[_tokenId];
amounts[_crystal.kind] = amounts[_crystal.kind].add(1);
weights[_crystal.kind] = weights[_crystal.kind].add(_crystal.weight);
}
}
function getCrystals(address _owner) external view returns(
uint256[] tokenIds,
uint256[] genes,
uint256[] kinds,
uint256[] weights,
uint256[] mintedAts
) {
uint256 _tokenCount = ownedTokensCount[_owner];
tokenIds = new uint256[](_tokenCount);
genes = new uint256[](_tokenCount);
kinds = new uint256[](_tokenCount);
weights = new uint256[](_tokenCount);
mintedAts = new uint256[](_tokenCount);
for (uint256 i = 0; i < _tokenCount; i++) {
uint256 _tokenId = ownedTokens[_owner][i];
Crystal memory _crystal = tokenIdToCrystal[_tokenId];
tokenIds[i] = _tokenId;
genes[i] = _crystal.gene;
kinds[i] = _crystal.kind;
weights[i] = _crystal.weight;
mintedAts[i] = _crystal.mintedAt;
}
}
function getCrystalsByKind(address _owner, uint256 _kind) external view returns(
uint256[] tokenIds,
uint256[] genes,
uint256[] weights,
uint256[] mintedAts
) {
require(_kind < 100);
uint256 _tokenCount = ownedTokensCount[_owner];
tokenIds = new uint256[](_tokenCount);
genes = new uint256[](_tokenCount);
weights = new uint256[](_tokenCount);
mintedAts = new uint256[](_tokenCount);
uint256 index;
for (uint256 i = 0; i < _tokenCount; i++) {
uint256 _tokenId = ownedTokens[_owner][i];
Crystal memory _crystal = tokenIdToCrystal[_tokenId];
if (_crystal.kind == _kind) {
tokenIds[index] = _tokenId;
genes[index] = _crystal.gene;
weights[index] = _crystal.weight;
mintedAts[i] = _crystal.mintedAt;
index = index.add(1);
}
}
}
}