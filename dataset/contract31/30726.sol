pragma solidity ^0.4.13;
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
contract ERC20Basic {
uint256 public totalSupply;
function balanceOf(address who) public constant returns (uint256);
function transfer(address to, uint256 value) public returns (bool);
event Transfer(address indexed from, address indexed to, uint256 value);
}
contract ERC20 is ERC20Basic {
function allowance(address owner, address spender) public constant returns (uint256);
function transferFrom(address from, address to, uint256 value) public returns (bool);
function approve(address spender, uint256 value) public returns (bool);
event Approval(address indexed owner, address indexed spender, uint256 value);
}
contract FornicoinPresale {
using SafeMath for uint256;
uint256 public startPresale;
uint256 public endPresale;
mapping (address => uint256) contributors;
address public wallet;
address public admin;
bool public haltSale;
uint256 public weiRaised;
uint256 public presaleRate = (1300 * (10 ** uint256(18)))/(1 ether);
event TokenPurchase(address indexed purchaser, uint256 value, uint256 amount);
function FornicoinPresale(address _wallet, uint256 _startTime, address _admin) {
require(_startTime >= now);
require(_wallet != 0x0);
admin = _admin;
startPresale = _startTime;
endPresale = startPresale + 7 days;
wallet = _wallet;
}
function setHaltSale( bool halt ) {
require( msg.sender == admin );
haltSale = halt;
}
function () payable {
buyTokens();
}
function buyTokens() public payable {
require(tx.gasprice <= 50000000000 wei);
require(!haltSale);
require(!hasEnded());
require(validPurchase());
uint256 weiAmount = msg.value;
uint256 tokens = weiAmount.mul(presaleRate);
contributors[msg.sender] = contributors[msg.sender].add(tokens);
weiRaised = weiRaised.add(weiAmount);
TokenPurchase(msg.sender, weiAmount, tokens);
forwardFunds();
}
function forwardFunds() internal {
wallet.transfer(msg.value);
}
function validPurchase() internal constant returns (bool) {
bool withinPeriod = now >= startPresale && now <= endPresale;
bool nonZeroPurchase = msg.value >= 2 ether;
return withinPeriod && nonZeroPurchase;
}
function emergencyDrain(ERC20 anyToken) returns(bool){
require(msg.sender == admin);
require(hasEnded());
if(this.balance > 0) {
wallet.transfer(this.balance);
}
if(anyToken != address(0x0)) {
assert(anyToken.transfer(wallet, anyToken.balanceOf(this)));
}
return true;
}
function hasEnded() public constant returns (bool) {
return now > endPresale;
}
}