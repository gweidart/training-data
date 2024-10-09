pragma solidity ^0.4.21;
library SafeMath {
function mul(uint256 a, uint256 b) internal pure returns (uint256) {
if (a == 0) {
return 0;
}
uint256 c = a * b;
require(c / a == b);
return c;
}
function div(uint256 a, uint256 b) internal pure returns (uint256) {
require(b > 0);
uint256 c = a / b;
require(a == b * c + a % b);
return c;
}
function sub(uint256 a, uint256 b) internal pure returns (uint256) {
require(b <= a);
return a - b;
}
function add(uint256 a, uint256 b) internal pure returns (uint256) {
uint256 c = a + b;
require(c >= a);
return c;
}
}
contract ERC20Basic {
uint256 public totalSupply;
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
contract BurnableCADVToken is ERC20 {
uint8 public decimals = 18;
string public name;
string public symbol;
function approve(address _spender, uint256 _value) public returns (bool) {
require(_spender != _spender);
require(_value != _value);
revert();
}
function increaseApproval(address _spender, uint _addedValue) public returns (bool);
function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool);
function multipleTransfer(address[] _tos, uint256 _value) public returns (bool);
function burn(uint256 _value) public;
event Burn(address indexed burner, uint256 value);
}
contract Ownable {
address public owner;
function Ownable() public {
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
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
}
contract ControlledCrowdSale {
using SafeMath for uint256;
mapping (address => uint256) public deposited;
mapping (address => bool) public unboundedLimit;
uint256 public maxPerUser = 5 ether;
uint256 public minPerUser = 1 ether / 1000;
modifier controlledDonation() {
require(msg.value >= minPerUser);
deposited[msg.sender] = deposited[msg.sender].add(msg.value);
require(maxPerUser >= deposited[msg.sender] || unboundedLimit[msg.sender]);
_;
}
}
contract CoinAdvisorPreIco is Ownable, ControlledCrowdSale {
using SafeMath for uint256;
enum State { Active, Refunding, Completed }
struct Phase {
uint expireDate;
uint256 maxAmount;
bool maxAmountEnabled;
uint rate;
bool locked;
}
Phase[] public phases;
uint256 lastActivePhase;
State state;
uint256 public goal;
address public beneficiary;
BurnableCADVToken public token;
uint256 public refunduingStartDate;
event PreIcoClosed(string message, address crowdSaleClosed);
event RefundsEnabled();
event Refunded(address indexed beneficiary, uint256 weiAmount);
event PreIcoStarted(string message, address crowdSaleStarted);
function CoinAdvisorPreIco(address _beneficiary, address _token, uint256 _goal, uint256 _refunduingStartDate) public {
require(_beneficiary != address(0));
beneficiary = _beneficiary;
token = BurnableCADVToken(_token);
phases.push(Phase(0, 0, false, 0, false));
lastActivePhase = 0;
goal = _goal * 1 ether;
state = State.Active;
refunduingStartDate = _refunduingStartDate;
}
function isPhaseValid(uint256 index) public view returns (bool) {
return phases[index].expireDate >= now && (!phases[index].maxAmountEnabled || phases[index].maxAmount > minPerUser);
}
function currentPhaseId() public view returns (uint256) {
uint256 index = lastActivePhase;
while(index < phases.length-1 && !isPhaseValid(index)) {
index = index +1;
}
return index;
}
function addPhases(uint expireDate, uint256 maxAmount, bool maxAmountEnabled, uint rate, bool locked) onlyOwner public {
phases.push(Phase(expireDate, maxAmount, maxAmountEnabled, rate, locked));
}
function resetPhases(uint expireDate, uint256 maxAmount, bool maxAmountEnabled, uint rate, bool locked) onlyOwner public {
require(!phases[currentPhaseId()].locked);
phases.length = 0;
lastActivePhase = 0;
addPhases(expireDate, maxAmount, maxAmountEnabled, rate, locked);
}
function () controlledDonation public payable {
require(state != State.Refunding);
uint256 phaseId = currentPhaseId();
require(isPhaseValid(phaseId));
if (phases[phaseId].maxAmountEnabled) {
if (phases[phaseId].maxAmount >= msg.value) {
phases[phaseId].maxAmount = phases[phaseId].maxAmount.sub(msg.value);
} else {
phases[phaseId].maxAmount = 0;
}
}
require(token.transfer(msg.sender, msg.value.mul(phases[phaseId].rate)));
lastActivePhase = phaseId;
}
function retrieveFounds() onlyOwner public {
require(state == State.Completed || (state == State.Active && address(this).balance >= goal));
state = State.Completed;
beneficiary.transfer(address(this).balance);
}
function startRefunding() public {
require(state == State.Active);
require(address(this).balance < goal);
require(refunduingStartDate < now);
state = State.Refunding;
emit RefundsEnabled();
}
function forceRefunding() onlyOwner public {
require(state == State.Active);
state = State.Refunding;
emit RefundsEnabled();
}
function refund(address investor) public {
require(state == State.Refunding);
require(deposited[investor] > 0);
uint256 depositedValue = deposited[investor];
deposited[investor] = 0;
investor.transfer(depositedValue);
emit Refunded(investor, depositedValue);
}
function retrieveCadvsLeftInRefunding() onlyOwner public {
require(token.balanceOf(this) > 0);
require(token.transfer(beneficiary, token.balanceOf(this)));
}
function gameOver() onlyOwner public {
require(!isPhaseValid(currentPhaseId()));
require(state == State.Completed || (state == State.Active && address(this).balance >= goal));
require(token.transfer(beneficiary, token.balanceOf(this)));
selfdestruct(beneficiary);
}
function setUnboundedLimit(address _investor, bool _state) onlyOwner public {
require(_investor != address(0));
unboundedLimit[_investor] = _state;
}
function currentState() public view returns (string) {
if (state == State.Active) {
return "Active";
}
if (state == State.Completed) {
return "Completed";
}
if (state == State.Refunding) {
return "Refunding";
}
}
function tokensOnSale() public view returns (uint256) {
uint256 i = currentPhaseId();
if (isPhaseValid(i)) {
return phases[i].maxAmountEnabled ? phases[i].maxAmount : token.balanceOf(this);
} else {
return 0;
}
}
}