pragma solidity ^0.4.8;
library SafeMath {
function mul(uint256 a, uint256 b) internal constant returns (uint256) {
uint256 c = a * b;
assert(a == 0 || c / a == b);
return c;
}
function div(uint256 a, uint256 b) internal constant returns (uint256) {
uint256 c = a / b;
return c;
}
function sub(uint256 a, uint256 b) internal constant returns (uint256) {
assert(b <= a);
return a - b;
}
function add(uint256 a, uint256 b) internal constant returns (uint256) {
uint256 c = a + b;
assert(c >= a);
return c;
}
}
contract ERC20Basic {
uint256 public totalSupply;
function balanceOf(address who) constant returns (uint256);
function transfer(address to, uint256 value) returns (bool);
event Transfer(address indexed from, address indexed to, uint256 value);
}
contract BasicToken is ERC20Basic {
using SafeMath for uint256;
mapping(address => uint256) balances;
function transfer(address _to, uint256 _value) returns (bool) {
balances[msg.sender] = balances[msg.sender].sub(_value);
balances[_to] = balances[_to].add(_value);
Transfer(msg.sender, _to, _value);
return true;
}
function balanceOf(address _owner) constant returns (uint256 balance) {
return balances[_owner];
}
}
contract ERC20 is ERC20Basic {
function allowance(address owner, address spender) constant returns (uint256);
function transferFrom(address from, address to, uint256 value) returns (bool);
function approve(address spender, uint256 value) returns (bool);
event Approval(address indexed owner, address indexed spender, uint256 value);
}
contract StandardToken is ERC20, BasicToken {
mapping (address => mapping (address => uint256)) allowed;
function transferFrom(address _from, address _to, uint256 _value) returns (bool) {
var _allowance = allowed[_from][msg.sender];
balances[_to] = balances[_to].add(_value);
balances[_from] = balances[_from].sub(_value);
allowed[_from][msg.sender] = _allowance.sub(_value);
Transfer(_from, _to, _value);
return true;
}
function approve(address _spender, uint256 _value) returns (bool) {
require((_value == 0) || (allowed[msg.sender][_spender] == 0));
allowed[msg.sender][_spender] = _value;
Approval(msg.sender, _spender, _value);
return true;
}
function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
return allowed[_owner][_spender];
}
}
contract Ownable {
address public owner;
function Ownable() {
owner = msg.sender;
}
modifier onlyOwner() {
require(msg.sender == owner);
_;
}
function transferOwnership(address newOwner) onlyOwner {
if (newOwner != address(0)) {
owner = newOwner;
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
function mint(address _to, uint256 _amount) onlyOwner canMint returns (bool) {
totalSupply = totalSupply.add(_amount);
balances[_to] = balances[_to].add(_amount);
Mint(_to, _amount);
return true;
}
function finishMinting() onlyOwner returns (bool) {
mintingFinished = true;
MintFinished();
return true;
}
}
contract PauseInfrastructure is Ownable {
event triggerUnpauseEvent();
event triggerPauseEvent();
bool public paused;
function PauseInfrastructure(bool _paused){
paused = _paused;
}
modifier whenNotPaused() {
if (paused) revert();
_;
}
modifier whenPaused {
require (paused);
_;
}
}
contract Startable is PauseInfrastructure {
function Startable () PauseInfrastructure(true){
}
function start() onlyOwner whenPaused returns (bool) {
paused = false;
triggerUnpauseEvent();
return true;
}
}
contract StartableMintableToken is Startable, MintableToken {
function transfer(address _to, uint _value) whenNotPaused returns (bool){
return super.transfer(_to, _value);
}
function transferFrom(address _from, address _to, uint256 _value) whenNotPaused returns (bool) {
return super.transferFrom(_from, _to, _value);
}
}
contract SeratioCoin is StartableMintableToken {
string constant public name = "SeratioCoin";
string constant public symbol = "SER";
uint8 constant public decimals = 7;
uint32 constant public DECIMAL_ZEROS = 10000000;
}
contract SeratioICO is Ownable{
using SafeMath for uint;
event DepositAcceptedEvent(address _from, uint value);
uint16 constant public MIN_INVESTMENT_ICO_PHASE_ONE_POUNDS = 5000;
uint16 constant public MIN_INVESTMENT_ICO_PHASE_TWO_POUNDS = 1000;
uint32 constant public INVESTMENT_CAP_ICO_PHASE_ONE_POUNDS = 1000000;
uint32 public investmentCapIcoPhaseTwoPounds = 4000000000;
uint8 constant BASE_TOKEN_PRICE_IN_POUND_PENCES = 20;
bool investmentCapPreIcoReached = false;
uint totalValue;
uint public timeStampOfCrowdSaleStart;
uint public timeStampOfCrowdSaleEnd;
address wallet;
struct IcoPhaseOneConfig{
uint startingTime;
uint8 tokenPriceInPoundPences;
}
IcoPhaseOneConfig[] IcoPhaseOneArray;
uint32 public etherPriceInPoundPences = 30000;
SeratioCoin public seratioCoin;
function SeratioICO(address multisig, uint _timeStampOfCrowdSaleStart, SeratioCoin serationCoinAddress){
seratioCoin = SeratioCoin(serationCoinAddress);
timeStampOfCrowdSaleStart = _timeStampOfCrowdSaleStart;
timeStampOfCrowdSaleEnd = timeStampOfCrowdSaleStart + 47 days;
wallet = multisig;
IcoPhaseOneArray.push(IcoPhaseOneConfig({startingTime: timeStampOfCrowdSaleStart +  0 days,  tokenPriceInPoundPences:  10}));
IcoPhaseOneArray.push(IcoPhaseOneConfig({startingTime: timeStampOfCrowdSaleStart +  3 days,  tokenPriceInPoundPences:  12}));
IcoPhaseOneArray.push(IcoPhaseOneConfig({startingTime: timeStampOfCrowdSaleStart +  6 days,  tokenPriceInPoundPences:  14}));
IcoPhaseOneArray.push(IcoPhaseOneConfig({startingTime: timeStampOfCrowdSaleStart +  9 days,  tokenPriceInPoundPences:  16}));
IcoPhaseOneArray.push(IcoPhaseOneConfig({startingTime: timeStampOfCrowdSaleStart + 12 days,  tokenPriceInPoundPences:  18}));
}
function getIcoPhaseOneThreeDayIndex(uint time) constant returns (uint){
for (uint i = 1; i <= IcoPhaseOneArray.length; i++) {
uint indexToEvaluate = IcoPhaseOneArray.length-i;
if (time >= IcoPhaseOneArray[indexToEvaluate].startingTime)
return indexToEvaluate;
}
}
function getIcoPhaseOneTokenPriceInPoundPences(uint time) constant returns (uint8){
IcoPhaseOneConfig storage todaysConfig = IcoPhaseOneArray[getIcoPhaseOneThreeDayIndex(time)];
return todaysConfig.tokenPriceInPoundPences;
}
function hasIcoPhaseOneEnded (uint time) constant returns (bool){
return time >= (IcoPhaseOneArray[IcoPhaseOneArray.length-1].startingTime + 4 days);
}
function () payable hasCrowdSaleStarted hasCrowdSaleNotYetEnded {
if (msg.value > 0){
mintSerTokens(msg.sender, msg.value, now);
require (wallet.send(msg.value));
DepositAcceptedEvent(msg.sender, msg.value);
}
}
modifier hasCrowdSaleStarted() {
require (now >= timeStampOfCrowdSaleStart);
_;
}
modifier hasCrowdSaleEnded() {
require (now >= timeStampOfCrowdSaleEnd);
_;
}
modifier hasCrowdSaleNotYetEnded() {
require (now < timeStampOfCrowdSaleEnd);
_;
}
function calculateEthers(uint poundPences) constant returns (uint){
return poundPences.mul(1 ether).div(etherPriceInPoundPences)+1;
}
function calculatePoundsTimesEther(uint ethersAmount) constant returns (uint){
return ethersAmount.mul(etherPriceInPoundPences).div(100);
}
function setEtherPriceInPoundPences(uint32 _etherPriceInPoundPences) onlyOwner{
etherPriceInPoundPences = _etherPriceInPoundPences;
}
function setInvestmentCapIcoPhaseTwoPounds(uint32 _investmentCapIcoPhaseTwoPounds) onlyOwner{
investmentCapIcoPhaseTwoPounds = _investmentCapIcoPhaseTwoPounds;
}
function createSeratioStake() hasCrowdSaleEnded onlyOwner{
uint SeratioTokens = seratioCoin.totalSupply().mul(3);
seratioCoin.mint(wallet, SeratioTokens);
seratioCoin.finishMinting();
}
function SwitchTokenTransactionsOn() hasCrowdSaleEnded onlyOwner{
seratioCoin.start();
}
function mintSerTokens(address sender, uint value, uint timeStampOfInvestment) private {
uint investmentCapInPounds;
uint minimumInvestmentInPounds;
uint8 tokenPriceInPoundPences;
uint investmentInPoundsTimesEther = calculatePoundsTimesEther(value);
if (hasIcoPhaseOneEnded(timeStampOfInvestment) || investmentCapPreIcoReached){
investmentCapInPounds = investmentCapIcoPhaseTwoPounds;
minimumInvestmentInPounds = MIN_INVESTMENT_ICO_PHASE_TWO_POUNDS;
tokenPriceInPoundPences = BASE_TOKEN_PRICE_IN_POUND_PENCES;
require(investmentInPoundsTimesEther >= minimumInvestmentInPounds.mul(1 ether));
}else{
investmentCapInPounds = INVESTMENT_CAP_ICO_PHASE_ONE_POUNDS;
minimumInvestmentInPounds = MIN_INVESTMENT_ICO_PHASE_ONE_POUNDS;
tokenPriceInPoundPences = getIcoPhaseOneTokenPriceInPoundPences(timeStampOfInvestment);
require(investmentInPoundsTimesEther >= minimumInvestmentInPounds.mul(1 ether));
uint totalInvestmentInPoundsTimesEther = calculatePoundsTimesEther(getTotalValue().add(value));
uint investmentCapInPoundsTimesEther = investmentCapInPounds.mul(1 ether);
if(totalInvestmentInPoundsTimesEther > investmentCapInPoundsTimesEther){
investmentCapPreIcoReached = true;
uint retargetedInvestmentInPoundsTimesEther = totalInvestmentInPoundsTimesEther.sub(investmentCapInPoundsTimesEther);
uint investmentInPoundsTimesEtherToFulfilCap = investmentInPoundsTimesEther.sub(retargetedInvestmentInPoundsTimesEther);
mintHelper(sender, investmentInPoundsTimesEtherToFulfilCap, tokenPriceInPoundPences);
investmentInPoundsTimesEther = retargetedInvestmentInPoundsTimesEther;
tokenPriceInPoundPences = BASE_TOKEN_PRICE_IN_POUND_PENCES;
}
}
mintHelper(sender, investmentInPoundsTimesEther, tokenPriceInPoundPences);
totalValue = totalValue.add(value);
}
function mintHelper(address sender, uint investmentInPoundsTimesEther, uint8 tokenPriceInPoundPences) private {
uint tokens = investmentInPoundsTimesEther
.mul(100).div(tokenPriceInPoundPences)
.mul(uint(seratioCoin.DECIMAL_ZEROS()))
.div(1 ether);
seratioCoin.mint(sender, tokens);
}
function manuallyMintTokens(address beneficiary, uint value, uint timeStampOfInvestment) onlyOwner{
mintSerTokens(beneficiary, value, timeStampOfInvestment);
}
function rawManuallyMintTokens(address beneficiary, uint tokens) onlyOwner{
seratioCoin.mint(beneficiary, tokens);
}
function getPrice(uint time) constant returns (uint) {
uint8 tokenPriceInPoundPences;
if (hasIcoPhaseOneEnded(time)){
tokenPriceInPoundPences = BASE_TOKEN_PRICE_IN_POUND_PENCES;
}else{
tokenPriceInPoundPences = getIcoPhaseOneTokenPriceInPoundPences(time);
}
return tokenPriceInPoundPences;
}
function getTotalSupply() constant returns (uint) {
return seratioCoin.totalSupply();
}
function getTotalValue() constant returns (uint) {
return totalValue;
}
}