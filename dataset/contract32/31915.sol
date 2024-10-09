library WalletMainLib {
using Array256Lib for uint256[];
using BasicMathLib for uint256;
struct WalletData {
uint256 maxOwners;
address[] owners;
uint256 requiredAdmin;
uint256 requiredMajor;
uint256 requiredMinor;
mapping (address => uint256[2]) currentSpend;
mapping (address => uint256) majorThreshold;
mapping (uint256 => bytes32[]) transactions;
mapping (address => uint256) ownerIndex;
mapping (bytes32 => Transaction[]) transactionInfo;
}
struct Transaction {
uint256 day;
uint256 value;
address tokenAdress;
uint256 amount;
bytes data;
uint256[] confirmedOwners;
uint256 confirmCount;
uint256 confirmRequired;
bool success;
}
event LogRevokeNotice(bytes32 txid, address sender, uint256 confirmsNeeded);
event LogTransactionFailed(bytes32 txid, address sender);
event LogTransactionConfirmed(bytes32 txid, address sender, uint256 confirmsNeeded);
event LogTransactionComplete(bytes32 txid, address target, uint256 value, bytes data);
event LogContractCreated(address newContract, uint256 value);
event LogErrorMsg(uint256 amount, string msg);
function init(WalletData storage self,
address[] _owners,
uint256 _requiredAdmin,
uint256 _requiredMajor,
uint256 _requiredMinor,
uint256 _majorThreshold) public returns (bool)
{
require(self.owners.length == 0);
require(_owners.length >= _requiredAdmin && _requiredAdmin > 0);
require(_owners.length >= _requiredMajor && _requiredMajor > 0);
require(_owners.length >= _requiredMinor && _requiredMinor > 0);
self.owners.push(0);
for (uint256 i=0; i<_owners.length; i++) {
require(_owners[i] != 0);
self.owners.push(_owners[i]);
self.ownerIndex[_owners[i]] = i+1;
}
self.requiredAdmin = _requiredAdmin;
self.requiredMajor = _requiredMajor;
self.requiredMinor = _requiredMinor;
self.maxOwners = 50;
self.majorThreshold[0] = _majorThreshold;
return true;
}
function checkNotConfirmed(WalletData storage self, bytes32 _id, uint256 _txIndex)
public returns (bool)
{
require(self.ownerIndex[msg.sender] > 0);
uint256 _txLen = self.transactionInfo[_id].length;
if(_txLen == 0 || _txIndex >= _txLen){
LogErrorMsg(_txLen, "Tx not initiated");
LogTransactionFailed(_id, msg.sender);
return false;
}
if(self.transactionInfo[_id][_txIndex].success){
LogErrorMsg(_txIndex, "Transaction already complete");
LogTransactionFailed(_id, msg.sender);
return false;
}
bool found;
uint256 index;
(found, index) = self.transactionInfo[_id][_txIndex].confirmedOwners.indexOf(uint256(msg.sender), false);
if(found){
LogErrorMsg(index, "Owner already confirmed");
LogTransactionFailed(_id, msg.sender);
return false;
}
return true;
}
function calcConfirmsNeeded(uint256 _required, uint256 _count) public pure returns (uint256){
return _required - _count;
}
function getAmount(bytes _txData) public pure returns (bool,uint256) {
bytes32 getSig;
bytes4 sig;
bytes4 tSig = 0xa9059cbb;
bytes4 aSig = 0x095ea7b3;
bytes4 tfSig = 0x23b872dd;
bool transfer;
bytes32 _amountData;
uint256 _amount;
assembly { getSig := mload(add(_txData,0x20)) }
sig = bytes4(getSig);
if(sig ==  tSig || sig == aSig){
transfer = true;
assembly { _amountData := mload(add(_txData,0x44)) }
_amount = uint256(_amountData);
} else if(sig == tfSig){
transfer = true;
assembly { _amountData := mload(add(_txData,0x64)) }
_amount = uint256(_amountData);
}
return (transfer,_amount);
}
function getRequired(WalletData storage self,
address _to,
uint256 _value,
bool _isTransfer,
uint256 _amount)
public returns (uint256)
{
bool err;
uint256 res;
bool major = true;
if((now / 1 days) > self.currentSpend[0][0]){
self.currentSpend[0][0] = now / 1 days;
self.currentSpend[0][1] = 0;
}
(err, res) = self.currentSpend[0][1].plus(_value);
require(!err);
if(res < self.majorThreshold[0])
major = false;
if(_to != 0 && _isTransfer){
if((now / 1 days) > self.currentSpend[_to][0]){
self.currentSpend[_to][0] = now / 1 days;
self.currentSpend[_to][1] = 0;
}
(err, res) = self.currentSpend[_to][1].plus(_amount);
require(!err);
if(res >= self.majorThreshold[_to])
major = true;
}
return major ? self.requiredMajor : self.requiredMinor;
}
function createContract(bytes _txData, uint256 _value) public {
address _newContract;
bool allGood;
assembly {
_newContract := create(_value, add(_txData, 0x20), mload(_txData))
allGood := gt(extcodesize(_newContract),0)
}
require(allGood);
LogContractCreated(_newContract, _value);
}
function serveTx(WalletData storage self,
address _to,
uint256 _value,
bytes _txData,
bool _confirm,
bytes _data)
public returns (bool,bytes32)
{
bytes32 _id = keccak256("serveTx",_to,_value,_txData);
uint256 _txIndex = self.transactionInfo[_id].length;
uint256 _required = self.requiredMajor;
if(msg.sender != address(this)){
bool allGood;
uint256 _amount;
if(!_confirm) {
allGood = revokeConfirm(self, _id);
return (allGood,_id);
} else {
if(_to != 0)
(allGood,_amount) = getAmount(_txData);
if(_txIndex == 0 || self.transactionInfo[_id][_txIndex - 1].success){
require(self.ownerIndex[msg.sender] > 0);
_required = getRequired(self, _to, _value, allGood,_amount);
self.transactionInfo[_id].length++;
self.transactionInfo[_id][_txIndex].confirmRequired = _required;
self.transactionInfo[_id][_txIndex].day = now / 1 days;
self.transactions[now / 1 days].push(_id);
} else {
_txIndex--;
allGood = checkNotConfirmed(self, _id, _txIndex);
if(!allGood)
return (false,_id);
}
}
self.transactionInfo[_id][_txIndex].confirmedOwners.push(uint256(msg.sender));
self.transactionInfo[_id][_txIndex].confirmCount++;
} else {
_txIndex--;
}
if(self.transactionInfo[_id][_txIndex].confirmCount ==
self.transactionInfo[_id][_txIndex].confirmRequired)
{
self.currentSpend[0][1] += _value;
self.currentSpend[_to][1] += _amount;
self.transactionInfo[_id][_txIndex].success = true;
if(_to == 0){
createContract(_txData, _value);
} else {
require(_to.call.value(_value)(_txData));
}
delete self.transactionInfo[_id][_txIndex].data;
LogTransactionComplete(_id, _to, _value, _data);
} else {
if(self.transactionInfo[_id][_txIndex].data.length == 0)
self.transactionInfo[_id][_txIndex].data = _data;
uint256 confirmsNeeded = calcConfirmsNeeded(self.transactionInfo[_id][_txIndex].confirmRequired,
self.transactionInfo[_id][_txIndex].confirmCount);
LogTransactionConfirmed(_id, msg.sender, confirmsNeeded);
}
return (true,_id);
}
function confirmTx(WalletData storage self, bytes32 _id)
public returns (bool) {
require(self.ownerIndex[msg.sender] > 0);
uint256 _txIndex = self.transactionInfo[_id].length;
bool ret;
if(_txIndex == 0){
LogErrorMsg(_txIndex, "Tx not initiated");
LogTransactionFailed(_id, msg.sender);
return false;
}
_txIndex--;
bool allGood = checkNotConfirmed(self, _id, _txIndex);
if(!allGood)
return false;
self.transactionInfo[_id][_txIndex].confirmedOwners.push(uint256(msg.sender));
self.transactionInfo[_id][_txIndex].confirmCount++;
if(self.transactionInfo[_id][_txIndex].confirmCount ==
self.transactionInfo[_id][_txIndex].confirmRequired)
{
address a = address(this);
require(a.call(self.transactionInfo[_id][_txIndex].data));
} else {
uint256 confirmsNeeded = calcConfirmsNeeded(self.transactionInfo[_id][_txIndex].confirmRequired,
self.transactionInfo[_id][_txIndex].confirmCount);
LogTransactionConfirmed(_id, msg.sender, confirmsNeeded);
ret = true;
}
return ret;
}
function revokeConfirm(WalletData storage self, bytes32 _id)
public
returns (bool)
{
require(self.ownerIndex[msg.sender] > 0);
uint256 _txIndex = self.transactionInfo[_id].length;
if(_txIndex == 0){
LogErrorMsg(_txIndex, "Tx not initiated");
LogTransactionFailed(_id, msg.sender);
return false;
}
_txIndex--;
if(self.transactionInfo[_id][_txIndex].success){
LogErrorMsg(_txIndex, "Transaction already complete");
LogTransactionFailed(_id, msg.sender);
return false;
}
bool found;
uint256 index;
(found, index) = self.transactionInfo[_id][_txIndex].confirmedOwners.indexOf(uint256(msg.sender), false);
if(!found){
LogErrorMsg(index, "Owner has not confirmed tx");
LogTransactionFailed(_id, msg.sender);
return false;
}
self.transactionInfo[_id][_txIndex].confirmedOwners[index] = 0;
self.transactionInfo[_id][_txIndex].confirmCount--;
uint256 confirmsNeeded = calcConfirmsNeeded(self.transactionInfo[_id][_txIndex].confirmRequired,
self.transactionInfo[_id][_txIndex].confirmCount);
if(self.transactionInfo[_id][_txIndex].confirmCount == 0)
self.transactionInfo[_id].length--;
LogRevokeNotice(_id, msg.sender, confirmsNeeded);
return true;
}
}
library Array256Lib {
function sumElements(uint256[] storage self) public view returns(uint256 sum) {
assembly {
mstore(0x60,self_slot)
for { let i := 0 } lt(i, sload(self_slot)) { i := add(i, 1) } {
sum := add(sload(add(sha3(0x60,0x20),i)),sum)
}
}
}
function getMax(uint256[] storage self) public view returns(uint256 maxValue) {
assembly {
mstore(0x60,self_slot)
maxValue := sload(sha3(0x60,0x20))
for { let i := 0 } lt(i, sload(self_slot)) { i := add(i, 1) } {
switch gt(sload(add(sha3(0x60,0x20),i)), maxValue)
case 1 {
maxValue := sload(add(sha3(0x60,0x20),i))
}
}
}
}
function getMin(uint256[] storage self) public view returns(uint256 minValue) {
assembly {
mstore(0x60,self_slot)
minValue := sload(sha3(0x60,0x20))
for { let i := 0 } lt(i, sload(self_slot)) { i := add(i, 1) } {
switch gt(sload(add(sha3(0x60,0x20),i)), minValue)
case 0 {
minValue := sload(add(sha3(0x60,0x20),i))
}
}
}
}
function indexOf(uint256[] storage self, uint256 value, bool isSorted)
public
view
returns(bool found, uint256 index) {
assembly{
mstore(0x60,self_slot)
switch isSorted
case 1 {
let high := sub(sload(self_slot),1)
let mid := 0
let low := 0
for { } iszero(gt(low, high)) { } {
mid := div(add(low,high),2)
switch lt(sload(add(sha3(0x60,0x20),mid)),value)
case 1 {
low := add(mid,1)
}
case 0 {
switch gt(sload(add(sha3(0x60,0x20),mid)),value)
case 1 {
high := sub(mid,1)
}
case 0 {
found := 1
index := mid
low := add(high,1)
}
}
}
}
case 0 {
for { let low := 0 } lt(low, sload(self_slot)) { low := add(low, 1) } {
switch eq(sload(add(sha3(0x60,0x20),low)), value)
case 1 {
found := 1
index := low
low := sload(self_slot)
}
}
}
}
}
function getParentI(uint256 index) private pure returns (uint256 pI) {
uint256 i = index - 1;
pI = i/2;
}
function getLeftChildI(uint256 index) private pure returns (uint256 lcI) {
uint256 i = index * 2;
lcI = i + 1;
}
function heapSort(uint256[] storage self) public {
uint256 end = self.length - 1;
uint256 start = getParentI(end);
uint256 root = start;
uint256 lChild;
uint256 rChild;
uint256 swap;
uint256 temp;
while(start >= 0){
root = start;
lChild = getLeftChildI(start);
while(lChild <= end){
rChild = lChild + 1;
swap = root;
if(self[swap] < self[lChild])
swap = lChild;
if((rChild <= end) && (self[swap]<self[rChild]))
swap = rChild;
if(swap == root)
lChild = end+1;
else {
temp = self[swap];
self[swap] = self[root];
self[root] = temp;
root = swap;
lChild = getLeftChildI(root);
}
}
if(start == 0)
break;
else
start = start - 1;
}
while(end > 0){
temp = self[end];
self[end] = self[0];
self[0] = temp;
end = end - 1;
root = 0;
lChild = getLeftChildI(0);
while(lChild <= end){
rChild = lChild + 1;
swap = root;
if(self[swap] < self[lChild])
swap = lChild;
if((rChild <= end) && (self[swap]<self[rChild]))
swap = rChild;
if(swap == root)
lChild = end + 1;
else {
temp = self[swap];
self[swap] = self[root];
self[root] = temp;
root = swap;
lChild = getLeftChildI(root);
}
}
}
}
function uniq(uint256[] storage self) public returns (uint256 length) {
bool contains;
uint256 index;
for (uint256 i = 0; i < self.length; i++) {
(contains, index) = indexOf(self, self[i], false);
if (i > index) {
for (uint256 j = i; j < self.length - 1; j++){
self[j] = self[j + 1];
}
delete self[self.length - 1];
self.length--;
i--;
}
}
length = self.length;
}
}
library BasicMathLib {
function times(uint256 a, uint256 b) public view returns (bool err,uint256 res) {
assembly{
res := mul(a,b)
switch or(iszero(b), eq(div(res,b), a))
case 0 {
err := 1
res := 0
}
}
}
function dividedBy(uint256 a, uint256 b) public view returns (bool err,uint256 i) {
uint256 res;
assembly{
switch iszero(b)
case 0 {
res := div(a,b)
let loc := mload(0x40)
mstore(add(loc,0x20),res)
i := mload(add(loc,0x20))
}
default {
err := 1
i := 0
}
}
}
function plus(uint256 a, uint256 b) public view returns (bool err, uint256 res) {
assembly{
res := add(a,b)
switch and(eq(sub(res,b), a), or(gt(res,b),eq(res,b)))
case 0 {
err := 1
res := 0
}
}
}
function minus(uint256 a, uint256 b) public view returns (bool err,uint256 res) {
assembly{
res := sub(a,b)
switch eq(and(eq(add(res,b), a), or(lt(res,a), eq(res,a))), 1)
case 0 {
err := 1
res := 0
}
}
}
}