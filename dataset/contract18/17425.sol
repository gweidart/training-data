pragma solidity 0.4.23;
contract RandoLotto {
uint256 PrizePool;
uint256 highScore;
address currentWinner;
uint256 lastTimestamp;
constructor () public {
highScore = 0;
currentWinner = msg.sender;
lastTimestamp = now;
}
function () public payable {
require(msg.sender == tx.origin);
require(msg.value >= 0.001 ether);
uint256 randomNumber = uint256(keccak256(blockhash(block.number - 1)));
if (randomNumber > highScore) {
currentWinner = msg.sender;
lastTimestamp = now;
}
}
function claimWinnings() public {
require(now > lastTimestamp + 1 days);
require(msg.sender == currentWinner);
msg.sender.transfer(address(this).balance);
}
}
library SafeMath {
function mul(uint256 a, uint256 b) internal pure returns (uint256) {
if (a == 0) {
return 0;
}
uint256 c = a * b;
assert(c / a == b);
return c;
}
function div(uint256 a, uint256 b) internal pure returns (uint256) {
uint256 c = a / b;
return c;
}
function sub(uint256 a, uint256 b) internal pure returns (uint256) {
assert(b <= a);
return a - b;
}
function add(uint256 a, uint256 b) internal pure returns (uint256) {
uint256 c = a + b;
assert(c >= a);
return c;
}
}