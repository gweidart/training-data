pragma solidity 0.4.21;
interface ExchangeHandler {
function getAvailableAmount(
address[8] orderAddresses,
uint256[6] orderValues,
uint256 exchangeFee,
uint8 v,
bytes32 r,
bytes32 s
) external returns (uint256);
function performBuy(
address[8] orderAddresses,
uint256[6] orderValues,
uint256 exchangeFee,
uint256 amountToFill,
uint8 v,
bytes32 r,
bytes32 s
) external payable returns (uint256);
function performSell(
address[8] orderAddresses,
uint256[6] orderValues,
uint256 exchangeFee,
uint256 amountToFill,
uint8 v,
bytes32 r,
bytes32 s
) external returns (uint256);
}
library SafeMath {
function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
if (a == 0) {
return 0;
}
c = a * b;
assert(c / a == b);
return c;
}
function div(uint256 a, uint256 b) internal pure returns (uint256) {
return a / b;
}
function sub(uint256 a, uint256 b) internal pure returns (uint256) {
assert(b <= a);
return a - b;
}
function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
c = a + b;
assert(c >= a);
return c;
}
}
contract ERC20Basic {
function totalSupply() public view returns (uint256);
function balanceOf(address who) public view returns (uint256);
function transfer(address to, uint256 value) public returns (bool);
event Transfer(address indexed from, address indexed to, uint256 value);
}
contract Token is ERC20Basic {
function allowance(address owner, address spender) public view returns (uint256);
function transferFrom(address from, address to, uint256 value) public returns (bool);
function approve(address spender, uint256 value) public returns (bool);
event Approval(address indexed owner, address indexed spender, uint256 value);
}
interface Kyber {
function trade(Token src, uint srcAmount, Token dest, address destAddress, uint maxDestAmount, uint minConversionRate, address walletId) public payable returns (uint);
}
contract KyberHandler is ExchangeHandler {
Kyber public exchange;
Token constant public ETH_TOKEN_ADDRESS = Token(0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee);
function KyberHandler(address _exchange) public {
exchange = Kyber(_exchange);
}
function getAvailableAmount(
address[8] orderAddresses,
uint256[6] orderValues,
uint256 exchangeFee,
uint8 v,
bytes32 r,
bytes32 s
) external returns (uint256) {
return orderValues[0];
}
function performBuy(
address[8] orderAddresses,
uint256[6] orderValues,
uint256 exchangeFee,
uint256 amountToFill,
uint8 v,
bytes32 r,
bytes32 s
) external payable returns (uint256) {
require(msg.value == orderValues[0]);
uint256 tokenAmountObtained = trade(
ETH_TOKEN_ADDRESS,
orderValues[0],
Token(orderAddresses[0]),
orderAddresses[1],
orderValues[2],
orderValues[3],
orderAddresses[2]
);
if(this.balance > 0) {
msg.sender.transfer(this.balance);
}
return tokenAmountObtained;
}
function performSell(
address[8] orderAddresses,
uint256[6] orderValues,
uint256 exchangeFee,
uint256 amountToFill,
uint8 v,
bytes32 r,
bytes32 s
) external returns (uint256) {
require(Token(orderAddresses[0]).approve(address(exchange), orderValues[0]));
uint256 etherAmountObtained = trade(
Token(orderAddresses[0]),
orderValues[0],
ETH_TOKEN_ADDRESS,
orderAddresses[1],
orderValues[2],
orderValues[3],
orderAddresses[2]
);
return etherAmountObtained;
}
function trade(
Token src,
uint srcAmount,
Token dest,
address destAddress,
uint maxDestAmount,
uint minConversionRate,
address walletId
) internal returns (uint256) {
uint256 valToSend = 0;
if(src == ETH_TOKEN_ADDRESS) {
valToSend = srcAmount;
}
return exchange.trade.value(valToSend)(
src,
srcAmount,
dest,
destAddress,
maxDestAmount,
minConversionRate,
walletId
);
}
function() public payable {
require(msg.sender == address(exchange));
}
}