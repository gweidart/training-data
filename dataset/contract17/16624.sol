pragma solidity ^0.4.23;
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
struct optionDatum {
address seller;
uint96 nonceSeller;
address buyer;
uint96 nonceBuyer;
}
mapping (bytes32 => optionDatum) public optionData;
enum optionStates {
Invalid,
Available,
Cancelled,
Live,
Exercised,
Matured,
Closed
}
event Deposit(address indexed user, address indexed asset, uint256 amount);
event Withdrawal(address indexed user, address indexed asset, uint256 amount);
event OrderFilled(bytes32 indexed optionHash,
address indexed maker,
address indexed taker,
address[3] assetLocked_assetTraded_firstMaker,
uint256[3] amountLocked_amountTraded_maturation,
uint256[2] amountPremium_expiration,
address assetPremium,
bool makerIsSeller,
uint96 nonce);
event OrderCancelled(bytes32 indexed optionHash, bool bySeller, uint96 nonce);
event OptionExercised(bytes32 indexed optionHash, address indexed buyer, address indexed seller);
event OptionClosed(bytes32 indexed optionHash, address indexed seller);
event UserBalanceUpdated(address indexed user, address indexed asset, uint256 newBalance);
function changeAdmin(address _admin) external {
require(msg.sender == admin);
admin = _admin;
}
function depositETH() external payable {
userBalance[msg.sender][0] = userBalance[msg.sender][0].add(msg.value);
emit Deposit(msg.sender, 0, msg.value);
emit UserBalanceUpdated(msg.sender, 0, userBalance[msg.sender][0]);
}
function withdrawETH(uint256 amount) external {
require(userBalance[msg.sender][0] >= amount);
userBalance[msg.sender][0] = userBalance[msg.sender][0].sub(amount);
msg.sender.transfer(amount);
emit Withdrawal(msg.sender, 0, amount);
emit UserBalanceUpdated(msg.sender, 0, userBalance[msg.sender][0]);
}
function depositToken(address token, uint256 amount) external {
require(Token(token).transferFrom(msg.sender, this, amount));
userBalance[msg.sender][token] = userBalance[msg.sender][token].add(amount);
emit Deposit(msg.sender, token, amount);
emit UserBalanceUpdated(msg.sender, token, userBalance[msg.sender][token]);
}
function withdrawToken(address token, uint256 amount) external {
require(userBalance[msg.sender][token] >= amount);
userBalance[msg.sender][token] = userBalance[msg.sender][token].sub(amount);
require(Token(token).transfer(msg.sender, amount));
emit Withdrawal(msg.sender, token, amount);
emit UserBalanceUpdated(msg.sender, token, userBalance[msg.sender][token]);
}
function transferUserToUser(address from, address to, address asset, uint256 amount) private {
require(userBalance[from][asset] >= amount);
userBalance[from][asset] = userBalance[from][asset].sub(amount);
userBalance[to][asset] = userBalance[to][asset].add(amount);
emit UserBalanceUpdated(from, asset, userBalance[from][asset]);
emit UserBalanceUpdated(to, asset, userBalance[to][asset]);
}
function getOptionHash(address[3] assetLocked_assetTraded_firstMaker,
uint256[3] amountLocked_amountTraded_maturation) pure public returns(bytes32) {
bytes32 optionHash = keccak256(assetLocked_assetTraded_firstMaker[0],
assetLocked_assetTraded_firstMaker[1],
assetLocked_assetTraded_firstMaker[2],
amountLocked_amountTraded_maturation[0],
amountLocked_amountTraded_maturation[1],
amountLocked_amountTraded_maturation[2]);
return optionHash;
}
function getOrderHash(bytes32 optionHash,
uint256[2] amountPremium_expiration,
address assetPremium,
bool makerIsSeller,
uint96 nonce) view public returns(bytes32) {
bytes32 orderHash = keccak256("\x19Ethereum Signed Message:\n32",
keccak256(address(this),
optionHash,
amountPremium_expiration[0],
amountPremium_expiration[1],
assetPremium,
makerIsSeller,
nonce));
return orderHash;
}
function getOptionState(address[3] assetLocked_assetTraded_firstMaker,
uint256[3] amountLocked_amountTraded_maturation) view public returns(optionStates) {
if(assetLocked_assetTraded_firstMaker[0] == assetLocked_assetTraded_firstMaker[1]) return optionStates.Invalid;
if(amountLocked_amountTraded_maturation[0] == 0) return optionStates.Invalid;
if(amountLocked_amountTraded_maturation[1] == 0) return optionStates.Invalid;
if(amountLocked_amountTraded_maturation[2] < 1514764800) return optionStates.Invalid;
if(amountLocked_amountTraded_maturation[2] > 1893456000) return optionStates.Invalid;
bytes32 optionHash = getOptionHash(assetLocked_assetTraded_firstMaker, amountLocked_amountTraded_maturation);
address seller = optionData[optionHash].seller;
uint96 nonceSeller = optionData[optionHash].nonceSeller;
address buyer = optionData[optionHash].buyer;
if(seller == 0x0) {
if(nonceSeller != 0) return optionStates.Cancelled;
if(buyer == 0x0) return optionStates.Available;
return optionStates.Closed;
}
if(buyer == 0x0) return optionStates.Exercised;
if(now < amountLocked_amountTraded_maturation[2]) return optionStates.Live;
return optionStates.Matured;
}
function payForOption(address buyer, address seller, address assetPremium, uint256 amountPremium) private {
uint256 fee = (amountPremium.mul(fee_ratio)).div(1 ether);
transferUserToUser(buyer, seller, assetPremium, amountPremium.sub(fee));
transferUserToUser(buyer, admin, assetPremium, fee);
}
function fillOptionOrder(address[3] assetLocked_assetTraded_firstMaker,
uint256[3] amountLocked_amountTraded_maturation,
uint256[2] amountPremium_expiration,
address assetPremium,
bool makerIsSeller,
uint96 nonce,
uint8 v,
bytes32[2] r_s) external {
require(now < amountPremium_expiration[1]);
bytes32 optionHash = getOptionHash(assetLocked_assetTraded_firstMaker, amountLocked_amountTraded_maturation);
bytes32 orderHash = getOrderHash(optionHash, amountPremium_expiration, assetPremium, makerIsSeller, nonce);
if(nonce == 0) {
require(getOptionState(assetLocked_assetTraded_firstMaker, amountLocked_amountTraded_maturation) == optionStates.Available);
require(now < amountLocked_amountTraded_maturation[2]);
require(ecrecover(orderHash, v, r_s[0], r_s[1]) == assetLocked_assetTraded_firstMaker[2]);
optionData[optionHash].seller = makerIsSeller ? assetLocked_assetTraded_firstMaker[2] : msg.sender;
optionData[optionHash].nonceSeller = 1;
optionData[optionHash].buyer = makerIsSeller ? msg.sender : assetLocked_assetTraded_firstMaker[2];
optionData[optionHash].nonceBuyer = 1;
payForOption(optionData[optionHash].buyer, optionData[optionHash].seller, assetPremium, amountPremium_expiration[0]);
require(userBalance[optionData[optionHash].seller][assetLocked_assetTraded_firstMaker[0]] >= amountLocked_amountTraded_maturation[0]);
userBalance[optionData[optionHash].seller][assetLocked_assetTraded_firstMaker[0]] = userBalance[optionData[optionHash].seller][assetLocked_assetTraded_firstMaker[0]].sub(amountLocked_amountTraded_maturation[0]);
emit UserBalanceUpdated(optionData[optionHash].seller, assetLocked_assetTraded_firstMaker[0], userBalance[optionData[optionHash].seller][assetLocked_assetTraded_firstMaker[0]]);
emit OrderFilled(optionHash,
assetLocked_assetTraded_firstMaker[2],
msg.sender,
assetLocked_assetTraded_firstMaker,
amountLocked_amountTraded_maturation,
amountPremium_expiration,
assetPremium,
makerIsSeller,
nonce);
} else {
require(getOptionState(assetLocked_assetTraded_firstMaker, amountLocked_amountTraded_maturation) == optionStates.Live);
if(makerIsSeller) {
require(optionData[optionHash].nonceSeller == nonce);
require(ecrecover(orderHash, v, r_s[0], r_s[1]) == optionData[optionHash].seller);
payForOption(optionData[optionHash].seller, msg.sender, assetPremium, amountPremium_expiration[0]);
transferUserToUser(msg.sender, optionData[optionHash].seller, assetLocked_assetTraded_firstMaker[0], amountLocked_amountTraded_maturation[0]);
optionData[optionHash].seller = msg.sender;
optionData[optionHash].nonceSeller += 1;
emit OrderFilled(optionHash,
optionData[optionHash].seller,
msg.sender,
assetLocked_assetTraded_firstMaker,
amountLocked_amountTraded_maturation,
amountPremium_expiration,
assetPremium,
makerIsSeller,
nonce);
} else {
require(optionData[optionHash].nonceBuyer == nonce);
require(ecrecover(orderHash, v, r_s[0], r_s[1]) == optionData[optionHash].buyer);
payForOption(msg.sender, optionData[optionHash].buyer, assetPremium, amountPremium_expiration[0]);
optionData[optionHash].buyer = msg.sender;
optionData[optionHash].nonceBuyer += 1;
emit OrderFilled(optionHash,
optionData[optionHash].buyer,
msg.sender,
assetLocked_assetTraded_firstMaker,
amountLocked_amountTraded_maturation,
amountPremium_expiration,
assetPremium,
makerIsSeller,
nonce);
}
}
}
function cancelOptionOrder(address[3] assetLocked_assetTraded_firstMaker,
uint256[3] amountLocked_amountTraded_maturation,
bool makerIsSeller) external {
optionStates state = getOptionState(assetLocked_assetTraded_firstMaker, amountLocked_amountTraded_maturation);
require(state == optionStates.Available || state == optionStates.Live);
bytes32 optionHash = getOptionHash(assetLocked_assetTraded_firstMaker, amountLocked_amountTraded_maturation);
if(state == optionStates.Available) {
require(msg.sender == assetLocked_assetTraded_firstMaker[2]);
emit OrderCancelled(optionHash, makerIsSeller, 0);
optionData[optionHash].nonceSeller = 1;
} else {
if(makerIsSeller) {
require(msg.sender == optionData[optionHash].seller);
emit OrderCancelled(optionHash, makerIsSeller, optionData[optionHash].nonceSeller);
optionData[optionHash].nonceSeller += 1;
} else {
require(msg.sender == optionData[optionHash].buyer);
emit OrderCancelled(optionHash, makerIsSeller, optionData[optionHash].nonceBuyer);
optionData[optionHash].nonceBuyer += 1;
}
}
}
function exerciseOption(address[3] assetLocked_assetTraded_firstMaker,
uint256[3] amountLocked_amountTraded_maturation) external {
require(getOptionState(assetLocked_assetTraded_firstMaker, amountLocked_amountTraded_maturation) == optionStates.Live);
bytes32 optionHash = getOptionHash(assetLocked_assetTraded_firstMaker, amountLocked_amountTraded_maturation);
address buyer = optionData[optionHash].buyer;
address seller = optionData[optionHash].seller;
require(msg.sender == buyer);
transferUserToUser(buyer, seller, assetLocked_assetTraded_firstMaker[1], amountLocked_amountTraded_maturation[1]);
delete optionData[optionHash].buyer;
delete optionData[optionHash].nonceBuyer;
userBalance[buyer][assetLocked_assetTraded_firstMaker[0]] = userBalance[buyer][assetLocked_assetTraded_firstMaker[0]].add(amountLocked_amountTraded_maturation[0]);
emit UserBalanceUpdated(buyer, assetLocked_assetTraded_firstMaker[0], userBalance[buyer][assetLocked_assetTraded_firstMaker[0]]);
emit OptionExercised(optionHash, buyer, seller);
}
function closeOption(address[3] assetLocked_assetTraded_firstMaker,
uint256[3] amountLocked_amountTraded_maturation) external {
require(getOptionState(assetLocked_assetTraded_firstMaker, amountLocked_amountTraded_maturation) == optionStates.Matured);
bytes32 optionHash = getOptionHash(assetLocked_assetTraded_firstMaker, amountLocked_amountTraded_maturation);
address seller = optionData[optionHash].seller;
require(msg.sender == seller);
delete optionData[optionHash].seller;
delete optionData[optionHash].nonceSeller;
userBalance[seller][assetLocked_assetTraded_firstMaker[0]] = userBalance[seller][assetLocked_assetTraded_firstMaker[0]].add(amountLocked_amountTraded_maturation[0]);
emit UserBalanceUpdated(seller, assetLocked_assetTraded_firstMaker[0], userBalance[seller][assetLocked_assetTraded_firstMaker[0]]);
emit OptionClosed(optionHash, seller);
}
function() payable external {
revert();
}
}