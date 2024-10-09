pragma solidity ^0.4.0;
contract HashRank {
mapping (bytes => address[]) approved;
function approve(bytes doc) public {
approved[doc].push(msg.sender);
}
function rankOf(bytes doc) public constant returns (uint256) {
uint256 rank = 0;
uint256 len = approved[doc].length;
for (uint256 i = 0; i < len; ++i) {
address voter = approved[doc][i];
bool voted = false;
for (uint256 j = 0; j < i; ++j) {
voted = voted || approved[doc][j] == voter;
}
if (!voted) {
rank += voter.balance;
}
}
return rank;
}
}