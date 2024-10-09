pragma solidity ^0.4.18;
contract ERC721 {
event Transfer(address indexed _from, address indexed _to, uint256 _tokenId);
event Approval(address indexed _owner, address indexed _approved, uint256 _tokenId);
function balanceOf(address _owner) public view returns (uint256 _balance);
function ownerOf(uint256 _tokenId) public view returns (address _owner);
function transfer(address _to, uint256 _tokenId) public;
function approve(address _to, uint256 _tokenId) public;
function takeOwnership(uint256 _tokenId) public;
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
contract ERC721Token is ERC721 {
using SafeMath for uint256;
uint256 internal totalTokens;
mapping (uint256 => address) private tokenOwner;
mapping (uint256 => address) private tokenApprovals;
mapping (address => uint256[]) private ownedTokens;
mapping(uint256 => uint256) private ownedTokensIndex;
modifier onlyOwnerOf(uint256 _tokenId) {
require(ownerOf(_tokenId) == msg.sender);
_;
}
function totalSupply() public view returns (uint256) {
return totalTokens;
}
function balanceOf(address _owner) public view returns (uint256) {
return ownedTokens[_owner].length;
}
function tokensOf(address _owner) public view returns (uint256[]) {
return ownedTokens[_owner];
}
function ownerOf(uint256 _tokenId) public view returns (address) {
address owner = tokenOwner[_tokenId];
require(owner != address(0));
return owner;
}
function approvedFor(uint256 _tokenId) public view returns (address) {
return tokenApprovals[_tokenId];
}
function transfer(address _to, uint256 _tokenId) public onlyOwnerOf(_tokenId) {
clearApprovalAndTransfer(msg.sender, _to, _tokenId);
}
function approve(address _to, uint256 _tokenId) public onlyOwnerOf(_tokenId) {
address owner = ownerOf(_tokenId);
require(_to != owner);
if (approvedFor(_tokenId) != 0 || _to != 0) {
tokenApprovals[_tokenId] = _to;
Approval(owner, _to, _tokenId);
}
}
function takeOwnership(uint256 _tokenId) public {
require(isApprovedFor(msg.sender, _tokenId));
clearApprovalAndTransfer(ownerOf(_tokenId), msg.sender, _tokenId);
}
function _mint(address _to, uint256 _tokenId) internal {
require(_to != address(0));
addToken(_to, _tokenId);
Transfer(0x0, _to, _tokenId);
}
function _burn(uint256 _tokenId) onlyOwnerOf(_tokenId) internal {
if (approvedFor(_tokenId) != 0) {
clearApproval(msg.sender, _tokenId);
}
removeToken(msg.sender, _tokenId);
Transfer(msg.sender, 0x0, _tokenId);
}
function isApprovedFor(address _owner, uint256 _tokenId) internal view returns (bool) {
return approvedFor(_tokenId) == _owner;
}
function clearApprovalAndTransfer(address _from, address _to, uint256 _tokenId) internal {
require(_to != address(0));
require(_to != ownerOf(_tokenId));
require(ownerOf(_tokenId) == _from);
clearApproval(_from, _tokenId);
removeToken(_from, _tokenId);
addToken(_to, _tokenId);
Transfer(_from, _to, _tokenId);
}
function clearApproval(address _owner, uint256 _tokenId) private {
require(ownerOf(_tokenId) == _owner);
tokenApprovals[_tokenId] = 0;
Approval(_owner, 0, _tokenId);
}
function addToken(address _to, uint256 _tokenId) private {
require(tokenOwner[_tokenId] == address(0));
tokenOwner[_tokenId] = _to;
uint256 length = balanceOf(_to);
ownedTokens[_to].push(_tokenId);
ownedTokensIndex[_tokenId] = length;
totalTokens = totalTokens.add(1);
}
function removeToken(address _from, uint256 _tokenId) private {
require(ownerOf(_tokenId) == _from);
uint256 tokenIndex = ownedTokensIndex[_tokenId];
uint256 lastTokenIndex = balanceOf(_from).sub(1);
uint256 lastToken = ownedTokens[_from][lastTokenIndex];
tokenOwner[_tokenId] = 0;
ownedTokens[_from][tokenIndex] = lastToken;
ownedTokens[_from][lastTokenIndex] = 0;
ownedTokens[_from].length--;
ownedTokensIndex[_tokenId] = 0;
ownedTokensIndex[lastToken] = tokenIndex;
totalTokens = totalTokens.sub(1);
}
}
contract Ownable {
modifier onlyOwner() {
checkOwner();
_;
}
function checkOwner() internal;
}
contract OwnableImpl is Ownable {
address public owner;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
function OwnableImpl() public {
owner = msg.sender;
}
function checkOwner() internal {
require(msg.sender == owner);
}
function transferOwnership(address newOwner) onlyOwner public {
require(newOwner != address(0));
OwnershipTransferred(owner, newOwner);
owner = newOwner;
}
}
contract DragonToken is OwnableImpl, ERC721Token {
uint256 public price;
uint256 public cap;
string public name;
string public symbol;
function DragonToken(uint256 _price, uint256 _cap, string _name, string _symbol) public {
price = _price;
cap = _cap;
name = _name;
symbol = _symbol;
}
function () payable public {
require(totalTokens < cap);
require(msg.value >= price);
_mint(msg.sender, totalTokens + 1);
if (msg.value > price) {
msg.sender.transfer(msg.value - price);
}
}
function withdraw(address beneficiary, uint256 amount) onlyOwner public {
beneficiary.transfer(amount);
}
}