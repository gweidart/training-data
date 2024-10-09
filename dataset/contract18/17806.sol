pragma solidity ^0.4.21;
contract ProofOfLongHodl {
using SafeMath for uint256;
event Deposit(address user, uint amount);
event Withdraw(address user, uint amount);
event Claim(address user, uint dividends);
event Reinvest(address user, uint dividends);
address owner;
mapping(address => bool) preauthorized;
bool gameStarted;
uint constant depositTaxDivisor = 5;
uint constant withdrawalTaxDivisor = 5;
uint constant lotteryFee = 20;
mapping(address => uint) public investment;
mapping(address => uint) public stake;
uint public totalStake;
uint stakeValue;
mapping(address => uint) dividendCredit;
mapping(address => uint) dividendDebit;
function ProofOfLongHodl() public {
owner = msg.sender;
preauthorized[owner] = true;
}
function preauthorize(address _user) public {
require(msg.sender == owner);
preauthorized[_user] = true;
}
function startGame() public {
require(msg.sender == owner);
gameStarted = true;
}
function depositHelper(uint _amount) private {
require(_amount > 0);
uint _tax = _amount.div(depositTaxDivisor);
uint _lotteryPool = _amount.div(lotteryFee);
uint _amountAfterTax = _amount.sub(_tax).sub(_lotteryPool);
uint weeklyPoolFee = _lotteryPool.div(5);
uint dailyPoolFee = _lotteryPool.sub(weeklyPoolFee);
uint tickets = _amount.div(TICKET_PRICE);
weeklyPool = weeklyPool.add(weeklyPoolFee);
dailyPool = dailyPool.add(dailyPoolFee);
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
return a / b;
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