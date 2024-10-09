pragma solidity ^0.4.18;
contract Ownable {
address public owner;
function Ownable() public {
owner = msg.sender;
}
modifier onlyOwner() {
if (msg.sender != owner) {
revert();
}
_;
}
function transferOwnership(address newOwner) internal onlyOwner {
if (newOwner != address(0)) {
owner = newOwner;
}
}
}
library SafeMath {
function mul(uint256 a, uint256 b) internal pure returns (uint256) {
uint256 c = a * b;
assert(a == 0 || c / a == b);
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
contract TradeFeeCalculator is Ownable {
using SafeMath for uint256;
uint256[3] public exFees;
function TradeFeeCalculator() public {
owner = msg.sender;
}
function updateFeeSchedule(uint256 _baseTokenFee, uint256 _etherFee, uint256 _normalTokenFee) public onlyOwner {
require(_baseTokenFee >= 0 && _baseTokenFee <=  1 * 1 ether);
require(_etherFee >= 0 && _etherFee <=  1 * 1 ether);
require(_normalTokenFee >= 0);
require(exFees.length == 3);
exFees[0] = _baseTokenFee;
exFees[1] = _etherFee;
exFees[2] = _normalTokenFee;
}
function calcTradeFee(uint256 _value, uint256 _feeIndex) public view returns (uint256) {
require(_feeIndex >= 0 && _feeIndex <= 2);
require(_value > 0 && _value >=  1* 1 ether);
require(exFees.length == 3 && exFees[_feeIndex] > 0 );
uint256 _totalFees = (_value.mul(exFees[_feeIndex])).div(1 ether);
require(_totalFees > 0);
return _totalFees;
}
function calcTradeFeeMulti(uint256[] _values, uint256[] _feeIndexes) public view returns (uint256[]) {
require(_values.length > 0);
require(_feeIndexes.length > 0);
require(_values.length == _feeIndexes.length);
require(exFees.length == 3);
uint256[] memory _totalFees = new uint256[](_values.length);
for (uint256 i = 0; i < _values.length; i++){
_totalFees[i] =  calcTradeFee(_values[i], _feeIndexes[i]);
}
require(_totalFees.length > 0);
require(_values.length == _totalFees.length);
return _totalFees;
}
}