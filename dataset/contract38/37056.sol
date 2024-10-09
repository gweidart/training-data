pragma solidity ^0.4.16;
contract FuckToken { function giveBlockReward(); }
contract OldFuckMaker {
FuckToken fuck;
function OldFuckMaker(FuckToken _fuck) {
fuck = _fuck;
}
function makeOldFucks(uint32 number) {
uint32 i;
for (i = 0; i < number; i++) {
fuck.giveBlockReward();
}
}
}