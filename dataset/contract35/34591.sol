pragma solidity ^0.4.17;
contract BokkyPooBahTrickyStickLeaderboard  {
event Solved(address indexed account, string name, string timeToSolve);
function solved(string name, string timeToSolve) public {
Solved(msg.sender, name, timeToSolve);
}
function () public {
}
}