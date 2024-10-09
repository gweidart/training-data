pragma solidity ^0.4.18;
contract ECVerify  {
function ecrecovery(bytes32 _msgHash, uint8 v, bytes32 r, bytes32 s) public pure returns (address) {
if (v < 27) {
v += 27;
}
if (v != 27 && v != 28) {
return (address(0));
}
if (v==27) {
return ecrecover(_msgHash, v, r, s);
}
else if (v==28) {
return ecrecover(_msgHash, v, r, s);
}
return (address(0));
}
function ecverify(bytes32 _msgHash, uint8 v, bytes32 r, bytes32 s, address _signer) public pure returns (bool) {
if (_signer == address(0)) {
return false;
}
return ecrecovery(_msgHash, v, r, s) == _signer;
}
}