pragma solidity 0.4.17;
contract ERC20Basic {
uint256 public totalSupply;
function balanceOf(address who) public constant returns (uint256);
function transfer(address to, uint256 value) public returns (bool);
event Transfer(address indexed from, address indexed to, uint256 value);
}
contract Ownable {
address internal owner;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
function Ownable() public {
owner = msg.sender;
}
modifier onlyOwner() {
require(msg.sender == owner);
_;
}
function transferOwnership(address newOwner) onlyOwner public {
require(newOwner != address(0));
OwnershipTransferred(owner, newOwner);
owner = newOwner;
}
}
contract BasicToken is ERC20Basic {
using SafeMath for uint256;
mapping(address => uint256) balances;
function transfer(address _to, uint256 _value) public returns (bool) {
require(_to != address(0));
balances[msg.sender] = balances[msg.sender].sub(_value);
balances[_to] = balances[_to].add(_value);
Transfer(msg.sender, _to, _value);
return true;
}
function balanceOf(address _owner) public constant returns (uint256 balance) {
return balances[_owner];
}
}
contract ERC20 is ERC20Basic {
function allowance(address owner, address spender) public constant returns (uint256);
function transferFrom(address from, address to, uint256 value) public returns (bool);
function approve(address spender, uint256 value) public returns (bool);
event Approval(address indexed owner, address indexed spender, uint256 value);
}
contract StandardToken is ERC20, BasicToken {
mapping (address => mapping (address => uint256)) allowed;
function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
require(_to != address(0));
uint256 _allowance = allowed[_from][msg.sender];
balances[_from] = balances[_from].sub(_value);
balances[_to] = balances[_to].add(_value);
allowed[_from][msg.sender] = _allowance.sub(_value);
Transfer(_from, _to, _value);
return true;
}
function approve(address _spender, uint256 _value) public returns (bool) {
allowed[msg.sender][_spender] = _value;
Approval(msg.sender, _spender, _value);
return true;
}
function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
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
contract MintableToken is StandardToken, Ownable {
event Mint(address indexed to, uint256 amount);
event MintFinished();
bool public mintingFinished = false;
modifier canMint() {
require(!mintingFinished);
_;
}
function mint(address _to, uint256 _amount) onlyOwner canMint public returns (bool) {
balances[_to] = balances[_to].add(_amount);
Mint(_to, _amount);
Transfer(msg.sender, _to, _amount);
return true;
}
function finishMinting() onlyOwner public returns (bool) {
mintingFinished = true;
MintFinished();
return true;
}
function burnTokens(uint256 _unsoldTokens) onlyOwner public returns (bool) {
totalSupply = SafeMath.sub(totalSupply, _unsoldTokens);
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
Pause();
}
function unpause() onlyOwner whenPaused public {
paused = false;
Unpause();
}
}
contract Crowdsale is Ownable, Pausable {
using SafeMath for uint256;
MintableToken internal token;
address internal wallet;
uint256 public rate;
uint256 internal weiRaised;
uint256 public privateSaleStartTime;
uint256 public privateSaleEndTime;
uint internal privateSaleBonus;
uint256 public totalSupply = SafeMath.mul(400000000, 1 ether);
uint256 internal privateSaleSupply = SafeMath.mul(SafeMath.div(totalSupply,100),20);
bool internal checkUnsoldTokens;
event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);
function Crowdsale(uint256 _startTime, uint256 _endTime, uint256 _rate, address _wallet) internal {
require(_wallet != 0x0);
token = createTokenContract();
privateSaleStartTime = _startTime;
privateSaleEndTime = _endTime;
rate = _rate;
wallet = _wallet;
privateSaleBonus = SafeMath.div(SafeMath.mul(rate,50),100);
}
function createTokenContract() internal returns (MintableToken) {
return new MintableToken();
}
function () payable {
buyTokens(msg.sender);
}
function privateSaleTokens(uint256 weiAmount, uint256 tokens) internal returns (uint256) {
require(privateSaleSupply > 0);
tokens = SafeMath.add(tokens, weiAmount.mul(privateSaleBonus));
tokens = SafeMath.add(tokens, weiAmount.mul(rate));
require(privateSaleSupply >= tokens);
privateSaleSupply = privateSaleSupply.sub(tokens);
return tokens;
}
function buyTokens(address beneficiary) whenNotPaused public payable {
require(beneficiary != 0x0);
require(validPurchase());
uint256 accessTime = now;
uint256 tokens = 0;
uint256 weiAmount = msg.value;
require((weiAmount >= (100000000000000000)) && (weiAmount <= (20000000000000000000)));
if ((accessTime >= privateSaleStartTime) && (accessTime < privateSaleEndTime)) {
tokens = privateSaleTokens(weiAmount, tokens);
} else {
revert();
}
privateSaleSupply = privateSaleSupply.sub(tokens);
weiRaised = weiRaised.add(weiAmount);
token.mint(beneficiary, tokens);
TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);
forwardFunds();
}
function forwardFunds() internal {
wallet.transfer(msg.value);
}
function validPurchase() internal constant returns (bool) {
bool withinPeriod = now >= privateSaleStartTime && now <= privateSaleEndTime;
bool nonZeroPurchase = msg.value != 0;
return withinPeriod && nonZeroPurchase;
}
function hasEnded() public constant returns (bool) {
return now > privateSaleEndTime;
}
function getTokenAddress() onlyOwner public returns (address) {
return token;
}
}
contract AutoCoinToken is MintableToken {
string public constant name = "Auto Coin";
string public constant symbol = "Auto Coin";
uint8 public constant decimals = 18;
uint256 public constant _totalSupply = 400000000 * 1 ether;
function AutoCoinToken() {
totalSupply = _totalSupply;
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
contract CrowdsaleFunctions is Crowdsale {
function transferAirdropTokens(address[] beneficiary, uint256[] tokens) onlyOwner public {
for (uint256 i = 0; i < beneficiary.length; i++) {
tokens[i] = SafeMath.mul(tokens[i], 1 ether);
require(privateSaleSupply >= tokens[i]);
privateSaleSupply = SafeMath.sub(privateSaleSupply, tokens[i]);
token.mint(beneficiary[i], tokens[i]);
}
}
function transferTokens(address beneficiary, uint256 tokens) onlyOwner public {
require(privateSaleSupply > 0);
tokens = SafeMath.mul(tokens,1 ether);
require(privateSaleSupply >= tokens);
privateSaleSupply = SafeMath.sub(privateSaleSupply, tokens);
token.mint(beneficiary, tokens);
}
}
contract AutoCoinICO is Crowdsale, CrowdsaleFunctions {
function AutoCoinICO(uint256 _startTime, uint256 _endTime, uint256 _rate, address _wallet)
Crowdsale(_startTime,_endTime,_rate,_wallet)
{
}
function createTokenContract() internal returns (MintableToken) {
return new AutoCoinToken();
}
}