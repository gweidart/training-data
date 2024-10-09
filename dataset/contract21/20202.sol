pragma solidity ^0.4.19;
contract GKInterface {
function enter(bytes32 _passcode, bytes8 _gateKey) public returns (bool);
}
contract theProxy  {
address private constant THECYBERGATEKEEPER_ = 0x44919b8026f38D70437A8eB3BE47B06aB1c3E4Bf;
function theProxy() public {}
function enter(bytes32 _passcode, bytes8 _gateKey) public returns (bool) {
GKInterface gk = GKInterface(THECYBERGATEKEEPER_);
return gk.enter(_passcode, _gateKey);
}
}