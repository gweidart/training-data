pragma solidity ^0.4.18;
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
contract Ownable {
address public owner;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
function Ownable() public {
owner = msg.sender;
}
modifier onlyOwner() {
require(msg.sender == owner);
_;
}
function transferOwnership(address newOwner) public onlyOwner {
require(newOwner != address(0));
OwnershipTransferred(owner, newOwner);
owner = newOwner;
}
}
contract Destructible is Ownable {
function Destructible() public payable { }
function destroy() onlyOwner public {
selfdestruct(owner);
}
function destroyAndSend(address _recipient) onlyOwner public {
selfdestruct(_recipient);
}
}
contract PullPayment {
using SafeMath for uint256;
mapping(address => uint256) public payments;
uint256 public totalPayments;
function asyncSend(address dest, uint256 amount) internal {
payments[dest] = payments[dest].add(amount);
totalPayments = totalPayments.add(amount);
}
function withdrawPayments() public {
address payee = msg.sender;
uint256 payment = payments[payee];
require(payment != 0);
require(this.balance >= payment);
totalPayments = totalPayments.sub(payment);
payments[payee] = 0;
assert(payee.send(payment));
}
}
contract Bounty is PullPayment, Destructible {
bool public claimed;
mapping(address => address) public researchers;
event TargetCreated(address createdAddress);
function() external payable {
require(!claimed);
}
function createTarget() public returns(Target) {
Target target = Target(deployContract());
researchers[target] = msg.sender;
TargetCreated(target);
return target;
}
function deployContract() internal returns(address);
function claim(Target target) public {
address researcher = researchers[target];
require(researcher != 0);
require(!target.checkInvariant());
asyncSend(researcher, this.balance);
claimed = true;
}
}
contract Target {
function checkInvariant() public returns(bool);
}
contract PricingStrategy is Ownable {
uint256 public totalSoldTokens = 0;
uint256 public weiRaised = 0;
function countTokens(uint256 _value) internal returns (uint256 tokensAndBonus);
function soldInTranche(uint256 _tokensAndBonus) internal;
function getFreeTokensInTranche(uint256 _requiredTokens) internal constant returns (bool);
function isNoEmptyTranches() public constant returns(bool);
}
contract  TranchePricingStrategy is PricingStrategy, Target {
using SafeMath for uint256;
uint256 public tokensCap;
uint256 public capInWei;
struct BonusSchedule {
uint256 bonus;
uint valueForTranche;
uint rate;
}
event TokenForInvestor(uint256 _token, uint256 _tokenAndBonus, uint256 indexOfperiod);
uint tranchesCount = 0;
uint MAX_TRANCHES = 50;
BonusSchedule[] public tranches;
function TranchePricingStrategy(uint256[] _bonuses, uint[] _valueForTranches, uint[] _rates,
uint256 _capInWei, uint256 _tokensCap) public {
tokensCap = _tokensCap;
capInWei = _capInWei;
require(_bonuses.length == _valueForTranches.length && _valueForTranches.length == _rates.length);
require(_bonuses.length <= MAX_TRANCHES);
tranchesCount = _bonuses.length;
for (uint i = 0; i < _bonuses.length; i++) {
tranches.push(BonusSchedule({
bonus: _bonuses[i],
valueForTranche: _valueForTranches[i],
rate: _rates[i]
}));
}
}
function countTokens(uint256 _value) internal returns (uint256 tokensAndBonus) {
uint256 indexOfTranche = defineTranchePeriod();
require(indexOfTranche != MAX_TRANCHES + 1);
BonusSchedule currentTranche = tranches[indexOfTranche];
uint256 etherInWei = 1e18;
uint256 bonusRate = currentTranche.bonus;
uint val = msg.value * etherInWei;
uint256 oneTokenInWei = etherInWei/currentTranche.rate;
uint tokens = val / oneTokenInWei;
uint256 bonusToken = tokens.mul(bonusRate).div(100);
tokensAndBonus = tokens.add(bonusToken);
soldInTranche(tokensAndBonus);
weiRaised += _value;
TokenForInvestor(tokens, tokensAndBonus, indexOfTranche);
return tokensAndBonus;
}
function getFreeTokensInTranche(uint256 _requiredTokens) internal constant returns (bool) {
bool hasTokens = false;
uint256 indexOfTranche = defineTranchePeriod();
hasTokens = tranches[indexOfTranche].valueForTranche > _requiredTokens;
return hasTokens;
}
function soldInTranche(uint256 _tokensAndBonus) internal {
uint256 indexOfTranche = defineTranchePeriod();
require(tranches[indexOfTranche].valueForTranche >= _tokensAndBonus);
tranches[indexOfTranche].valueForTranche = tranches[indexOfTranche].valueForTranche.sub(_tokensAndBonus);
totalSoldTokens = totalSoldTokens.add(_tokensAndBonus);
}
function isNoEmptyTranches() public constant returns(bool) {
uint256 sumFreeTokens = 0;
for (uint i = 0; i < tranches.length; i++) {
sumFreeTokens = sumFreeTokens.add(tranches[i].valueForTranche);
}
bool isValid = sumFreeTokens > 0;
return isValid;
}
function defineTranchePeriod() internal constant returns (uint256) {
for (uint256 i = 0; i < tranches.length; i++) {
if (tranches[i].valueForTranche > 0) {
return i;
}
}
return MAX_TRANCHES + 1;
}
function checkInvariant() public returns(bool) {
uint256 tranchePeriod = defineTranchePeriod();
bool isTranchesDone = tranchePeriod == MAX_TRANCHES + 1;
bool isTokensCapReached = tokensCap == totalSoldTokens;
bool isWeiCapReached = weiRaised == capInWei;
bool isNoCapReached = isTranchesDone &&
(!isTokensCapReached || !isWeiCapReached);
bool isExceededCap = !isTranchesDone &&
(isTokensCapReached || isWeiCapReached);
if (isNoCapReached || isExceededCap) {
return false;
}
return true;
}
function payContract() payable {
countTokens(msg.value);
}
}
contract MowjowBounty is Bounty {
uint256[] public rates;
uint256[] public bonuses;
uint256[] public valueForTranches;
uint256 capInWei;
uint256 capInTokens;
function MowjowBounty (uint256[] _bonuses, uint256[] _valueForTranches,
uint256[] _rates, uint256 _capInWei, uint256 _capInTokens) public {
bonuses = _bonuses;
valueForTranches = _valueForTranches;
rates = _rates;
capInWei = _capInWei;
capInTokens = _capInTokens;
}
function deployContract() internal returns(address) {
return new TranchePricingStrategy(bonuses, valueForTranches, rates, capInWei, capInTokens);
}
}