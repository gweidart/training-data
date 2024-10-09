pragma solidity ^0.4.13;
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
contract ReentrancyGuard {
bool private rentrancy_lock = false;
modifier nonReentrant() {
require(!rentrancy_lock);
rentrancy_lock = true;
_;
rentrancy_lock = false;
}
}
contract ArgumentsChecker {
modifier payloadSizeIs(uint size) {
_;
}
modifier validAddress(address addr) {
require(addr != address(0));
_;
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
contract LightFundsRegistry is ArgumentsChecker, Ownable, ReentrancyGuard {
using SafeMath for uint256;
enum State {
GATHERING,
REFUNDING,
SUCCEEDED
}
event StateChanged(State _state);
event Invested(address indexed investor, uint256 amount);
event EtherSent(address indexed to, uint value);
event RefundSent(address indexed to, uint value);
modifier requiresState(State _state) {
require(m_state == _state);
_;
}
function LightFundsRegistry(address owner80, address owner20)
public
validAddress(owner80)
validAddress(owner20)
{
m_owner80 = owner80;
m_owner20 = owner20;
}
function changeState(State _newState)
external
onlyOwner
{
assert(m_state != _newState);
if (State.GATHERING == m_state) {   assert(State.REFUNDING == _newState || State.SUCCEEDED == _newState); }
else assert(false);
m_state = _newState;
StateChanged(m_state);
if (State.SUCCEEDED == _newState) {
uint _80percent = this.balance.mul(80).div(100);
m_owner80.transfer(_80percent);
EtherSent(m_owner80, _80percent);
uint _20percent = this.balance;
m_owner20.transfer(_20percent);
EtherSent(m_owner20, _20percent);
}
}
function invested(address _investor)
external
payable
onlyOwner
requiresState(State.GATHERING)
{
uint256 amount = msg.value;
require(0 != amount);
if (0 == m_weiBalances[_investor])
m_investors.push(_investor);
totalInvested = totalInvested.add(amount);
m_weiBalances[_investor] = m_weiBalances[_investor].add(amount);
Invested(_investor, amount);
}
function withdrawPayments(address payee)
external
nonReentrant
onlyOwner
requiresState(State.REFUNDING)
{
uint256 payment = m_weiBalances[payee];
require(payment != 0);
require(this.balance >= payment);
totalInvested = totalInvested.sub(payment);
m_weiBalances[payee] = 0;
payee.transfer(payment);
RefundSent(payee, payment);
}
function getInvestorsCount() external view returns (uint) { return m_investors.length; }
uint256 public totalInvested;
State public m_state = State.GATHERING;
mapping(address => uint256) public m_weiBalances;
address[] public m_investors;
address public m_owner80;
address public m_owner20;
}