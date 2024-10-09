pragma solidity ^0.4.24;
library ECRecovery {
function recover(bytes32 hash, bytes sig) internal pure returns (address) {
bytes32 r;
bytes32 s;
uint8 v;
if (sig.length != 65) {
return (address(0));
}
assembly {
r := mload(add(sig, 32))
s := mload(add(sig, 64))
v := byte(0, mload(add(sig, 96)))
}
if (v < 27) {
v += 27;
}
if (v != 27 && v != 28) {
return (address(0));
} else {
return ecrecover(hash, v, r, s);
}
}
function toEthSignedMessageHash(
bytes32 hash
) internal pure returns (bytes32) {
return
keccak256(
abi.encodePacked("\x19Ethereum Signed Message:\n32", hash)
);
}
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
contract Feeless {
address internal msgSender;
mapping(address => uint256) public nonces;
modifier feeless() {
if (msgSender == address(0)) {
msgSender = msg.sender;
_;
msgSender = address(0);
} else {
_;
}
}
function performFeelessTransaction(
address sender,
address target,
bytes data,
uint256 nonce,
bytes sig
) public payable {
require(this == target);
bytes memory prefix = "\x19Ethereum Signed Message:\n32";
bytes32 hash = keccak256(prefix, keccak256(target, data, nonce));
msgSender = ECRecovery.recover(hash, sig);
require(msgSender == sender);
require(nonces[msgSender]++ == nonce);
require(target.call.value(msg.value)(data));
msgSender = address(0);
}
}
contract ERC20Basic {
function transfer(address to, uint256 value) public returns (bool);
event Transfer(address indexed from, address indexed to, uint256 value);
}
contract AbstractFee is ERC20Basic, Feeless {
using SafeMath for uint256;
mapping(address => uint256) balances;
function transfer(
address _to,
uint256 _value
) public feeless returns (bool) {
balances[msgSender] = balances[msgSender].sub(_value);
balances[_to] = balances[_to].add(_value);
Transfer(msgSender, _to, _value);
return true;
}
}