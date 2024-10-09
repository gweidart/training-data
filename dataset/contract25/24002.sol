pragma solidity ^0.4.20;
library SafeMath {
function mul(uint256 a, uint256 b) pure internal returns (uint256) {
uint256 c = a * b;
assert((a == 0) || (c / a == b));
return c;
}
function div(uint256 a, uint256 b) pure internal returns (uint256) {
uint256 c = a / b;
return c;
}
function sub(uint256 a, uint256 b) pure internal returns (uint256) {
assert(b <= a);
return a - b;
}
function add(uint256 a, uint256 b) pure internal returns (uint256) {
uint256 c = a + b;
assert(c >= a);
return c;
}
}
contract Token {
function transferFrom(address from, address to, uint256 value) public returns (bool success) {}
function transfer(address to, uint256 value) public returns (bool success) {}
}
contract OptionsExchange {
using SafeMath for uint256;
uint256 public fee_ratio = 10 ** 16;
address public admin = msg.sender;
mapping (address => mapping(address => uint256)) public userBalance;
mapping (bytes32 => address) public optionTaker;
mapping (bytes32 => bool) public optionOrderCancelled;
mapping (bytes32 => mapping(address => uint256)) public optionBalance;
enum optionStates {
Invalid,
Available,
Cancelled,
Expired,
Tradeable,
Matured,
Closed
}
event Deposit(address indexed user, address indexed token, uint256 amount);
event Withdrawal(address indexed user, address indexed token, uint256 amount);
event OrderFilled(bytes32 indexed optionHash);
event OrderCancelled(bytes32 indexed optionHash);
event OptionTraded(bytes32 indexed optionHash, uint256 amountToOption, bool tradingTokenAToOption);
event OptionClosed(bytes32 indexed optionHash);
function changeAdmin(address _admin) external {
require(msg.sender == admin);
admin = _admin;
}
function depositETH() external payable {
userBalance[msg.sender][0] = userBalance[msg.sender][0].add(msg.value);
Deposit(msg.sender, 0, msg.value);
}
function withdrawETH(uint256 amount) external {
require(userBalance[msg.sender][0] >= amount);
userBalance[msg.sender][0] = userBalance[msg.sender][0].sub(amount);
msg.sender.transfer(amount);
Withdrawal(msg.sender, 0, amount);
}
function depositToken(address token, uint256 amount) external {
require(Token(token).transferFrom(msg.sender, this, amount));
userBalance[msg.sender][token] = userBalance[msg.sender][token].add(amount);
Deposit(msg.sender, token, amount);
}
function withdrawToken(address token, uint256 amount) external {
require(userBalance[msg.sender][token] >= amount);
userBalance[msg.sender][token] = userBalance[msg.sender][token].sub(amount);
require(Token(token).transfer(msg.sender, amount));
Withdrawal(msg.sender, token, amount);
}
function transferUserToUser(address from, address to, address token, uint256 amount) private {
require(userBalance[from][token] >= amount);
userBalance[from][token] = userBalance[from][token].sub(amount);
userBalance[to][token] = userBalance[to][token].add(amount);
}
function transferUserToOption(address from, bytes32 optionHash, address token, uint256 amount) private {
require(userBalance[from][token] >= amount);
userBalance[from][token] = userBalance[from][token].sub(amount);
optionBalance[optionHash][token] = optionBalance[optionHash][token].add(amount);
}
function transferOptionToUser(bytes32 optionHash, address to, address token, uint256 amount) private {
require(optionBalance[optionHash][token] >= amount);
optionBalance[optionHash][token] = optionBalance[optionHash][token].sub(amount);
userBalance[to][token] = userBalance[to][token].add(amount);
}
function getOptionHash(address[3] tokenA_tokenB_maker,
uint256[3] limitTokenA_limitTokenB_premium,
uint256[2] maturation_expiration,
bool makerIsSeller,
bool premiumIsTokenA) pure public returns(bytes32) {
bytes32 optionHash = keccak256(
tokenA_tokenB_maker[0],
tokenA_tokenB_maker[1],
tokenA_tokenB_maker[2],
limitTokenA_limitTokenB_premium[0],
limitTokenA_limitTokenB_premium[1],
limitTokenA_limitTokenB_premium[2],
maturation_expiration[0],
maturation_expiration[1],
makerIsSeller,
premiumIsTokenA
);
return optionHash;
}
function getOptionState(address[3] tokenA_tokenB_maker,
uint256[3] limitTokenA_limitTokenB_premium,
uint256[2] maturation_expiration,
bool makerIsSeller,
bool premiumIsTokenA) view public returns(optionStates) {
if(tokenA_tokenB_maker[0] == tokenA_tokenB_maker[1]) return optionStates.Invalid;
if((limitTokenA_limitTokenB_premium[0] == 0) || (limitTokenA_limitTokenB_premium[1] == 0)) return optionStates.Invalid;
if(maturation_expiration[0] <= maturation_expiration[1]) return optionStates.Invalid;
bytes32 optionHash = getOptionHash(tokenA_tokenB_maker, limitTokenA_limitTokenB_premium, maturation_expiration, makerIsSeller, premiumIsTokenA);
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
function payForOption(address buyer, address seller, uint256 premium, address TokenA, address TokenB, bool premiumIsTokenA) private {
uint256 fee = (premium.mul(fee_ratio)).div(1 ether);
address premiumToken = premiumIsTokenA ? TokenA : TokenB;
transferUserToUser(buyer, seller, premiumToken, premium.sub(fee));
transferUserToUser(buyer, admin, premiumToken, fee);
}
function fillOptionOrder(address[3] tokenA_tokenB_maker,
uint256[3] limitTokenA_limitTokenB_premium,
uint256[2] maturation_expiration,
bool makerIsSeller,
bool premiumIsTokenA,
uint8 v,
bytes32[2] r_s) external {
require(getOptionState(tokenA_tokenB_maker, limitTokenA_limitTokenB_premium, maturation_expiration, makerIsSeller, premiumIsTokenA) == optionStates.Available);
bytes32 optionHash = getOptionHash(tokenA_tokenB_maker, limitTokenA_limitTokenB_premium, maturation_expiration, makerIsSeller, premiumIsTokenA);
require(ecrecover(keccak256("\x19Ethereum Signed Message:\n32", optionHash), v, r_s[0], r_s[1]) == tokenA_tokenB_maker[2]);
address seller = getSeller(tokenA_tokenB_maker[2], msg.sender, makerIsSeller);
address buyer = getBuyer(tokenA_tokenB_maker[2], msg.sender, makerIsSeller);
payForOption(buyer, seller, limitTokenA_limitTokenB_premium[2], tokenA_tokenB_maker[0], tokenA_tokenB_maker[1], premiumIsTokenA);
transferUserToOption(seller, optionHash, tokenA_tokenB_maker[0], limitTokenA_limitTokenB_premium[0]);
optionTaker[optionHash] = msg.sender;
OrderFilled(optionHash);
}
function cancelOptionOrder(address[3] tokenA_tokenB_maker,
uint256[3] limitTokenA_limitTokenB_premium,
uint256[2] maturation_expiration,
bool makerIsSeller,
bool premiumIsTokenA) external {
require(getOptionState(tokenA_tokenB_maker, limitTokenA_limitTokenB_premium, maturation_expiration, makerIsSeller, premiumIsTokenA) == optionStates.Available);
require(msg.sender == tokenA_tokenB_maker[2]);
bytes32 optionHash = getOptionHash(tokenA_tokenB_maker, limitTokenA_limitTokenB_premium, maturation_expiration, makerIsSeller, premiumIsTokenA);
optionOrderCancelled[optionHash] = true;
OrderCancelled(optionHash);
}
function tradeOptionHelper(address buyer,
bytes32 optionHash,
address tokenToOption,
address tokenFromOption,
uint256 limitToOption,
uint256 limitFromOption,
uint256 amountToOption) private {
transferUserToOption(buyer, optionHash, tokenToOption, amountToOption);
uint256 amountFromOption = (amountToOption.mul(limitFromOption)).div(limitToOption);
transferOptionToUser(optionHash, buyer, tokenFromOption, amountFromOption);
}
function tradeOption(address[3] tokenA_tokenB_maker,
uint256[3] limitTokenA_limitTokenB_premium,
uint256[2] maturation_expiration,
bool makerIsSeller,
bool premiumIsTokenA,
uint256 amountToOption,
bool tradingTokenAToOption) external {
require(getOptionState(tokenA_tokenB_maker, limitTokenA_limitTokenB_premium, maturation_expiration, makerIsSeller, premiumIsTokenA) == optionStates.Tradeable);
bytes32 optionHash = getOptionHash(tokenA_tokenB_maker, limitTokenA_limitTokenB_premium, maturation_expiration, makerIsSeller, premiumIsTokenA);
address buyer = getBuyer(tokenA_tokenB_maker[2], optionTaker[optionHash], makerIsSeller);
require(msg.sender == buyer);
if(tradingTokenAToOption) {
tradeOptionHelper(buyer, optionHash, tokenA_tokenB_maker[0], tokenA_tokenB_maker[1], limitTokenA_limitTokenB_premium[0], limitTokenA_limitTokenB_premium[1], amountToOption);
} else {
tradeOptionHelper(buyer, optionHash, tokenA_tokenB_maker[1], tokenA_tokenB_maker[0], limitTokenA_limitTokenB_premium[1], limitTokenA_limitTokenB_premium[0], amountToOption);
}
OptionTraded(optionHash, amountToOption, tradingTokenAToOption);
}
function closeOption(address[3] tokenA_tokenB_maker,
uint256[3] limitTokenA_limitTokenB_premium,
uint256[2] maturation_expiration,
bool makerIsSeller,
bool premiumIsTokenA) external {
require(getOptionState(tokenA_tokenB_maker, limitTokenA_limitTokenB_premium, maturation_expiration, makerIsSeller, premiumIsTokenA) == optionStates.Matured);
bytes32 optionHash = getOptionHash(tokenA_tokenB_maker, limitTokenA_limitTokenB_premium, maturation_expiration, makerIsSeller, premiumIsTokenA);
address seller = getSeller(tokenA_tokenB_maker[2], optionTaker[optionHash], makerIsSeller);
require(msg.sender == seller);
transferOptionToUser(optionHash, seller, tokenA_tokenB_maker[0], optionBalance[optionHash][tokenA_tokenB_maker[0]]);
transferOptionToUser(optionHash, seller, tokenA_tokenB_maker[1], optionBalance[optionHash][tokenA_tokenB_maker[1]]);
OptionClosed(optionHash);
}
function() payable external {
revert();
}
}