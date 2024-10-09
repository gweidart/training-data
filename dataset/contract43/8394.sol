pragma solidity ^0.4.7;
contract AbstractSYCCrowdsale {
}
contract SYCEarlyPurchase {
string public constant PURCHASE_AMOUNT_UNIT = 'ETH';
uint public constant WEI_MINIMUM_PURCHASE = 1 * 10 ** 18;
uint public constant WEI_MAXIMUM_EARLYPURCHASE = 2 * 10 ** 18;
address public owner;
EarlyPurchase[] public earlyPurchases;
uint public earlyPurchaseClosedAt;
uint public totalEarlyPurchaseRaised;
struct EarlyPurchase {
address purchaser;
uint amount;
uint purchasedAt;
}
AbstractSYCCrowdsale public sycCrowdsale;
modifier onlyOwner() {
if (msg.sender != owner) {
throw;
}
_;
}
modifier onlyEarlyPurchaseTerm() {
if (earlyPurchaseClosedAt > 0) {
throw;
}
_;
}
function SYCEarlyPurchase() {
owner = msg.sender;
}
function purchasedAmountBy(address purchaser)
external
constant
returns (uint amount)
{
for (uint i; i < earlyPurchases.length; i++) {
if (earlyPurchases[i].purchaser == purchaser) {
amount += earlyPurchases[i].amount;
}
}
}
function numberOfEarlyPurchases()
external
constant
returns (uint)
{
return earlyPurchases.length;
}
function appendEarlyPurchase(address purchaser, uint amount, uint purchasedAt)
internal
onlyEarlyPurchaseTerm
returns (bool)
{
if (purchasedAt == 0 || purchasedAt > now) {
throw;
}
if (purchasedAt == 0 || purchasedAt > now) {
throw;
}
if(totalEarlyPurchaseRaised + amount >= WEI_MAXIMUM_EARLYPURCHASE){
purchaser.send(totalEarlyPurchaseRaised + amount - WEI_MAXIMUM_EARLYPURCHASE);
earlyPurchases.push(EarlyPurchase(purchaser, WEI_MAXIMUM_EARLYPURCHASE - totalEarlyPurchaseRaised, purchasedAt));
totalEarlyPurchaseRaised += WEI_MAXIMUM_EARLYPURCHASE - totalEarlyPurchaseRaised;
}
else{
earlyPurchases.push(EarlyPurchase(purchaser, amount, purchasedAt));
totalEarlyPurchaseRaised += amount;
}
if(totalEarlyPurchaseRaised >= WEI_MAXIMUM_EARLYPURCHASE){
closeEarlyPurchase();
}
return true;
}
function closeEarlyPurchase()
onlyOwner
returns (bool)
{
earlyPurchaseClosedAt = now;
}
function setup(address sycCrowdsaleAddress)
external
onlyOwner
returns (bool)
{
if (address(sycCrowdsale) == 0) {
sycCrowdsale = AbstractSYCCrowdsale(sycCrowdsaleAddress);
return true;
}
return false;
}
function withdraw(uint withdrawalAmount) onlyOwner {
if(!owner.send(withdrawalAmount)) throw;
}
function withdrawAll() onlyOwner {
if(!owner.send(this.balance)) throw;
}
function transferOwnership(address newOwner) onlyOwner {
owner = newOwner;
}
function () payable{
require(msg.value >= WEI_MINIMUM_PURCHASE);
appendEarlyPurchase(msg.sender, msg.value, block.timestamp);
}
}