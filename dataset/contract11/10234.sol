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
interface tokenRecipient {
function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) public;
}
contract LuHuToken is PausableToken {
using SafeERC20 for ERC20;
using SafeMath for uint;
uint public constant TOKEN_PER_ETHER = 60000;
uint private CONTRIBUTIONS_MIN = 1 ether;
uint constant public OFFSET = 420;
uint constant public MIN_CROWSALE_TIME = 600;
uint8 public constant DECIMALS = 18;
uint public constant DECIMALSFACTOR = 10 ** uint(DECIMALS);
uint public constant TOKENS_TOTAL = 100 * 10 ** 8 * DECIMALSFACTOR;
uint public constant TOKENS_CAP_ICO = 25 * 10 ** 8 * DECIMALSFACTOR;
string public name = "LuHuToken";
uint8 public decimals = DECIMALS;
uint public divider = 10 ** uint(18 - decimals);
string public symbol;
mapping(address => uint256) public weiBalances;
uint public period = 30 days;
uint public startDate = 1519862400;
uint public endDate = startDate + period;
function setStartDate(uint _startDate) public onlyOwner {
uint nowTime = getNow();
require(startDate > nowTime);
require(_startDate > nowTime);
startDate = _startDate;
uint tempEndDate = startDate.add(MIN_CROWSALE_TIME);
if (endDate < tempEndDate) {
endDate = tempEndDate;
}
}
function setEndDate(uint _endDate) public onlyOwner {
uint nowTime = getNow();
require(endDate > nowTime);
require(_endDate > nowTime);
endDate = _endDate;
}
address public wallet;
uint public fakeNow = 0;
uint public crowsaleShare = 0;
function getNow() internal view returns (uint) {
if (fakeNow == 0) {
return now;
}
return fakeNow;
}
modifier validAddress(address addr) {
require(addr != address(0x0));
_;
}
mapping(address => bool) userWhitelist;
function whitelist(address user) onlyOwner public {
userWhitelist[user] = true;
}
function unWhitelist(address user) onlyOwner public {
userWhitelist[user] = false;
}
function isInWhitelist(address user) internal view returns (bool) {
return userWhitelist[user];
}
function LuHuToken(string _symbol, address _wallet) validAddress(_wallet) public {
symbol = _symbol;
totalSupply_ = TOKENS_TOTAL;
wallet = _wallet;
balances[wallet] = totalSupply_;
}
function () external payable {
proxyPayment(msg.sender);
}
function hasEnded() public view returns (bool) {
return getNow() > endDate;
}
function proxyPayment(address participant) public payable {
require(participant != address(0x0));
uint nowTime = getNow();
require(nowTime >= startDate && nowTime <= endDate);
require(isInWhitelist(msg.sender));
require(isInWhitelist(participant));
uint weiRaised = msg.value;
require(weiRaised >= CONTRIBUTIONS_MIN);
uint tokens = TOKEN_PER_ETHER.mul(weiRaised);
crowsaleShare = crowsaleShare.add(tokens);
require(crowsaleShare <= TOKENS_CAP_ICO);
weiBalances[participant] = weiBalances[participant].add(weiRaised);
balances[participant] = balances[participant].add(tokens);
balances[wallet] = balances[wallet].sub(tokens);
wallet.transfer(weiRaised);
TokenPurchase(wallet, msg.sender, participant, weiRaised, tokens);
}
function changeWallet(address _wallet) onlyOwner public {
require(_wallet != address(0x0));
require(_wallet != wallet);
balances[_wallet] = balances[wallet];
balances[wallet] = 0;
wallet = _wallet;
WalletUpdated(wallet);
}
function approveAndCall(address _spender, uint256 _value, bytes _extraData) public
returns (bool success)
{
tokenRecipient spender = tokenRecipient(_spender);
if (approve(_spender, _value)) {
spender.receiveApproval(msg.sender, _value, this, _extraData);
return true;
}
return false;
}
event TokenPurchase(address indexed wallet, address indexed purchaser, address indexed beneficiary,
uint256 value, uint256 amount);
event WalletUpdated(address newWallet);
}
contract TokenMock is LuHuToken {
function TokenMock(string symbol, address wallet) LuHuToken(symbol, wallet) public {
}
function setNow(uint _now) public onlyOwner {
fakeNow = _now;
}
function getNowFromOwner() public view returns (uint time) {
return getNow();
}
}