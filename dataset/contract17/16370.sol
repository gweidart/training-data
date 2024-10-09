pragma solidity 0.4.18;
library MerkleProof {
function verifyProof(bytes _proof, bytes32 _root, bytes32 _leaf) public pure returns (bool) {
if (_proof.length % 32 != 0) return false;
bytes32 proofElement;
bytes32 computedHash = _leaf;
for (uint256 i = 32; i <= _proof.length; i += 32) {
assembly {
proofElement := mload(add(_proof, i))
}
if (computedHash < proofElement) {
computedHash = keccak256(computedHash, proofElement);
} else {
computedHash = keccak256(proofElement, computedHash);
}
}
return computedHash == _root;
}
}