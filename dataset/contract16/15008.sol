pragma solidity ^0.4.21;
interface BancorConverter {
function quickConvert(address[] _path, uint256 _amount, uint256 _minReturn) public payable returns (uint256);
}
contract BancorHandler {
uint256 public MAX_UINT = 2**256 -1;
BancorConverter public exchange;
function BancorHandler(address _exchange) public {
exchange = BancorConverter(_exchange);
}
function getAvailableAmount(
address[21] orderAddresses,
uint256[6] orderValues,
uint256 exchangeFee,
uint8 v,
bytes32 r,
bytes32 s
) external returns (uint256) {
return MAX_UINT;
}
function performBuy(
address[21] orderAddresses,
uint256[6] orderValues,
uint256 exchangeFee,
uint256 amountToFill,
uint8 v,
bytes32 r,
bytes32 s
) external payable returns (uint256) {
return trade(orderAddresses, orderValues);
}
function performSell(
address[21] orderAddresses,
uint256[6] orderValues,
uint256 exchangeFee,
uint256 amountToFill,
uint8 v,
bytes32 r,
bytes32 s
) external returns (uint256) {
return trade(orderAddresses, orderValues);
}
function trade(
address[21] orderAddresses,
uint256[6] orderValues
) internal returns (uint256) {
uint256 len = 0;
for(; len < orderAddresses.length; len++) {
if(orderAddresses[len] == 0) {
break;
}
}
address[] memory conversionPath = new address[](len);
for(uint256 i = 0; i < len; i++) {
conversionPath[i] = orderAddresses[i];
}
return exchange.quickConvert.value(msg.value)(conversionPath, orderValues[0], orderValues[1]);
}
function() public payable {
}
}