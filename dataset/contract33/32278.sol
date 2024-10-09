pragma solidity ^0.4.18;
contract Ownable {
address public owner;
function Ownable() {
owner = msg.sender;
}
modifier onlyOwner() {
require(msg.sender == owner);
_;
}
function transferOwnership(address newOwner) onlyOwner {
require(newOwner != address(0));
owner = newOwner;
}
}
contract SafeMath {
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
function max64(uint64 a, uint64 b) internal constant returns (uint64) {
return a >= b ? a : b;
}
function min64(uint64 a, uint64 b) internal constant returns (uint64) {
return a < b ? a : b;
}
function max256(uint256 a, uint256 b) internal constant returns (uint256) {
return a >= b ? a : b;
}
function min256(uint256 a, uint256 b) internal constant returns (uint256) {
return a < b ? a : b;
}
}
contract RefundVault is Ownable, SafeMath{
enum State { Active, Refunding, Closed }
mapping (address => uint256) public deposited;
mapping (address => uint256) public refunded;
State public state;
address[] public reserveWallet;
event Closed();
event RefundsEnabled();
event Refunded(address indexed beneficiary, uint256 weiAmount);
function RefundVault(address[] _reserveWallet) {
state = State.Active;
reserveWallet = _reserveWallet;
}
function deposit(address investor) onlyOwner payable {
require(state == State.Active);
deposited[investor] = add(deposited[investor], msg.value);
}
event Transferred(address _to, uint _value);
function close() onlyOwner {
require(state == State.Active);
state = State.Closed;
uint256 balance = this.balance;
uint256 reserveAmountForEach = div(balance, reserveWallet.length);
for(uint8 i = 0; i < reserveWallet.length; i++){
reserveWallet[i].transfer(reserveAmountForEach);
Transferred(reserveWallet[i], reserveAmountForEach);
}
Closed();
}
function enableRefunds() onlyOwner {
require(state == State.Active);
state = State.Refunding;
RefundsEnabled();
}
function refund(address investor) returns (bool) {
require(state == State.Refunding);
if (refunded[investor] > 0) {
return false;
}
uint256 depositedValue = deposited[investor];
deposited[investor] = 0;
refunded[investor] = depositedValue;
investor.transfer(depositedValue);
Refunded(investor, depositedValue);
return true;
}
}