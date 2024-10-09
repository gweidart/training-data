pragma solidity ^0.4.23;
contract RouletteRules {
function getTotalBetAmount(bytes32 first16, bytes32 second16) public pure returns(uint totalBetAmount);
function getBetResult(bytes32 betTypes, bytes32 first16, bytes32 second16, uint wheelResult) public view returns(uint wonAmount);
}
contract OracleRoulette {