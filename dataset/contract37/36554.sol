pragma solidity ^0.4.11;
contract ERC20Basic {
uint256 public totalSupply;
function balanceOf(address who) constant returns (uint256);
function transfer(address to, uint256 value) returns (bool);
event Transfer(address indexed from, address indexed to, uint256 value);
}
contract Ownable {
address public owner;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
function Ownable() {
owner = msg.sender;
}
modifier onlyOwner() {
require(msg.sender == owner);
_;
}
function transferOwnership(address newOwner) onlyOwner {
require(newOwner != address(0));
OwnershipTransferred(owner, newOwner);
owner = newOwner;
}
}
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
contract Haltable is Ownable {
bool public halted;
modifier stopInEmergency {
require(!halted);
_;
}
modifier stopNonOwnersInEmergency {
require(!halted && msg.sender == owner);
_;
}
modifier onlyInEmergency {
require(halted);
_;
}
function halt() external onlyOwner {
halted = true;
}
function unhalt() external onlyOwner onlyInEmergency {
halted = false;
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
function RefundVault(address _wallet) {
require(_wallet != 0x0);
wallet = _wallet;
state = State.Active;
}
function deposit(address investor) onlyOwner payable {
require(state == State.Active);
deposited[investor] = deposited[investor].add(msg.value);
}
function close() onlyOwner payable {
require(state == State.Active);
state = State.Closed;
Closed();
wallet.transfer(this.balance);
}
function enableRefunds() onlyOwner {
require(state == State.Active);
state = State.Refunding;
RefundsEnabled();
}
function refund(address investor) payable {
require(state == State.Refunding);
uint256 depositedValue = deposited[investor];
deposited[investor] = 0;
investor.transfer(depositedValue);
Refunded(investor, depositedValue);
}
}
contract BasicToken is ERC20Basic {
using SafeMath for uint256;
mapping(address => uint256) balances;
function transfer(address _to, uint256 _value) returns (bool) {
require(_to != address(0));
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
require(_to != address(0));
var _allowance = allowed[_from][msg.sender];
balances[_from] = balances[_from].sub(_value);
balances[_to] = balances[_to].add(_value);
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
function increaseApproval (address _spender, uint _addedValue)
returns (bool success) {
allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
return true;
}
function decreaseApproval (address _spender, uint _subtractedValue)
returns (bool success) {
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
contract HarborToken is StandardToken, Ownable {
string public constant name = "HarborToken";
string public constant symbol = "HBR";
uint8 public constant decimals = 18;
mapping (address => bool) public mintAgents;
event Mint(address indexed to, uint256 amount);
event MintOpened();
event MintFinished();
event MintingAgentChanged(address addr, bool state  );
event BurnToken(address addr,uint256 amount);
bool public mintingFinished = false;
modifier canMint() {
require(!mintingFinished);
_;
}
modifier onlyMintAgent() {
require(mintAgents[msg.sender]);
_;
}
function setMintAgent(address addr, bool state) onlyOwner canMint public {
mintAgents[addr] = state;
MintingAgentChanged(addr, state);
}
function mint(address _to, uint256 _amount) onlyMintAgent canMint returns (bool) {
totalSupply = totalSupply.add(_amount);
balances[_to] = balances[_to].add(_amount);
Mint(_to, _amount);
Transfer(0x0, _to, _amount);
return true;
}
function burn(address _addr,uint256 _amount) onlyMintAgent canMint  returns (bool) {
require(_amount > 0);
totalSupply = totalSupply.sub(_amount);
balances[_addr] = balances[_addr].sub(_amount);
BurnToken(_addr,_amount);
return true;
}
function openMinting() onlyOwner returns (bool) {
mintingFinished = false;
MintOpened();
return true;
}
function finishMinting() onlyOwner returns (bool) {
mintingFinished = true;
MintFinished();
return true;
}
}
contract HarborCrowdsale is Haltable {
using SafeMath for uint256;
HarborToken public token;
uint256 public startTime;
uint256 public endTime;
address public wallet;
uint256 public weiRaised;
uint256 public cap;
bool public isFinalized = false;
uint256 public minimumFundingGoal;
RefundVault public vault;
mapping (address => uint256) public projectBuget;
event Finalized();
event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount,uint256 projectamount);
event EndsAtChanged(uint newEndsAt);
function HarborCrowdsale(uint256 _startTime, uint256 _endTime,  address _wallet, uint256 _cap, uint256 _minimumFundingGoal) {
require(_startTime >= now);
require(_endTime >= _startTime);
require(_wallet != 0x0);
require(_cap > 0);
require(_minimumFundingGoal > 0);
token = createTokenContract();
startTime = _startTime;
endTime = _endTime;
wallet = _wallet;
cap = _cap;
vault = new RefundVault(wallet);
minimumFundingGoal = _minimumFundingGoal;
token.setMintAgent(address(this), true);
}
function createTokenContract() internal returns (HarborToken) {
return new HarborToken();
}
function () payable stopInEmergency{
buyTokens(msg.sender);
}
function buyPrice() constant returns (uint) {
return buyPriceAt(now);
}
function buyPriceAt(uint at) constant returns (uint) {
if (at < startTime) {
return 0;
} else if (at < (startTime + 1 days)) {
return 2200;
} else if (at < (startTime + 7 days)) {
return 2100;
} else if (at <= endTime) {
return 2000;
} else {
return 0;
}
}
function buyTokens(address beneficiary) payable stopInEmergency {
require(beneficiary != 0x0);
require(validPurchase());
require(buyPrice() > 0);
uint256 weiAmount = msg.value;
uint256 price = buyPrice();
uint256 tokens = weiAmount.mul(price);
uint256 projectTokens = tokens.mul(2);
projectTokens = projectTokens.div(3);
weiRaised = weiRaised.add(weiAmount);
token.mint(beneficiary, tokens);
token.mint(wallet,projectTokens);
projectBuget[beneficiary] = projectBuget[beneficiary].add(projectTokens);
TokenPurchase(msg.sender, beneficiary, weiAmount, tokens, projectTokens);
forwardFunds();
}
function forwardFunds() internal {
vault.deposit.value(msg.value)(msg.sender);
}
function validPurchase() internal constant returns (bool) {
bool withinPeriod = now >= startTime && now <= endTime;
bool nonZeroPurchase = msg.value != 0;
bool withinCap = weiRaised <= cap;
return withinPeriod && nonZeroPurchase && withinCap;
}
function hasEnded() public constant returns (bool) {
bool capReached = weiRaised >= cap;
return (now > endTime) || capReached;
}
function finalize() onlyOwner {
require(!isFinalized);
require(hasEnded());
finalization();
Finalized();
isFinalized = true;
}
function finalization() internal {
if (minFundingGoalReached()) {
vault.close();
} else {
vault.enableRefunds();
}
}
function claimRefund() payable stopInEmergency{
require(isFinalized);
require(!minFundingGoalReached());
vault.refund(msg.sender);
uint256 _hbr_amount = token.balanceOf(msg.sender);
token.burn(msg.sender,_hbr_amount);
uint256 _hbr_project = projectBuget[msg.sender];
projectBuget[msg.sender] = 0;
token.burn(wallet,_hbr_project);
}
function minFundingGoalReached() public constant returns (bool) {
return weiRaised >= minimumFundingGoal;
}
function setEndsAt(uint time) onlyOwner {
require(now <= time);
endTime = time;
EndsAtChanged(endTime);
}
}