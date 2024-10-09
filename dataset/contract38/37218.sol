pragma solidity ^0.4.13;
contract ProvideWorkOrder {
using SafeMath for uint;
enum Status { Pending, InProgress, Completed, Paid }
address public prvd;
address public paymentEscrow;
address public peer;
address public provider;
uint128 public identifier;
Status public status;
uint256 public amount;
string public details;
event WorkOrderStarted(uint128 _identifier);
event WorkOrderCompleted(uint128 _identifier, uint256 _amount, string _details);
event TransactionCompleted(uint128 _identifier, uint256 _paymentAmount, uint256 feeAmount, string _details);
function ProvideWorkOrder(
address _prvd,
address _paymentEscrow,
address _peer,
uint128 _identifier
) {
if (_prvd == 0x0) revert();
if (_paymentEscrow == 0x0) revert();
if (_peer == 0x0) revert();
prvd = _prvd;
paymentEscrow = _paymentEscrow;
peer = _peer;
identifier = _identifier;
status = Status.Pending;
}
function start(address _provider) public onlyPrvd onlyPending {
if (provider != 0x0) revert();
provider = _provider;
status = Status.InProgress;
WorkOrderStarted(identifier);
}
function complete(uint256 _amount, string _details) public onlyProvider onlyInProgress {
amount = _amount;
details = _details;
status = Status.Completed;
WorkOrderCompleted(identifier, amount, details);
}
function completeTransaction() public onlyPurchaser onlyCompleted payable {
if (msg.value != amount) revert();
uint paymentAmount = msg.value.mul(uint(95).div(100));
paymentEscrow.transfer(paymentAmount);
uint feeAmount = msg.value.sub(paymentAmount);
prvd.transfer(feeAmount);
status = Status.Paid;
TransactionCompleted(identifier, paymentAmount, feeAmount, details);
}
modifier onlyPrvd() {
if (msg.sender != prvd) revert();
_;
}
modifier onlyPurchaser() {
if (msg.sender != peer) revert();
_;
}
modifier onlyProvider() {
if (msg.sender != provider) revert();
_;
}
modifier onlyPending() {
if (uint(status) != uint(Status.Pending)) revert();
_;
}
modifier onlyInProgress() {
if (uint(status) != uint(Status.InProgress)) revert();
_;
}
modifier onlyCompleted() {
if (uint(status) != uint(Status.Completed)) revert();
_;
}
}
library SafeMath {
function mul(uint a, uint b) internal returns (uint) {
uint c = a * b;
assert(a == 0 || c / a == b);
return c;
}
function div(uint a, uint b) internal returns (uint) {
return a / b;
}
function sub(uint a, uint b) internal returns (uint) {
assert(b <= a);
return a - b;
}
function add(uint a, uint b) internal returns (uint) {
uint c = a + b;
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
function assertTrue(bool val) internal {
assert(val);
}
function assertFalse(bool val) internal {
assert(!val);
}
}