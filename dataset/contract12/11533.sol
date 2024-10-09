pragma solidity ^0.4.23;
library StringUtils {
struct slice {
uint _len;
uint _ptr;
}
function toSlice(string self) internal pure returns (slice) {
uint ptr;
assembly {
ptr := add(self, 0x20)
}
return slice(bytes(self).length, ptr);
}
function copy(slice self) internal pure returns (slice) {
return slice(self._len, self._ptr);
}
function toString(slice self) internal pure returns (string) {
string memory ret = new string(self._len);
uint retptr;
assembly { retptr := add(ret, 32) }
memcpy(retptr, self._ptr, self._len);
return ret;
}
function lower(string _base) internal pure returns (string) {
bytes memory _baseBytes = bytes(_base);
for (uint i = 0; i < _baseBytes.length; i++) {
_baseBytes[i] = _lower(_baseBytes[i]);
}
return string(_baseBytes);
}
function _lower(bytes1 _b1) internal pure returns (bytes1) {
if (_b1 >= 0x41 && _b1 <= 0x5A) {
return bytes1(uint8(_b1) + 32);
}
return _b1;
}
function memcpy(uint dest, uint src, uint len) private pure {
for (; len >= 32; len -= 32) {
assembly {
mstore(dest, mload(src))
}
dest += 32;
src += 32;
}
uint mask = 256 ** (32 - len) - 1;
assembly {
let srcpart := and(mload(src), not(mask))
let destpart := and(mload(dest), mask)
mstore(dest, or(destpart, srcpart))
}
}
}