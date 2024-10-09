pragma solidity ^0.4.13;
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
contract ERC20Basic {
function totalSupply() public view returns (uint256);
function balanceOf(address who) public view returns (uint256);
function transfer(address to, uint256 value) public returns (bool);
event Transfer(address indexed from, address indexed to, uint256 value);
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
contract BurnableToken is BasicToken {
event Burn(address indexed burner, uint256 value);
function burn(uint256 _value) public {
require(_value <= balances[msg.sender]);
address burner = msg.sender;
balances[burner] = balances[burner].sub(_value);
totalSupply_ = totalSupply_.sub(_value);
Burn(burner, _value);
}
}
contract ERC20 is ERC20Basic {
function allowance(address owner, address spender) public view returns (uint256);
function transferFrom(address from, address to, uint256 value) public returns (bool);
function approve(address spender, uint256 value) public returns (bool);
event Approval(address indexed owner, address indexed spender, uint256 value);
}
library SafeERC20 {
function safeTransfer(ERC20Basic token, address to, uint256 value) internal {
assert(token.transfer(to, value));
}
function safeTransferFrom(ERC20 token, address from, address to, uint256 value) internal {
assert(token.transferFrom(from, to, value));
}
function safeApprove(ERC20 token, address spender, uint256 value) internal {
assert(token.approve(spender, value));
}
}
contract StandardToken is ERC20, BasicToken {
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
contract TokenVesting is Ownable {
using SafeMath for uint256;
using SafeERC20 for ERC20Basic;
event Released(uint256 amount);
event Revoked();
address public beneficiary;
uint256 public cliff;
uint256 public start;
uint256 public duration;
bool public revocable;
mapping (address => uint256) public released;
mapping (address => bool) public revoked;
function TokenVesting(address _beneficiary, uint256 _start, uint256 _cliff, uint256 _duration, bool _revocable) public {
require(_beneficiary != address(0));
require(_cliff <= _duration);
beneficiary = _beneficiary;
revocable = _revocable;
duration = _duration;
cliff = _start.add(_cliff);
start = _start;
}
function release(ERC20Basic token) public {
uint256 unreleased = releasableAmount(token);
require(unreleased > 0);
released[token] = released[token].add(unreleased);
token.safeTransfer(beneficiary, unreleased);
Released(unreleased);
}
function revoke(ERC20Basic token) public onlyOwner {
require(revocable);
require(!revoked[token]);
uint256 balance = token.balanceOf(this);
uint256 unreleased = releasableAmount(token);
uint256 refund = balance.sub(unreleased);
revoked[token] = true;
token.safeTransfer(owner, refund);
Revoked();
}
function releasableAmount(ERC20Basic token) public view returns (uint256) {
return vestedAmount(token).sub(released[token]);
}
function vestedAmount(ERC20Basic token) public view returns (uint256) {
uint256 currentBalance = token.balanceOf(this);
uint256 totalBalance = currentBalance.add(released[token]);
if (now < cliff) {
return 0;
} else if (now >= start.add(duration) || revoked[token]) {
return totalBalance;
} else {
return totalBalance.mul(now.sub(start)).div(duration);
}
}
}
contract MintableToken is StandardToken, Ownable {
event Mint(address indexed to, uint256 amount);
event MintFinished();
bool public mintingFinished = false;
modifier canMint() {
require(!mintingFinished);
_;
}
function finishMinting() onlyOwner canMint public returns (bool) {
mintingFinished = true;
MintFinished();
return true;
}
function mint(address _to, uint256 _amount) onlyOwner canMint internal returns (bool) {
totalSupply_ = totalSupply_.add(_amount);
balances[_to] = balances[_to].add(_amount);
Mint(_to, _amount);
Transfer(address(0), _to, _amount);
return true;
}
}
contract SafePercent {
using SafeMath for uint256;
function percent(uint256 numerator, uint256 denominator, uint256 precision)
pure
public
returns(uint256)
{
uint256 _numerator = numerator.mul(10 ** (precision + 1));
uint256 quotient = ((_numerator.div(denominator)).add(5)).div(10);
return (quotient);
}
}
contract SafePayloadChecker {
modifier onlyPayloadSize(uint size) {
assert(msg.data.length == size + 4);
_;
}
}
contract PATH is MintableToken, BurnableToken, SafePayloadChecker {
uint256 public initialSupply = 400000000 * (10 ** uint256(decimals));
string public constant name    = "PATH Token";
string public constant symbol  = "PATH";
uint8 public constant decimals = 18;
uint256 public transferableStartTime;
address privatePresaleWallet;
address publicPresaleContract;
address publicCrowdsaleContract;
address pathTeamMultisig;
TokenVesting public founderTokenVesting;
modifier onlyWhenTransferEnabled()
{
if (now <= transferableStartTime) {
require(
msg.sender == privatePresaleWallet ||
msg.sender == publicPresaleContract ||
msg.sender == publicCrowdsaleContract ||
msg.sender == pathTeamMultisig
);
}
_;
}
modifier validDestination(address _addr)
{
require(_addr != address(this));
_;
}
function PATH(uint256 _transferableStartTime)
public
{
transferableStartTime = _transferableStartTime;
}
function transfer(address _to, uint256 _value)
onlyPayloadSize(32 + 32)
validDestination(_to)
onlyWhenTransferEnabled
public
returns (bool)
{
return super.transfer(_to, _value);
}
function transferFrom(address _from, address _to, uint256 _value)
onlyPayloadSize(32 + 32 + 32)
validDestination(_to)
onlyWhenTransferEnabled
public
returns (bool)
{
return super.transferFrom(_from, _to, _value);
}
function burn(uint256 _value)
onlyWhenTransferEnabled
public
{
super.burn(_value);
}
function burnFrom(address _from, uint256 _value)
onlyPayloadSize(32 + 32)
onlyWhenTransferEnabled
public
{
require(_value <= allowed[_from][msg.sender]);
require(_value <= balances[_from]);
balances[_from] = balances[_from].sub(_value);
totalSupply_ = totalSupply_.sub(_value);
Burn(_from, _value);
Transfer(_from, address(0), _value);
}
function approve(address _spender, uint256 _value)
onlyPayloadSize(32 + 32)
public
returns (bool)
{
return super.approve(_spender, _value);
}
function increaseApproval(address _spender, uint256 _addedValue)
onlyPayloadSize(32 + 32)
public
returns (bool)
{
return super.increaseApproval(_spender, _addedValue);
}
function decreaseApproval(address _spender, uint256 _subtractedValue)
onlyPayloadSize(32 + 32)
public
returns (bool)
{
return super.decreaseApproval(_spender, _subtractedValue);
}
function distributeTokens(
address _privatePresaleWallet,
address _publicPresaleContract,
address _publicCrowdsaleContract,
address _pathCompanyMultisig,
address _pathAdvisorVault,
address _pathFounderAddress
)
onlyOwner
canMint
external
{
privatePresaleWallet = _privatePresaleWallet;
publicPresaleContract = _publicPresaleContract;
publicCrowdsaleContract = _publicCrowdsaleContract;
pathTeamMultisig = _pathCompanyMultisig;
mint(_privatePresaleWallet, 200000000 * (10 ** uint256(decimals)));
mint(_publicPresaleContract, 32000000 * (10 ** uint256(decimals)));
mint(_publicCrowdsaleContract, 8000000 * (10 ** uint256(decimals)));
mint(_pathCompanyMultisig, 80000000 * (10 ** uint256(decimals)));
mint(_pathAdvisorVault, 40000000 * (10 ** uint256(decimals)));
uint256 cliff = 6 * 4 weeks;
founderTokenVesting = new TokenVesting(
_pathFounderAddress,
now,
cliff,
cliff,
false
);
mint(address(founderTokenVesting), 40000000 * (10 ** uint256(decimals)));
finishMinting();
assert(totalSupply_ == initialSupply);
}
}
contract StandardCrowdsale {
using SafeMath for uint256;
PATH public token;
uint256 public startTime;
uint256 public endTime;
address public wallet;
uint256 public rate;
uint256 public weiRaised;
event TokenPurchase(
address indexed purchaser,
address indexed beneficiary,
uint256 value,
uint256 amount
);
function StandardCrowdsale(
uint256 _startTime,
uint256 _endTime,
uint256 _rate,
address _wallet,
PATH _token
)
public
{
require(_startTime >= now);
require(_endTime >= _startTime);
require(_rate > 0);
require(_wallet != address(0));
require(_token != address(0));
startTime = _startTime;
endTime = _endTime;
rate = _rate;
wallet = _wallet;
token = _token;
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
require(token.transfer(beneficiary, tokens));
TokenPurchase(
msg.sender,
beneficiary,
weiAmount,
tokens
);
forwardFunds();
}
function hasEnded() public view returns (bool) {
return now > endTime;
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
contract FinalizableCrowdsale is StandardCrowdsale, Ownable {
using SafeMath for uint256;
bool public isFinalized = false;
event Finalized();
function finalize() public {
require(!isFinalized);
require(hasEnded());
finalization();
Finalized();
isFinalized = true;
}
function finalization() internal {
}
}
contract BurnableCrowdsale is FinalizableCrowdsale {
function finalization() internal {
token.burn(token.balanceOf(address(this)));
super.finalization();
}
}
contract RateConfigurable is StandardCrowdsale, Ownable {
modifier onlyBeforeStart() {
require(now < startTime);
_;
}
function updateRate(uint256 _rate)
onlyOwner
onlyBeforeStart
external
{
rate = _rate;
}
}
contract ReallocatableCrowdsale is StandardCrowdsale, Ownable {
function reallocate(uint256 _value)
external
onlyOwner
{
require(!hasEnded());
reallocation(_value);
}
function reallocation(uint256 _value)
internal
{
}
}
contract PathPublicCrowdsale is RateConfigurable, BurnableCrowdsale, ReallocatableCrowdsale, SafePercent {
using SafeMath for uint256;
address public pathAdvisorVault;
address public privatePresaleWallet;
function PathPublicCrowdsale (
uint256 _startTime,
uint256 _endTime,
uint256 _rate,
address _wallet,
address _pathAdvisorVault,
PATH _token,
address _privatePresaleWallet
)
BurnableCrowdsale()
StandardCrowdsale(_startTime, _endTime, _rate, _wallet, _token)
public
{
pathAdvisorVault = _pathAdvisorVault;
privatePresaleWallet = _privatePresaleWallet;
}
function finalization() internal {
super.finalization();
uint256 amountToBurn = calculateBurnAmount();
TokenVault(pathAdvisorVault).approve(
address(this),
token,
amountToBurn
);
token.burnFrom(pathAdvisorVault, amountToBurn);
TokenVault(pathAdvisorVault).open();
}
function calculateBurnAmount()
internal
view
returns (uint256)
{
uint256 maxPossibleRaised = token.initialSupply().mul(3).div(5);
uint256 actuallyRaised = token.totalSupply().sub(
token.initialSupply().mul(2).div(5)
);
uint256 precision = 4;
uint256 raisedRatio = percent(actuallyRaised, maxPossibleRaised, precision);
uint256 burnRatio = (10 ** precision).sub(raisedRatio);
uint256 amountToBurnWithPrecision = token.balanceOf(pathAdvisorVault).mul(burnRatio);
return amountToBurnWithPrecision.div(10 ** precision);
}
function getTokenAmount(uint256 weiAmount) internal view returns (uint256) {
var timeSinceStart = now - startTime;
uint256 discountMultiplier;
if (timeSinceStart <= 1 weeks) {
discountMultiplier = 70;
} else if (timeSinceStart <= 2 weeks) {
discountMultiplier = 80;
} else if (timeSinceStart <= 3 weeks) {
discountMultiplier = 90;
} else {
discountMultiplier = 100;
}
return weiAmount.mul(rate).mul(100).div(discountMultiplier);
}
function reallocation(uint256 _value)
internal
{
require(token.transfer(privatePresaleWallet, _value));
}
}
contract TokenVault is Ownable {
bool public open = false;
address public beneficiary;
modifier isOpen() {
require(open);
_;
}
modifier onlyBeneficiary() {
require(msg.sender == beneficiary);
_;
}
function TokenVault(address _beneficiary)
public
{
beneficiary = _beneficiary;
}
function open()
onlyOwner
external
{
open = true;
}
function withdraw(StandardToken _token)
isOpen
onlyBeneficiary
external
{
require(_token.transfer(msg.sender, _token.balanceOf(address(this))));
}
function approve(
address _beneficiary,
StandardToken _token,
uint256 _value
)
onlyOwner
public
{
require(_token.approve(_beneficiary, _value));
}
}