pragma solidity ^0.4.11;
library SafeMath {
function mul(uint256 a, uint256 b) internal constant returns (uint256) {
uint256 c = a * b;
assert(a == 0 || c / a == b);
return c;
}
function div(uint256 a, uint256 b) internal constant returns (uint256) {
uint256 c = a / b;
return c;
}
function sub(uint256 a, uint256 b) internal constant returns (uint256) {
assert(b <= a);
return a - b;
}
function add(uint256 a, uint256 b) internal constant returns (uint256) {
uint256 c = a + b;
assert(c >= a);
return c;
}
}
contract token { function transfer(address receiver, uint amount){  } }
contract Crowdsale {
using SafeMath for uint256;
address public wallet;
address public addressOfTokenUsedAsReward;
uint256 public weiPerToken = 4321000000000000000000;
token tokenReward;
uint256 public weiRaised;
event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);
function Crowdsale() {
wallet = 0x6a3a52fF68f684A6D8402F450d52275F41246253;
addressOfTokenUsedAsReward = 0x657C449c76500BCaA9AdEd6C0E087fA28663E3ff;
tokenReward = token(addressOfTokenUsedAsReward);
}
bool public started = true;
function startSale(){
if (msg.sender != wallet) throw;
started = true;
}
function stopSale(){
if(msg.sender != wallet) throw;
started = false;
}
function setWeiPerToken(uint256 _weiPerToken){
if(msg.sender!=wallet) throw;
weiPerToken = _weiPerToken;
}
function changeWallet(address _wallet){
if(msg.sender != wallet) throw;
wallet = _wallet;
}
function changeTokenReward(address _token){
if(msg.sender!=wallet) throw;
tokenReward = token(_token);
}
function () payable {
buyTokens(msg.sender);
}
function buyTokens(address beneficiary) payable {
require(beneficiary != 0x0);
require(validPurchase());
uint256 weiAmount = msg.value;
uint256 tokens = ((weiAmount * (10**18)) / weiPerToken);
weiRaised = weiRaised.add(weiAmount);
tokenReward.transfer(beneficiary, tokens);
TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);
forwardFunds();
}
function forwardFunds() internal {
if (!wallet.send(msg.value)) {
throw;
}
}
function validPurchase() internal constant returns (bool) {
bool withinPeriod = started;
bool nonZeroPurchase = msg.value != 0;
return withinPeriod && nonZeroPurchase;
}
function withdrawTokens(uint256 _amount) {
if(msg.sender!=wallet) throw;
tokenReward.transfer(wallet,_amount);
}
}