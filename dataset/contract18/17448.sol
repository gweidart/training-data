pragma solidity ^0.4.17;
library SafeMath {
function add(uint a, uint b) internal pure returns (uint c) {
c = a + b;
require(c >= a);
}
function sub(uint a, uint b) internal pure returns (uint c) {
require(b <= a);
c = a - b;
}
function mul(uint a, uint b) internal pure returns (uint c) {
c = a * b;
require(a == 0 || c / a == b);
}
function div(uint a, uint b) internal pure returns (uint c) {
require(b > 0);
c = a / b;
}
}
contract Owned {
address public owner;
event OwnershipTransferred(address indexed _from, address indexed _to);
function Owned() public {
owner = 0x3fCD36fcE4097245AB0f2bA50486BC01D2a3ee44;
}
modifier onlyOwner {
require(msg.sender == owner);
_;
}
function transferOwnership(address _newOwner) public onlyOwner {
require(_newOwner != address(0x0));
emit OwnershipTransferred(owner,_newOwner);
owner = _newOwner;
}
}
contract CesiraeToken {
function balanceOf(address _owner) public constant returns (uint256 balance);
function transfer(address _to, uint256 _value) public returns (bool success);
}
contract CesiraeICO is Owned {
using SafeMath for uint256;
enum State {
PrivatePreSale,
PreICO,
ICORound1,
ICORound2,
ICORound3,
ICORound4,
ICORound5,
Successful
}
State public state;
uint256 public totalRaised;
uint256 public totalDistributed;
CesiraeToken public CSE;
mapping(address => bool) whitelist;
event LogWhiteListed(address _addr);
event LogBlackListed(address _addr);
event LogFundingReceived(address _addr, uint _amount, uint _currentTotal);
event LogBeneficiaryPaid(address _beneficiaryAddress);
event LogFundingSuccessful(uint _totalRaised);
event LogFunderInitialized(address _creator);
event LogContributorsPayout(address _addr, uint _amount);
modifier onlyIfNotFinished {
require(state != State.Successful);
_;
}
modifier onlyIfWhiteListedOnPreSale {
if(state == State.PrivatePreSale) {
require(whitelist[msg.sender]);
}
_;
}
function CesiraeICO (CesiraeToken _addressOfToken) public {
require(_addressOfToken != address(0));
CSE = CesiraeToken(_addressOfToken);
state = State.PrivatePreSale;
emit LogFunderInitialized(owner);
}
function() public payable {
contribute();
}
function contribute() onlyIfNotFinished onlyIfWhiteListedOnPreSale public payable {
uint256 tokenBought;
uint256 bonus;
uint256 tokenPrice;
if (state == State.PrivatePreSale){
require(msg.value >= 2 ether);
tokenPrice = 160000;
tokenBought = msg.value.mul(tokenPrice);
bonus = tokenBought;
}
else if (state == State.PreICO){
require(msg.value >= 1 ether);
tokenPrice = 160000;
tokenBought = msg.value.mul(tokenPrice);
bonus = tokenBought.mul(50).div(100);
}
else if (state == State.ICORound1){
require(msg.value >= 0.7 ether);
tokenPrice = 140000;
tokenBought = msg.value.mul(tokenPrice);
bonus = tokenBought.mul(40).div(100);
}
else if (state == State.ICORound2){
require(msg.value >= 0.5 ether);
tokenPrice = 120000;
tokenBought = msg.value.mul(tokenPrice);
bonus = tokenBought.mul(30).div(100);
}
else if (state == State.ICORound3){
require(msg.value >= 0.3 ether);
tokenPrice = 100000;
tokenBought = msg.value.mul(tokenPrice);
bonus = tokenBought.mul(20).div(100);
}
else if (state == State.ICORound4){
require(msg.value >= 0.2 ether);
tokenPrice = 80000;
tokenBought = msg.value.mul(tokenPrice);
bonus = tokenBought.mul(10).div(100);
}
else if (state == State.ICORound5){
require(msg.value >= 0.1 ether);
tokenPrice = 60000;
tokenBought = msg.value.mul(tokenPrice);
bonus = 0;
}
tokenBought = tokenBought.add(bonus);
require(CSE.balanceOf(this) >= tokenBought);
totalRaised = totalRaised.add(msg.value);
totalDistributed = totalDistributed.add(tokenBought);
CSE.transfer(msg.sender,tokenBought);
owner.transfer(msg.value);
emit LogContributorsPayout(msg.sender,tokenBought);
emit LogBeneficiaryPaid(owner);
emit LogFundingReceived(msg.sender, msg.value, totalRaised);
}
function finished() onlyOwner public {
uint256 remainder = CSE.balanceOf(this);
if(address(this).balance > 0) {
owner.transfer(address(this).balance);
emit LogBeneficiaryPaid(owner);
}
CSE.transfer(owner,remainder);
emit LogContributorsPayout(owner, remainder);
state = State.Successful;
}
function nextState() onlyOwner public {
require(state != State.ICORound5);
state = State(uint(state) + 1);
}
function previousState() onlyOwner public {
require(state != State.PrivatePreSale);
state = State(uint(state) - 1);
}
function addToWhiteList(address _userAddress) onlyOwner public returns(bool) {
require(_userAddress != address(0));
if (!whitelist[_userAddress]) {
whitelist[_userAddress] = true;
emit LogWhiteListed(_userAddress);
return true;
} else {
return false;
}
}
function removeFromWhiteList(address _userAddress) onlyOwner public returns(bool) {
require(_userAddress != address(0));
if(whitelist[_userAddress]) {
whitelist[_userAddress] = false;
emit LogBlackListed(_userAddress);
return true;
} else {
return false;
}
}
function checkIfWhiteListed(address _userAddress) view public returns(bool) {
return whitelist[_userAddress];
}
function claimTokens() onlyOwner public {
uint256 remainder = CSE.balanceOf(this);
CSE.transfer(owner,remainder);
}
}