pragma solidity ^0.4.19;
contract theCyberGatekeeperInterface {
function enter(bytes32 _passcode, bytes8 _gateKey) public returns (bool);
}
contract theCyberKey {
address private gatekeeperAddress = 0x44919b8026f38D70437A8eB3BE47B06aB1c3E4Bf;
function setGatekeeperAddress(address gatekeeper) public {
gatekeeperAddress = gatekeeper;
}
function enter(bytes32 passcode) public returns (bool) {
bytes8 key = generateKey();
return theCyberGatekeeperInterface(gatekeeperAddress).enter(passcode, key);
}
function generateKey() private returns (bytes8 key) {
uint32 lower4Bytes = 0;
uint32 upper4Bytes = 1;
uint16 lower2Bytes = uint16(tx.origin);
lower4Bytes |= lower2Bytes;
uint64 allBytes = lower4Bytes;
allBytes |= uint64(upper4Bytes) << 32;
key = bytes8(allBytes);
return key;
}
}