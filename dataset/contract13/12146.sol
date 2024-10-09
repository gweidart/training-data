pragma solidity ^0.4.23;
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
constructor() public {
owner = 0xcb26A1328d8B9244d43F5D466c62F5b5Fcf9d725;
}
modifier onlyOwner() {
require(msg.sender == owner);
_;
}
function transferOwnership(address newOwner) public onlyOwner {
require(newOwner != address(0));
emit OwnershipTransferred(owner, newOwner);
owner = newOwner;
}
}
contract Pausable is Ownable {
event Pause();
event Unpause();
bool public paused = false;
modifier whenNotPaused() {
require(!paused);
_;
}
modifier whenPaused() {
require(paused);
_;
}
function pause() onlyOwner whenNotPaused public {
paused = true;
emit Pause();
}
function unpause() onlyOwner whenPaused public {
paused = false;
emit Unpause();
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
constructor(address _wallet) public {
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
emit Closed();
wallet.transfer(address(this).balance);
}
function enableRefunds() onlyOwner public {
require(state == State.Active);
state = State.Refunding;
emit RefundsEnabled();
}
function refund(address investor) public {
require(state == State.Refunding);
uint256 depositedValue = deposited[investor];
deposited[investor] = 0;
investor.transfer(depositedValue);
emit Refunded(investor, depositedValue);
}
}
contract ERC20Basic {
function totalSupply() public view returns (uint256);
function balanceOf(address who) public view returns (uint256);
function transfer(address to, uint256 value) public returns (bool);
event Transfer(address indexed from, address indexed to, uint256 value);
}
contract ERC20 is ERC20Basic {
function allowance(address owner, address spender) public view returns (uint256);
function transferFrom(address from, address to, uint256 value) public returns (bool);
function approve(address spender, uint256 value) public returns (bool);
event Approval(address indexed owner, address indexed spender, uint256 value);
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
emit Transfer(msg.sender, _to, _value);
return true;
}
function balanceOf(address _owner) public view returns (uint256 balance) {
return balances[_owner];
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
emit Transfer(_from, _to, _value);
return true;
}
function approve(address _spender, uint256 _value) public returns (bool) {
allowed[msg.sender][_spender] = _value;
emit Approval(msg.sender, _spender, _value);
return true;
}
function allowance(address _owner, address _spender) public view returns (uint256) {
return allowed[_owner][_spender];
}
function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
return true;
}
function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
uint oldValue = allowed[msg.sender][_spender];
if (_subtractedValue > oldValue) {
allowed[msg.sender][_spender] = 0;
} else {
allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
}
emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
return true;
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
modifier hasMintPermission() {
require(msg.sender == owner);
_;
}
function mint(
address _to,
uint256 _amount
)
hasMintPermission
canMint
public
returns (bool)
{
totalSupply_ = totalSupply_.add(_amount);
balances[_to] = balances[_to].add(_amount);
emit Mint(_to, _amount);
emit Transfer(address(0), _to, _amount);
return true;
}
function finishMinting() onlyOwner canMint public returns (bool) {
mintingFinished = true;
emit MintFinished();
return true;
}
}
contract VIPX_Crowdsale is Pausable {
using SafeMath for uint256;
ERC20 public token;
address public wallet;
uint256 public goal;
RefundVault public vault;
uint256 public rate;
uint256 public weiRaised;
uint256 public cap;
uint256 public minInvest;
uint256 public openingTime;
uint256 public closingTime;
uint256 public duration;
event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);
constructor() public {
rate = 500;
wallet = owner;
token = ERC20(0x7b9585eeC0598c8C5E508fB42B23D9d21B645170);
minInvest = 0.1 * 1 ether;
duration = 60 days;
openingTime = 2524608000;
closingTime = openingTime + duration;
goal = 2000 ether;
vault = new RefundVault(wallet);
}
function start() public onlyOwner {
openingTime = now;
closingTime =  now + duration;
}
function getCurrentRate() public view returns (uint256) {
if (now <= openingTime.add(7 days)) return rate.add(rate*3/10);
if (now > openingTime.add(7 days) && now <= openingTime.add(14 days)) return rate.add(rate/5);
if (now > openingTime.add(14 days) && now <= openingTime.add(21 days)) return rate.add(rate/10);
if (now > openingTime.add(21 days) && now <= openingTime.add(28 days)) return rate.add(rate/20);
}
function () external payable {
buyTokens(msg.sender);
}
function buyTokens(address _beneficiary) public payable {
uint256 weiAmount = msg.value;
_preValidatePurchase(_beneficiary, weiAmount);
uint256 tokens = _getTokenAmount(weiAmount);
weiRaised = weiRaised.add(weiAmount);
_processPurchase(_beneficiary, tokens);
emit TokenPurchase(msg.sender, _beneficiary, weiAmount, tokens);
_forwardFunds();
}
function _preValidatePurchase(address _beneficiary, uint256 _weiAmount) internal whenNotPaused {
require(_beneficiary != address(0));
require(_weiAmount >= minInvest);
require(now >= openingTime && now <= closingTime);
}
function _deliverTokens(address _beneficiary, uint256 _tokenAmount) internal {
require(MintableToken(token).mint(_beneficiary, _tokenAmount));
}
function _processPurchase(address _beneficiary, uint256 _tokenAmount) internal {
_deliverTokens(_beneficiary, _tokenAmount);
}
function _getTokenAmount(uint256 _weiAmount) internal view returns (uint256) {
uint256 currentRate = getCurrentRate();
return currentRate.mul(_weiAmount);
}
function _forwardFunds() internal {
vault.deposit.value(msg.value)(msg.sender);
}
function hasClosed() public view returns (bool) {
return now > closingTime;
}
bool public isFinalized = false;
event Finalized();
function finalize() onlyOwner public {
require(!isFinalized);
require(hasClosed());
finalization();
emit Finalized();
isFinalized = true;
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
} else {
vault.enableRefunds();
}
}
}