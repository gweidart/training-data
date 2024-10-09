pragma solidity ^0.4.18;
contract GeneScienceInterface {
function isGeneScience() public pure returns (bool);
function mixGenes(uint256 genes1, uint256 genes2, uint256 targetBlock) public returns (uint256);
}
contract KittiesDNA {
GeneScienceInterface geneScience;
function KittiesDNA() public {
geneScience = GeneScienceInterface(0xf97e0A5b616dfFC913e72455Fde9eA8bBe946a2B);
}
function mixGenes(uint256 matronGenes, uint256 sireGenes, uint256 targetBlock) public returns (uint256) {
return geneScience.mixGenes(matronGenes, sireGenes, targetBlock);
}
}