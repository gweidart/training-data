pragma solidity ^0.4.18;
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
contract ERC20Basic {
uint256 public totalSupply;
function balanceOf(address who) public view returns (uint256);
function transfer(address to, uint256 value) public returns (bool);
event Transfer(address indexed from, address indexed to, uint256 value);
}
contract BasicToken is ERC20Basic {
using SafeMath for uint256;
mapping(address => uint256) balances;
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
contract PausableToken is StandardToken, Pausable {
function transfer(address _to, uint256 _value) public whenNotPaused returns (bool) {
return super.transfer(_to, _value);
}
function transferFrom(address _from, address _to, uint256 _value) public whenNotPaused returns (bool) {
return super.transferFrom(_from, _to, _value);
}
function approve(address _spender, uint256 _value) public whenNotPaused returns (bool) {
return super.approve(_spender, _value);
}
function increaseApproval(address _spender, uint _addedValue) public whenNotPaused returns (bool success) {
return super.increaseApproval(_spender, _addedValue);
}
function decreaseApproval(address _spender, uint _subtractedValue) public whenNotPaused returns (bool success) {
return super.decreaseApproval(_spender, _subtractedValue);
}
}
contract BearToken is PausableToken {
using SafeMath for uint;
string public constant name = "BearToken";
string public constant symbol = "BBC";
uint public constant decimals = 18;
uint public maxTotalSupply;
address public minter;
modifier onlyMinter {
assert(msg.sender == minter);
_;
}
modifier isLaterThan (uint x){
assert(now > x);
_;
}
modifier maxTokenAmountNotReached (uint amount){
assert(totalSupply.add(amount) <= maxTotalSupply);
_;
}
modifier validAddress( address addr ) {
require(addr != address(0x0));
require(addr != address(this));
_;
}
function BearToken(address _minter, address _admin, uint _maxTotalSupply)
public
validAddress(_admin)
validAddress(_minter)
{
minter = _minter;
maxTotalSupply = _maxTotalSupply;
transferOwnership(_admin);
}
function mint(address receipent, uint amount)
external
onlyMinter
maxTokenAmountNotReached(amount)
returns (bool)
{
balances[receipent] = balances[receipent].add(amount);
totalSupply = totalSupply.add(amount);
return true;
}
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
contract TokenTimelock {
using SafeERC20 for ERC20Basic;
ERC20Basic public token;
address public beneficiary;
uint public releaseTime;
function TokenTimelock(ERC20Basic _token, address _beneficiary, uint _releaseTime) public {
require(_releaseTime > now);
token = _token;
beneficiary = _beneficiary;
releaseTime = _releaseTime;
}
function release() public {
require(now >= releaseTime);
uint256 amount = token.balanceOf(this);
require(amount > 0);
token.safeTransfer(beneficiary, amount);
}
}
contract BearCrowdSale is Pausable {
using SafeMath for uint;
uint public constant TOTAL_SUPPLY = 1000000000000 ether;
uint public constant MAX_SALE_DURATION = 3 years;
uint public constant LOCK_TIME =  1 days;
uint public constant PRICE_RATE_FIRST = 10000000;
uint public constant PRICE_RATE_SECOND = 5000000;
uint public constant PRICE_RATE_LAST = 2500000;
uint256 public minBuyLimit = 0.01 ether;
uint256 public maxBuyLimit = 100 ether;
uint public constant LOCK_STAKE = 50;
uint public constant OPEN_SALE_STAKE = 25;
uint public constant TEAM_STAKE = 25;
uint public constant DIVISOR_STAKE = 100;
uint public constant MAX_OPEN_SOLD = TOTAL_SUPPLY * OPEN_SALE_STAKE / DIVISOR_STAKE;
uint public constant STAKE_MULTIPLIER = TOTAL_SUPPLY / DIVISOR_STAKE;
address public wallet;
address public lockAddress;
address public teamAddress;
uint public startTime;
uint public endTime;
uint public openSoldTokens;
BearToken public bearToken;
TokenTimelock public tokenTimelock;
event NewSale(address indexed destAddress, uint ethCost, uint gotTokens);
event NewWallet(address onwer, address oldWallet, address newWallet);
modifier notEarlierThan(uint x) {
require(now >= x);
_;
}
modifier earlierThan(uint x) {
require(now < x);
_;
}
modifier ceilingNotReached() {
require(openSoldTokens < MAX_OPEN_SOLD);
_;
}
modifier isSaleEnded() {
require(now > endTime || openSoldTokens >= MAX_OPEN_SOLD);
_;
}
modifier validAddress( address addr ) {
require(addr != address(0x0));
require(addr != address(this));
_;
}
function BearCrowdSale (address _admin,
address _wallet,
address _lockAddress,
address _teamAddress
) public
validAddress(_admin)
validAddress(_wallet)
validAddress(_lockAddress)
validAddress(_teamAddress)
{
wallet = _wallet;
lockAddress = _lockAddress;
teamAddress = _teamAddress;
startTime = now;
endTime = startTime + MAX_SALE_DURATION;
openSoldTokens = 0;
bearToken = new BearToken(this, _admin, TOTAL_SUPPLY);
tokenTimelock = new TokenTimelock(bearToken, lockAddress, now + LOCK_TIME);
bearToken.mint(tokenTimelock, LOCK_STAKE * STAKE_MULTIPLIER);
bearToken.mint(teamAddress, TEAM_STAKE * STAKE_MULTIPLIER);
transferOwnership(_admin);
}
function setMaxBuyLimit(uint256 limit)
public
onlyOwner
earlierThan(endTime)
{
maxBuyLimit = limit;
}
function setMinBuyLimit(uint256 limit)
public
onlyOwner
earlierThan(endTime)
{
minBuyLimit = limit;
}
function setWallet(address newAddress)  external onlyOwner {
NewWallet(owner, wallet, newAddress);
wallet = newAddress;
}
function saleNotEnd() constant internal returns (bool) {
return now < endTime && openSoldTokens < MAX_OPEN_SOLD;
}
function () public payable {
buyBBC(msg.sender);
}
function buyBBC(address receipient)
public
payable
whenNotPaused
ceilingNotReached
earlierThan(endTime)
validAddress(receipient)
returns (bool)
{
require(msg.value >= minBuyLimit);
require(msg.value <= maxBuyLimit);
require(!isContract(msg.sender));
require(tx.gasprice <= 50000000000 wei);
doBuy(receipient);
return true;
}
function doBuy(address receipient) internal {
uint tokenAvailable = MAX_OPEN_SOLD.sub(openSoldTokens);
require(tokenAvailable > 0);
uint toFund;
uint toCollect;
(toFund, toCollect) = costAndBuyTokens(tokenAvailable);
if (toFund > 0) {
require(bearToken.mint(receipient, toCollect));
wallet.transfer(toFund);
openSoldTokens = openSoldTokens.add(toCollect);
NewSale(receipient, toFund, toCollect);
}
uint toReturn = msg.value.sub(toFund);
if (toReturn > 0) {
msg.sender.transfer(toReturn);
}
}
function priceRate() public view returns (uint) {
if (startTime <= now && now < startTime + 1 years ) {
return  PRICE_RATE_FIRST;
}else if (startTime + 1 years <= now && now < startTime + 2 years ) {
return PRICE_RATE_SECOND;
}else if (startTime + 2 years <= now && now < endTime) {
return PRICE_RATE_LAST;
}else {
assert(false);
}
return now;
}
function costAndBuyTokens(uint availableToken) constant internal returns (uint costValue, uint getTokens) {
uint exchangeRate = priceRate();
getTokens = exchangeRate * msg.value;
if (availableToken >= getTokens) {
costValue = msg.value;
} else {
costValue = availableToken / exchangeRate;
getTokens = availableToken;
}
}
function isContract(address _addr) constant internal returns(bool) {
uint size;
if (_addr == 0) {
return false;
}
assembly {
size := extcodesize(_addr)
}
return size > 0;
}
function releaseLockToken()  external onlyOwner {
tokenTimelock.release();
}
}