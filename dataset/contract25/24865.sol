pragma solidity ^0.4.20;
library SafeMath {
function mul(uint a, uint b) pure internal returns (uint) {
uint c = a * b;
assert((a == 0) || (c / a == b));
return c;
}
function div(uint a, uint b) pure internal returns (uint) {
uint c = a / b;
return c;
}
function sub(uint a, uint b) pure internal returns (uint) {
assert(b <= a);
return a - b;
}
function add(uint a, uint b) pure internal returns (uint) {
uint c = a + b;
assert(c >= a);
return c;
}
}
contract Token {
function transferFrom(address from, address to, uint256 value) public returns (bool success) {}
function transfer(address to, uint256 value) public returns (bool success) {}
}
contract OptionsExchange {
using SafeMath for uint;
uint public fee_ratio = 10 ** 16;
address public admin = msg.sender;
mapping (address => mapping(address => uint)) public userBalance;
mapping (bytes32 => address) public optionTaker;
mapping (bytes32 => bool) public optionOrderCancelled;
mapping (bytes32 => mapping(address => uint)) public optionBalance;
enum optionStates {
Invalid,
Available,
Cancelled,
Expired,
Tradeable,
Matured,
Closed
}
function changeAdmin(address _admin) external {
require(msg.sender == admin);
admin = _admin;
}
function depositETH() external payable {
userBalance[msg.sender][0] = userBalance[msg.sender][0].add(msg.value);
}
function withdrawETH(uint amount) external {
require(userBalance[msg.sender][0] >= amount);
userBalance[msg.sender][0] = userBalance[msg.sender][0].sub(amount);
msg.sender.transfer(amount);
}
function depositToken(address token, uint amount) external {
require(Token(token).transferFrom(msg.sender, this, amount));
userBalance[msg.sender][token] = userBalance[msg.sender][token].add(amount);
}
function withdrawToken(address token, uint amount) external {
require(userBalance[msg.sender][token] >= amount);
userBalance[msg.sender][token] = userBalance[msg.sender][token].sub(amount);
require(Token(token).transfer(msg.sender, amount));
}
function transferUserToUser(address from, address to, address token, uint amount) private {
require(userBalance[from][token] >= amount);
userBalance[from][token] = userBalance[from][token].sub(amount);
userBalance[to][token] = userBalance[to][token].add(amount);
}
function transferUserToOption(address from, bytes32 optionHash, address token, uint amount) private {
require(userBalance[from][token] >= amount);
userBalance[from][token] = userBalance[from][token].sub(amount);
optionBalance[optionHash][token] = optionBalance[optionHash][token].add(amount);
}
function transferOptionToUser(bytes32 optionHash, address to, address token, uint amount) private {
require(optionBalance[optionHash][token] >= amount);
optionBalance[optionHash][token] = optionBalance[optionHash][token].sub(amount);
userBalance[to][token] = userBalance[to][token].add(amount);
}
function getOptionHash(address[3] tokenA_tokenB_maker,
uint[3] limitTokenA_limitTokenB_premium,
uint[2] maturation_expiration,
bool makerIsSeller) pure public returns(bytes32) {
bytes32 optionHash = keccak256(
tokenA_tokenB_maker[0],
tokenA_tokenB_maker[1],
tokenA_tokenB_maker[2],
limitTokenA_limitTokenB_premium[0],
limitTokenA_limitTokenB_premium[1],
limitTokenA_limitTokenB_premium[2],
maturation_expiration[0],
maturation_expiration[1],
makerIsSeller
);
return optionHash;
}
function getOptionState(address[3] tokenA_tokenB_maker,
uint[3] limitTokenA_limitTokenB_premium,
uint[2] maturation_expiration,
bool makerIsSeller) view public returns(optionStates) {
if(tokenA_tokenB_maker[0] == tokenA_tokenB_maker[1]) return optionStates.Invalid;
if((limitTokenA_limitTokenB_premium[0] == 0) || (limitTokenA_limitTokenB_premium[1] == 0)) return optionStates.Invalid;
if(maturation_expiration[0] <= maturation_expiration[1]) return optionStates.Invalid;
bytes32 optionHash = getOptionHash(tokenA_tokenB_maker, limitTokenA_limitTokenB_premium, maturation_expiration, makerIsSeller);
if(optionOrderCancelled[optionHash]) return optionStates.Cancelled;
if(optionTaker[optionHash] == 0) {
if(now >= maturation_expiration[1]) return optionStates.Expired;
return optionStates.Available;
}
if((optionBalance[optionHash][tokenA_tokenB_maker[0]] == 0) &&
(optionBalance[optionHash][tokenA_tokenB_maker[1]] == 0)) return optionStates.Closed;
if(now >= maturation_expiration[0]) return optionStates.Matured;
return optionStates.Tradeable;
}
function getSeller(address maker, address taker, bool makerIsSeller) pure private returns(address) {
address seller = makerIsSeller ? maker : taker;
return seller;
}
function getBuyer(address maker, address taker, bool makerIsSeller) pure private returns(address) {
address buyer = makerIsSeller ? taker : maker;
return buyer;
}
function payForOption(address buyer, address seller, uint premium) private {
uint fee = (premium.mul(fee_ratio)).div(1 ether);
transferUserToUser(buyer, seller, 0, premium.sub(fee));
transferUserToUser(buyer, admin, 0, fee);
}
function fillOptionOrder(address[3] tokenA_tokenB_maker,
uint[3] limitTokenA_limitTokenB_premium,
uint[2] maturation_expiration,
bool makerIsSeller,
uint8 v,
bytes32[2] r_s) external {
require(getOptionState(tokenA_tokenB_maker, limitTokenA_limitTokenB_premium, maturation_expiration, makerIsSeller) == optionStates.Available);
bytes32 optionHash = getOptionHash(tokenA_tokenB_maker, limitTokenA_limitTokenB_premium, maturation_expiration, makerIsSeller);
require(ecrecover(keccak256("\x19Ethereum Signed Message:\n32", optionHash), v, r_s[0], r_s[1]) == tokenA_tokenB_maker[2]);
address seller = getSeller(tokenA_tokenB_maker[2], msg.sender, makerIsSeller);
address buyer = getBuyer(tokenA_tokenB_maker[2], msg.sender, makerIsSeller);
payForOption(buyer, seller, limitTokenA_limitTokenB_premium[2]);
transferUserToOption(seller, optionHash, tokenA_tokenB_maker[0], limitTokenA_limitTokenB_premium[0]);
optionTaker[optionHash] = msg.sender;
}
function cancelOptionOrder(address[3] tokenA_tokenB_maker,
uint[3] limitTokenA_limitTokenB_premium,
uint[2] maturation_expiration,
bool makerIsSeller) external {
require(getOptionState(tokenA_tokenB_maker, limitTokenA_limitTokenB_premium, maturation_expiration, makerIsSeller) == optionStates.Available);
require(msg.sender == tokenA_tokenB_maker[2]);
bytes32 optionHash = getOptionHash(tokenA_tokenB_maker, limitTokenA_limitTokenB_premium, maturation_expiration, makerIsSeller);
optionOrderCancelled[optionHash] = true;
}
function tradeOptionHelper(address buyer,
bytes32 optionHash,
address tokenToOption,
address tokenFromOption,
uint limitToOption,
uint limitFromOption,
uint amountToOption) private {
transferUserToOption(buyer, optionHash, tokenToOption, amountToOption);
uint amountFromOption = (amountToOption.mul(limitFromOption)).div(limitToOption);
transferOptionToUser(optionHash, buyer, tokenFromOption, amountFromOption);
}
function tradeOption(address[3] tokenA_tokenB_maker,
uint[3] limitTokenA_limitTokenB_premium,
uint[2] maturation_expiration,
bool makerIsSeller,
uint amountToOption,
bool tradingTokenAToOption) external {
require(getOptionState(tokenA_tokenB_maker, limitTokenA_limitTokenB_premium, maturation_expiration, makerIsSeller) == optionStates.Tradeable);
bytes32 optionHash = getOptionHash(tokenA_tokenB_maker, limitTokenA_limitTokenB_premium, maturation_expiration, makerIsSeller);
address buyer = getBuyer(tokenA_tokenB_maker[2], optionTaker[optionHash], makerIsSeller);
require(msg.sender == buyer);
if(tradingTokenAToOption) {
tradeOptionHelper(buyer, optionHash, tokenA_tokenB_maker[0], tokenA_tokenB_maker[1], limitTokenA_limitTokenB_premium[0], limitTokenA_limitTokenB_premium[1], amountToOption);
} else {
tradeOptionHelper(buyer, optionHash, tokenA_tokenB_maker[1], tokenA_tokenB_maker[0], limitTokenA_limitTokenB_premium[1], limitTokenA_limitTokenB_premium[0], amountToOption);
}
}
function closeOption(address[3] tokenA_tokenB_maker,
uint[3] limitTokenA_limitTokenB_premium,
uint[2] maturation_expiration,
bool makerIsSeller) external {
require(getOptionState(tokenA_tokenB_maker, limitTokenA_limitTokenB_premium, maturation_expiration, makerIsSeller) == optionStates.Matured);
bytes32 optionHash = getOptionHash(tokenA_tokenB_maker, limitTokenA_limitTokenB_premium, maturation_expiration, makerIsSeller);
address seller = getSeller(tokenA_tokenB_maker[2], optionTaker[optionHash], makerIsSeller);
require(msg.sender == seller);
transferOptionToUser(optionHash, seller, tokenA_tokenB_maker[0], optionBalance[optionHash][tokenA_tokenB_maker[0]]);
transferOptionToUser(optionHash, seller, tokenA_tokenB_maker[1], optionBalance[optionHash][tokenA_tokenB_maker[1]]);
}
function() payable external {
revert();
}
}