contract owned {
address public owner;
function owned() {
owner = msg.sender;
}
function setOwner(address _new) onlyOwner {
owner = _new;
}
modifier onlyOwner {
if (msg.sender != owner) throw;
}
}
contract TheGrid is owned {
uint public gameId = 1;
uint public size = 4;
uint public nextsize = 5;
uint public empty = 16;
uint public benefitMicros = 24900;
uint public price = 100 finney;
uint public startPrice = 100 finney;
uint public priceIncrease = 15000;
uint public win;
mapping(address => uint) public pendingPayouts;
uint public totalPayouts;
mapping(address => uint) public balanceOf;
uint public totalSupply;
address[] public theGrid;
address[] public players;
address public lastPlayer;
uint public timeout = 6 hours;
uint public timeoutAt;
event GameEnded(uint indexed gameId, uint win, uint totalPoints);
event GameStart(uint indexed gameId, uint size);
event PositionBought(uint indexed gameId, uint indexed moveNo,
uint where, address who, uint pointsGained,
uint etherPaid);
event Timeout(uint indexed gameId, uint indexed moveNo);
event Collect(address indexed who, uint value);
function TheGrid() {
theGrid.length = empty;
timeoutAt = now + timeout;
GameStart(gameId, size);
}
function directionCount(int _x, int _y, int _dx, int _dy)
internal returns (uint) {
var found = uint(0);
var s = int(size);
_x += _dx;
_y += _dy;
while (_x < s && _y < s && _x >= 0 && _y >= 0) {
if (theGrid[getIndex(uint(_x), uint(_y))] == msg.sender) {
found ++;
} else {
break;
}
_x += _dx;
_y += _dy;
}
return found;
}
function buy(uint _x, uint _y) {
if (theGrid[getIndex(_x, _y)] != 0) throw;
if (msg.sender == lastPlayer) throw;
if (now > timeoutAt) {
price = price / 2;
if (price < 1 finney) price = 1 finney;
nextsize = 3;
Timeout(gameId, size*size - empty + 1);
}
if (msg.value < price) {
throw;
} else {
var benefit = price / 1000000 * benefitMicros;
if (pendingPayouts[owner] + benefit < pendingPayouts[owner]) throw;
pendingPayouts[owner] += benefit;
if (pendingPayouts[msg.sender] + msg.value - price < pendingPayouts[msg.sender]) throw;
pendingPayouts[msg.sender] += msg.value - price;
if (totalPayouts + msg.value - price + benefit < totalPayouts) throw;
totalPayouts += msg.value - price + benefit;
if (win + price - benefit < win) throw;
win += price - benefit;
}
empty --;
theGrid[getIndex(_x, _y)] = msg.sender;
var found = uint(0);
if (balanceOf[msg.sender] == 0) {
players.push(msg.sender);
found = 1;
}
var x = int(_x);
var y = int(_y);
var a = 1 + directionCount(x, y, 1, 0) + directionCount(x, y, -1, 0);
if (a >= 3) {
found += a * a;
}
a = 1 + directionCount(x, y, 1, 1) + directionCount(x, y, -1, -1);
if (a >= 3) {
found += a * a;
}
a = 1 + directionCount(x, y, 0, 1) + directionCount(x, y, 0, -1);
if (a >= 3) {
found += a * a;
}
a = 1 + directionCount(x, y, 1, -1) + directionCount(x, y, -1, 1);
if (a >= 3) {
found += a * a;
}
if (balanceOf[msg.sender] + found < balanceOf[msg.sender]) throw;
balanceOf[msg.sender] += found;
if (totalSupply + found < totalSupply) throw;
totalSupply += found;
PositionBought(gameId, size*size-empty, getIndex(_x, _y), msg.sender, found, price);
price = price / 1000000 * (1000000 + priceIncrease);
timeoutAt = now + timeout;
lastPlayer = msg.sender;
if (empty == 0) nextRound();
}
function collect() {
var balance = pendingPayouts[msg.sender];
pendingPayouts[msg.sender] = 0;
totalPayouts -= balance;
if (!msg.sender.send(balance)) throw;
Collect(msg.sender, balance);
}
function getIndex(uint _x, uint _y) internal returns (uint) {
if (_x >= size) throw;
if (_y >= size) throw;
return _x * size + _y;
}
function nextRound() internal {
GameEnded(gameId, win, totalSupply);
if (totalPayouts + win < totalPayouts) throw;
totalPayouts += win;
var share = totalSupply == 0 ? 0 : win / totalSupply;
for (var i = 0; i < players.length; i++) {
var amount = share * balanceOf[players[i]];
totalSupply -= balanceOf[players[i]];
balanceOf[players[i]] = 0;
if (pendingPayouts[players[i]] + amount < pendingPayouts[players[i]]) throw;
pendingPayouts[players[i]] += amount;
win -= amount;
}
delete theGrid;
delete players;
lastPlayer = 0x0;
size = nextsize;
if (nextsize < 64) nextsize ++;
gameId ++;
empty = size * size;
theGrid.length = empty;
price = startPrice;
GameStart(gameId, size);
}
}