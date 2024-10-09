pragma solidity ^0.4.13;
contract Test {
address public owner;
uint8 public maxResult;
function Test() {
owner = msg.sender;
maxResult = 100;
}
function() {
revert();
}
function getResult(uint index) constant returns (uint8 a)
{
bytes32 blockHash = block.blockhash(index);
bytes32 shaPlayer = sha3(owner, blockHash);
a = uint8(uint256(shaPlayer) % maxResult);
}
function getResultblockHash(bytes32 blockHash) constant returns (uint8 a)
{
bytes32 shaPlayer = sha3(owner, blockHash);
a = uint8(uint256(shaPlayer) % maxResult);
}
}