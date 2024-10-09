pragma solidity ^0.4.18;
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
contract Claimable is Ownable {
address public pendingOwner;
modifier onlyPendingOwner() {
require(msg.sender == pendingOwner);
_;
}
function transferOwnership(address newOwner) onlyOwner public {
pendingOwner = newOwner;
}
function claimOwnership() onlyPendingOwner public {
OwnershipTransferred(owner, pendingOwner);
owner = pendingOwner;
pendingOwner = address(0);
}
}
contract Pausable is Ownable {
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
Pause();
}
function unpause() onlyOwner whenPaused public {
paused = false;
Unpause();
}
}
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
library SafeERC20 {
function safeTransfer(ERC20Basic token, address to, uint256 value) internal {
assert(token.transfer(to, value));
}
function safeTransferFrom(ERC20 token, address from, address to, uint256 value) internal {
assert(token.transferFrom(from, to, value));
}
function safeApprove(ERC20 token, address spender, uint256 value) internal {
assert(token.approve(spender, value));
}
}
contract CanReclaimToken is Ownable {
using SafeERC20 for ERC20Basic;
function reclaimToken(ERC20Basic token) external onlyOwner {
uint256 balance = token.balanceOf(this);
token.safeTransfer(owner, balance);
}
}
contract MetaGameAccessControl is Claimable, Pausable, CanReclaimToken {
address public cfoAddress;
function MetaGameAccessControl() public {
cfoAddress = msg.sender;
}
modifier onlyCFO() {
require(msg.sender == cfoAddress);
_;
}
function setCFO(address _newCFO) external onlyOwner {
require(_newCFO != address(0));
cfoAddress = _newCFO;
}
}
contract MetaGameBase is MetaGameAccessControl {
using SafeMath for uint256;
mapping (uint256 => address) identifierToOwner;
mapping (uint256 => address) identifierToApproved;
mapping (address => uint256) ownershipDeedCount;
mapping (uint256 => uint256) identifierToParentIdentifier;
uint256[] public identifiers;
function getAllIdentifiers() external view returns(uint256[]) {
return identifiers;
}
function parentOf(uint256 identifier) external view returns (uint256 parentIdentifier) {
parentIdentifier = identifierToParentIdentifier[identifier];
}
}
interface ERC721 {
function supportsInterface(bytes4 _interfaceID) external pure returns (bool);
function ownerOf(uint256 _deedId) external view returns (address _owner);
function countOfDeeds() public view returns (uint256 _count);
function countOfDeedsByOwner(address _owner) public view returns (uint256 _count);
function deedOfOwnerByIndex(address _owner, uint256 _index) external view returns (uint256 _deedId);
event Transfer(address indexed from, address indexed to, uint256 indexed deedId);
event Approval(address indexed owner, address indexed approved, uint256 indexed deedId);
function approve(address _to, uint256 _deedId) external;
function takeOwnership(uint256 _deedId) external;
function transfer(address _to, uint256 _deedId) external;
}
interface ERC721Metadata {
function name() public pure returns (string _deedName);
function symbol() public pure returns (string _deedSymbol);
contract PullPayment {
using SafeMath for uint256;
mapping(address => uint256) public payments;
uint256 public totalPayments;
function withdrawPayments() public {
address payee = msg.sender;
uint256 payment = payments[payee];
require(payment != 0);
require(this.balance >= payment);
totalPayments = totalPayments.sub(payment);
payments[payee] = 0;
assert(payee.send(payment));
}
function asyncSend(address dest, uint256 amount) internal {
payments[dest] = payments[dest].add(amount);
totalPayments = totalPayments.add(amount);
}
}
contract MetaGameFinance is MetaGameDeed, PullPayment {
uint256 public dividendPercentage = 1000;
uint256 public minimumFee = 2500;
uint256 public minimumFeePlusDividends = 7000;
mapping (uint256 => uint256) public identifierToPrice;
uint256 public directPaymentThreshold = 0 ether;
bool public allowChangePrice = false;
uint256 public maxDividendDepth = 6;
event Price(uint256 indexed identifier, uint256 price, uint256 nextPrice);
event Buy(address indexed oldOwner, address indexed newOwner, uint256 indexed identifier, uint256 price, uint256 ownerWinnings);
event DividendPaid(address indexed beneficiary, uint256 indexed identifierBought, uint256 indexed identifier, uint256 dividend);
function setDirectPaymentThreshold(uint256 threshold) external onlyCFO {
directPaymentThreshold = threshold;
}
function setAllowChangePrice(bool _allowChangePrice) external onlyCFO {
allowChangePrice = _allowChangePrice;
}
function setMaxDividendDepth(uint256 _maxDividendDepth) external onlyCFO {
maxDividendDepth = _maxDividendDepth;
}
function nextPrice(uint256 currentPrice) public pure returns(uint256) {
if (currentPrice < 1 ether) {
return currentPrice.mul(200).div(100);
} else if (currentPrice < 5 ether) {
return currentPrice.mul(150).div(100);
} else {
return currentPrice.mul(135).div(100);
}
}
function changeDeedPrice(uint256 identifier, uint256 newPrice) public {
require(identifierToOwner[identifier] == msg.sender);
require(allowChangePrice);
require(newPrice < identifierToPrice[identifier]);
identifierToPrice[identifier] = newPrice;
Price(identifier, newPrice, nextPrice(newPrice));
}
function changeInitialPrice(uint256 identifier, uint256 newPrice) public onlyCFO {
require(identifierToOwner[identifier] == address(this));
identifierToPrice[identifier] = newPrice;
Price(identifier, newPrice, nextPrice(newPrice));
}
function _payDividends(uint256 identifierBought, uint256 identifier, uint256 dividend, uint256 depth)
internal
returns(uint256 totalDividendsPaid)
{
uint256 parentIdentifier = identifierToParentIdentifier[identifier];
if (parentIdentifier != 0 && depth < maxDividendDepth) {
address parentOwner = identifierToOwner[parentIdentifier];
if (parentOwner != address(this)) {
_sendFunds(parentOwner, dividend);
DividendPaid(parentOwner, identifierBought, parentIdentifier, dividend);
}
totalDividendsPaid = dividend;
uint256 dividendsPaid = _payDividends(identifierBought, parentIdentifier, dividend, depth + 1);
totalDividendsPaid = totalDividendsPaid.add(dividendsPaid);
} else {
totalDividendsPaid = 0;
}
}
function calculateFee(uint256 price, uint256 dividendsPaid) public view returns(uint256 fee) {
fee = price.mul(minimumFee).div(100000);
uint256 _minimumFeePlusDividends = price.mul(minimumFeePlusDividends).div(100000);
if (_minimumFeePlusDividends > dividendsPaid) {
uint256 feeMinusDividends = _minimumFeePlusDividends.sub(dividendsPaid);
if (feeMinusDividends > fee) {
fee = feeMinusDividends;
}
}
}
function _sendFunds(address beneficiary, uint256 amount) internal {
if (amount < directPaymentThreshold) {
asyncSend(beneficiary, amount);
} else if (!beneficiary.send(amount)) {
asyncSend(beneficiary, amount);
}
}
function withdrawFreeBalance() external onlyCFO {
uint256 freeBalance = this.balance - totalPayments;
cfoAddress.transfer(freeBalance);
}
}
contract MetaGameCore is MetaGameFinance {
function MetaGameCore() public {
paused = true;
}
function createCollectible(uint256 identifier, address owner, uint256 parentIdentifier, uint256 price) external onlyCFO {
require(identifier >= 1);
require(identifierToOwner[identifier] == 0x0);
identifiers.push(identifier);
address initialOwner = owner;
if (initialOwner == 0x0) {
initialOwner = address(this);
}
_transfer(0x0, initialOwner, identifier);
identifierToParentIdentifier[identifier] = parentIdentifier;
identifierToPrice[identifier] = price;
Price(identifier, price, nextPrice(price));
}
function setParent(uint256 identifier, uint256 parentIdentifier) external onlyCFO {
require(identifierToOwner[identifier] != 0x0);
identifierToParentIdentifier[identifier] = parentIdentifier;
}
function buy(uint256 identifier) external payable whenNotPaused {
require(identifierToOwner[identifier] != 0x0);
address oldOwner = identifierToOwner[identifier];
uint256 price = identifierToPrice[identifier];
require(oldOwner != msg.sender);
require(msg.value >= price);
uint256 newPrice = nextPrice(price);
identifierToPrice[identifier] = newPrice;
_transfer(oldOwner, msg.sender, identifier);
Price(identifier, newPrice, nextPrice(newPrice));
uint256 dividend = price.mul(dividendPercentage).div(100000);
uint256 dividendsPaid = _payDividends(identifier, identifier, dividend, 0);
uint256 fee = calculateFee(price, dividendsPaid);
uint256 oldOwnerWinnings = price.sub(dividendsPaid).sub(fee);
Buy(oldOwner, msg.sender, identifier, price, oldOwnerWinnings);
if (oldOwner != address(this)) {
_sendFunds(oldOwner, oldOwnerWinnings);
}
uint256 excess = price - msg.value;
if (excess > 0) {
msg.sender.transfer(excess);
}
}
function getDeed(uint256 identifier)
external
view
returns(uint256 deedId, address owner, uint256 buyPrice, uint256 nextBuyPrice)
{
deedId = identifier;
owner = identifierToOwner[identifier];
buyPrice = identifierToPrice[identifier];
nextBuyPrice = nextPrice(buyPrice);
}
}