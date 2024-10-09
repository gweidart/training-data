pragma solidity 0.4.18;
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
contract Mintable {
function mint(address to, uint256 amount) public;
}
contract ExternalCrowdsale is Ownable {
using SafeMath for uint256;
Mintable public token;
uint256 public startBlock;
uint256 public endBlock;
mapping (bytes32 => bool) public isPaymentRegistered;
uint256 public availableAmount;
function ExternalCrowdsale(Mintable _token, uint256 _availableAmount)
public
onlyValid(_token)
onlyNotZero(_availableAmount)
{
token = _token;
availableAmount = _availableAmount;
}
event PurchaseRegistered(bytes32 indexed paymentId, address indexed purchaser, uint256 amount);
event SaleScheduled(uint256 startBlock, uint256 endBlock);
modifier onlySufficientAvailableTokens(uint256 amount) {
require(availableAmount >= amount);
_;
}
modifier onlyUniquePayment(bytes32 paymentId) {
require(!isPaymentRegistered[paymentId]);
_;
}
modifier onlyValid(address addr) {
require(addr != address(0));
_;
}
modifier onlyNotZero(uint256 value) {
require(value != 0);
_;
}
modifier onlyNotScheduled() {
require(startBlock == 0);
require(endBlock == 0);
_;
}
modifier onlyActive() {
require(isActive());
_;
}
function scheduleSale(uint256 _startBlock, uint256 _endBlock)
public
onlyOwner
onlyNotScheduled
onlyNotZero(_startBlock)
onlyNotZero(_endBlock)
{
require(_startBlock < _endBlock);
startBlock = _startBlock;
endBlock = _endBlock;
SaleScheduled(_startBlock, _endBlock);
}
function registerPurchase(bytes32 paymentId, address purchaser, uint256 amount)
public
onlyOwner
onlyActive
onlyValid(purchaser)
onlyNotZero(amount)
onlyUniquePayment(paymentId)
onlySufficientAvailableTokens(amount)
{
isPaymentRegistered[paymentId] = true;
availableAmount = availableAmount.sub(amount);
token.mint(purchaser, amount);
PurchaseRegistered(paymentId, purchaser, amount);
}
function isActive() public view returns (bool) {
return block.number >= startBlock && block.number <= endBlock;
}
}