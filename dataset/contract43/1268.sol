pragma solidity ^0.4.18;
interface token {
function transfer(address receiver, uint amount) public;
}
contract withdrawToken {
function transfer(address _to, uint _value) external returns (bool success);
function balanceOf(address _owner) external constant returns (uint balance);
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
contract Crowdsale {
using SafeMath for uint256;
mapping(address => uint256) public contributionByAddress;
event FundTransfer(address backer, uint amount, bool isContribution);
modifier onlyOwner() {
require(msg.sender == owner);
_;
}
function Crowdsale(
uint saleStartTime,
address ownerAddress,
address operationsAddress,
address indexAddress,
address rewardTokenAddress
) public {
}
function () public payable {
uint256 amount = msg.value;
require(now > startTime);
require(amount <= 1000 ether);
contributionByAddress[msg.sender] = contributionByAddress[msg.sender].add(amount);
amountRaised = amountRaised.add(amount);
amountRaisedPhase = amountRaisedPhase.add(amount);
tokensSold = tokensSold.add(amount.mul(10**18).div(phase1Price));
tokenReward.transfer(msg.sender, amount.mul(10**18).div(phase1Price));
FundTransfer(msg.sender, amount, true);
}
contributionByAddress[msg.sender] = contributionByAddress[msg.sender].add(amount);
amountRaised = amountRaised.add(amount);
amountRaisedPhase = amountRaisedPhase.add(amount);
tokensSold = tokensSold.add(amount.mul(10**18).div(phase2Price));
tokenReward.transfer(msg.sender, amount.mul(10**18).div(phase2Price));
FundTransfer(msg.sender, amount, true);
}
contributionByAddress[msg.sender] = contributionByAddress[msg.sender].add(amount);
amountRaised = amountRaised.add(amount);
amountRaisedPhase = amountRaisedPhase.add(amount);
tokensSold = tokensSold.add(amount.mul(10**18).div(phase3Price));
tokenReward.transfer(msg.sender, amount.mul(10**18).div(phase3Price));
FundTransfer(msg.sender, amount, true);
}
contributionByAddress[msg.sender] = contributionByAddress[msg.sender].add(amount);
amountRaised = amountRaised.add(amount);
amountRaisedPhase = amountRaisedPhase.add(amount);
tokensSold = tokensSold.add(amount.mul(10**18).div(phase4Price));
tokenReward.transfer(msg.sender, amount.mul(10**18).div(phase4Price));
FundTransfer(msg.sender, amount, true);
}
contributionByAddress[msg.sender] = contributionByAddress[msg.sender].add(amount);
amountRaised = amountRaised.add(amount);
amountRaisedPhase = amountRaisedPhase.add(amount);
tokensSold = tokensSold.add(amount.mul(10**18).div(phase5Price));
tokenReward.transfer(msg.sender, amount.mul(10**18).div(phase5Price));
FundTransfer(msg.sender, amount, true);
}
contributionByAddress[msg.sender] = contributionByAddress[msg.sender].add(amount);
amountRaised = amountRaised.add(amount);
amountRaisedPhase = amountRaisedPhase.add(amount);
tokensSold = tokensSold.add(amount.mul(10**18).div(phase6Price));
tokenReward.transfer(msg.sender, amount.mul(10**18).div(phase6Price));
FundTransfer(msg.sender, amount, true);
}
}
function withdrawTokens(address tokenContract) external onlyOwner {
withdrawToken tc = withdrawToken(tokenContract);
tc.transfer(owner, tc.balanceOf(this));
}
function withdrawEther() external onlyOwner {
uint256 total = this.balance;
uint256 operationsSplit = 40;
uint256 indexSplit = 60;
operations.transfer(total * operationsSplit / 100);
index.transfer(total * indexSplit / 100);
}
}