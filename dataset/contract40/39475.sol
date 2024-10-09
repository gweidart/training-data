pragma solidity 0.4.4;
contract Token {
function transfer(address to, uint256 value) returns (bool success);
}
contract DutchAuction {
event BidSubmission(address indexed sender, uint256 amount);
uint constant public MAX_TOKENS_SOLD = 9000000 * 10**18;
uint constant public WAITING_PERIOD = 7 days;
Token public gnosisToken;
address public wallet;
address public owner;
uint public ceiling;
uint public priceFactor;
uint public startBlock;
uint public endTime;
uint public totalReceived;
uint public finalPrice;
mapping (address => uint) public bids;
Stages public stage;
enum Stages {
AuctionDeployed,
AuctionStarted,
AuctionEnded,
TradingStarted
}
modifier atStage(Stages _stage) {
if (stage != _stage)
throw;
_;
}
modifier isOwner() {
if (msg.sender != owner)
throw;
_;
}
modifier isWallet() {
if (msg.sender != wallet)
throw;
_;
}
modifier timedTransitions() {
if (stage == Stages.AuctionStarted && calcTokenPrice() <= calcStopPrice())
finalizeAuction();
if (stage == Stages.AuctionEnded && now > endTime + WAITING_PERIOD)
stage = Stages.TradingStarted;
_;
}
function DutchAuction(address _wallet, uint _ceiling, uint _priceFactor)
public
{
if (_wallet == 0 || _ceiling == 0 || _priceFactor == 0)
throw;
owner = msg.sender;
wallet = _wallet;
ceiling = _ceiling;
priceFactor = _priceFactor;
stage = Stages.AuctionDeployed;
}
function setup(address _gnosisToken)
public
isOwner
{
if (address(gnosisToken) != 0 || _gnosisToken == 0)
throw;
gnosisToken = Token(_gnosisToken);
}
function startAuction()
public
isWallet
atStage(Stages.AuctionDeployed)
{
stage = Stages.AuctionStarted;
startBlock = block.number;
}
function changeSettings(uint _ceiling, uint _priceFactor)
public
isWallet
atStage(Stages.AuctionDeployed)
{
ceiling = _ceiling;
priceFactor = _priceFactor;
}
function calcCurrentTokenPrice()
public
timedTransitions
returns (uint)
{
if (stage == Stages.AuctionEnded || stage == Stages.TradingStarted)
return finalPrice;
return calcTokenPrice();
}
function updateStage()
public
timedTransitions
returns (Stages)
{
return stage;
}
function bid(address receiver)
public
payable
timedTransitions
atStage(Stages.AuctionStarted)
returns (uint amount)
{
if (receiver == 0)
receiver = msg.sender;
amount = msg.value;
uint maxEther = (MAX_TOKENS_SOLD / 10**18) * calcTokenPrice() - totalReceived;
uint maxEtherBasedOnTotalReceived = ceiling - totalReceived;
if (maxEtherBasedOnTotalReceived < maxEther)
maxEther = maxEtherBasedOnTotalReceived;
if (amount > maxEther) {
amount = maxEther;
if (!receiver.send(msg.value - amount))
throw;
}
if (amount == 0 || !wallet.send(amount))
throw;
bids[receiver] += amount;
totalReceived += amount;
if (maxEther == amount)
finalizeAuction();
BidSubmission(receiver, amount);
}
function claimTokens(address receiver)
public
timedTransitions
atStage(Stages.TradingStarted)
{
if (receiver == 0)
receiver = msg.sender;
uint tokenCount = bids[receiver] * 10**18 / finalPrice;
bids[receiver] = 0;
gnosisToken.transfer(receiver, tokenCount);
}
function calcStopPrice()
constant
public
returns (uint)
{
return totalReceived * 10**18 / MAX_TOKENS_SOLD + 1;
}
function calcTokenPrice()
constant
public
returns (uint)
{
return priceFactor * 1 ether / (block.number - startBlock + 7500) + 1;
}
function finalizeAuction()
private
{
stage = Stages.AuctionEnded;
if (totalReceived == ceiling)
finalPrice = calcTokenPrice();
else
finalPrice = calcStopPrice();
uint soldTokens = totalReceived * 10**18 / finalPrice;
gnosisToken.transfer(wallet, MAX_TOKENS_SOLD - soldTokens);
endTime = now;
}
}