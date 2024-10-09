pragma solidity ^0.4.11;
library SafeMath {
function mul(uint256 a, uint256 b) internal pure returns (uint256) {
uint256 c = a * b;
assert(a == 0 || c / a == b);
return c;
}
function div(uint256 a, uint256 b) internal pure returns (uint256) {
assert(b > 0);
uint256 c = a / b;
assert(a == b * c + a % b);
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
function transferOwnership(address newOwner) onlyOwner public {
require(newOwner != address(0));
OwnershipTransferred(owner, newOwner);
owner = newOwner;
}
}
contract ERC20Basic {
uint256 public totalSupply;
function balanceOf(address who) constant public returns (uint256);
function transfer(address to, uint256 value) public returns (bool);
event Transfer(address indexed from, address indexed to, uint256 value);
}
contract BasicToken is ERC20Basic {
using SafeMath for uint256;
mapping(address => uint256) tokenBalances;
function transfer(address _to, uint256 _value) public returns (bool) {
require(tokenBalances[msg.sender]>=_value);
tokenBalances[msg.sender] = tokenBalances[msg.sender].sub(_value);
tokenBalances[_to] = tokenBalances[_to].add(_value);
Transfer(msg.sender, _to, _value);
return true;
}
function balanceOf(address _owner) constant public returns (uint256 balance) {
return tokenBalances[_owner];
}
}
contract QuantumBreakToken is BasicToken,Ownable {
using SafeMath for uint256;
string public constant name = "Quantum Break";
string public constant symbol = "QBT";
uint256 public constant decimals = 18;
address public ownerWallet;
uint256 public constant INITIAL_SUPPLY = 5000000000;
event Debug(string message, address addr, uint256 number);
function QuantumBreakToken(address wallet) public {
owner = msg.sender;
ownerWallet = wallet;
totalSupply = INITIAL_SUPPLY;
tokenBalances[ownerWallet] = INITIAL_SUPPLY * 10 ** 18;
}
function mint(address buyer, uint256 tokenAmount) public onlyOwner {
require(tokenBalances[ownerWallet] >= tokenAmount);
tokenBalances[buyer] = tokenBalances[buyer].add(tokenAmount);
tokenBalances[ownerWallet] = tokenBalances[ownerWallet].sub(tokenAmount);
Transfer(ownerWallet, buyer, tokenAmount);
}
function showMyTokenBalance(address addr) public view returns (uint tokenBalance) {
tokenBalance = tokenBalances[addr];
}
function makeAnotherContractOwnerOfToken(address newContractAddress) public
{
require(msg.sender == ownerWallet);
owner = newContractAddress;
}
}
contract Crowdsale {
using SafeMath for uint256;
QuantumBreakToken public token;
uint256 public startTime;
uint256 public endTime;
address public wallet;
uint256 public ratePerWei = 1 * 10 ** 5;
uint256 public weiRaised;
uint256 tokensSold;
uint256 upperCap = 4500000000 * 10 ** 18;
uint256 duration = 90 days;
bool ownerAmountPaid = false;
event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);
function Crowdsale(uint256 _startTime, address _wallet) public {
startTime = _startTime;
endTime = startTime + duration;
require(endTime >= startTime);
require(_wallet != 0x0);
wallet = _wallet;
token = createTokenContract(wallet);
}
function createTokenContract(address wall) internal returns (QuantumBreakToken) {
return new QuantumBreakToken(wall);
}
function () public payable {
buyTokens(msg.sender);
}
function buyTokens(address beneficiary) public payable {
require(beneficiary != 0x0);
require(validPurchase());
uint256 weiAmount = msg.value;
uint256 tokens = weiAmount.mul(ratePerWei);
uint discountTokens;
uint discountPercentage;
(discountTokens,discountPercentage) = determineDiscount(weiAmount, tokens);
uint tokensAboutToBeSold = tokens.add(discountTokens);
uint tokensYouCanGive = upperCap - tokensSold;
require (tokensYouCanGive>0);
uint ethsToReturn;
if (tokensYouCanGive < tokensAboutToBeSold)
{
discountPercentage = discountPercentage.add(100);
uint tokensToCharge = tokensYouCanGive.mul(100);
tokensToCharge = tokensToCharge.div(discountPercentage);
uint ethsToCharge = tokensToCharge.div(ratePerWei);
ethsToReturn = weiAmount - ethsToCharge;
tokensAboutToBeSold = tokensYouCanGive;
}
uint actualFundsRaised = weiAmount-ethsToReturn;
weiRaised = weiRaised.add(actualFundsRaised);
token.mint(beneficiary, tokensAboutToBeSold);
TokenPurchase(msg.sender, beneficiary, actualFundsRaised, tokensAboutToBeSold);
tokensSold = tokensSold.add(tokensAboutToBeSold);
beneficiary.transfer(ethsToReturn);
forwardFunds(actualFundsRaised);
}
function determineDiscount(uint256 weiAmount, uint256 tokens) internal view returns (uint discountTokens, uint discountPercentage) {
if (weiAmount > 0 && weiAmount < 1 * 10 ** 18)
{
discountTokens = tokens.mul(10);
discountTokens = discountTokens.div(100);
discountPercentage = 10;
}
else if (weiAmount >= 1 * 10 ** 18 && weiAmount < 5 * 10 ** 18)
{
discountTokens = tokens.mul(20);
discountTokens = discountTokens.div(100);
discountPercentage = 20;
}
else if (weiAmount >= 5 * 10 ** 18 && weiAmount <10 * 10 ** 18)
{
discountTokens = tokens.mul(30);
discountTokens = discountTokens.div(100);
discountPercentage = 30;
}
else if (weiAmount >= 10 * 10 * 10 ** 18 && weiAmount <20 * 10 ** 18)
{
discountTokens = tokens.mul(40);
discountTokens = discountTokens.div(100);
discountPercentage = 40;
}
else if (weiAmount >= 20 * 10 * 10 ** 18)
{
discountTokens = tokens.mul(50);
discountTokens = discountTokens.div(100);
discountPercentage = 50;
}
}
function forwardFunds(uint funds) internal {
wallet.transfer(funds);
}
function validPurchase() internal constant returns (bool) {
bool withinPeriod = now >= startTime && now <= endTime;
bool nonZeroPurchase = msg.value != 0;
return withinPeriod && nonZeroPurchase;
}
function hasEnded() public constant returns (bool) {
return now > endTime;
}
function showMyTokenBalance(address sender) public view returns (uint256 tokenBalance) {
tokenBalance = token.showMyTokenBalance(sender);
}
function changeStartTime(uint256 newStartTime) public
{
require (msg.sender == wallet);
startTime = newStartTime;
}
function changeEndTime(uint256 newEndTime) public
{
require (msg.sender == wallet);
endTime = newEndTime;
}
}