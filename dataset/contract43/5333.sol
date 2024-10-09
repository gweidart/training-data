pragma solidity ^0.4.25;
interface HourglassInterface {
function() payable external;
function buy(address _investorAddress) payable external returns(uint256);
function reinvest() external;
function exit() payable external;
function withdraw() payable external;
function sell(uint256 _amountOfTokens) external;
function transfer(address _toAddress, uint256 _amountOfTokens) external returns(bool);
function totalEthereumBalance() external;
function totalSupply() external;
function myTokens() external returns(uint256);
function myDividends(bool _includeReferralBonus) external;
function balanceOf(address _investorAddress) external pure returns(uint256);
function dividendsOf(address _investorAddress) external;
function sellPrice() payable external returns (uint256);
function buyPrice() external;
function calculateTokensReceived(uint256 _ethereumToSpend) external;
function calculateEthereumReceived(uint256 _tokensToSell) external returns(uint256);
function purchaseTokens(uint256 _incomingEthereum, address _referredBy) external;
}
contract CryptoMinerFund {
using ItsJustBasicMathBro
for uint;
address constant _parojectMarketing = 0x3d3B4a38caD44c2B77DAAC1D746124D2e2b8a27C;
HourglassInterface constant CMTContract = HourglassInterface(0x0a97094c19295E320D5121d72139A150021a2702);
mapping(address => uint) public walletDeposits;
mapping(address => uint) public walletTimer;
mapping(address => uint) public withdrawedAmounts;
uint constant _masterTaxOnInvestment = 8;
uint constant payOutInterval = 1 hours;
uint constant basePercent = 270;
uint constant lowPercent = 320;
uint constant averagePercent = 375;
uint constant highPercent = 400;
uint constant phasePreperation = 500 ether;
uint constant phaseEngineStart = 1500 ether;
uint constant phaseLiftoff = 4000 ether;
function() external payable {
if (msg.value > 0) {
if (now > walletTimer[msg.sender].add(payOutInterval)) {
makeDeposit();
}
} else {
requestPayDay();
}
}
function makeDeposit() internal{
if (msg.value > 0) {
if (now > walletTimer[msg.sender].add(payOutInterval)) {
walletDeposits[msg.sender] = walletDeposits[msg.sender].add(msg.value);
walletTimer[msg.sender] = now;
startDivDistribution();
}
}
}
function requestPayDay() internal{
uint payDay = 0;
if(walletDeposits[msg.sender].mul(92).div(100) > getAvailablePayout()){
payDay = walletDeposits[msg.sender].mul(92).div(100);
withdrawedAmounts[msg.sender] = 0;
walletDeposits[msg.sender] = 0;
walletTimer[msg.sender] = 0;
msg.sender.transfer(payDay);
} else{
payDay = getAvailablePayout();
withdrawedAmounts[msg.sender] += payDay;
walletDeposits[msg.sender] = 0;
walletTimer[msg.sender] = 0;
msg.sender.transfer(payDay);
}
}
function startDivDistribution() internal{
CMTContract.buy.value(msg.value.mul(_masterTaxOnInvestment).div(100))(_parojectMarketing);
CMTContract.sell(totalEthereumBalance());
CMTContract.reinvest();
}
function getAvailablePayout() public view returns(uint) {
uint percent = resolvePercentRate();
uint interestRate = now.sub(walletTimer[msg.sender]).div(payOutInterval);
uint baseRate = walletDeposits[msg.sender].mul(percent).div(100000);
uint withdrawAmount = baseRate.mul(interestRate);
if(withdrawAmount > walletDeposits[msg.sender].mul(2)){
return walletDeposits[msg.sender].mul(2);
}
return (withdrawAmount);
}
function resolvePercentRate() public view returns(uint) {
uint balance = address(this).balance;
if (balance < phasePreperation) {
return (basePercent);
}
if (balance >= phasePreperation && balance < phaseEngineStart) {
return (lowPercent);
}
if (balance >= phaseEngineStart && balance < phaseLiftoff) {
return (averagePercent);
}
if (balance >= phaseLiftoff) {
return (highPercent);
}
}
function totalEthereumBalance() public view returns (uint) {
return address(this).balance;
}
}
library ItsJustBasicMathBro {
function mul(uint a, uint b) internal pure returns(uint) {
uint c = a * b;
assert(a == 0 || c / a == b);
return c;
}
function div(uint a, uint b) internal pure returns(uint) {
uint c = a / b;
return c;
}
function sub(uint a, uint b) internal pure returns(uint) {
assert(b <= a);
return a - b;
}
function add(uint a, uint b) internal pure returns(uint) {
uint c = a + b;
assert(c >= a);
return c;
}
}