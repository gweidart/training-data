pragma solidity 0.4.24;
interface VaultI {
function deposit(address contributor) external payable;
function saleSuccessful() external;
function enableRefunds() external;
function refund(address contributor) external;
function close() external;
function sendFundsToWallet() external;
}
library Math {
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
contract Ownable {
address public owner;
event OwnershipRenounced(address indexed previousOwner);
event OwnershipTransferred(
address indexed previousOwner,
address indexed newOwner
);
constructor() public {
owner = msg.sender;
}
modifier onlyOwner() {
require(msg.sender == owner);
_;
}
function renounceOwnership() public onlyOwner {
emit OwnershipRenounced(owner);
owner = address(0);
}
function transferOwnership(address _newOwner) public onlyOwner {
_transferOwnership(_newOwner);
}
function _transferOwnership(address _newOwner) internal {
require(_newOwner != address(0));
emit OwnershipTransferred(owner, _newOwner);
owner = _newOwner;
}
}
contract Vault is VaultI, Ownable {
using SafeMath for uint256;
enum State { Active, Success, Refunding, Closed }
uint256 public firstDepositTimestamp;
mapping (address => uint256) public deposited;
uint256 public disbursementWei;
uint256 public disbursementDuration;
address public trustedWallet;
uint256 public initialWei;
uint256 public nextDisbursement;
uint256 public totalDeposited;
uint256 public refundable;
State public state;
event Closed();
event RefundsEnabled();
event Refunded(address indexed contributor, uint256 amount);
modifier atState(State _state) {
require(state == _state);
_;
}
constructor (
address _wallet,
uint256 _initialWei,
uint256 _disbursementWei,
uint256 _disbursementDuration
)
public
{
require(_wallet != address(0));
require(_disbursementWei != 0);
trustedWallet = _wallet;
initialWei = _initialWei;
disbursementWei = _disbursementWei;
disbursementDuration = _disbursementDuration;
state = State.Active;
}
function deposit(address _contributor) onlyOwner external payable {
require(state == State.Active || state == State.Success);
if (firstDepositTimestamp == 0) {
firstDepositTimestamp = now;
}
totalDeposited = totalDeposited.add(msg.value);
deposited[_contributor] = deposited[_contributor].add(msg.value);
}
function saleSuccessful()
onlyOwner
external
atState(State.Active)
{
state = State.Success;
transferToWallet(initialWei);
}
function enableRefunds() onlyOwner external {
require(state != State.Refunding);
state = State.Refunding;
uint256 currentBalance = address(this).balance;
refundable = currentBalance <= totalDeposited ? currentBalance : totalDeposited;
emit RefundsEnabled();
}
function refund(address _contributor) external atState(State.Refunding) {
require(deposited[_contributor] > 0);
uint256 refundAmount = deposited[_contributor].mul(refundable).div(totalDeposited);
deposited[_contributor] = 0;
_contributor.transfer(refundAmount);
emit Refunded(_contributor, refundAmount);
}
function close() external atState(State.Success) onlyOwner {
state = State.Closed;
nextDisbursement = now;
emit Closed();
}
function sendFundsToWallet() external atState(State.Closed) {
require(nextDisbursement <= now);
if (disbursementDuration == 0) {
trustedWallet.transfer(address(this).balance);
return;
}
uint256 numberOfDisbursements = now.sub(nextDisbursement).div(disbursementDuration).add(1);
nextDisbursement = nextDisbursement.add(disbursementDuration.mul(numberOfDisbursements));
transferToWallet(disbursementWei.mul(numberOfDisbursements));
}
function transferToWallet(uint256 _amount) internal {
uint256 amountToSend = Math.min256(_amount, address(this).balance);
trustedWallet.transfer(amountToSend);
}
}