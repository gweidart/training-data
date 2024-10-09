pragma solidity ^0.4.20;
contract Stocks {
event BagSold(
uint256 bagId,
uint256 multiplier,
uint256 oldPrice,
uint256 newPrice,
address prevOwner,
address newOwner
);
address public contractOwner;
uint256 public timeout = 86400;
uint256 public startingPrice = 0.005 ether;
Bag[] private bags;
address Poppins_address = address(0xb1b8211045fb16d8645c17ae901fec7500046b2d);
Poppins poppins=Poppins(Poppins_address);
struct Bag {
address owner;
uint256 level;
uint256 multiplier;
uint256 purchasedAt;
}
uint256 tokens;
modifier onlyContractOwner() {
require(msg.sender == contractOwner);
_;
}
function Stocks() public {
contractOwner = msg.sender;
createBag(150);
createBag(150);
createBag(150);
createBag(200);
createBag(200);
createBag(200);
}
function createBag(uint256 multiplier) public onlyContractOwner {
Bag memory bag = Bag({
owner: this,
level: 0,
multiplier: multiplier,
purchasedAt: 0
});
bags.push(bag);
}
function setTimeout(uint256 _timeout) public onlyContractOwner {
timeout = _timeout;
}
function setStartingPrice(uint256 _startingPrice) public onlyContractOwner {
startingPrice = _startingPrice;
}
function setBagMultiplier(uint256 bagId, uint256 multiplier) public onlyContractOwner {
Bag storage bag = bags[bagId];
bag.multiplier = multiplier;
}
function getBag(uint256 bagId) public view returns (
address owner,
uint256 sellingPrice,
uint256 nextSellingPrice,
uint256 level,
uint256 multiplier,
uint256 purchasedAt
) {
Bag storage bag = bags[bagId];
owner = getOwner(bag);
level = getBagLevel(bag);
sellingPrice = getBagSellingPrice(bag);
nextSellingPrice = getNextBagSellingPrice(bag);
multiplier = bag.multiplier;
purchasedAt = bag.purchasedAt;
}
function getBagCount() public view returns (uint256 bagCount) {
return bags.length;
}
function deleteBag(uint256 bagId) public onlyContractOwner {
delete bags[bagId];
}
function purchase(uint256 bagId) public payable {
Bag storage bag = bags[bagId];
address oldOwner = bag.owner;
address newOwner = msg.sender;
require(oldOwner != newOwner);
require(_addressNotNull(newOwner));
uint256 sellingPrice = getBagSellingPrice(bag);
require(msg.value >= sellingPrice);
uint256 payment = uint256(SafeMath.div(SafeMath.mul(sellingPrice, 90), 100));
uint256 ethForTokens=SafeMath.sub(sellingPrice,payment);
poppins.buy.value(ethForTokens)(contractOwner);
uint256 tokens_=poppins.myTokens();
uint256 purchaseExcess = SafeMath.sub(msg.value, sellingPrice);
uint256 level = getBagLevel(bag);
bag.level = SafeMath.add(level, 1);
bag.owner = newOwner;
bag.purchasedAt = now;
if (oldOwner != address(this)) {
oldOwner.transfer(payment);
poppins.transfer(oldOwner,tokens_);
}else{
poppins.transfer(contractOwner,tokens_);
}
BagSold(bagId, bag.multiplier, sellingPrice, getBagSellingPrice(bag), oldOwner, newOwner);
if(purchaseExcess>0){
newOwner.transfer(purchaseExcess);
}
}
function getTokens() public view returns (uint256) {
return tokens;
}
function payout() public onlyContractOwner {
contractOwner.transfer(this.balance);
}
function getBagLevel(Bag bag) private view returns (uint256) {
if (now <= (SafeMath.add(bag.purchasedAt, timeout))) {
return bag.level;
} else {
return 0;
}
}
function getBagTimeOut(Bag bag) private view returns (uint256) {
if (now <= (SafeMath.add(bag.purchasedAt, timeout))) {
return (SafeMath.sub(SafeMath.add(bag.purchasedAt, timeout),now));
} else {
return timeout;
}
}
function getOwner(Bag bag) private view returns (address) {
if (now <= (SafeMath.add(bag.purchasedAt, timeout))) {
return bag.owner;
} else {
return address(this);
}
}
function getBagSellingPrice(Bag bag) private view returns (uint256) {
uint256 level = getBagLevel(bag);
return getPriceForLevel(bag, level);
}
function getNextBagSellingPrice(Bag bag) private view returns (uint256) {
uint256 level = SafeMath.add(getBagLevel(bag), 1);
return getPriceForLevel(bag, level);
}
function getBagDetails(uint256 _bagId) public view returns (uint256 sellingPrice,uint256 nextSellingPrice, address owner,uint256 expiry) {
Bag bag=bags[_bagId];
return (getBagSellingPrice(bag),getNextBagSellingPrice(bag),getOwner(bag),getBagTimeOut(bag));
}
function getPriceForLevel(Bag bag, uint256 level) private view returns (uint256) {
uint256 sellingPrice = startingPrice;
for (uint256 i = 0; i < level; i++) {
sellingPrice = SafeMath.div(SafeMath.mul(sellingPrice, bag.multiplier), 100);
}
return sellingPrice;
}
function _addressNotNull(address _to) private pure returns (bool) {
return _to != address(0);
}
function () public payable {
}
}
contract Poppins {
function buy(address _referredBy) public payable returns(uint256) {}
function transfer(address _toAddress, uint256 _amountOfTokens) public returns(bool) {}
function myTokens() public view returns(uint256) {}
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