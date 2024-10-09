pragma solidity ^0.4.23;
contract Datatrust {
mapping (bytes32 => bool) public anchors;
event NewAnchor(bytes32 merkleRoot);
function saveNewAnchor(bytes32 _merkleRoot) public {
anchors[_merkleRoot] = true;
emit NewAnchor(_merkleRoot);
}
}