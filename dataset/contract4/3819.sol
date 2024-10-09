pragma solidity 0.4.24;
library CertificateLibrary {
struct Document {
bytes ipfsHash;
bytes32 transcriptHash;
bytes32 contentHash;
}
function addCertification(Document storage self, bytes32 _contentHash, bytes _ipfsHash, bytes32 _transcriptHash) public {
self.ipfsHash = _ipfsHash;
self.contentHash= _contentHash;
self.transcriptHash = _transcriptHash;
}
function validate(Document storage self, bytes _ipfsHash, bytes32 _contentHash, bytes32 _transcriptHash) public view returns(bool) {
bytes storage ipfsHash = self.ipfsHash;
bytes32 contentHash = self.contentHash;
bytes32 transcriptHash = self.transcriptHash;
return contentHash == _contentHash && keccak256(ipfsHash) == keccak256(_ipfsHash) && transcriptHash == _transcriptHash;
}
function validateIpfsDoc(Document storage self, bytes _ipfsHash) public view returns(bool) {
bytes storage ipfsHash = self.ipfsHash;
return keccak256(ipfsHash) == keccak256(_ipfsHash);
}
function validateContentHash(Document storage self, bytes32 _contentHash) public view returns(bool) {
bytes32 contentHash = self.contentHash;
return contentHash == _contentHash;
}
function validateTranscriptHash(Document storage self, bytes32 _transcriptHash) public view returns(bool) {
bytes32 transcriptHash = self.transcriptHash;
return transcriptHash == _transcriptHash;
}
}