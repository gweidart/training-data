pragma solidity ^0.4.19;
contract LemonToken {
function balanceOf(address who) public constant returns (uint256);
function transfer(address to, uint256 value) public returns (bool);
}
contract Ownable {
address public owner;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
function Ownable() {
owner = msg.sender;
}
modifier onlyOwner() {
require(msg.sender == owner);
_;
}
function transferOwnership(address newOwner) onlyOwner public {
require(newOwner != address(0));
OwnershipTransferred(owner, newOwner);
owner = newOwner;
}
}
contract LemonSelfDrop is Ownable {
LemonToken public LemonContract;
uint8 public dropNumber;
uint256 public LemonsDroppedToTheWorld;
uint256 public LemonsRemainingToDrop;
uint256 public holderAmount;
uint256 public basicReward;
uint256 public donatorReward;
uint256 public holderReward;
uint8 public totalDropTransactions;
mapping (address => uint8) participants;
function LemonSelfDrop () {
address c = 0x2089899d03607b2192afb2567874a3f287f2f1e4;
LemonContract = LemonToken(c);
dropNumber = 1;
LemonsDroppedToTheWorld = 0;
LemonsRemainingToDrop = 0;
basicReward = 50000000000;
donatorReward = 50000000000;
holderReward = 50000000000;
holderAmount = 5000000000000;
totalDropTransactions = 0;
}
function() payable {
require (participants[msg.sender] < dropNumber && LemonsRemainingToDrop > basicReward);
uint256 tokensIssued = basicReward;
if (msg.value > 0)
tokensIssued += donatorReward;
if (LemonContract.balanceOf(msg.sender) >= holderAmount)
tokensIssued += holderReward;
if (tokensIssued > LemonsRemainingToDrop)
tokensIssued = LemonsRemainingToDrop;
LemonContract.transfer(msg.sender, tokensIssued);
participants[msg.sender] = dropNumber;
LemonsRemainingToDrop -= tokensIssued;
LemonsDroppedToTheWorld += tokensIssued;
totalDropTransactions += 1;
}
function participant(address part) public constant returns (uint8 participationCount) {
return participants[part];
}
function setDropNumber(uint8 dropN) public onlyOwner {
dropNumber = dropN;
LemonsRemainingToDrop = LemonContract.balanceOf(this);
}
function setHolderAmount(uint256 amount) public onlyOwner {
holderAmount = amount;
}
function setRewards(uint256 basic, uint256 donator, uint256 holder) public onlyOwner {
basicReward = basic;
donatorReward = donator;
holderReward = holder;
}
function withdrawAll() public onlyOwner {
owner.transfer(this.balance);
}
function withdrawLemonCoins() public onlyOwner {
LemonContract.transfer(owner, LemonContract.balanceOf(this));
LemonsRemainingToDrop = 0;
}
function updateLemonCoinsRemainingToDrop() public {
LemonsRemainingToDrop = LemonContract.balanceOf(this);
}
}