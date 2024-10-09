pragma solidity ^0.4.17;
contract ECVerifyTest {
function ecrecoverFromSig(bytes32 hash, bytes sig) public pure returns (address recoveredAddress) {
bytes32 r;
bytes32 s;
uint8 v;
if (sig.length != 65) return address(0);
assembly {
r := mload(add(sig, 32))
s := mload(add(sig, 64))
v := byte(0, mload(add(sig, 96)))
}
if (v < 27) {
v += 27;
}
if (v != 27 && v != 28) return address(0);
return ecrecover(hash, v, r, s);
}
function ecrecoverFromVRS(bytes32 hash, uint8 v, bytes32 r, bytes32 s) public pure returns (address recoveredAddress) {
return ecrecover(hash, v, r, s);
}
}