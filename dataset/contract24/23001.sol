pragma solidity ^0.4.18;
contract ERC20Basic {
function totalSupply() public view returns (uint256);
function balanceOf(address who) public view returns (uint256);
function transfer(address to, uint256 value) public returns (bool);
event Transfer(address indexed from, address indexed to, uint256 value);
}
contract Ownable {
address public owner;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
function Ownable() public {
owner=msg.sender;
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
contract BasicToken is ERC20Basic {
using SafeMath for uint256;
mapping(address => uint256) balances;
uint256 totalSupply_;
function totalSupply() public view returns (uint256) {
return totalSupply_;
}
function transfer(address _to, uint256 _value) public returns (bool) {
require(_to != address(0));
require(_value <= balances[msg.sender]);
balances[msg.sender] = balances[msg.sender].sub(_value);
balances[_to] = balances[_to].add(_value);
Transfer(msg.sender, _to, _value);
return true;
}
function balanceOf(address _owner) public view returns (uint256 balance) {
return balances[_owner];
}
}
contract ERC20 is ERC20Basic {
function allowance(address owner, address spender) public view returns (uint256);
function transferFrom(address from, address to, uint256 value) public returns (bool);
function approve(address spender, uint256 value) public returns (bool);
event Approval(address indexed owner, address indexed spender, uint256 value);
}
contract StandardToken is ERC20, BasicToken ,Ownable {
mapping (address => mapping (address => uint256)) internal allowed;
function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
require(_to != address(0));
require(_value <= balances[_from]);
require(_value <= allowed[_from][msg.sender]);
balances[_from] = balances[_from].sub(_value);
balances[_to] = balances[_to].add(_value);
allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
Transfer(_from, _to, _value);
return true;
}
function approve(address _spender, uint256 _value) public returns (bool) {
allowed[msg.sender][_spender] = _value;
Approval(msg.sender, _spender, _value);
return true;
}
function allowance(address _owner, address _spender) public view returns (uint256) {
return allowed[_owner][_spender];
}
function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
return true;
}
function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
uint oldValue = allowed[msg.sender][_spender];
if (_subtractedValue > oldValue) {
allowed[msg.sender][_spender] = 0;
} else {
allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
}
Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
return true;
}
}
contract MintableToken is StandardToken {
event Mint(address indexed to, uint256 amount);
event MintFinished();
bool public mintingFinished = false;
modifier canMint() {
require(!mintingFinished);
_;
}
function mint(address _to, uint256 _amount) onlyOwner canMint public returns (bool) {
totalSupply_ = totalSupply_.add(_amount);
balances[_to] = balances[_to].add(_amount);
Mint(_to, _amount);
Transfer(address(0), _to, _amount);
return true;
}
function finishMinting() onlyOwner canMint public returns (bool) {
mintingFinished = true;
MintFinished();
return true;
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
contract Crowdsale {
using SafeMath for uint256;
MintableToken public token;
uint256 public startTime;
uint256 public endTime;
address public wallet;
uint256 public rate;
uint256 public weiRaised;
event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);
function Crowdsale(uint256 _startTime, uint256 _endTime, uint256 _rate, address _wallet) public {
require(_startTime >= now);
require(_endTime >= _startTime);
require(_rate > 0);
require(_wallet != address(0));
token = createTokenContract();
startTime = _startTime;
endTime = _endTime;
rate = _rate;
wallet = _wallet;
}
function () external payable {
buyTokens(msg.sender);
}
function buyTokens(address beneficiary) public payable {
require(beneficiary != address(0));
require(validPurchase());
uint256 weiAmount = msg.value;
uint256 tokens = getTokenAmount(weiAmount);
weiRaised = weiRaised.add(weiAmount);
token.mint(beneficiary, tokens);
TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);
forwardFunds();
}
function hasEnded() public view returns (bool) {
return now > endTime;
}
function createTokenContract() internal returns (MintableToken) {
return new MintableToken();
}
function getTokenAmount(uint256 weiAmount) internal view returns(uint256) {
return weiAmount.mul(rate);
}
function forwardFunds() internal {
wallet.transfer(msg.value);
}
function validPurchase() internal view returns (bool) {
bool withinPeriod = now >= startTime && now <= endTime;
bool nonZeroPurchase = msg.value != 0;
return withinPeriod && nonZeroPurchase;
}
}
contract FinalizableCrowdsale is Crowdsale, Ownable {
using SafeMath for uint256;
bool public isFinalized = false;
event Finalized();
function finalize() onlyOwner public {
require(!isFinalized);
require(hasEnded());
finalization();
Finalized();
isFinalized = true;
}
function finalization() internal {
}
}
contract RefundVault is Ownable {
using SafeMath for uint256;
enum State { Active, Refunding, Closed }
mapping (address => uint256) public deposited;
address public wallet;
State public state;
event Closed();
event RefundsEnabled();
event Refunded(address indexed beneficiary, uint256 weiAmount);
function RefundVault(address _wallet) public {
require(_wallet != address(0));
wallet = _wallet;
state = State.Active;
}
function deposit(address investor) onlyOwner public payable {
require(state == State.Active);
deposited[investor] = deposited[investor].add(msg.value);
}
function close() onlyOwner public {
require(state == State.Active);
state = State.Closed;
Closed();
wallet.transfer(this.balance);
}
function enableRefunds() onlyOwner public {
require(state == State.Active);
state = State.Refunding;
RefundsEnabled();
}
function refund(address investor) public {
require(state == State.Refunding);
uint256 depositedValue = deposited[investor];
deposited[investor] = 0;
investor.transfer(depositedValue);
Refunded(investor, depositedValue);
}
}
contract RefundableCrowdsale is FinalizableCrowdsale {
using SafeMath for uint256;
uint256 public goal;
RefundVault public vault;
function RefundableCrowdsale(uint256 _goal) public {
require(_goal > 0);
vault = new RefundVault(wallet);
goal = _goal;
}
function claimRefund() public {
require(isFinalized);
require(!goalReached());
vault.refund(msg.sender);
}
function goalReached() public view returns (bool) {
return weiRaised >= goal;
}
function finalization() internal {
if (goalReached()) {
vault.close();
}
else {
vault.enableRefunds();
}
super.finalization();
}
function forwardFunds() internal {
vault.deposit.value(msg.value)(msg.sender);
}
}
contract CappedCrowdsale is Crowdsale {
using SafeMath for uint256;
uint256 public cap;
function CappedCrowdsale(uint256 _cap) public {
require(_cap > 0);
cap = _cap;
}
function hasEnded() public view returns (bool) {
bool capReached = weiRaised >= cap;
return capReached || super.hasEnded();
}
function validPurchase() internal view returns (bool) {
bool withinCap = weiRaised.add(msg.value) <= cap;
return withinCap && super.validPurchase();
}
}
contract Toplancer is MintableToken {
string public constant name = "Toplancer";
string public constant symbol = "TLC";
uint8 public constant decimals = 18;
}
contract Allocation is Ownable {
using SafeMath for uint;
uint256 public unlockedAt;
Toplancer tlc;
mapping (address => uint) founderAllocations;
uint256 tokensCreated = 0;
uint256 public constant decimalFactor = 10 ** uint256(18);
uint256 constant public FounderAllocationTokens = 840000000*decimalFactor;
address public founderStorageVault = 0x97763051c517DD3aBc2F6030eac6Aa04576E05E1;
function TeamAllocation() {
tlc = Toplancer(msg.sender);
unlockedAt = now;
founderAllocations[founderStorageVault] = FounderAllocationTokens;
}
function getTotalAllocation() returns (uint256){
return (FounderAllocationTokens);
}
function unlock() external payable {
require (now >=unlockedAt);
if (tokensCreated == 0) {
tokensCreated = tlc.balanceOf(this);
}
tlc.transfer(founderStorageVault, tokensCreated);
}
}
contract TLCMarketCrowdsale is RefundableCrowdsale,CappedCrowdsale {
enum State {PRESALE, PUBLICSALE}
State public state;
uint256 public constant decimalFactor = 10 ** uint256(18);
uint256 public constant _totalSupply = 2990000000 *decimalFactor;
uint256 public presaleCap = 200000000 *decimalFactor;
uint256 public soldTokenInPresale;
uint256 public publicSaleCap = 1950000000 *decimalFactor;
uint256 public soldTokenInPublicsale;
uint256 public distributionSupply = 840000000 *decimalFactor;
Allocation allocation;
mapping (address => uint256) public investedAmountOf;
uint256 public investorCount;
uint256 public minContribAmount = 0.1 ether;
function TLCMarketCrowdsale(uint256 _startTime, uint256 _endTime, uint256 _rate, address _wallet, uint256 _goal, uint256 _cap)
Crowdsale (_startTime, _endTime, _rate, _wallet)  RefundableCrowdsale(_goal*decimalFactor) CappedCrowdsale(_cap*decimalFactor)
{
state = State.PRESALE;
}
function createTokenContract() internal returns (MintableToken) {
return new Toplancer();
}
function buyTokens(address beneficiary) public payable {
require(publicSaleCap > 0);
require(validPurchase());
uint256  weiAmount = msg.value;
uint256 tokens = weiAmount.mul(rate);
uint256 Bonus = tokens.mul(getTimebasedBonusRate()).div(100);
tokens = tokens.add(Bonus);
if (state == State.PRESALE) {
assert (soldTokenInPresale + tokens <= presaleCap);
soldTokenInPresale = soldTokenInPresale.add(tokens);
presaleCap=presaleCap.sub(tokens);
} else if(state==State.PUBLICSALE){
assert (soldTokenInPublicsale + tokens <= publicSaleCap);
soldTokenInPublicsale = soldTokenInPublicsale.add(tokens);
publicSaleCap=publicSaleCap.sub(tokens);
}
if(investedAmountOf[beneficiary] == 0) {
investorCount++;
}
investedAmountOf[beneficiary] = investedAmountOf[beneficiary].add(weiAmount);
forwardFunds();
weiRaised = weiRaised.add(weiAmount);
token.mint(beneficiary, tokens);
TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);
}
function validPurchase() internal constant returns (bool) {
bool minContribution = minContribAmount <= msg.value;
bool withinPeriod = now >= startTime && now <= endTime;
bool nonZeroPurchase = msg.value != 0;
bool Publicsale =publicSaleCap !=0;
return withinPeriod && minContribution && nonZeroPurchase && Publicsale;
}
function getNow() public constant returns (uint) {
return (now);
}
function getTimebasedBonusRate() internal constant returns (uint256) {
uint256 bonusRate = 0;
if (state == State.PRESALE) {
bonusRate = 100;
} else {
uint256 nowTime = getNow();
uint256 bonusFirstWeek = startTime + (7 days * 1000);
uint256 bonusSecondWeek = bonusFirstWeek + (7 days * 1000);
uint256 bonusThirdWeek = bonusSecondWeek + (7 days * 1000);
uint256 bonusFourthWeek = bonusThirdWeek + (7 days * 1000);
if (nowTime <= bonusFirstWeek) {
bonusRate = 30;
} else if (nowTime <= bonusSecondWeek) {
bonusRate = 30;
} else if (nowTime <= bonusThirdWeek) {
bonusRate = 15;
} else if (nowTime <= bonusFourthWeek) {
bonusRate = 15;
}
}
return bonusRate;
}
function startPublicsale(uint256 _startTime, uint256 _endTime) public onlyOwner {
require(state == State.PRESALE && _endTime >= _startTime);
state = State.PUBLICSALE;
startTime = _startTime;
endTime = _endTime;
publicSaleCap=publicSaleCap.add(presaleCap);
presaleCap=presaleCap.sub(presaleCap);
}
function finalization() internal {
if(goalReached()){
allocation = new Allocation();
token.mint(address(allocation), distributionSupply);
distributionSupply=distributionSupply.sub(distributionSupply);
}
token.finishMinting();
super.finalization();
}
function changeStarttime(uint256 _startTime) public onlyOwner {
require(_startTime != 0);
startTime = _startTime;
}
function changeEndtime(uint256 _endTime) public onlyOwner {
require(_endTime != 0);
endTime = _endTime;
}
function changeRate(uint256 _rate) public onlyOwner {
require(_rate != 0);
rate = _rate;
}
function changeWallet (address _wallet) onlyOwner  {
wallet = _wallet;
}
}