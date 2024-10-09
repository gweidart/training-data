pragma solidity ^0.4.18;
library SafeMath {
function mul(uint256 a, uint256 b) internal pure returns (uint256) {
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
function max64(uint64 a, uint64 b) internal pure returns (uint64) {
return a >= b ? a : b;
}
function min64(uint64 a, uint64 b) internal pure returns (uint64) {
return a < b ? a : b;
}
function max256(uint256 a, uint256 b) internal pure returns (uint256) {
return a >= b ? a : b;
}
function min256(uint256 a, uint256 b) internal pure returns (uint256) {
return a < b ? a : b;
}
}
contract ERC20Basic {
uint256 public totalSupply;
bool public transfersEnabled;
function balanceOf(address who) public view returns (uint256);
function transfer(address to, uint256 value) public returns (bool);
event Transfer(address indexed from, address indexed to, uint256 value);
}
contract ERC20 {
uint256 public totalSupply;
bool public transfersEnabled;
function balanceOf(address _owner) public constant returns (uint256 balance);
function transfer(address _to, uint256 _value) public returns (bool success);
function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
function approve(address _spender, uint256 _value) public returns (bool success);
function allowance(address _owner, address _spender) public constant returns (uint256 remaining);
event Transfer(address indexed _from, address indexed _to, uint256 _value);
event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}
contract BasicToken is ERC20Basic {
using SafeMath for uint256;
mapping (address => uint256) balances;
modifier onlyPayloadSize(uint numwords) {
assert(msg.data.length == numwords * 32 + 4);
_;
}
function transfer(address _to, uint256 _value) public onlyPayloadSize(2) returns (bool) {
require(_to != address(0));
require(_value <= balances[msg.sender]);
require(transfersEnabled);
balances[msg.sender] = balances[msg.sender].sub(_value);
balances[_to] = balances[_to].add(_value);
Transfer(msg.sender, _to, _value);
return true;
}
function balanceOf(address _owner) public constant returns (uint256 balance) {
return balances[_owner];
}
}
contract StandardToken is ERC20, BasicToken {
mapping (address => mapping (address => uint256)) internal allowed;
function transferFrom(address _from, address _to, uint256 _value) public onlyPayloadSize(3) returns (bool) {
require(_to != address(0));
require(_value <= balances[_from]);
require(_value <= allowed[_from][msg.sender]);
require(transfersEnabled);
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
function allowance(address _owner, address _spender) public onlyPayloadSize(2) constant returns (uint256 remaining) {
return allowed[_owner][_spender];
}
function increaseApproval(address _spender, uint _addedValue) public returns (bool success) {
allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
return true;
}
function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool success) {
uint oldValue = allowed[msg.sender][_spender];
if (_subtractedValue > oldValue) {
allowed[msg.sender][_spender] = 0;
}
else {
allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
}
Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
return true;
}
}
contract Ownable {
address public owner;
event OwnerChanged(address indexed previousOwner, address indexed newOwner);
function Ownable() public {
}
modifier onlyOwner() {
require(msg.sender == owner);
_;
}
function changeOwner(address newOwner) onlyOwner internal {
require(newOwner != address(0));
OwnerChanged(owner, newOwner);
owner = newOwner;
}
}
contract MintableToken is StandardToken, Ownable {
string public constant name = "Bitcoin Futures Alpha";
string public constant symbol = "BFA";
uint8 public constant decimals = 10;
event Mint(address indexed to, uint256 amount);
event MintFinished();
bool public mintingFinished;
modifier canMint() {
require(!mintingFinished);
_;
}
function mint(address _to, uint256 _amount, address _owner) canMint internal returns (bool) {
balances[_to] = balances[_to].add(_amount);
balances[_owner] = balances[_owner].sub(_amount);
Mint(_to, _amount);
Transfer(_owner, _to, _amount);
return true;
}
function finishMinting() onlyOwner canMint internal returns (bool) {
mintingFinished = true;
MintFinished();
return true;
}
function claimTokens(address _token) public onlyOwner {
if (_token == 0x0) {
owner.transfer(this.balance);
return;
}
MintableToken token = MintableToken(_token);
uint256 balance = token.balanceOf(this);
token.transfer(owner, balance);
Transfer(_token, owner, balance);
}
}
contract Crowdsale is Ownable {
using SafeMath for uint256;
address public wallet;
uint256 public weiRaised;
uint256 public tokenAllocated;
function Crowdsale(
address _wallet
)
public
{
require(_wallet != address(0));
wallet = _wallet;
}
}
contract BTACrowdsale is Ownable, Crowdsale, MintableToken {
using SafeMath for uint256;
enum State {Active, Closed}
State public state;
uint256[] public rates  = [300, 290, 275, 250];
uint256[] public weiMinSale =  [10*10**16,  5*10**16, 1*10**16, 0];
mapping (address => uint256) public deposited;
uint256 public constant INITIAL_SUPPLY = 2000 * (10 ** 6) * (10 ** uint256(decimals));
uint256 public fundForSale = 1550 * (10 ** 6) * (10 ** uint256(decimals));
uint256 public fundForTeam =  450 * (10 ** 6) * (10 ** uint256(decimals));
uint256 public countInvestor;
event TokenPurchase(address indexed beneficiary, uint256 value, uint256 amount);
event TokenLimitReached(uint256 tokenRaised, uint256 purchasedToken);
event Finalized();
function BTACrowdsale(
address _owner,
address _wallet
)
public
Crowdsale(_wallet)
{
require(_wallet != address(0));
require(_owner != address(0));
owner = _owner;
transfersEnabled = true;
mintingFinished = false;
state = State.Active;
totalSupply = INITIAL_SUPPLY;
bool resultMintForOwner = mintForOwner(owner);
require(resultMintForOwner);
}
modifier inState(State _state) {
require(state == _state);
_;
}
function() payable public {
buyTokens(msg.sender);
}
function buyTokens(address _investor) public inState(State.Active) payable returns (uint256){
require(_investor != address(0));
uint256 weiAmount = msg.value;
uint256 tokens = validPurchaseTokens(weiAmount);
if (tokens == 0) {revert();}
weiRaised = weiRaised.add(weiAmount);
tokenAllocated = tokenAllocated.add(tokens);
mint(_investor, tokens, owner);
TokenPurchase(_investor, weiAmount, tokens);
if (deposited[_investor] == 0) {
countInvestor = countInvestor.add(1);
}
deposit(_investor);
wallet.transfer(weiAmount);
return tokens;
}
function getTotalAmountOfTokens(uint256 _weiAmount) internal view returns (uint256) {
uint256 currentDate = now;
uint256 currentPeriod = getPeriod(currentDate);
uint256 amountOfTokens = 0;
if(currentPeriod < 4){
if(_weiAmount < weiMinSale[currentPeriod]){
return 0;
}
amountOfTokens = (_weiAmount.mul(rates[currentPeriod])).div(uint256(10**8));
}
return amountOfTokens;
}
function getPeriod(uint256 _currentDate) public pure returns (uint) {
if( 1519689600 <= _currentDate && _currentDate <= 1521676799){
return 0;
}
if( 1521676800 <= _currentDate && _currentDate <= 1524614399){
return 1;
}
if( 1524614400 <= _currentDate && _currentDate <= 1528415999){
return 2;
}
if( 1528416000 <= _currentDate && _currentDate <= 1532908799){
return 3;
}
return 10;
}
function deposit(address investor) internal {
require(state == State.Active);
deposited[investor] = deposited[investor].add(msg.value);
}
function mintForOwner(address _wallet) internal returns (bool result) {
result = false;
require(_wallet != address(0));
balances[_wallet] = balances[_wallet].add(INITIAL_SUPPLY);
result = true;
}
function getDeposited(address _investor) public view returns (uint256){
return deposited[_investor];
}
function validPurchaseTokens(uint256 _weiAmount) public inState(State.Active) returns (uint256) {
uint256 addTokens = getTotalAmountOfTokens(_weiAmount);
if (tokenAllocated.add(addTokens) > fundForSale) {
TokenLimitReached(tokenAllocated, addTokens);
return 0;
}
return addTokens;
}
function finalize() public onlyOwner inState(State.Active) returns (bool result) {
result = false;
state = State.Closed;
wallet.transfer(this.balance);
finishMinting();
Finalized();
result = true;
}
function removeContract() public onlyOwner {
selfdestruct(owner);
}
}