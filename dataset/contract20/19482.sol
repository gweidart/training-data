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
contract ERC20 {
function totalSupply() constant returns (uint256 supply) {}
function balanceOf(address _owner) constant returns (uint256 balance) {}
function transfer(address _to, uint256 _value) returns (bool success) {}
function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {}
function approve(address _spender, uint256 _value) returns (bool success) {}
function allowance(address _owner, address _spender) constant returns (uint256 remaining) {}
event Transfer(address indexed _from, address indexed _to, uint256 _value);
event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}
contract Ownable {
address public owner;
function Ownable() public {
owner = 0x3c5568c646068212805550Cd1433bD9728667DfD;
}
modifier onlyOwner() {
require(msg.sender == owner);
_;
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
wallet.transfer(this.balance);
Closed();
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
contract HurtleCoin is ERC20, Ownable {
using SafeMath for uint256;
RefundVault public vault;
mapping(address => uint256) balances;
mapping (address => mapping (address => uint256)) allowed;
uint256 totalSupply_;
string public name = 'HurtleCoin';
string public symbol = 'HRTL';
uint256 public decimals = 4;
uint256 public initialSupply = 200000000;
uint256 public ratePreICO = 200000000000000;
uint256 public rateICO    = 280000000000000;
uint256 public preSaleMaxCapInWei = 500 ether;
uint256 public preSaleRaised = 0;
uint256 public icoSoftCapInWei = 3300 ether;
uint256 public icoHardCapInWei = 35000 ether;
uint256 public icoRaised = 0;
uint256 public presaleStartTimestamp;
uint256 public presaleEndTimestamp;
uint256 public icoStartTimestamp;
uint256 public icoEndTimestamp;
uint256 public presaleTokenLimit;
uint256 public icoTokenLimit;
uint256 public investorCount;
enum State {Unknown, Preparing, PreSale, ICO, Success, Failure, PresaleFinalized, ICOFinalized}
State public crowdSaleState;
modifier nonZero() {
require(msg.value > 0);
_;
}
function HurtleCoin() public {
owner = 0x3c5568c646068212805550Cd1433bD9728667DfD;
vault = new RefundVault(0x3c5568c646068212805550Cd1433bD9728667DfD);
totalSupply_ = initialSupply*(10**decimals);
balances[owner] = totalSupply_;
presaleStartTimestamp = 1525046400;
presaleEndTimestamp = presaleStartTimestamp + 30 * 1 days;
icoStartTimestamp = presaleEndTimestamp + 1 days;
icoEndTimestamp = icoStartTimestamp + 90 * 1 days;
crowdSaleState = State.Preparing;
}
function () nonZero payable {
enter();
}
function enter() public nonZero payable {
if(isPreSalePeriod()) {
if(crowdSaleState == State.Preparing) {
crowdSaleState = State.PreSale;
}
buyTokens(msg.sender, msg.value);
}
else if (isICOPeriod()) {
if(crowdSaleState == State.PresaleFinalized) {
crowdSaleState = State.ICO;
}
buyTokens(msg.sender, msg.value);
} else {
revert();
}
}
function buyTokens(address _recipient, uint256 _value) internal nonZero returns (bool success) {
uint256 boughtTokens = calculateTokens(_value);
require(boughtTokens != 0);
boughtTokens = boughtTokens*(10**decimals);
if(balanceOf(_recipient) == 0) {
investorCount++;
}
if(isCrowdSaleStatePreSale()) {
transferTokens(_recipient, boughtTokens);
vault.deposit.value(_value)(_recipient);
preSaleRaised = preSaleRaised.add(_value);
return true;
} else if (isCrowdSaleStateICO()) {
transferTokens(_recipient, boughtTokens);
vault.deposit.value(_value)(_recipient);
icoRaised = icoRaised.add(_value);
return true;
}
}
function transferTokens(address _recipient, uint256 tokens_in_cents) internal returns (bool) {
require(
tokens_in_cents > 0
&& _recipient != owner
&& tokens_in_cents < balances[owner]
);
balances[owner] = balances[owner].sub(tokens_in_cents);
balances[_recipient] = balances[_recipient].add(tokens_in_cents);
Transfer(owner, _recipient, tokens_in_cents);
return true;
}
function transfer(address _to, uint256 _tokens_in_cents) public returns (bool) {
require(_tokens_in_cents > 0);
require(_to != msg.sender);
require(balances[msg.sender] >= _tokens_in_cents);
if(balanceOf(_to) == 0) {
investorCount++;
}
balances[msg.sender] = balances[msg.sender].sub(_tokens_in_cents);
balances[_to] = balances[_to].add(_tokens_in_cents);
if(balanceOf(msg.sender) == 0) {
investorCount=investorCount-1;
}
Transfer(msg.sender, _to, _tokens_in_cents);
return true;
}
function transferFrom(address _from, address _to, uint256 _tokens_in_cents) public returns (bool success) {
require(_tokens_in_cents > 0);
require(_from != _to);
require(balances[_from] >= _tokens_in_cents);
require(allowed[_from][msg.sender] >= _tokens_in_cents);
if(balanceOf(_to) == 0) {
investorCount++;
}
balances[_from] = balances[_from].sub(_tokens_in_cents);
balances[_to] = balances[_to].add(_tokens_in_cents);
allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_tokens_in_cents);
if(balanceOf(_from) == 0) {
investorCount=investorCount-1;
}
Transfer(_from, _to, _tokens_in_cents);
return true;
}
function approve(address _spender, uint256 _tokens_in_cents) returns (bool success) {
allowed[msg.sender][_spender] = _tokens_in_cents;
Approval(msg.sender, _spender, _tokens_in_cents);
return true;
}
function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
return allowed[_owner][_spender];
}
function calculateTokens(uint256 _amount) internal returns (uint256 tokens){
if(crowdSaleState == State.Preparing && isPreSalePeriod()) {
crowdSaleState = State.PreSale;
}
if(isCrowdSaleStatePreSale()) {
tokens = _amount.div(ratePreICO);
} else if (isCrowdSaleStateICO()) {
tokens = _amount.div(rateICO);
} else {
tokens = 0;
}
}
function getRefund(address _recipient) public returns (bool){
require(crowdSaleState == State.Failure);
require(refundedAmount(_recipient));
vault.refund(_recipient);
return true;
}
function refundedAmount(address _recipient) internal returns (bool) {
require(balances[_recipient] != 0);
balances[_recipient] = 0;
return true;
}
function totalSupply() public view returns (uint256) {
return totalSupply_;
}
function balanceOf(address a) public view returns (uint256 balance) {
return balances[a];
}
function isCrowdSaleStatePreSale() public constant returns (bool) {
return crowdSaleState == State.PreSale;
}
function isCrowdSaleStateICO() public constant returns (bool) {
return crowdSaleState == State.ICO;
}
function isPreSalePeriod() public constant returns (bool) {
if(preSaleRaised > preSaleMaxCapInWei || now >= presaleEndTimestamp) {
crowdSaleState = State.PresaleFinalized;
return false;
} else {
return now > presaleStartTimestamp;
}
}
function isICOPeriod() public constant returns (bool) {
if (icoRaised > icoHardCapInWei || now >= icoEndTimestamp){
crowdSaleState = State.ICOFinalized;
return false;
} else {
return now > icoStartTimestamp;
}
}
function endCrowdSale() public onlyOwner {
require(now >= icoEndTimestamp || icoRaised >= icoSoftCapInWei);
if(icoRaised >= icoSoftCapInWei){
crowdSaleState = State.Success;
vault.close();
} else {
crowdSaleState = State.Failure;
vault.enableRefunds();
}
}
function getInvestorCount() public constant returns (uint256) {
return investorCount;
}
function getPresaleRaisedAmount() public constant returns (uint256) {
return preSaleRaised;
}
function getICORaisedAmount() public constant returns (uint256) {
return icoRaised;
}
}