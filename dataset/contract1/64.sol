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
library ManageTokens {
using Contract for *;
using SafeMath for uint;
bytes32 internal constant TRANSFER_AGENT_STATUS = keccak256('TransferAgentStatusUpdate(bytes32,address,bool)');
bytes32 internal constant FINAL_SEL = keccak256('CrowdsaleFinalized(bytes32)');
bytes32 private constant TOKEN_CONFIGURED = keccak256("TokenConfigured(bytes32,bytes32,bytes32,uint256)");
function AGENT_STATUS(bytes32 _exec_id, address _agent) private pure returns (bytes32[3] memory)
{ return [TRANSFER_AGENT_STATUS, _exec_id, bytes32(_agent)]; }
function FINALIZE(bytes32 _exec_id) private pure returns (bytes32[2] memory)
{ return [FINAL_SEL, _exec_id]; }
function TOKEN_INIT(bytes32 _exec_id, bytes32 _name, bytes32 _symbol) private pure returns (bytes32[4] memory)
{ return [TOKEN_CONFIGURED, _exec_id, _name, _symbol]; }
function initCrowdsaleToken(bytes32 _name, bytes32 _symbol, uint _decimals) internal pure {
if (_name == 0 || _symbol == 0 || _decimals > 18)
revert("Improper token initialization");
Contract.storing();
Contract.set(TokenManager.tokenName()).to(_name);
Contract.set(TokenManager.tokenSymbol()).to(_symbol);
Contract.set(TokenManager.tokenDecimals()).to(_decimals);
Contract.emitting();
Contract.log(
TOKEN_INIT(Contract.execID(), _name, _symbol), bytes32(_decimals)
);
}
function setTransferAgentStatus(address _agent, bool _is_agent) internal pure {
if (_agent == 0)
revert('invalid transfer agent');
Contract.storing();
Contract.set(TokenManager.transferAgents(_agent)).to(_is_agent);
Contract.emitting();
Contract.log(
AGENT_STATUS(Contract.execID(), _agent), _is_agent ? bytes32(1) : bytes32(0)
);
}
function updateMultipleReservedTokens(
address[] _destinations,
uint[] _num_tokens,
uint[] _num_percents,
uint[] _percent_decimals
) internal view {
if (
_destinations.length != _num_tokens.length
|| _num_tokens.length != _num_percents.length
|| _num_percents.length != _percent_decimals.length
|| _destinations.length == 0
) revert('invalid input length');
uint num_destinations = uint(Contract.read(TokenManager.reservedDestinations()));
Contract.storing();
for (uint i = 0; i < _destinations.length; i++) {
address to_add = _destinations[i];
if (to_add == 0)
revert('invalid destination');
if (Contract.read(TokenManager.destIndex(_destinations[i])) == 0) {
for (uint j = _destinations.length - 1; j > i; j--) {
if (_destinations[j] == to_add) {
to_add = address(0);
break;
}
}
if (to_add == 0)
continue;
num_destinations = num_destinations.add(1);
if (num_destinations > 20)
revert('too many reserved destinations');
Contract.set(
bytes32(32 * num_destinations + uint(TokenManager.reservedDestinations()))
).to(to_add);
Contract.set(TokenManager.destIndex(to_add)).to(num_destinations);
}
Contract.set(TokenManager.destTokens(to_add)).to(_num_tokens[i]);
Contract.set(TokenManager.destPercent(to_add)).to(_num_percents[i]);
Contract.set(TokenManager.destPrecision(to_add)).to(_percent_decimals[i]);
}
Contract.set(TokenManager.reservedDestinations()).to(num_destinations);
}
function removeReservedTokens(address _destination) internal view {
if (_destination == 0)
revert('invalid destination');
Contract.storing();
uint reservation_len = uint(Contract.read(TokenManager.reservedDestinations()));
uint to_remove = uint(Contract.read(TokenManager.destIndex(_destination)));
if (to_remove > reservation_len || to_remove == 0)
revert('removing too many reservations');
if (to_remove != reservation_len) {
address last_index =
address(Contract.read(
bytes32(32 * reservation_len + uint(TokenManager.reservedDestinations()))
));
Contract.set(TokenManager.destIndex(last_index)).to(to_remove);
Contract.set(
bytes32((32 * to_remove) + uint(TokenManager.reservedDestinations()))
).to(last_index);
}
Contract.decrease(TokenManager.reservedDestinations()).by(1);
Contract.set(TokenManager.destIndex(_destination)).to(uint(0));
}
function distributeReservedTokens(uint _num_destinations) internal view {
if (_num_destinations == 0)
revert('invalid number of destinations');
uint total_sold = uint(Contract.read(TokenManager.tokensSold()));
uint total_supply = uint(Contract.read(TokenManager.tokenTotalSupply()));
uint reserved_len = uint(Contract.read(TokenManager.reservedDestinations()));
Contract.storing();
if (reserved_len == 0)
revert('no remaining destinations');
if (_num_destinations > reserved_len)
_num_destinations = reserved_len;
Contract.decrease(TokenManager.reservedDestinations()).by(_num_destinations);
for (uint i = 0; i < _num_destinations; i++) {
address addr =
address(Contract.read(
bytes32(32 * (_num_destinations - i) + uint(TokenManager.reservedDestinations()))
));
uint to_add = uint(Contract.read(TokenManager.destPercent(addr)));
uint precision = uint(Contract.read(TokenManager.destPrecision(addr))).add(2);
precision = 10 ** precision;
to_add = total_sold.mul(to_add).div(precision);
to_add = to_add.add(uint(Contract.read(TokenManager.destTokens(addr))));
total_supply = total_supply.add(to_add);
Contract.increase(TokenManager.balances(addr)).by(to_add);
}
Contract.set(TokenManager.tokenTotalSupply()).to(total_supply);
}
function finalizeCrowdsaleAndToken() internal view {
distributeAndUnlockTokens();
Contract.set(TokenManager.isFinished()).to(true);
Contract.emitting();
Contract.log(
FINALIZE(Contract.execID()), bytes32(0)
);
}
function distributeAndUnlockTokens() internal view {
uint total_sold = uint(Contract.read(TokenManager.tokensSold()));
uint total_supply = uint(Contract.read(TokenManager.tokenTotalSupply()));
uint num_destinations = uint(Contract.read(TokenManager.reservedDestinations()));
Contract.storing();
if (num_destinations == 0) {
Contract.set(TokenManager.tokensUnlocked()).to(true);
return;
}
Contract.set(TokenManager.reservedDestinations()).to(uint(0));
for (uint i = 0; i < num_destinations; i++) {
address addr =
address(Contract.read(
bytes32(32 + (32 * i) + uint(TokenManager.reservedDestinations()))
));
uint to_add = uint(Contract.read(TokenManager.destPercent(addr)));
uint precision = uint(Contract.read(TokenManager.destPrecision(addr))).add(2);
precision = 10 ** precision;
to_add = total_sold.mul(to_add).div(precision);
to_add = to_add.add(uint(Contract.read(TokenManager.destTokens(addr))));
total_supply = total_supply.add(to_add);
Contract.increase(TokenManager.balances(addr)).by(to_add);
}
Contract.set(TokenManager.tokenTotalSupply()).to(total_supply);
Contract.set(TokenManager.tokensUnlocked()).to(true);
}
function finalizeAndDistributeToken() internal view {
distributeAndUnlockTokens();
}
}
library TokenManager {
using Contract for *;
function admin() internal pure returns (bytes32)
{ return keccak256('sale_admin'); }
function isConfigured() internal pure returns (bytes32)
{ return keccak256("sale_is_configured"); }
function isFinished() internal pure returns (bytes32)
{ return keccak256("sale_is_completed"); }
function tokensSold() internal pure returns (bytes32)
{ return keccak256("sale_tokens_sold"); }
function tokenName() internal pure returns (bytes32)
{ return keccak256("token_name"); }
function tokenSymbol() internal pure returns (bytes32)
{ return keccak256("token_symbol"); }
function tokenDecimals() internal pure returns (bytes32)
{ return keccak256("token_decimals"); }
function tokenTotalSupply() internal pure returns (bytes32)
{ return keccak256("token_total_supply"); }
bytes32 internal constant TOKEN_BALANCES = keccak256("token_balances");
function balances(address _owner) internal pure returns (bytes32)
{ return keccak256(_owner, TOKEN_BALANCES); }
bytes32 internal constant TOKEN_TRANSFER_AGENTS = keccak256("token_transfer_agents");
function transferAgents(address _agent) internal pure returns (bytes32)
{ return keccak256(_agent, TOKEN_TRANSFER_AGENTS); }
function tokensUnlocked() internal pure returns (bytes32)
{ return keccak256('sale_tokens_unlocked'); }
function reservedDestinations() internal pure returns (bytes32)
{ return keccak256("reserved_token_dest_list"); }
function destIndex(address _destination) internal pure returns (bytes32)
{ return keccak256(_destination, "index", reservedDestinations()); }
function destTokens(address _destination) internal pure returns (bytes32)
{ return keccak256(_destination, "numtokens", reservedDestinations()); }
function destPercent(address _destination) internal pure returns (bytes32)
{ return keccak256(_destination, "numpercent", reservedDestinations()); }
function destPrecision(address _destination) internal pure returns (bytes32)
{ return keccak256(_destination, "precision", reservedDestinations()); }
function saleFinalized() internal view {
if (Contract.read(isFinished()) == 0)
revert('sale must be finalized');
}
function onlyAdmin() internal view {
if (address(Contract.read(admin())) != Contract.sender())
revert('sender is not admin');
}
function onlyAdminAndNotInit() internal view {
if (address(Contract.read(admin())) != Contract.sender())
revert('sender is not admin');
if (Contract.read(isConfigured()) != 0)
revert('sale has already been initialized');
}
function emitAndStore() internal pure {
if (Contract.emitted() == 0 || Contract.stored() == 0)
revert('invalid state change');
}
function onlyStores() internal pure {
if (Contract.paid() != 0 || Contract.emitted() != 0)
revert('expected only storage');
if (Contract.stored() == 0)
revert('expected storage');
}
function senderAdminAndSaleNotFinal() internal view {
if (Contract.sender() != address(Contract.read(admin())))
revert('sender is not admin');
if (Contract.read(isConfigured()) == 0 || Contract.read(isFinished()) != 0)
revert('invalid sale state');
}
function initCrowdsaleToken(bytes32 _name, bytes32 _symbol, uint _decimals) external view {
Contract.authorize(msg.sender);
Contract.checks(onlyAdminAndNotInit);
ManageTokens.initCrowdsaleToken(_name, _symbol, _decimals);
Contract.checks(emitAndStore);
Contract.commit();
}
function setTransferAgentStatus(address _agent, bool _is_agent) external view {
Contract.authorize(msg.sender);
Contract.checks(onlyAdmin);
ManageTokens.setTransferAgentStatus(_agent, _is_agent);
Contract.checks(emitAndStore);
Contract.commit();
}
function updateMultipleReservedTokens(
address[] _destinations,
uint[] _num_tokens,
uint[] _num_percents,
uint[] _percent_decimals
) external view {
Contract.authorize(msg.sender);
Contract.checks(onlyAdminAndNotInit);
ManageTokens.updateMultipleReservedTokens(_destinations, _num_tokens, _num_percents, _percent_decimals);
Contract.checks(onlyStores);
Contract.commit();
}
function removeReservedTokens(address _destination) external view {
Contract.authorize(msg.sender);
Contract.checks(onlyAdminAndNotInit);
ManageTokens.removeReservedTokens(_destination);
Contract.checks(onlyStores);
Contract.commit();
}
function distributeReservedTokens(uint _num_destinations) external view {
Contract.authorize(msg.sender);
Contract.checks(saleFinalized);
ManageTokens.distributeReservedTokens(_num_destinations);
Contract.checks(onlyStores);
Contract.commit();
}
function finalizeCrowdsaleAndToken() external view {
Contract.authorize(msg.sender);
Contract.checks(senderAdminAndSaleNotFinal);
ManageTokens.finalizeCrowdsaleAndToken();
Contract.checks(emitAndStore);
Contract.commit();
}
function finalizeAndDistributeToken() external view {
Contract.authorize(msg.sender);
Contract.checks(saleFinalized);
ManageTokens.finalizeAndDistributeToken();
Contract.checks(onlyStores);
Contract.commit();
}
}