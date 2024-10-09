pragma solidity ^0.4.16;
contract FarmCoin {
uint public totalSupply;
function balanceOf(address who) constant returns (uint);
function allowance(address owner, address spender) constant returns (uint);
function transfer(address to, uint value) returns (bool ok);
function transferFrom(address from, address to, uint value) returns (bool ok);
function approve(address spender, uint value) returns (bool ok);
function mintToken(address to, uint256 value) returns (uint256);
function changeTransfer(bool allowed);
}
contract FarmCoinSale {
uint256 public maxMintable;
uint256 public totalMinted;
uint256 public decimals = 18;
uint256 rate;
uint public endBlock;
uint public startBlock;
uint public exchangeRate= rate;
uint public startTime;
bool public isFunding;
FarmCoin public Token;
address public ETHWallet;
uint256 public heldTotal;
bool private configSet;
address public creator;
mapping (address => uint256) public heldTokens;
mapping (address => uint) public heldTimeline;
event Contribution(address from, uint256 amount);
event ReleaseTokens(address from, uint256 amount);
function FarmCoinSale() {
startBlock = block.number;
maxMintable = 4000000000000000000000000;
ETHWallet = 0x3b444fC8c2C45DCa5e6610E49dC54423c5Dcd86E;
isFunding = true;
creator = msg.sender;
createHeldCoins();
startTime = 1517461200000;
exchangeRate= rate;
}
uint256 constant public START = 1517461200000;
uint256 constant public END = 1522555200000;
function getRate() constant returns (uint256 rate) {
if      (now < START)            return rate = 840;
else if (now <= START +  6 days) return rate = 810;
else if (now <= START + 13 days) return rate = 780;
else if (now <= START + 20 days) return rate = 750;
else if (now <= START + 28 days) return rate = 720;
return rate = 600;
}
function setup(address TOKEN, uint endBlockTime) {
require(!configSet);
Token = FarmCoin(TOKEN);
endBlock = endBlockTime;
configSet = true;
}
function closeSale() external {
require(msg.sender==creator);
isFunding = false;
}
function contribute() external payable {
require(msg.value>0);
require(isFunding);
require(block.number <= endBlock);
uint256 amount = msg.value * exchangeRate;
uint256 total = totalMinted + amount;
require(total<=maxMintable);
totalMinted += total;
ETHWallet.transfer(msg.value);
Token.mintToken(msg.sender, amount);
Contribution(msg.sender, amount);
}
function updateRate(uint256 rate) external {
require(msg.sender==creator);
require(isFunding);
exchangeRate = rate;
}
function changeCreator(address _creator) external {
require(msg.sender==creator);
creator = _creator;
}
function changeTransferStats(bool _allowed) external {
require(msg.sender==creator);
Token.changeTransfer(_allowed);
}
function createHeldCoins() internal {
createHoldToken(msg.sender, 1000);
createHoldToken(0xd9710D829fa7c36E025011b801664009E4e7c69D, 100000000000000000000000);
createHoldToken(0xd9710D829fa7c36E025011b801664009E4e7c69D, 100000000000000000000000);
}
function createHoldToken(address _to, uint256 amount) internal {
heldTokens[_to] = amount;
heldTimeline[_to] = block.number + 0;
heldTotal += amount;
totalMinted += heldTotal;
}
function releaseHeldCoins() external {
uint256 held = heldTokens[msg.sender];
uint heldBlock = heldTimeline[msg.sender];
require(!isFunding);
require(held >= 0);
require(block.number >= heldBlock);
heldTokens[msg.sender] = 0;
heldTimeline[msg.sender] = 0;
Token.mintToken(msg.sender, held);
ReleaseTokens(msg.sender, held);
}
}