pragma solidity ^0.4.18;
pragma solidity ^0.4.18;
library SafeMath {
function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
if (a == 0) {
return 0;
}
c = a * b;
assert(c / a == b);
return c;
}
function div(uint256 a, uint256 b) internal pure returns (uint256) {
return a / b;
}
function sub(uint256 a, uint256 b) internal pure returns (uint256) {
assert(b <= a);
return a - b;
}
function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
c = a + b;
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
contract Ownable {
address public owner;
event OwnershipRenounced(address indexed previousOwner);
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
constructor() public {
owner = msg.sender;
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
function renounceOwnership() public onlyOwner {
emit OwnershipRenounced(owner);
owner = address(0);
}
}
contract VIDI1Token is Ownable, ERC20Basic {
using SafeMath for uint256;
string public constant name     = "Vidion private-round token";
string public constant symbol   = "VIDI1";
uint8  public constant decimals = 18;
bool public mintingFinished = false;
mapping(address => uint256) public balances;
address[] public holders;
event Mint(address indexed to, uint256 amount);
event MintFinished();
function mint(address _to, uint256 _amount) onlyOwner canMint public returns (bool) {
totalSupply = totalSupply.add(_amount);
if (balances[_to] == 0) {
holders.push(_to);
}
balances[_to] = balances[_to].add(_amount);
Mint(_to, _amount);
Transfer(address(0), _to, _amount);
return true;
}
function finishMinting() onlyOwner canMint public returns (bool) {
mintingFinished = true;
MintFinished();
return true;
}
function transfer(address, uint256) public returns (bool) {
revert();
return false;
}
function balanceOf(address _owner) public view returns (uint256 balance) {
return balances[_owner];
}
modifier canMint() {
require(!mintingFinished);
_;
}
}
contract Crowdsale is Ownable {
using SafeMath for uint256;
uint256   public constant rate = 12500;
uint256   public constant cap = 12500000 ether;
bool      public isFinalized = false;
uint256   public endTime = 1534377599;
VIDI1Token     public token;
address       public wallet;
uint256       public weiRaised;
uint256   public firstBonus = 30;
uint256   public secondBonus = 50;
event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);
event Finalized();
function Crowdsale (VIDI1Token _VIDI1, address _wallet) public {
assert(address(_VIDI1) != address(0));
assert(_wallet != address(0));
assert(endTime > now);
assert(rate > 0);
assert(cap > 0);
token = _VIDI1;
wallet = _wallet;
}
function () public payable {
buyTokens(msg.sender);
}
function buyTokens(address beneficiary) public payable {
require(beneficiary != address(0));
require(validPurchase());
uint256 weiAmount = msg.value;
uint256 tokens = tokensForWei(weiAmount);
weiRaised = weiRaised.add(weiAmount);
token.mint(beneficiary, tokens);
TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);
forwardFunds();
}
function getBonus(uint256 _tokens, uint256 _weiAmount) public view returns (uint256) {
if (_weiAmount >= 30 ether) {
return _tokens.mul(secondBonus).div(100);
}
return _tokens.mul(firstBonus).div(100);
}
function setFirstBonus(uint256 _newBonus) onlyOwner public {
firstBonus = _newBonus;
}
function setSecondBonus(uint256 _newBonus) onlyOwner public {
secondBonus = _newBonus;
}
function changeEndTime(uint256 _endTime) onlyOwner public {
require(_endTime >= now);
endTime = _endTime;
}
function finalize() onlyOwner public {
require(!isFinalized);
finalization();
Finalized();
isFinalized = true;
}
function forwardFunds() internal {
wallet.transfer(msg.value);
}
function validPurchase() internal view returns (bool) {
bool tokenMintingFinished = token.mintingFinished();
bool withinCap = token.totalSupply().add(tokensForWei(msg.value)) <= cap;
bool withinPeriod = now <= endTime;
bool nonZeroPurchase = msg.value != 0;
bool moreThanMinimumPayment = msg.value >= 1 ether;
return !tokenMintingFinished && withinCap && withinPeriod && nonZeroPurchase && moreThanMinimumPayment;
}
function tokensForWei(uint weiAmount) public view returns (uint tokens) {
tokens = weiAmount.mul(rate);
tokens = tokens.add(getBonus(tokens, weiAmount));
}
function finalization() internal {
token.finishMinting();
endTime = now;
}
function hasEnded() public view returns (bool) {
return now > endTime;
}
}