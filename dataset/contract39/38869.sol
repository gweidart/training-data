pragma solidity ^0.4.11;
contract SafeMath {
function SafeMath() {
}
function safeAdd(uint256 _x, uint256 _y) internal returns (uint256) {
uint256 z = _x + _y;
assert(z >= _x);
return z;
}
function safeSub(uint256 _x, uint256 _y) internal returns (uint256) {
assert(_x >= _y);
return _x - _y;
}
function safeMul(uint256 _x, uint256 _y) internal returns (uint256) {
uint256 z = _x * _y;
assert(_x == 0 || z / _x == _y);
return z;
}
}
contract IBancorFormula {
function calculatePurchaseReturn(uint256 _supply, uint256 _reserveBalance, uint16 _reserveRatio, uint256 _depositAmount) public constant returns (uint256);
function calculateSaleReturn(uint256 _supply, uint256 _reserveBalance, uint16 _reserveRatio, uint256 _sellAmount) public constant returns (uint256);
}
contract BancorFormula is IBancorFormula, SafeMath {
uint8 constant PRECISION   = 32;
uint256 constant FIXED_ONE = uint256(1) << PRECISION;
uint256 constant FIXED_TWO = uint256(2) << PRECISION;
uint256 constant MAX_VAL   = uint256(1) << (256 - PRECISION);
string public version = '0.1';
function BancorFormula() {
}
function calculatePurchaseReturn(uint256 _supply, uint256 _reserveBalance, uint16 _reserveRatio, uint256 _depositAmount) public constant returns (uint256) {
require(_supply != 0 && _reserveBalance != 0 && _reserveRatio > 0 && _reserveRatio <= 100);
if (_depositAmount == 0)
return 0;
uint256 baseN = safeAdd(_depositAmount, _reserveBalance);
uint256 temp;
if (_reserveRatio == 100) {
temp = safeMul(_supply, baseN) / _reserveBalance;
return safeSub(temp, _supply);
}
uint256 resN = power(baseN, _reserveBalance, _reserveRatio, 100);
temp = safeMul(_supply, resN) / FIXED_ONE;
uint256 result =  safeSub(temp, _supply);
return safeSub(result, _supply / 0x100000000);
}
function calculateSaleReturn(uint256 _supply, uint256 _reserveBalance, uint16 _reserveRatio, uint256 _sellAmount) public constant returns (uint256) {
require(_supply != 0 && _reserveBalance != 0 && _reserveRatio > 0 && _reserveRatio <= 100 && _sellAmount <= _supply);
if (_sellAmount == 0)
return 0;
uint256 baseN = safeSub(_supply, _sellAmount);
uint256 temp1;
uint256 temp2;
if (_reserveRatio == 100) {
temp1 = safeMul(_reserveBalance, _supply);
temp2 = safeMul(_reserveBalance, baseN);
return safeSub(temp1, temp2) / _supply;
}
if (_sellAmount == _supply)
return _reserveBalance;
uint256 resN = power(_supply, baseN, 100, _reserveRatio);
temp1 = safeMul(_reserveBalance, resN);
temp2 = safeMul(_reserveBalance, FIXED_ONE);
uint256 result = safeSub(temp1, temp2) / resN;
return safeSub(result, _reserveBalance / 0x100000000);
}
function power(uint256 _baseN, uint256 _baseD, uint32 _expN, uint32 _expD) constant returns (uint256 resN) {
uint256 logbase = ln(_baseN, _baseD);
resN = fixedExp(safeMul(logbase, _expN) / _expD);
return resN;
}
function ln(uint256 _numerator, uint256 _denominator) public constant returns (uint256) {
assert(_denominator <= _numerator);
assert(_denominator != 0 && _numerator != 0);
assert(_numerator < MAX_VAL);
assert(_denominator < MAX_VAL);
return fixedLoge( (_numerator * FIXED_ONE) / _denominator);
}
function fixedLoge(uint256 _x) constant returns (uint256 logE) {
assert(_x >= FIXED_ONE);
uint256 log2 = fixedLog2(_x);
logE = (log2 * 0xb17217f7d1cf78) >> 56;
}
function fixedLog2(uint256 _x) constant returns (uint256) {
assert( _x >= FIXED_ONE);
uint256 hi = 0;
while (_x >= FIXED_TWO) {
_x >>= 1;
hi += FIXED_ONE;
}
for (uint8 i = 0; i < PRECISION; ++i) {
_x = (_x * _x) / FIXED_ONE;
if (_x >= FIXED_TWO) {
_x >>= 1;
hi += uint256(1) << (PRECISION - 1 - i);
}
}
return hi;
}
function fixedExp(uint256 _x) constant returns (uint256) {
assert(_x <= 0x386bfdba29);
return fixedExpUnsafe(_x);
}
function fixedExpUnsafe(uint256 _x) constant returns (uint256) {
uint256 xi = FIXED_ONE;
uint256 res = 0xde1bc4d19efcac82445da75b00000000 * xi;
xi = (xi * _x) >> PRECISION;
res += xi * 0xde1bc4d19efcb0000000000000000000;
xi = (xi * _x) >> PRECISION;
res += xi * 0x6f0de268cf7e58000000000000000000;
xi = (xi * _x) >> PRECISION;
res += xi * 0x2504a0cd9a7f72000000000000000000;
xi = (xi * _x) >> PRECISION;
res += xi * 0x9412833669fdc800000000000000000;
xi = (xi * _x) >> PRECISION;
res += xi * 0x1d9d4d714865f500000000000000000;
xi = (xi * _x) >> PRECISION;
res += xi * 0x4ef8ce836bba8c0000000000000000;
xi = (xi * _x) >> PRECISION;
res += xi * 0xb481d807d1aa68000000000000000;
xi = (xi * _x) >> PRECISION;
res += xi * 0x16903b00fa354d000000000000000;
xi = (xi * _x) >> PRECISION;
res += xi * 0x281cdaac677b3400000000000000;
xi = (xi * _x) >> PRECISION;
res += xi * 0x402e2aad725eb80000000000000;
xi = (xi * _x) >> PRECISION;
res += xi * 0x5d5a6c9f31fe24000000000000;
xi = (xi * _x) >> PRECISION;
res += xi * 0x7c7890d442a83000000000000;
xi = (xi * _x) >> PRECISION;
res += xi * 0x9931ed540345280000000000;
xi = (xi * _x) >> PRECISION;
res += xi * 0xaf147cf24ce150000000000;
xi = (xi * _x) >> PRECISION;
res += xi * 0xbac08546b867d000000000;
xi = (xi * _x) >> PRECISION;
res += xi * 0xbac08546b867d00000000;
xi = (xi * _x) >> PRECISION;
res += xi * 0xafc441338061b8000000;
xi = (xi * _x) >> PRECISION;
res += xi * 0x9c3cabbc0056e000000;
xi = (xi * _x) >> PRECISION;
res += xi * 0x839168328705c80000;
xi = (xi * _x) >> PRECISION;
res += xi * 0x694120286c04a0000;
xi = (xi * _x) >> PRECISION;
res += xi * 0x50319e98b3d2c400;
xi = (xi * _x) >> PRECISION;
res += xi * 0x3a52a1e36b82020;
xi = (xi * _x) >> PRECISION;
res += xi * 0x289286e0fce002;
xi = (xi * _x) >> PRECISION;
res += xi * 0x1b0c59eb53400;
xi = (xi * _x) >> PRECISION;
res += xi * 0x114f95b55400;
xi = (xi * _x) >> PRECISION;
res += xi * 0xaa7210d200;
xi = (xi * _x) >> PRECISION;
res += xi * 0x650139600;
xi = (xi * _x) >> PRECISION;
res += xi * 0x39b78e80;
xi = (xi * _x) >> PRECISION;
res += xi * 0x1fd8080;
xi = (xi * _x) >> PRECISION;
res += xi * 0x10fbc0;
xi = (xi * _x) >> PRECISION;
res += xi * 0x8c40;
xi = (xi * _x) >> PRECISION;
res += xi * 0x462;
xi = (xi * _x) >> PRECISION;
res += xi * 0x22;
return res / 0xde1bc4d19efcac82445da75b00000000;
}
}