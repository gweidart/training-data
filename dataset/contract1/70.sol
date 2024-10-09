pragma solidity ^0.4.23;
library SafeMath {
function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
if (a == 0) {
return 0;
}
c = a * b;
require(c / a == b, "Overflow - Multiplication");
return c;
}
function div(uint256 a, uint256 b) internal pure returns (uint256) {
return a / b;
}
function sub(uint256 a, uint256 b) internal pure returns (uint256) {
require(b <= a, "Underflow - Subtraction");
return a - b;
}
function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
c = a + b;
require(c >= a, "Overflow - Addition");
return c;
}
}
library Contract {
using SafeMath for uint;
modifier conditions(function () pure first, function () pure last) {
first();
_;
last();
}
bytes32 internal constant EXEC_PERMISSIONS = keccak256('script_exec_permissions');
function authorize(address _script_exec) internal view {
initialize();
bytes32 perms = EXEC_PERMISSIONS;
bool authorized;
assembly {
mstore(0, _script_exec)
mstore(0x20, perms)
mstore(0, keccak256(0x0c, 0x34))
mstore(0x20, mload(0x80))
authorized := sload(keccak256(0, 0x40))
}
if (!authorized)
revert("Sender is not authorized as a script exec address");
}
function initialize() internal view {
require(freeMem() == 0x80, "Memory allocated prior to execution");
assembly {
mstore(0x80, sload(0))
mstore(0xa0, sload(1))
mstore(0xc0, 0)
mstore(0xe0, 0)
mstore(0x100, 0)
mstore(0x120, 0)
mstore(0x140, 0)
mstore(0x160, 0)
mstore(0x40, 0x180)
}
assert(execID() != bytes32(0) && sender() != address(0));
}
function checks(function () view _check) conditions(validState, validState) internal view {
_check();
}
function checks(function () pure _check) conditions(validState, validState) internal pure {
_check();
}
function commit() conditions(validState, none) internal pure {
bytes32 ptr = buffPtr();
require(ptr >= 0x180, "Invalid buffer pointer");
assembly {
let size := mload(add(0x20, ptr))
mstore(ptr, 0x20)
revert(ptr, add(0x40, size))
}
}
function validState() private pure {
if (freeMem() < 0x180)
revert('Expected Contract.execute()');
if (buffPtr() != 0 && buffPtr() < 0x180)
revert('Invalid buffer pointer');
assert(execID() != bytes32(0) && sender() != address(0));
}
function buffPtr() private pure returns (bytes32 ptr) {
assembly { ptr := mload(0xc0) }
}
function freeMem() private pure returns (bytes32 ptr) {
assembly { ptr := mload(0x40) }
}
function currentAction() private pure returns (bytes4 action) {
if (buffPtr() == bytes32(0))
return bytes4(0);
assembly { action := mload(0xe0) }
}
function isStoring() private pure {
if (currentAction() != STORES)
revert('Invalid current action - expected STORES');
}
function isEmitting() private pure {
if (currentAction() != EMITS)
revert('Invalid current action - expected EMITS');
}
function isPaying() private pure {
if (currentAction() != PAYS)
revert('Invalid current action - expected PAYS');
}
function startBuffer() private pure {
assembly {
let ptr := msize()
mstore(0xc0, ptr)
mstore(ptr, 0)
mstore(add(0x20, ptr), 0)
mstore(0x40, add(0x40, ptr))
mstore(0x100, 1)
}
}
function validStoreBuff() private pure {
if (buffPtr() == bytes32(0))
startBuffer();
if (stored() != 0 || currentAction() == STORES)
revert('Duplicate request - stores');
}
function validEmitBuff() private pure {
if (buffPtr() == bytes32(0))
startBuffer();
if (emitted() != 0 || currentAction() == EMITS)
revert('Duplicate request - emits');
}
function validPayBuff() private pure {
if (buffPtr() == bytes32(0))
startBuffer();
if (paid() != 0 || currentAction() == PAYS)
revert('Duplicate request - pays');
}
function none() private pure { }
function execID() internal pure returns (bytes32 exec_id) {
assembly { exec_id := mload(0x80) }
require(exec_id != bytes32(0), "Execution id overwritten, or not read");
}
function sender() internal pure returns (address addr) {
assembly { addr := mload(0xa0) }
require(addr != address(0), "Sender address overwritten, or not read");
}
function read(bytes32 _location) internal view returns (bytes32 data) {
data = keccak256(_location, execID());
assembly { data := sload(data) }
}
bytes4 internal constant EMITS = bytes4(keccak256('Emit((bytes32[],bytes)[])'));
bytes4 internal constant STORES = bytes4(keccak256('Store(bytes32[])'));
bytes4 internal constant PAYS = bytes4(keccak256('Pay(bytes32[])'));
bytes4 internal constant THROWS = bytes4(keccak256('Error(string)'));
enum NextFunction {
INVALID, NONE, STORE_DEST, VAL_SET, VAL_INC, VAL_DEC, EMIT_LOG, PAY_DEST, PAY_AMT
}
function validStoreDest() private pure {
if (expected() != NextFunction.STORE_DEST)
revert('Unexpected function order - expected storage destination to be pushed');
isStoring();
}
function validStoreVal() private pure {
if (
expected() != NextFunction.VAL_SET &&
expected() != NextFunction.VAL_INC &&
expected() != NextFunction.VAL_DEC
) revert('Unexpected function order - expected storage value to be pushed');
isStoring();
}
function validPayDest() private pure {
if (expected() != NextFunction.PAY_DEST)
revert('Unexpected function order - expected payment destination to be pushed');
isPaying();
}
function validPayAmt() private pure {
if (expected() != NextFunction.PAY_AMT)
revert('Unexpected function order - expected payment amount to be pushed');
isPaying();
}
function validEvent() private pure {
if (expected() != NextFunction.EMIT_LOG)
revert('Unexpected function order - expected event to be pushed');
isEmitting();
}
function storing() conditions(validStoreBuff, isStoring) internal pure {
bytes4 action_req = STORES;
assembly {
let ptr := add(0x20, mload(0xc0))
mstore(add(0x20, add(ptr, mload(ptr))), action_req)
mstore(add(0x24, add(ptr, mload(ptr))), 0)
mstore(ptr, add(0x24, mload(ptr)))
mstore(0xe0, action_req)
mstore(0x100, 2)
mstore(sub(ptr, 0x20), add(ptr, mload(ptr)))
}
setFreeMem();
}
function set(bytes32 _field) conditions(validStoreDest, validStoreVal) internal pure returns (bytes32) {
assembly {
let ptr := add(0x20, mload(0xc0))
mstore(add(0x20, add(ptr, mload(ptr))), _field)
mstore(ptr, add(0x20, mload(ptr)))
mstore(0x100, 3)
mstore(
mload(sub(ptr, 0x20)),
add(1, mload(mload(sub(ptr, 0x20))))
)
mstore(0x120, add(1, mload(0x120)))
}
setFreeMem();
return _field;
}
function to(bytes32, bytes32 _val) conditions(validStoreVal, validStoreDest) internal pure {
assembly {
let ptr := add(0x20, mload(0xc0))
mstore(add(0x20, add(ptr, mload(ptr))), _val)
mstore(ptr, add(0x20, mload(ptr)))
mstore(0x100, 2)
}
setFreeMem();
}
function to(bytes32 _field, uint _val) internal pure {
to(_field, bytes32(_val));
}
function to(bytes32 _field, address _val) internal pure {
to(_field, bytes32(_val));
}
function to(bytes32 _field, bool _val) internal pure {
to(
_field,
_val ? bytes32(1) : bytes32(0)
);
}
function increase(bytes32 _field) conditions(validStoreDest, validStoreVal) internal view returns (bytes32 val) {
val = keccak256(_field, execID());
assembly {
val := sload(val)
let ptr := add(0x20, mload(0xc0))
mstore(add(0x20, add(ptr, mload(ptr))), _field)
mstore(ptr, add(0x20, mload(ptr)))
mstore(0x100, 4)
mstore(
mload(sub(ptr, 0x20)),
add(1, mload(mload(sub(ptr, 0x20))))
)
mstore(0x120, add(1, mload(0x120)))
}
setFreeMem();
return val;
}
function decrease(bytes32 _field) conditions(validStoreDest, validStoreVal) internal view returns (bytes32 val) {
val = keccak256(_field, execID());
assembly {
val := sload(val)
let ptr := add(0x20, mload(0xc0))
mstore(add(0x20, add(ptr, mload(ptr))), _field)
mstore(ptr, add(0x20, mload(ptr)))
mstore(0x100, 5)
mstore(
mload(sub(ptr, 0x20)),
add(1, mload(mload(sub(ptr, 0x20))))
)
mstore(0x120, add(1, mload(0x120)))
}
setFreeMem();
return val;
}
function by(bytes32 _val, uint _amt) conditions(validStoreVal, validStoreDest) internal pure {
if (expected() == NextFunction.VAL_INC)
_amt = _amt.add(uint(_val));
else if (expected() == NextFunction.VAL_DEC)
_amt = uint(_val).sub(_amt);
else
revert('Expected VAL_INC or VAL_DEC');
assembly {
let ptr := add(0x20, mload(0xc0))
mstore(add(0x20, add(ptr, mload(ptr))), _amt)
mstore(ptr, add(0x20, mload(ptr)))
mstore(0x100, 2)
}
setFreeMem();
}
function byMaximum(bytes32 _val, uint _amt) conditions(validStoreVal, validStoreDest) internal pure {
if (expected() == NextFunction.VAL_DEC) {
if (_amt >= uint(_val))
_amt = 0;
else
_amt = uint(_val).sub(_amt);
} else {
revert('Expected VAL_DEC');
}
assembly {
let ptr := add(0x20, mload(0xc0))
mstore(add(0x20, add(ptr, mload(ptr))), _amt)
mstore(ptr, add(0x20, mload(ptr)))
mstore(0x100, 2)
}
setFreeMem();
}
function emitting() conditions(validEmitBuff, isEmitting) internal pure {
bytes4 action_req = EMITS;
assembly {
let ptr := add(0x20, mload(0xc0))
mstore(add(0x20, add(ptr, mload(ptr))), action_req)
mstore(add(0x24, add(ptr, mload(ptr))), 0)
mstore(ptr, add(0x24, mload(ptr)))
mstore(0xe0, action_req)
mstore(0x100, 6)
mstore(sub(ptr, 0x20), add(ptr, mload(ptr)))
}
setFreeMem();
}
function log(bytes32 _data) conditions(validEvent, validEvent) internal pure {
assembly {
let ptr := add(0x20, mload(0xc0))
mstore(add(0x20, add(ptr, mload(ptr))), 0)
if eq(_data, 0) {
mstore(add(0x40, add(ptr, mload(ptr))), 0)
mstore(ptr, add(0x40, mload(ptr)))
}
if iszero(eq(_data, 0)) {
mstore(add(0x40, add(ptr, mload(ptr))), 0x20)
mstore(add(0x60, add(ptr, mload(ptr))), _data)
mstore(ptr, add(0x60, mload(ptr)))
}
mstore(
mload(sub(ptr, 0x20)),
add(1, mload(mload(sub(ptr, 0x20))))
)
mstore(0x140, add(1, mload(0x140)))
}
setFreeMem();
}
function log(bytes32[1] memory _topics, bytes32 _data) conditions(validEvent, validEvent) internal pure {
assembly {
let ptr := add(0x20, mload(0xc0))
mstore(add(0x20, add(ptr, mload(ptr))), 1)
mstore(add(0x40, add(ptr, mload(ptr))), mload(_topics))
if eq(_data, 0) {
mstore(add(0x60, add(ptr, mload(ptr))), 0)
mstore(ptr, add(0x60, mload(ptr)))
}
if iszero(eq(_data, 0)) {
mstore(add(0x60, add(ptr, mload(ptr))), 0x20)
mstore(add(0x80, add(ptr, mload(ptr))), _data)
mstore(ptr, add(0x80, mload(ptr)))
}
mstore(
mload(sub(ptr, 0x20)),
add(1, mload(mload(sub(ptr, 0x20))))
)
mstore(0x140, add(1, mload(0x140)))
}
setFreeMem();
}
function log(bytes32[2] memory _topics, bytes32 _data) conditions(validEvent, validEvent) internal pure {
assembly {
let ptr := add(0x20, mload(0xc0))
mstore(add(0x20, add(ptr, mload(ptr))), 2)
mstore(add(0x40, add(ptr, mload(ptr))), mload(_topics))
mstore(add(0x60, add(ptr, mload(ptr))), mload(add(0x20, _topics)))
if eq(_data, 0) {
mstore(add(0x80, add(ptr, mload(ptr))), 0)
mstore(ptr, add(0x80, mload(ptr)))
}
if iszero(eq(_data, 0)) {
mstore(add(0x80, add(ptr, mload(ptr))), 0x20)
mstore(add(0xa0, add(ptr, mload(ptr))), _data)
mstore(ptr, add(0xa0, mload(ptr)))
}
mstore(
mload(sub(ptr, 0x20)),
add(1, mload(mload(sub(ptr, 0x20))))
)
mstore(0x140, add(1, mload(0x140)))
}
setFreeMem();
}
function log(bytes32[3] memory _topics, bytes32 _data) conditions(validEvent, validEvent) internal pure {
assembly {
let ptr := add(0x20, mload(0xc0))
mstore(add(0x20, add(ptr, mload(ptr))), 3)
mstore(add(0x40, add(ptr, mload(ptr))), mload(_topics))
mstore(add(0x60, add(ptr, mload(ptr))), mload(add(0x20, _topics)))
mstore(add(0x80, add(ptr, mload(ptr))), mload(add(0x40, _topics)))
if eq(_data, 0) {
mstore(add(0xa0, add(ptr, mload(ptr))), 0)
mstore(ptr, add(0xa0, mload(ptr)))
}
if iszero(eq(_data, 0)) {
mstore(add(0xa0, add(ptr, mload(ptr))), 0x20)
mstore(add(0xc0, add(ptr, mload(ptr))), _data)
mstore(ptr, add(0xc0, mload(ptr)))
}
mstore(
mload(sub(ptr, 0x20)),
add(1, mload(mload(sub(ptr, 0x20))))
)
mstore(0x140, add(1, mload(0x140)))
}
setFreeMem();
}
function log(bytes32[4] memory _topics, bytes32 _data) conditions(validEvent, validEvent) internal pure {
assembly {
let ptr := add(0x20, mload(0xc0))
mstore(add(0x20, add(ptr, mload(ptr))), 4)
mstore(add(0x40, add(ptr, mload(ptr))), mload(_topics))
mstore(add(0x60, add(ptr, mload(ptr))), mload(add(0x20, _topics)))
mstore(add(0x80, add(ptr, mload(ptr))), mload(add(0x40, _topics)))
mstore(add(0xa0, add(ptr, mload(ptr))), mload(add(0x60, _topics)))
if eq(_data, 0) {
mstore(add(0xc0, add(ptr, mload(ptr))), 0)
mstore(ptr, add(0xc0, mload(ptr)))
}
if iszero(eq(_data, 0)) {
mstore(add(0xc0, add(ptr, mload(ptr))), 0x20)
mstore(add(0xe0, add(ptr, mload(ptr))), _data)
mstore(ptr, add(0xe0, mload(ptr)))
}
mstore(
mload(sub(ptr, 0x20)),
add(1, mload(mload(sub(ptr, 0x20))))
)
mstore(0x140, add(1, mload(0x140)))
}
setFreeMem();
}
function paying() conditions(validPayBuff, isPaying) internal pure {
bytes4 action_req = PAYS;
assembly {
let ptr := add(0x20, mload(0xc0))
mstore(add(0x20, add(ptr, mload(ptr))), action_req)
mstore(add(0x24, add(ptr, mload(ptr))), 0)
mstore(ptr, add(0x24, mload(ptr)))
mstore(0xe0, action_req)
mstore(0x100, 8)
mstore(sub(ptr, 0x20), add(ptr, mload(ptr)))
}
setFreeMem();
}
function pay(uint _amount) conditions(validPayAmt, validPayDest) internal pure returns (uint) {
assembly {
let ptr := add(0x20, mload(0xc0))
mstore(add(0x20, add(ptr, mload(ptr))), _amount)
mstore(ptr, add(0x20, mload(ptr)))
mstore(0x100, 7)
mstore(
mload(sub(ptr, 0x20)),
add(1, mload(mload(sub(ptr, 0x20))))
)
mstore(0x160, add(1, mload(0x160)))
}
setFreeMem();
return _amount;
}
function toAcc(uint, address _dest) conditions(validPayDest, validPayAmt) internal pure {
assembly {
let ptr := add(0x20, mload(0xc0))
mstore(add(0x20, add(ptr, mload(ptr))), _dest)
mstore(ptr, add(0x20, mload(ptr)))
mstore(0x100, 8)
}
setFreeMem();
}
function setFreeMem() private pure {
assembly { mstore(0x40, msize) }
}
function expected() private pure returns (NextFunction next) {
assembly { next := mload(0x100) }
}
function emitted() internal pure returns (uint num_emitted) {
if (buffPtr() == bytes32(0))
return 0;
assembly { num_emitted := mload(0x140) }
}
function stored() internal pure returns (uint num_stored) {
if (buffPtr() == bytes32(0))
return 0;
assembly { num_stored := mload(0x120) }
}
function paid() internal pure returns (uint num_paid) {
if (buffPtr() == bytes32(0))
return 0;
assembly { num_paid := mload(0x160) }
}
}
library Purchase {
using Contract for *;
using SafeMath for uint;
bytes32 internal constant BUY_SIG = keccak256('Purchase(bytes32,uint256,uint256,uint256)');
function PURCHASE(bytes32 _exec_id, uint _current_rate) private view returns (bytes32[4] memory)
{ return [BUY_SIG, _exec_id, bytes32(_current_rate), bytes32(now)]; }
function buy() internal view {
bool sale_is_whitelisted = Contract.read(Sale.isWhitelisted()) != 0 ? true : false;
bool sender_has_contributed = Contract.read(Sale.hasContributed(Contract.sender())) != 0 ? true : false;
uint current_rate = getCurrentRate(
uint(Contract.read(Sale.startTime())),
uint(Contract.read(Sale.startRate())),
uint(Contract.read(Sale.endRate())),
uint(Contract.read(Sale.totalDuration()))
);
uint min_contribution;
if (sale_is_whitelisted && !sender_has_contributed)
min_contribution = uint(Contract.read(Sale.whitelistMinTok(Contract.sender())));
else if (!sale_is_whitelisted && !sender_has_contributed)
min_contribution = uint(Contract.read(Sale.globalMinPurchaseAmt()));
uint spend_amount;
uint tokens_purchased;
(spend_amount, tokens_purchased) = getPurchaseInfo(
uint(Contract.read(Sale.tokenDecimals())),
current_rate,
uint(Contract.read(Sale.tokensRemaining())),
sale_is_whitelisted,
uint(Contract.read(Sale.whitelistMaxTok(Contract.sender()))),
min_contribution
);
assert(spend_amount != 0 && spend_amount <= msg.value && tokens_purchased != 0);
Contract.paying();
Contract.pay(spend_amount).toAcc(address(Contract.read(Sale.wallet())));
Contract.storing();
Contract.increase(Sale.balances(Contract.sender())).by(tokens_purchased);
Contract.decrease(Sale.tokensRemaining()).by(tokens_purchased);
Contract.increase(Sale.tokensSold()).by(tokens_purchased);
Contract.increase(Sale.totalWeiRaised()).by(spend_amount);
if (sender_has_contributed == false) {
Contract.increase(Sale.contributors()).by(1);
Contract.set(Sale.hasContributed(Contract.sender())).to(true);
}
if (sale_is_whitelisted) {
Contract.set(Sale.whitelistMinTok(Contract.sender())).to(uint(0));
Contract.decrease(Sale.whitelistMaxTok(Contract.sender())).by(tokens_purchased);
}
Contract.emitting();
Contract.log(
PURCHASE(Contract.execID(), current_rate), bytes32(tokens_purchased)
);
}
function getCurrentRate(uint _start_time,	uint _start_rate,	uint _end_rate,	uint _duration) internal view
returns (uint current_rate) {
if (now < _start_time) {
current_rate = 0;
return;
}
uint elapsed = now.sub(_start_time);
if (elapsed >= _duration) {
current_rate = 0;
return;
}
elapsed = elapsed.mul(10 ** 18);
uint temp_rate = _start_rate.sub(_end_rate).mul(elapsed).div(_duration);
temp_rate = temp_rate.div(10 ** 18);
current_rate = _start_rate.sub(temp_rate);
}
function getPurchaseInfo(
uint _decimals, uint _current_rate, uint _tokens_remaining,
bool _sale_whitelisted,	uint _token_spend_remaining, uint _min_purchase_amount
) internal view returns (uint spend_amount, uint tokens_purchased) {
if (msg.value.mul(10 ** _decimals).div(_current_rate) > _tokens_remaining)
spend_amount = _current_rate.mul(_tokens_remaining).div(10 ** _decimals);
else
spend_amount = msg.value;
tokens_purchased = spend_amount.mul(10 ** _decimals).div(_current_rate);
if (_sale_whitelisted && tokens_purchased > _token_spend_remaining) {
tokens_purchased = _token_spend_remaining;
spend_amount = tokens_purchased.mul(_current_rate).div(10 ** _decimals);
}
if (spend_amount == 0 || spend_amount > msg.value)
revert("Invalid spend amount");
if (tokens_purchased > _tokens_remaining || tokens_purchased == 0)
revert("Invalid purchase amount");
if (tokens_purchased < _min_purchase_amount)
revert("Purchase is under minimum contribution amount");
}
}
library Sale {
using Contract for *;
function isConfigured() internal pure returns (bytes32)
{ return keccak256("sale_is_configured"); }
function isFinished() internal pure returns (bytes32)
{ return keccak256("sale_is_completed"); }
function startTime() internal pure returns (bytes32)
{ return keccak256("sale_start_time"); }
function totalDuration() internal pure returns (bytes32)
{ return keccak256("sale_total_duration"); }
function tokensRemaining() internal pure returns (bytes32)
{ return keccak256("sale_tokens_remaining"); }
function startRate() internal pure returns (bytes32)
{ return keccak256("sale_start_rate"); }
function endRate() internal pure returns (bytes32)
{ return keccak256("sale_end_rate"); }
function tokensSold() internal pure returns (bytes32)
{ return keccak256("sale_tokens_sold"); }
function globalMinPurchaseAmt() internal pure returns (bytes32)
{ return keccak256("sale_min_purchase_amt"); }
function contributors() internal pure returns (bytes32)
{ return keccak256("sale_contributors"); }
function hasContributed(address _purchaser) internal pure returns (bytes32)
{ return keccak256(_purchaser, contributors()); }
function wallet() internal pure returns (bytes32)
{ return keccak256("sale_destination_wallet"); }
function totalWeiRaised() internal pure returns (bytes32)
{ return keccak256("sale_tot_wei_raised"); }
function isWhitelisted() internal pure returns (bytes32)
{ return keccak256('sale_is_whitelisted'); }
function saleWhitelist() internal pure returns (bytes32)
{ return keccak256("sale_whitelist"); }
function whitelistMaxTok(address _spender) internal pure returns (bytes32)
{ return keccak256(_spender, "max_tok", saleWhitelist()); }
function whitelistMinTok(address _spender) internal pure returns (bytes32)
{ return keccak256(_spender, "min_tok", saleWhitelist()); }
function tokenDecimals() internal pure returns (bytes32)
{ return keccak256("token_decimals"); }
bytes32 internal constant TOKEN_BALANCES = keccak256("token_balances");
function balances(address _owner) internal pure returns (bytes32)
{ return keccak256(_owner, TOKEN_BALANCES); }
function validState() internal view {
if (msg.value == 0)
revert('no wei sent');
if (uint(Contract.read(startTime())) > now)
revert('sale has not started');
if (Contract.read(wallet()) == 0)
revert('invalid Crowdsale wallet');
if (Contract.read(isConfigured()) == 0)
revert('sale not initialized');
if (Contract.read(isFinished()) != 0)
revert('sale already finalized');
if (Contract.read(tokensRemaining()) == 0)
revert('Crowdsale is sold out');
if (Contract.read(startRate()) <= Contract.read(endRate()))
revert("end sale rate is greater than starting sale rate");
if (now > uint(Contract.read(startTime())) + uint(Contract.read(totalDuration())))
revert("the crowdsale is over");
}
function emitStoreAndPay() internal pure {
if (Contract.emitted() == 0 || Contract.stored() == 0 || Contract.paid() != 1)
revert('invalid state change');
}
function buy() external view {
Contract.authorize(msg.sender);
Contract.checks(validState);
Purchase.buy();
Contract.checks(emitStoreAndPay);
Contract.commit();
}
}