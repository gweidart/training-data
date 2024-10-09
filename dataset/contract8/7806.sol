pragma solidity ^0.4.23;
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
emit OwnershipTransferred(owner, newOwner);
owner = newOwner;
}
}
interface TokenInterface {
function totalSupply() external constant returns (uint);
function balanceOf(address tokenOwner) external constant returns (uint balance);
function allowance(address tokenOwner, address spender) external constant returns (uint remaining);
function transfer(address to, uint tokens) external returns (bool success);
function approve(address spender, uint tokens) external returns (bool success);
function transferFrom(address from, address to, uint tokens) external returns (bool success);
function burn(uint256 _value) external;
event Transfer(address indexed from, address indexed to, uint tokens);
event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
event Burn(address indexed burner, uint256 value);
}
contract ETHERFLEXCrowdsale is Ownable{
using SafeMath for uint256;
TokenInterface public token;
uint256 public ratePerEthPhase1 = 4866;
uint256 public ratePerEthPhase2 = 2433;
uint256 public ratePerEthPhase3 = 1081;
uint256 public weiRaised;
uint256 public TOKENS_SOLD;
bool isCrowdsalePaused = false;
uint public maxTokensToSale=51000000*10**18;
event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);
function ETHERFLEXCrowdsale(address _wallet, address _tokenAddress) public
{
require(_wallet != 0x0);
weiRaised=0;
owner = _wallet;
token = TokenInterface(_tokenAddress);
}
function () public  payable {
buyTokens(msg.sender);
}
function buyTokens(address beneficiary) public payable {
require(beneficiary != 0x0);
require(isCrowdsalePaused == false);
require(validPurchase());
require(TOKENS_SOLD<maxTokensToSale);
uint256 weiAmount = msg.value;
uint256 tokens=0;
if(TOKENS_SOLD<=5000000*10**18)
{
tokens = weiAmount.mul(ratePerEthPhase1);
}
else if(TOKENS_SOLD>5000000*10**18 && TOKENS_SOLD<=15000000*10**18)
{
tokens = weiAmount.mul(ratePerEthPhase2);
}
else if(TOKENS_SOLD>15000000*10**18 && TOKENS_SOLD<=51000000*10**18)
{
tokens = weiAmount.mul(ratePerEthPhase3);
}
else
{
revert();
}
weiRaised = weiRaised.add(weiAmount);
token.transfer(beneficiary,tokens);
emit TokenPurchase(owner, beneficiary, weiAmount, tokens);
TOKENS_SOLD = TOKENS_SOLD.add(tokens);
forwardFunds();
}
function forwardFunds() internal {
owner.transfer(msg.value);
}
function validPurchase() internal constant returns (bool) {
bool nonZeroPurchase = msg.value != 0;
return nonZeroPurchase;
}
function pauseCrowdsale() public onlyOwner {
isCrowdsalePaused = true;
}
function resumeCrowdsale() public onlyOwner {
isCrowdsalePaused = false;
}
function remainingTokensForSale() public constant returns (uint) {
return maxTokensToSale.sub(TOKENS_SOLD);
}
function burnUnsoldTokens() public onlyOwner
{
uint value = remainingTokensForSale();
token.burn(value);
TOKENS_SOLD = maxTokensToSale;
}
function takeTokensBack() public onlyOwner
{
uint remainingTokensInTheContract = token.balanceOf(address(this));
token.transfer(owner,remainingTokensInTheContract);
}
function manualTransfer(address beneficiary, uint tokens) public onlyOwner {
token.transfer(beneficiary,tokens);
emit TokenPurchase(owner, beneficiary, 0, tokens);
TOKENS_SOLD = TOKENS_SOLD.add(tokens);
}
}