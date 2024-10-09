contract SHA3_512 {
function hash(uint64[8]) pure public returns(uint32[16]) {}
}
contract Teikhos {
SHA3_512 public sha3_512 = SHA3_512(0xbD6361cC42fD113ED9A9fdbEDF7eea27b325a222);
mapping(string => bytes) proof_of_public_key;
mapping(string => uint) balanceOf;
function checkAccount(string _name) view public returns (uint balance, bytes proof) {
return (balanceOf[_name], proof_of_public_key[_name]);
}
function newAccount(string _name, bytes _proof_of_public_key) public {
require(proof_of_public_key[_name].length == 0);
require(_proof_of_public_key.length == 64);
require(bytes(_name).length != 0);
proof_of_public_key[_name] = _proof_of_public_key;
}
function deposit(string _name) public payable {
require(proof_of_public_key[_name].length == 64);
balanceOf[_name] += msg.value;
}
function authenticate(string _name, bytes _publicKey) public {
require(proof_of_public_key[_name].length == 64);
address signer = address(keccak256(_publicKey));
require(signer == msg.sender);
bytes memory keyHash = getHash(_publicKey);
bytes32 hash1;
bytes32 hash2;
assembly {
hash1 := mload(add(keyHash,0x20))
hash2 := mload(add(keyHash,0x40))
}
bytes memory PoPk = proof_of_public_key[_name];
bytes32 proof_of_public_key1;
bytes32 proof_of_public_key2;
assembly {
proof_of_public_key1 := mload(add(PoPk,0x20))
proof_of_public_key2 := mload(add(PoPk,0x40))
}
bytes32 r = proof_of_public_key1 ^ hash1;
bytes32 s = proof_of_public_key2 ^ hash2;
bytes32 msgHash = keccak256("\x19Ethereum Signed Message:\n64", _publicKey);
if(ecrecover(msgHash, 27, r, s) == signer || ecrecover(msgHash, 28, r, s) == signer ) {
uint amount = balanceOf[_name];
delete balanceOf[_name];
delete proof_of_public_key[_name];
require(msg.sender.send(amount));
}
}
function getHash(bytes _message) view internal returns (bytes messageHash) {
uint64[8] memory input;
bytes memory reversed = new bytes(64);
for(uint i = 0; i < 64; i++) {
reversed[i] = _message[63 - i];
}
for(i = 0; i < 8; i++) {
bytes8 oneEigth;
assembly {
oneEigth := mload(add(reversed, add(32, mul(i, 8))))
}
input[7 - i] = uint64(oneEigth);
}
uint32[16] memory output = sha3_512.hash(input);
bytes memory toBytes = new bytes(64);
for(i = 0; i < 16; i++) {
bytes4 oneSixteenth = bytes4(output[15 - i]);
assembly { mstore(add(toBytes, add(32, mul(i, 4))), oneSixteenth) }
}
messageHash = new bytes(64);
for(i = 0; i < 64; i++) {
messageHash[i] = toBytes[63 - i];
}
}
}