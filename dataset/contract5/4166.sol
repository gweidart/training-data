pragma solidity 0.4.24;
contract ERC20Basic {
function totalSupply() public view returns (uint256);
function balanceOf(address who) public view returns (uint256);
function transfer(address to, uint256 value) public returns (bool);
event Transfer(address indexed from, address indexed to, uint256 value);
}
contract ERC20 is ERC20Basic {
function allowance(address owner, address spender) public view returns (uint256);
function transferFrom(address from, address to, uint256 value) public returns (bool);
function approve(address spender, uint256 value) public returns (bool);
event Approval(address indexed owner, address indexed spender, uint256 value);
}
contract ERC721Basic {
bytes4 constant INTERFACE_ERC721 = 0x80ac58cd;
event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);
event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);
event ApprovalForAll(address indexed _owner, address indexed _operator, bool indexed _approved);
function balanceOf(address _owner) public view returns (uint256 _balance);
function ownerOf(uint256 _tokenId) public view returns (address _owner);
function exists(uint256 _tokenId) public view returns (bool _exists);
function approve(address _to, uint256 _tokenId) public;
function getApproved(uint256 _tokenId) public view returns (address _operator);
function setApprovalForAll(address _operator, bool _approved) public;
function isApprovedForAll(address _owner, address _operator) public view returns (bool);
function transferFrom(
address _from,
address _to,
uint256 _tokenId) public;
function safeTransferFrom(
address _from,
address _to,
uint256 _tokenId) public;
function safeTransferFrom(
address _from,
address _to,
uint256 _tokenId,
bytes _data) public;
}
contract ERC721Enumerable is ERC721Basic {
bytes4 constant INTERFACE_ERC721_ENUMERABLE = 0x780e9d63;
function totalSupply() public view returns (uint256);
function tokenOfOwnerByIndex(address _owner, uint256 _index) public view returns (uint256 _tokenId);
function tokenByIndex(uint256 _index) public view returns (uint256);
}
contract ERC721Metadata is ERC721Basic {
bytes4 constant INTERFACE_ERC721_METADATA = 0x5b5e139f;
function name() public view returns (string _name);
function symbol() public view returns (string _symbol);
function tokenURI(uint256 _tokenId) public view returns (string);
}
contract ERC721 is ERC721Basic, ERC721Enumerable, ERC721Metadata {
}
contract ERC165 {
bytes4 constant INTERFACE_ERC165 = 0x01ffc9a7;
function supportsInterface(bytes4 _interfaceID) public pure returns (bool) {
return _interfaceID == INTERFACE_ERC165;
}
}
library AddressUtils {
function isContract(address addr) internal view returns (bool) {
uint256 size;
assembly { size := extcodesize(addr) }
return size > 0;
}
}
library SafeMath {
function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
if (a == 0) {
return 0;
}
c = a * b;
assert(c / a == b);
return c;
}
function div(uint256 a, uint256 b) internal pure returns (uint256) {
return a / b;
}
function sub(uint256 a, uint256 b) internal pure returns (uint256) {
assert(b <= a);
return a - b;
}
function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
c = a + b;
assert(c >= a);
return c;
}
}
contract ERC721Receiver {
bytes4 constant ERC721_RECEIVED = 0x150b7a02;
function onERC721Received(
address _operator,
address _from,
uint256 _tokenId,
bytes _data)
public
returns(bytes4);
}
contract ERC721BasicToken is ERC721Basic, ERC165 {
using SafeMath for uint256;
using AddressUtils for address;
bytes4 constant ERC721_RECEIVED = 0x150b7a02;
mapping (uint256 => address) internal tokenOwner;
mapping (uint256 => address) internal tokenApprovals;
mapping (address => uint256) internal ownedTokensCount;
mapping (address => mapping (address => bool)) internal operatorApprovals;
modifier onlyOwnerOf(uint256 _tokenId) {
require(ownerOf(_tokenId) == msg.sender);
_;
}
function supportsInterface(bytes4 _interfaceID) public pure returns (bool) {
return super.supportsInterface(_interfaceID) || _interfaceID == INTERFACE_ERC721;
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
emit Approval(owner, _to, _tokenId);
}
}
function getApproved(uint256 _tokenId) public view returns (address) {
return tokenApprovals[_tokenId];
}
function setApprovalForAll(address _to, bool _approved) public {
require(_to != msg.sender);
operatorApprovals[msg.sender][_to] = _approved;
emit ApprovalForAll(msg.sender, _to, _approved);
}
function isApprovedForAll(address _owner, address _operator) public view returns (bool) {
return operatorApprovals[_owner][_operator];
}
function transferFrom(
address _from,
address _to,
uint256 _tokenId
)
public
{
internalTransferFrom(
_from,
_to,
_tokenId);
}
function safeTransferFrom(
address _from,
address _to,
uint256 _tokenId
)
public
{
internalSafeTransferFrom(
_from,
_to,
_tokenId,
"");
}
function safeTransferFrom(
address _from,
address _to,
uint256 _tokenId,
bytes _data
)
public
{
internalSafeTransferFrom(
_from,
_to,
_tokenId,
_data);
}
function internalTransferFrom(
address _from,
address _to,
uint256 _tokenId
)
internal
{
address owner = ownerOf(_tokenId);
require(_from == owner);
require(_to != address(0));
address sender = msg.sender;
require(
sender == owner || isApprovedForAll(owner, sender) || getApproved(_tokenId) == sender,
"Not authorized to transfer"
);
if (tokenApprovals[_tokenId] != address(0)) {
tokenApprovals[_tokenId] = address(0);
}
tokenOwner[_tokenId] = _to;
ownedTokensCount[_from] = ownedTokensCount[_from].sub(1);
ownedTokensCount[_to] = ownedTokensCount[_to].add(1);
emit Transfer(_from, _to, _tokenId);
}
function internalSafeTransferFrom(
address _from,
address _to,
uint256 _tokenId,
bytes _data
)
internal
{
internalTransferFrom(_from, _to, _tokenId);
require(
checkAndCallSafeTransfer(
_from,
_to,
_tokenId,
_data)
);
}
function checkAndCallSafeTransfer(
address _from,
address _to,
uint256 _tokenId,
bytes _data
)
internal
returns (bool)
{
if (!_to.isContract()) {
return true;
}
bytes4 retval = ERC721Receiver(_to)
.onERC721Received(
msg.sender,
_from,
_tokenId,
_data
);
return (retval == ERC721_RECEIVED);
}
}
contract ERC721Token is ERC721, ERC721BasicToken {
string internal name_;
string internal symbol_;
mapping (address => uint256[]) internal ownedTokens;
mapping(uint256 => uint256) internal ownedTokensIndex;
uint256[] internal allTokens;
mapping(uint256 => string) internal tokenURIs;
constructor(string _name, string _symbol) public {
name_ = _name;
symbol_ = _symbol;
}
function supportsInterface(bytes4 _interfaceID) public pure returns (bool) {
return super.supportsInterface(_interfaceID) || _interfaceID == INTERFACE_ERC721_ENUMERABLE || _interfaceID == INTERFACE_ERC721_METADATA;
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
function internalTransferFrom(
address _from,
address _to,
uint256 _tokenId
)
internal
{
super.internalTransferFrom(_from, _to, _tokenId);
uint256 removeTokenIndex = ownedTokensIndex[_tokenId];
uint256 lastTokenIndex = ownedTokens[_from].length.sub(1);
uint256 lastToken = ownedTokens[_from][lastTokenIndex];
ownedTokens[_from][removeTokenIndex] = lastToken;
ownedTokens[_from].length--;
ownedTokensIndex[lastToken] = removeTokenIndex;
ownedTokens[_to].push(_tokenId);
ownedTokensIndex[_tokenId] = ownedTokens[_to].length - 1;
}
function _setTokenURI(uint256 _tokenId, string _uri) internal {
require(exists(_tokenId));
tokenURIs[_tokenId] = _uri;
}
}
contract CodexRecordMetadata is ERC721Token {
struct CodexRecordData {
bytes32 nameHash;
bytes32 descriptionHash;
bytes32[] fileHashes;
}
event Modified(
address indexed _from,
uint256 _tokenId,
bytes32 _newNameHash,
bytes32 _newDescriptionHash,
bytes32[] _newFileHashes,
bytes _data
);
mapping(uint256 => CodexRecordData) internal tokenData;
string public tokenURIPrefix;
function modifyMetadataHashes(
uint256 _tokenId,
bytes32 _newNameHash,
bytes32 _newDescriptionHash,
bytes32[] _newFileHashes,
bytes _data
)
public
onlyOwnerOf(_tokenId)
{
if (!bytes32IsEmpty(_newNameHash)) {
tokenData[_tokenId].nameHash = _newNameHash;
}
tokenData[_tokenId].descriptionHash = _newDescriptionHash;
bool containsNullHash = false;
for (uint i = 0; i < _newFileHashes.length; i++) {
if (bytes32IsEmpty(_newFileHashes[i])) {
containsNullHash = true;
break;
}
}
if (_newFileHashes.length > 0 && !containsNullHash) {
tokenData[_tokenId].fileHashes = _newFileHashes;
}
emit Modified(
msg.sender,
_tokenId,
tokenData[_tokenId].nameHash,
tokenData[_tokenId].descriptionHash,
tokenData[_tokenId].fileHashes,
_data
);
}
function getTokenById(
uint256 _tokenId
)
public
view
returns (bytes32 nameHash, bytes32 descriptionHash, bytes32[] fileHashes)
{
return (
tokenData[_tokenId].nameHash,
tokenData[_tokenId].descriptionHash,
tokenData[_tokenId].fileHashes
);
}
function tokenURI(
uint256 _tokenId
)
public
view
returns (string)
{
bytes memory prefix = bytes(tokenURIPrefix);
if (prefix.length == 0) {
return "";
}
bytes memory tokenId = uint2bytes(_tokenId);
bytes memory output = new bytes(prefix.length + tokenId.length);
uint256 i;
uint256 outputIndex = 0;
for (i = 0; i < prefix.length; i++) {
output[outputIndex++] = prefix[i];
}
for (i = 0; i < tokenId.length; i++) {
output[outputIndex++] = tokenId[i];
}
return string(output);
}
function uint2bytes(uint256 i) internal pure returns (bytes) {
if (i == 0) {
return "0";
}
uint256 j = i;
uint256 length;
while (j != 0) {
length++;
j /= 10;
}
bytes memory bstr = new bytes(length);
uint256 k = length - 1;
j = i;
while (j != 0) {
bstr[k--] = byte(48 + j % 10);
j /= 10;
}
return bstr;
}
function bytes32IsEmpty(bytes32 _data) internal pure returns (bool) {
for (uint256 i = 0; i < 32; i++) {
if (_data[i] != 0x0) {
return false;
}
}
return true;
}
}
contract ERC900 {
event Staked(address indexed user, uint256 amount, uint256 total, bytes data);
event Unstaked(address indexed user, uint256 amount, uint256 total, bytes data);
function stake(uint256 amount, bytes data) public;
function stakeFor(address user, uint256 amount, bytes data) public;
function unstake(uint256 amount, bytes data) public;
function totalStakedFor(address addr) public view returns (uint256);
function totalStaked() public view returns (uint256);
function token() public view returns (address);
function supportsHistory() public pure returns (bool);
}
contract CodexStakeContractInterface is ERC900 {
function stakeForDuration(
address user,
uint256 amount,
uint256 lockInDuration,
bytes data)
public;
function spendCredits(
address user,
uint256 amount)
public;
function creditBalanceOf(
address user)
public
view
returns (uint256);
}
contract DelayedOwnable {
address public owner;
bool public isInitialized = false;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
modifier onlyOwner() {
require(msg.sender == owner);
_;
}
function initializeOwnable(address _owner) external {
require(
!isInitialized,
"The owner has already been set");
isInitialized = true;
owner = _owner;
}
function transferOwnership(address _newOwner) public onlyOwner {
require(_newOwner != address(0));
emit OwnershipTransferred(owner, _newOwner);
owner = _newOwner;
}
}
contract DelayedPausable is DelayedOwnable {
event Pause();
event Unpause();
bool public paused = false;
modifier whenNotPaused() {
require(!paused);
_;
}
modifier whenPaused() {
require(paused);
_;
}
function pause() onlyOwner whenNotPaused public {
paused = true;
emit Pause();
}
function unpause() onlyOwner whenPaused public {
paused = false;
emit Unpause();
}
}
contract CodexRecordFees is CodexRecordMetadata, DelayedPausable {
ERC20 public codexCoin;
CodexStakeContractInterface public codexStakeContract;
address public feeRecipient;
uint256 public creationFee = 0;
uint256 public transferFee = 0;
uint256 public modificationFee = 0;
modifier canPayFees(uint256 _baseFee) {
if (feeRecipient != address(0) && _baseFee > 0) {
bool feePaid = false;
if (codexStakeContract != address(0)) {
uint256 discountCredits = codexStakeContract.creditBalanceOf(msg.sender);
if (discountCredits > 0) {
codexStakeContract.spendCredits(msg.sender, 1);
feePaid = true;
}
}
if (!feePaid) {
require(
codexCoin.transferFrom(msg.sender, feeRecipient, _baseFee),
"Insufficient funds");
}
}
_;
}
function setFees(
ERC20 _codexCoin,
address _feeRecipient,
uint256 _creationFee,
uint256 _transferFee,
uint256 _modificationFee
)
external
onlyOwner
{
codexCoin = _codexCoin;
feeRecipient = _feeRecipient;
creationFee = _creationFee;
transferFee = _transferFee;
modificationFee = _modificationFee;
}
function setStakeContract(CodexStakeContractInterface _codexStakeContract) external onlyOwner {
codexStakeContract = _codexStakeContract;
}
}
contract CodexRecordCore is CodexRecordFees {
event Minted(uint256 _tokenId, bytes _data);
function setTokenURIPrefix(string _tokenURIPrefix) external onlyOwner {
tokenURIPrefix = _tokenURIPrefix;
}
function mint(
address _to,
bytes32 _nameHash,
bytes32 _descriptionHash,
bytes32[] _fileHashes,
bytes _data
)
public
{
uint256 newTokenId = allTokens.length;
internalMint(_to, newTokenId);
tokenData[newTokenId] = CodexRecordData({
nameHash: _nameHash,
descriptionHash: _descriptionHash,
fileHashes: _fileHashes
});
emit Minted(newTokenId, _data);
}
function internalMint(address _to, uint256 _tokenId) internal {
require(_to != address(0));
tokenOwner[_tokenId] = _to;
ownedTokensCount[_to] = ownedTokensCount[_to].add(1);
ownedTokensIndex[_tokenId] = ownedTokens[_to].length;
ownedTokens[_to].push(_tokenId);
allTokens.push(_tokenId);
emit Transfer(address(0), _to, _tokenId);
}
}
contract CodexRecordAccess is CodexRecordCore {
function mint(
address _to,
bytes32 _nameHash,
bytes32 _descriptionHash,
bytes32[] _fileHashes,
bytes _data
)
public
whenNotPaused
canPayFees(creationFee)
{
return super.mint(
_to,
_nameHash,
_descriptionHash,
_fileHashes,
_data);
}
function transferFrom(
address _from,
address _to,
uint256 _tokenId
)
public
whenNotPaused
canPayFees(transferFee)
{
return super.transferFrom(
_from,
_to,
_tokenId);
}
function safeTransferFrom(
address _from,
address _to,
uint256 _tokenId
)
public
whenNotPaused
canPayFees(transferFee)
{
return super.safeTransferFrom(
_from,
_to,
_tokenId);
}
function safeTransferFrom(
address _from,
address _to,
uint256 _tokenId,
bytes _data
)
public
whenNotPaused
canPayFees(transferFee)
{
return super.safeTransferFrom(
_from,
_to,
_tokenId,
_data
);
}
function modifyMetadataHashes(
uint256 _tokenId,
bytes32 _newNameHash,
bytes32 _newDescriptionHash,
bytes32[] _newFileHashes,
bytes _data
)
public
whenNotPaused
canPayFees(modificationFee)
{
return super.modifyMetadataHashes(
_tokenId,
_newNameHash,
_newDescriptionHash,
_newFileHashes,
_data);
}
}
contract CodexRecord is CodexRecordAccess {
constructor() public ERC721Token("Codex Record", "CR") { }
function reclaimToken(ERC20Basic token) external onlyOwner {
uint256 balance = token.balanceOf(this);
token.transfer(owner, balance);
}
}