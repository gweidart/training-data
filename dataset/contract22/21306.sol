pragma solidity ^0.4.21;
contract Dice{
function verifySeed(bytes32 seed, bytes32 seedHash) pure public returns (bool correct){
return keccak256(seed) == seedHash;
}
function determineOutcome(uint bet, uint number, uint limit, bool rollBelow) public pure returns(uint win, uint loss){
require(limit > 0 && limit <= 999);
if(rollBelow && number < limit){
win = bet*1000/limit - bet;
}
else if(!rollBelow && number > limit){
win = bet*1000/(1000-limit) - bet;
}
else{
loss = bet;
}
}
}