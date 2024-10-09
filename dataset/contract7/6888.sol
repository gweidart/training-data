pragma solidity ^0.4.18;
contract owned {
address public owner;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
function owned() public {
owner = msg.sender;
}
modifier onlyOwner {
require(msg.sender == owner);
_;
}
function transferOwnership(address newOwner) onlyOwner public {
owner = newOwner;
}
}
interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) public; }
contract NecashTokenBase {
string public constant _myTokeName = 'Necash Token';
string public constant _mySymbol = 'NEC';
uint public constant _myinitialSupply = 20000000;
string public name;
string public symbol;
uint256 public decimals = 18;
uint256 public totalSupply;
mapping (address => uint256) public balanceOf;
mapping (address => mapping (address => uint256)) public allowance;
event Transfer(address indexed from, address indexed to, uint256 value);
event Burn(address indexed from, uint256 value);
function NecashTokenBase() public {
totalSupply = _myinitialSupply * (10 ** uint256(decimals));
balanceOf[msg.sender] = totalSupply;
name = _myTokeName;
symbol = _mySymbol;
}
function _transfer(address _from, address _to, uint _value) internal {
require(_to != 0x0);
require(balanceOf[_from] >= _value);
require(balanceOf[_to] + _value > balanceOf[_to]);
uint previousBalances = balanceOf[_from] + balanceOf[_to];
balanceOf[_from] -= _value;
balanceOf[_to] += _value;
Transfer(_from, _to, _value);
assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
}
function transfer(address _to, uint256 _value) public {
_transfer(msg.sender, _to, _value);
}
function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
require(_value <= allowance[_from][msg.sender]);
allowance[_from][msg.sender] -= _value;
_transfer(_from, _to, _value);
return true;
}
function approve(address _spender, uint256 _value) public
returns (bool success) {
allowance[msg.sender][_spender] = _value;
return true;
}
function approveAndCall(address _spender, uint256 _value, bytes _extraData)
public
returns (bool success) {
tokenRecipient spender = tokenRecipient(_spender);
if (approve(_spender, _value)) {
spender.receiveApproval(msg.sender, _value, this, _extraData);
return true;
}
}
}
contract NecashToken is owned, NecashTokenBase {
mapping (address => bool) public frozenAccount;
event FrozenFunds(address target, bool frozen);
function NecashToken() NecashTokenBase() public {}
function _transfer(address _from, address _to, uint _value) internal {
require (_to != 0x0);
require (balanceOf[_from] >= _value);
require (balanceOf[_to] + _value > balanceOf[_to]);
require(!frozenAccount[_from]);
require(!frozenAccount[_to]);
balanceOf[_from] -= _value;
balanceOf[_to] += _value;
Transfer(_from, _to, _value);
}
function freezeAccount(address target, bool freeze) onlyOwner public {
frozenAccount[target] = freeze;
FrozenFunds(target, freeze);
}
}
contract Pausable is owned {
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
contract NeCashTokenSale is owned, Pausable {
using SafeMath for uint256;
event Purchase(address indexed buyer, uint256 weiAmount, uint256 tokenAmount);
event Finalized(uint256 tokensSold, uint256 weiAmount);
NecashToken public necashToken;
uint256 public startTime;
uint256 public weiRaised;
uint256 public tokensSold;
bool public finalized = false;
address public wallet;
uint256 public maxGasPrice = 50000000000;
uint256 public tokenPerEth = 1000;
uint256[4] public rates;
mapping (address => uint256) public contributors;
uint256 public constant minimumPurchase = 0.1 ether;
uint256 public constant maximumPurchase = 10 ether;
function NeCashTokenSale() public
{
necashToken = NecashToken(address(0xd4e179eadf65d230c0c0ab7540edf03715596c92));
startTime = 1530362569;
wallet = address(0xBC03d69aF2E5c329F5b4eE09ad01AcC8A7e8F719);
}
function () payable whenNotPaused public {
buyTokens();
}
function buyTokens() payable whenNotPaused public {
require(isValidPurchase());
uint256 amount = msg.value;
uint256 tokens = calculateTokenAmount(amount);
uint256 maxSellToken = necashToken.balanceOf(address(this));
if(tokens > maxSellToken){
uint256 possibleTokens = maxSellToken.sub(tokens);
uint256 change = calculatePriceForTokens(tokens.sub(possibleTokens));
msg.sender.transfer(change);
tokens = possibleTokens;
amount = amount.sub(change);
}
contributors[msg.sender] = contributors[msg.sender].add(amount);
necashToken.transfer(msg.sender, tokens);
tokensSold = tokensSold.add(tokens);
weiRaised = weiRaised.add(amount);
forwardFunds(amount);
Purchase(msg.sender, amount, tokens);
}
function changeMaxGasprice(uint256 _gasPrice)
public onlyOwner whenNotPaused
{
maxGasPrice = _gasPrice;
}
function changeTokenPrice(uint256 _tokens)
public onlyOwner whenNotPaused
{
tokenPerEth = _tokens;
}
function endSale() public onlyOwner whenNotPaused {
require(finalized == false);
finalizeSale();
}
function isValidPurchase() view internal returns(bool valid) {
require(now >= startTime);
require(msg.value >= minimumPurchase);
require(msg.value <= maximumPurchase);
require(tx.gasprice <= maxGasPrice);
return true;
}
function forwardFunds(uint256 _amount) internal {
wallet.transfer(_amount);
}
function calculateTokenAmount(uint256 weiAmount) view internal returns(uint256 tokenAmount){
return weiAmount.mul(tokenPerEth);
}
function calculatePriceForTokens(uint256 tokenAmount) view internal returns(uint256 weiAmount){
return tokenAmount.div(tokenPerEth);
}
function finalizeSale() internal {
finalized = true;
Finalized(tokensSold, weiRaised);
}
}