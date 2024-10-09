pragma solidity ^0.4.23;
contract LegalDocument {
string public documentIPFSHash;
string public governingLaw;
constructor(string ipfsHash, string law) public {
documentIPFSHash = ipfsHash;
governingLaw = law;
}
}