pragma solidity ^0.4.18;
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
uint256 public releaseTime;
function TokenTimelock(ERC20Basic _token, address _beneficiary, uint256 _releaseTime) public {
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
contract TokenVesting is Ownable {
using SafeMath for uint256;
using SafeERC20 for ERC20Basic;
event Released(uint256 amount);
event Revoked();
address public beneficiary;
uint256 public cliff;
uint256 public start;
uint256 public duration;
bool public revocable;
mapping (address => uint256) public released;
mapping (address => bool) public revoked;
function TokenVesting(address _beneficiary, uint256 _start, uint256 _cliff, uint256 _duration, bool _revocable) public {
require(_beneficiary != address(0));
require(_cliff <= _duration);
beneficiary = _beneficiary;
revocable = _revocable;
duration = _duration;
cliff = _start.add(_cliff);
start = _start;
}
function release(ERC20Basic token) public {
uint256 unreleased = releasableAmount(token);
require(unreleased > 0);
released[token] = released[token].add(unreleased);
token.safeTransfer(beneficiary, unreleased);
Released(unreleased);
}
function revoke(ERC20Basic token) public onlyOwner {
require(revocable);
require(!revoked[token]);
uint256 balance = token.balanceOf(this);
uint256 unreleased = releasableAmount(token);
uint256 refund = balance.sub(unreleased);
revoked[token] = true;
token.safeTransfer(owner, refund);
Revoked();
}
function releasableAmount(ERC20Basic token) public view returns (uint256) {
return vestedAmount(token).sub(released[token]);
}
function vestedAmount(ERC20Basic token) public view returns (uint256) {
uint256 currentBalance = token.balanceOf(this);
uint256 totalBalance = currentBalance.add(released[token]);
if (now < cliff) {
return 0;
} else if (now >= start.add(duration) || revoked[token]) {
return totalBalance;
} else {
return totalBalance.mul(now.sub(start)).div(duration);
}
}
}
contract InitialTokenDistribution is Ownable {
using SafeMath for uint256;
ERC20 public token;
mapping (address => uint256) public initiallyDistributed;
bool public initialDistributionDone = false;
modifier onInitialDistribution() {
require(!initialDistributionDone);
_;
}
function InitialTokenDistribution(ERC20 _token) public {
token = _token;
}
function totalTokensDistributed() public view returns (uint256);
function processInitialDistribution() onInitialDistribution onlyOwner public {
initialDistribution();
initialDistributionDone = true;
}
function initialTransfer(address to, uint256 amount) onInitialDistribution public {
require(to != address(0));
initiallyDistributed[to] = amount;
token.transferFrom(msg.sender, to, amount);
}
function initialDistribution() internal;
}
contract DetailedERC20 is ERC20 {
string public name;
string public symbol;
uint8 public decimals;
function DetailedERC20(string _name, string _symbol, uint8 _decimals) public {
name = _name;
symbol = _symbol;
decimals = _decimals;
}
}
contract CurrentInitialTokenDistribution is InitialTokenDistribution {
uint256 public reservedTokensFounders;
uint256 public reservedOperationalExpenses;
uint256 public reservedIcoCrowdsale;
address public foundersWallet;
address public operationalExpensesWallet;
address public icoCrowdsaleContract;
function CurrentInitialTokenDistribution (
DetailedERC20 _token,
address _foundersWallet,
address _operationalExpensesWallet,
address _icoCrowdsaleContract
) InitialTokenDistribution(_token) public
{
foundersWallet = _foundersWallet;
operationalExpensesWallet = _operationalExpensesWallet;
icoCrowdsaleContract = _icoCrowdsaleContract;
uint8 decimals = _token.decimals();
reservedTokensFounders = 40e9 * (10 ** uint256(decimals));
reservedOperationalExpenses = 10e9 * (10 ** uint256(decimals));
reservedIcoCrowdsale = 499e8 * (10 ** uint256(decimals));
}
function totalTokensDistributed() public view returns (uint256) {
return reservedTokensFounders + reservedOperationalExpenses + reservedIcoCrowdsale;
}
function initialDistribution() internal {
initialTransfer(foundersWallet, reservedTokensFounders);
initialTransfer(operationalExpensesWallet, reservedOperationalExpenses);
initialTransfer(icoCrowdsaleContract, reservedIcoCrowdsale);
}
}