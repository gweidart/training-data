pragma solidity ^0.4.19;
library SafeMath {
function mul(uint256 a, uint256 b) internal pure returns (uint256) {
if (a == 0 || b == 0){
return 0;
}
uint256 c = a * b;
assert(a == 0 || c / a == b);
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
address public newOwner;
address public techSupport;
address public newTechSupport;
modifier onlyOwner() {
require(msg.sender == owner);
_;
}
modifier onlyTechSupport() {
require(msg.sender == techSupport);
_;
}
function Ownable() public {
owner = msg.sender;
}
function transferOwnership(address _newOwner) public onlyOwner {
require(_newOwner != address(0));
newOwner = _newOwner;
}
function acceptOwnership() public {
if (msg.sender == newOwner) {
owner = newOwner;
}
}
function transferTechSupport (address _newSupport) public{
require (msg.sender == owner || msg.sender == techSupport);
newTechSupport = _newSupport;
}
function acceptSupport() public{
if(msg.sender == newTechSupport){
techSupport = newTechSupport;
}
}
}
contract CQTToken{
function setCrowdsaleContract (address) public{}
function sendCrowdsaleTokens(address, uint256)  public {}
function burnTokens(address) {}
function getCrowdsaleTokens() public view returns(uint) {}
function burnSomeTokens(uint _value) public{}
}
contract Crowdsale is Ownable{
using SafeMath for uint;
function pow(uint256 a, uint256 b) public pure returns (uint256){
return (a**b);
}
uint decimals = 8;
CQTToken public token;
function Crowdsale(address _tokenAddress, address _owner) public{
token = CQTToken(_tokenAddress);
owner = _owner;
techSupport = msg.sender;
token.setCrowdsaleContract(this);
}
uint minDeposit = 10000000000000000;
uint public preIcoStart = 1519189260;
uint public preIcoFinish = 1521694740;
uint preIcoMaxCap = 60000000*pow(10,decimals);
uint tokenPrice = 50000000000000;
uint public icoStart = 1521867660;
uint public icoFinish = 1524632340;
uint icoMinCap = 100000000*pow(10,decimals);
uint icoMaxCap = 550000000*pow(10,decimals);
function isPreIco(uint _time) public view returns (bool){
if((preIcoStart <= _time) && (_time <= preIcoFinish)){
return true;
}
return false;
}
function isIco(uint _time) public view returns (bool){
if((icoStart <= _time) && (_time <= icoFinish)){
return true;
}
return false;
}
uint public preIcoTokensSold = 0;
uint public icoTokensSold = 0;
uint public tokensSold = 0;
uint public ethCollected = 0;
mapping (address => uint) investorBalances;
function() public payable{
if (now > icoFinish){
finishCrowdsale();
}
require(isIco(now) || isPreIco(now));
require(msg.value >= minDeposit);
require(buy(msg.sender,msg.value,now));
}
function sendTokensManually(address _address, uint _value) public onlyTechSupport{
token.sendCrowdsaleTokens(_address, _value);
if(isPreIco(now)){
preIcoTokensSold = preIcoTokensSold.add(_value);
}
if(isIco(now)){
icoTokensSold = icoTokensSold.add(_value);
}
tokensSold = tokensSold.add(_value);
}
require(token.getCrowdsaleTokens() > 0);
uint tokensForSend = 0;
if (isPreIco(_time)){
require (preIcoMaxCap > preIcoTokensSold);
tokensForSend = etherToTokens(_value);
preIcoTokensSold = preIcoTokensSold.add(tokensForSend);
owner.transfer(this.balance);
}
if (isIco(_time)){
tokensForSend = etherToTokens(_value);
if(tokensForSend.add(tokensSold) > token.getCrowdsaleTokens()){
tokensForSend = token.getCrowdsaleTokens();
uint ethToTake = tokensForSend.mul(tokenPrice).div(pow(10,decimals));
uint etherSendBack = _value.sub(ethToTake);
_address.transfer(etherSendBack);
icoTokensSold = icoTokensSold.add(tokensForSend);
tokensSold = tokensSold.add(tokensForSend);
token.sendCrowdsaleTokens(_address, tokensForSend);
ethCollected = ethCollected.add(ethToTake);
investorBalances[_address] = investorBalances[_address].add(ethToTake);
owner.transfer(this.balance);
return true;
}
investorBalances[_address] = investorBalances[_address].add(_value);
icoTokensSold = icoTokensSold.add(tokensForSend);
}
tokensSold = tokensSold.add(tokensForSend);
token.sendCrowdsaleTokens(_address, tokensForSend);
if (isIcoTrue()){
owner.transfer(this.balance);
}
ethCollected = ethCollected.add(_value);
return true;
}
function etherToTokens(uint _value) public view returns(uint) {
uint res = _value.mul(pow(10,decimals)).div(tokenPrice);
if (now < preIcoStart || isPreIco(now)){
return res.add(res*40/100);
}
if (now > preIcoFinish && now < icoStart){
return res.add(res*30/100);
}
if (isIco(now)){
if(icoStart + 7 days <= now){
return res.add(res*30/100);
}
if(icoStart + 14 days <= now){
return res.add(res*20/100);
}
if(icoStart + 21 days <= now){
return res.add(res*10/100);
}
return res;
}
return 0;
}
function isIcoTrue() public view returns (bool){
if (tokensSold >= icoMinCap){
return true;
}
return false;
}
bool public isTryedFinishCrowdsale = false;
bool public isBurnActive = false;
function finishCrowdsale () public {
require (now > icoFinish);
if(!isTryedFinishCrowdsale){
if(tokensSold >= 610000000*pow(10,decimals)){
isBurnActive = true;
}else{
icoFinish = icoFinish + 7 days;
}
isTryedFinishCrowdsale = true;
}else{
isBurnActive = true;
}
}
function burnSomeTokens (uint _value) public onlyOwner{
require(isBurnActive);
token.burnSomeTokens(_value);
}
function refund() public{
require (!isIcoTrue());
require (icoFinish + 3 days <= now);
token.burnTokens(msg.sender);
msg.sender.transfer(investorBalances[msg.sender]);
investorBalances[msg.sender] = 0;
}
}