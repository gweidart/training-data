pragma solidity ^ 0.4 .11;
library strings {
struct slice {
uint _len;
uint _ptr;
}
function memcpy(uint dest, uint src, uint len) private {
for(; len >= 32; len -= 32) {
assembly {
mstore(dest, mload(src))
}
dest += 32;
src += 32;
}
uint mask = 256 ** (32 - len) - 1;
assembly {
let srcpart := and(mload(src), not(mask))
let destpart := and(mload(dest), mask)
mstore(dest, or(destpart, srcpart))
}
}
function toSlice(string self) internal returns (slice) {
uint ptr;
assembly {
ptr := add(self, 0x20)
}
return slice(bytes(self).length, ptr);
}
function len(bytes32 self) internal returns (uint) {
uint ret;
if (self == 0)
return 0;
if (self & 0xffffffffffffffffffffffffffffffff == 0) {
ret += 16;
self = bytes32(uint(self) / 0x100000000000000000000000000000000);
}
if (self & 0xffffffffffffffff == 0) {
ret += 8;
self = bytes32(uint(self) / 0x10000000000000000);
}
if (self & 0xffffffff == 0) {
ret += 4;
self = bytes32(uint(self) / 0x100000000);
}
if (self & 0xffff == 0) {
ret += 2;
self = bytes32(uint(self) / 0x10000);
}
if (self & 0xff == 0) {
ret += 1;
}
return 32 - ret;
}
function toSliceB32(bytes32 self) internal returns (slice ret) {
assembly {
let ptr := mload(0x40)
mstore(0x40, add(ptr, 0x20))
mstore(ptr, self)
mstore(add(ret, 0x20), ptr)
}
ret._len = len(self);
}
function copy(slice self) internal returns (slice) {
return slice(self._len, self._ptr);
}
function toString(slice self) internal returns (string) {
var ret = new string(self._len);
uint retptr;
assembly { retptr := add(ret, 32) }
memcpy(retptr, self._ptr, self._len);
return ret;
}
function len(slice self) internal returns (uint) {
var ptr = self._ptr - 31;
var end = ptr + self._len;
for (uint len = 0; ptr < end; len++) {
uint8 b;
assembly { b := and(mload(ptr), 0xFF) }
if (b < 0x80) {
ptr += 1;
} else if(b < 0xE0) {
ptr += 2;
} else if(b < 0xF0) {
ptr += 3;
} else if(b < 0xF8) {
ptr += 4;
} else if(b < 0xFC) {
ptr += 5;
} else {
ptr += 6;
}
}
return len;
}
function empty(slice self) internal returns (bool) {
return self._len == 0;
}
function compare(slice self, slice other) internal returns (int) {
uint shortest = self._len;
if (other._len < self._len)
shortest = other._len;
var selfptr = self._ptr;
var otherptr = other._ptr;
for (uint idx = 0; idx < shortest; idx += 32) {
uint a;
uint b;
assembly {
a := mload(selfptr)
b := mload(otherptr)
}
if (a != b) {
uint mask = ~(2 ** (8 * (32 - shortest + idx)) - 1);
var diff = (a & mask) - (b & mask);
if (diff != 0)
return int(diff);
}
selfptr += 32;
otherptr += 32;
}
return int(self._len) - int(other._len);
}
function equals(slice self, slice other) internal returns (bool) {
return compare(self, other) == 0;
}
function nextRune(slice self, slice rune) internal returns (slice) {
rune._ptr = self._ptr;
if (self._len == 0) {
rune._len = 0;
return rune;
}
uint len;
uint b;
assembly { b := and(mload(sub(mload(add(self, 32)), 31)), 0xFF) }
if (b < 0x80) {
len = 1;
} else if(b < 0xE0) {
len = 2;
} else if(b < 0xF0) {
len = 3;
} else {
len = 4;
}
if (len > self._len) {
rune._len = self._len;
self._ptr += self._len;
self._len = 0;
return rune;
}
self._ptr += len;
self._len -= len;
rune._len = len;
return rune;
}
function nextRune(slice self) internal returns (slice ret) {
nextRune(self, ret);
}
function ord(slice self) internal returns (uint ret) {
if (self._len == 0) {
return 0;
}
uint word;
uint len;
uint div = 2 ** 248;
assembly { word:= mload(mload(add(self, 32))) }
var b = word / div;
if (b < 0x80) {
ret = b;
len = 1;
} else if(b < 0xE0) {
ret = b & 0x1F;
len = 2;
} else if(b < 0xF0) {
ret = b & 0x0F;
len = 3;
} else {
ret = b & 0x07;
len = 4;
}
if (len > self._len) {
return 0;
}
for (uint i = 1; i < len; i++) {
div = div / 256;
b = (word / div) & 0xFF;
if (b & 0xC0 != 0x80) {
return 0;
}
ret = (ret * 64) | (b & 0x3F);
}
return ret;
}
function keccak(slice self) internal returns (bytes32 ret) {
assembly {
ret := sha3(mload(add(self, 32)), mload(self))
}
}
function startsWith(slice self, slice needle) internal returns (bool) {
if (self._len < needle._len) {
return false;
}
if (self._ptr == needle._ptr) {
return true;
}
bool equal;
assembly {
let len := mload(needle)
let selfptr := mload(add(self, 0x20))
let needleptr := mload(add(needle, 0x20))
equal := eq(sha3(selfptr, len), sha3(needleptr, len))
}
return equal;
}
function beyond(slice self, slice needle) internal returns (slice) {
if (self._len < needle._len) {
return self;
}
bool equal = true;
if (self._ptr != needle._ptr) {
assembly {
let len := mload(needle)
let selfptr := mload(add(self, 0x20))
let needleptr := mload(add(needle, 0x20))
equal := eq(sha3(selfptr, len), sha3(needleptr, len))
}
}
if (equal) {
self._len -= needle._len;
self._ptr += needle._len;
}
return self;
}
function endsWith(slice self, slice needle) internal returns (bool) {
if (self._len < needle._len) {
return false;
}
var selfptr = self._ptr + self._len - needle._len;
if (selfptr == needle._ptr) {
return true;
}
bool equal;
assembly {
let len := mload(needle)
let needleptr := mload(add(needle, 0x20))
equal := eq(sha3(selfptr, len), sha3(needleptr, len))
}
return equal;
}
function until(slice self, slice needle) internal returns (slice) {
if (self._len < needle._len) {
return self;
}
var selfptr = self._ptr + self._len - needle._len;
bool equal = true;
if (selfptr != needle._ptr) {
assembly {
let len := mload(needle)
let needleptr := mload(add(needle, 0x20))
equal := eq(sha3(selfptr, len), sha3(needleptr, len))
}
}
if (equal) {
self._len -= needle._len;
}
return self;
}
function findPtr(uint selflen, uint selfptr, uint needlelen, uint needleptr) private returns (uint) {
uint ptr;
uint idx;
if (needlelen <= selflen) {
if (needlelen <= 32) {
assembly {
let mask := not(sub(exp(2, mul(8, sub(32, needlelen))), 1))
let needledata := and(mload(needleptr), mask)
let end := add(selfptr, sub(selflen, needlelen))
ptr := selfptr
loop:
jumpi(exit, eq(and(mload(ptr), mask), needledata))
ptr := add(ptr, 1)
jumpi(loop, lt(sub(ptr, 1), end))
ptr := add(selfptr, selflen)
exit:
}
return ptr;
} else {
bytes32 hash;
assembly { hash := sha3(needleptr, needlelen) }
ptr = selfptr;
for (idx = 0; idx <= selflen - needlelen; idx++) {
bytes32 testHash;
assembly { testHash := sha3(ptr, needlelen) }
if (hash == testHash)
return ptr;
ptr += 1;
}
}
}
return selfptr + selflen;
}
function rfindPtr(uint selflen, uint selfptr, uint needlelen, uint needleptr) private returns (uint) {
uint ptr;
if (needlelen <= selflen) {
if (needlelen <= 32) {
assembly {
let mask := not(sub(exp(2, mul(8, sub(32, needlelen))), 1))
let needledata := and(mload(needleptr), mask)
ptr := add(selfptr, sub(selflen, needlelen))
loop:
jumpi(ret, eq(and(mload(ptr), mask), needledata))
ptr := sub(ptr, 1)
jumpi(loop, gt(add(ptr, 1), selfptr))
ptr := selfptr
jump(exit)
ret:
ptr := add(ptr, needlelen)
exit:
}
return ptr;
} else {
bytes32 hash;
assembly { hash := sha3(needleptr, needlelen) }
ptr = selfptr + (selflen - needlelen);
while (ptr >= selfptr) {
bytes32 testHash;
assembly { testHash := sha3(ptr, needlelen) }
if (hash == testHash)
return ptr + needlelen;
ptr -= 1;
}
}
}
return selfptr;
}
function find(slice self, slice needle) internal returns (slice) {
uint ptr = findPtr(self._len, self._ptr, needle._len, needle._ptr);
self._len -= ptr - self._ptr;
self._ptr = ptr;
return self;
}
function rfind(slice self, slice needle) internal returns (slice) {
uint ptr = rfindPtr(self._len, self._ptr, needle._len, needle._ptr);
self._len = ptr - self._ptr;
return self;
}
function split(slice self, slice needle, slice token) internal returns (slice) {
uint ptr = findPtr(self._len, self._ptr, needle._len, needle._ptr);
token._ptr = self._ptr;
token._len = ptr - self._ptr;
if (ptr == self._ptr + self._len) {
self._len = 0;
} else {
self._len -= token._len + needle._len;
self._ptr = ptr + needle._len;
}
return token;
}
function split(slice self, slice needle) internal returns (slice token) {
split(self, needle, token);
}
function rsplit(slice self, slice needle, slice token) internal returns (slice) {
uint ptr = rfindPtr(self._len, self._ptr, needle._len, needle._ptr);
token._ptr = ptr;
token._len = self._len - (ptr - self._ptr);
if (ptr == self._ptr) {
self._len = 0;
} else {
self._len -= token._len + needle._len;
}
return token;
}
function rsplit(slice self, slice needle) internal returns (slice token) {
rsplit(self, needle, token);
}
function count(slice self, slice needle) internal returns (uint count) {
uint ptr = findPtr(self._len, self._ptr, needle._len, needle._ptr) + needle._len;
while (ptr <= self._ptr + self._len) {
count++;
ptr = findPtr(self._len - (ptr - self._ptr), ptr, needle._len, needle._ptr) + needle._len;
}
}
function contains(slice self, slice needle) internal returns (bool) {
return rfindPtr(self._len, self._ptr, needle._len, needle._ptr) != self._ptr;
}
function concat(slice self, slice other) internal returns (string) {
var ret = new string(self._len + other._len);
uint retptr;
assembly { retptr := add(ret, 32) }
memcpy(retptr, self._ptr, self._len);
memcpy(retptr + self._len, other._ptr, other._len);
return ret;
}
function join(slice self, slice[] parts) internal returns (string) {
if (parts.length == 0)
return "";
uint len = self._len * (parts.length - 1);
for(uint i = 0; i < parts.length; i++)
len += parts[i]._len;
var ret = new string(len);
uint retptr;
assembly { retptr := add(ret, 32) }
for(i = 0; i < parts.length; i++) {
memcpy(retptr, parts[i]._ptr, parts[i]._len);
retptr += parts[i]._len;
if (i < parts.length - 1) {
memcpy(retptr, self._ptr, self._len);
retptr += self._len;
}
}
return ret;
}
}
contract Contract {function pegHandler( address _from, uint256 _value );}
contract Manager {
address owner;
address  manager;
modifier onlyOwner {
require(msg.sender == owner);
_;
}
modifier onlyManagement {
if( msg.sender != owner && msg.sender != manager ) throw;
_;
}
}
contract Token {
function balanceOf(address tokenHolder) constant returns(uint256)  {}
function totalSupply() constant returns(uint256) {}
function getAccountCount() constant returns(uint256) {}
function getAddress(uint slot) constant returns(address) {}
}
contract Contracts {
Contract public contract_address;
Token token;
uint256 profit_per_token;
address public TokenCreationContract;
mapping( address => bool ) public contracts;
mapping( address => bool ) public contractExists;
mapping( uint => address) public  contractIndex;
mapping( address => bool ) public contractOrigin;
uint public contractCount;
address owner;
event ContractCall ( address _address, uint _value );
event Log ( address _address, uint value  );
event Message ( uint value  );
modifier onlyOwner {
require(msg.sender == owner);
_;
}
modifier onlyTokenContractCreator {
require(msg.sender == TokenCreationContract  ||  msg.sender == owner);
_;
}
function addContract ( address _contract ) public onlyOwner returns(bool)  {
contracts[ _contract ] = true;
if  ( !contractExists[ _contract ]){
contractExists[ _contract ] = true;
contractIndex[ contractCount ] = _contract;
contractOrigin[ _contract ] = true;
contractCount++;
return true;
}
return false;
}
function setContractOrigin ( address _contract , bool who ) onlyTokenContractCreator {
contractOrigin[ _contract ] = who;
}
function getContractOrigin ()  returns (bool b)  {
return contractOrigin[ msg.sender ];
}
function latchContract () public returns(bool)  {
contracts[ msg.sender ] = true;
if  ( !contractExists[ msg.sender ]){
contractExists[ msg.sender ] = true;
contractIndex[ contractCount ] = msg.sender;
contractOrigin[ msg.sender ] = false;
contractCount++;
return true;
}
return false;
}
function unlatchContract ( ) public returns(bool){
contracts[ msg.sender ] = false;
}
function removeContract ( address _contract )  public  onlyOwner returns(bool) {
contracts[ _contract ] =  false;
return true;
}
function getContractCount() public constant returns (uint256){
return contractCount;
}
function getContractAddress( uint slot ) public constant returns (address){
return contractIndex[slot];
}
function getContractStatus( address _address) public constant returns (bool) {
return contracts[ _address];
}
function contractCheck ( address _address, uint256 value ) internal  {
if( contracts[ _address ] ) {
contract_address = Contract (  _address  );
contract_address.pegHandler  ( msg.sender , value );
}
}
}
contract tokenRecipient {
function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData);
}
library SafeMath {
function mul(uint256 a, uint256 b) internal constant returns(uint256) {
uint256 c = a * b;
assert(a == 0 || c / a == b);
return c;
}
function div(uint256 a, uint256 b) internal constant returns(uint256) {
uint256 c = a / b;
return c;
}
function sub(uint256 a, uint256 b) internal constant returns(uint256) {
assert(b <= a);
return a - b;
}
function add(uint256 a, uint256 b) internal constant returns(uint256) {
uint256 c = a + b;
assert(c >= a);
return c;
}
}
library StringUtils {
function compare(string _a, string _b) returns (int) {
bytes memory a = bytes(_a);
bytes memory b = bytes(_b);
uint minLength = a.length;
if (b.length < minLength) minLength = b.length;
for (uint i = 0; i < minLength; i ++)
if (a[i] < b[i])
return -1;
else if (a[i] > b[i])
return 1;
if (a.length < b.length)
return -1;
else if (a.length > b.length)
return 1;
else
return 0;
}
function equal(string _a, string _b) returns (bool) {
return compare(_a, _b) == 0;
}
function indexOf(string _haystack, string _needle) returns (int)
{
bytes memory h = bytes(_haystack);
bytes memory n = bytes(_needle);
if(h.length < 1 || n.length < 1 || (n.length > h.length))
return -1;
else if(h.length > (2**128 -1))
return -1;
else
{
uint subindex = 0;
for (uint i = 0; i < h.length; i ++)
{
if (h[i] == n[0])
{
subindex = 1;
while(subindex < n.length && (i + subindex) < h.length && h[i + subindex] == n[subindex])
{
subindex++;
}
if(subindex == n.length)
return int(i);
}
}
return -1;
}
}
}
contract ERC20 {
function totalSupply() constant returns(uint totalSupply);
function balanceOf(address who) constant returns(uint256);
function transfer(address to, uint value) returns(bool ok);
function transferFrom(address from, address to, uint value) returns(bool ok);
function approve(address spender, uint value) returns(bool ok);
function allowance(address owner, address spender) constant returns(uint);
event Transfer(address indexed from, address indexed to, uint value);
event Approval(address indexed owner, address indexed spender, uint value);
}
contract SubToken { function SubTokenCreate ( uint256 _initialSupply, uint8 decimalUnits, string  _name, string   _symbol, address _tokenowner )
returns (address){} }
contract Dividend { function setReseller ( address ){}}
contract Peg is ERC20, Contracts, Manager {
using strings for *;
using SafeMath
for uint256;
string public standard = 'Token 0.1';
string public name;
string public symbol;
uint8 public decimals;
uint256 public totalSupply;
uint256 public initialSupply;
address public owner;
address public minter;
address public manager;
address public masterresellercontract;
Memo m;
uint256 public dividendcommission;
uint256 public transactionfee;
mapping( address => uint256) public balanceOf;
mapping( uint => address) public accountIndex;
mapping( address => bool ) public accountFreeze;
mapping( address => bool ) public reseller;
uint accountCount;
struct Memo {
address   _from;
address     _to;
uint256 _amount;
string    _memo;
string    _hash;
}
mapping ( string => uint ) private memos;
mapping( uint => Memo ) private memoIndex;
uint memoCount;
mapping(address => mapping(address => uint256)) public allowance;
event Transfer(address indexed from, address indexed to, uint256 value);
event Approval(address indexed owner, address indexed spender, uint value);
event FrozenFunds ( address target, bool frozen );
event TTLAccounts ( uint accounts );
event TTLSupply ( uint supply ) ;
event Display  (address _from,  address _to, uint256 _amount, string _memo, string _hash);
event Burn(address indexed from, uint256 value);
function Peg() {
uint256 _initialSupply = 1000000000000000000000000000000000000 ;
uint8 decimalUnits = 30;
appendTokenHolders(msg.sender);
balanceOf[msg.sender] = _initialSupply;
totalSupply = _initialSupply;
initialSupply = _initialSupply;
name = "PEG";
symbol = "PEG";
decimals = decimalUnits;
memoCount++;
owner   = msg.sender;
manager = owner;
minter  = owner;
dividendcommission =  100;
}
function balanceOf(address tokenHolder) constant returns(uint256) {
return balanceOf[tokenHolder];
}
function totalSupply() constant returns(uint256) {
return totalSupply;
}
function getAccountCount() constant returns(uint256) {
return accountCount;
}
function getAddress(uint slot) constant returns(address) {
return accountIndex[slot];
}
function appendTokenHolders(address tokenHolder) private {
if (balanceOf[tokenHolder] == 0) {
accountIndex[accountCount] = tokenHolder;
accountCount++;
}
}
function transfer(address _to, uint256 _value) returns(bool ok) {
if (_to == 0x0) throw;
if (balanceOf[msg.sender] < _value) throw;
if (balanceOf[_to] + _value < balanceOf[_to]) throw;
if ( accountFreeze[ msg.sender ]  ) throw;
appendTokenHolders(_to);
balanceOf[msg.sender] -= _value;
balanceOf[_to] += _value;
Transfer(msg.sender, _to, _value);
contractCheck( _to , _value );
return true;
}
function transferWithMemo(address _to, uint256 _value, string _memo, string _hash ) public returns(bool ok) {
var _hh = _hash.toSlice();
uint len = _hh.len();
require ( len > 10 );
if ( memos[ _hash ] != 0 ) throw;
transfer ( _to, _value);
m._from   = msg.sender;
m._to     = _to;
m._amount = _value;
m._memo   = _memo;
m._hash   = _hash;
memoIndex[ memoCount ] = m;
memos [ _hash ] = memoCount;
memoCount++;
Display (  msg.sender ,   _to,  _value,  _memo, _hash );
return true;
}
function getMemos( string  _hash ) returns (  address _from,  address _to, uint256 _amount, string _memo ) {
if ( memos [_hash] == 0 ) throw;
_from = memoIndex[memos [_hash]]._from;
_to =  memoIndex[memos [_hash]]._to;
_amount  = memoIndex[memos [_hash]]._amount;
_memo = memoIndex[memos [_hash]]._memo;
Display (   _from,   _to,  _amount,  _memo, _hash );
return ( _from, _to, _amount, _memo ) ;
}
function getMemo( uint256 num ) returns (  address _from,  address _to, uint256 _amount, string _memo, string _hash )  {
require ( msg.sender == owner || msg.sender == manager );
_from = memoIndex[ num ]._from;
_to =  memoIndex[ num ]._to;
_amount  = memoIndex[ num ]._amount;
_memo = memoIndex[ num ]._memo;
_hash = memoIndex[ num ]._hash;
Display (   _from,   _to,  _amount,  _memo, _hash );
return ( _from, _to, _amount, _memo, _hash );
}
function setDividendCommission ( uint256 _comm )  {
if( msg.sender != owner && msg.sender != manager ) throw;
if  (_comm > 200 ) throw;
dividendcommission = _comm;
}
function setTransactionFee ( uint256 _fee ) {
if( msg.sender != owner && msg.sender != manager ) throw;
if  (_fee > 100 ) throw;
transactionfee= _fee;
}
function setMasterResellerContract ( address _contract ) {
if( msg.sender != owner && msg.sender != manager ) throw;
masterresellercontract = _contract;
}
function setResellerOnDistributionContract ( address _contract, address reseller ) {
if( msg.sender != owner && msg.sender != manager ) throw;
Dividend div = Dividend ( _contract );
div.setReseller ( reseller );
}
function addReseller ( address _contract )onlyReseller{
reseller[_contract] = true;
}
function isReseller ( address _contract ) constant returns(bool){
return reseller[_contract];
}
function removeReseller ( address _contract )onlyOwner{
reseller[_contract] = false;
}
function approve(address _spender, uint256 _value)
returns(bool success) {
allowance[msg.sender][_spender] = _value;
Approval( msg.sender ,_spender, _value);
return true;
}
function approveAndCall(address _spender, uint256 _value, bytes _extraData)
returns(bool success) {
tokenRecipient spender = tokenRecipient(_spender);
if (approve(_spender, _value)) {
spender.receiveApproval(msg.sender, _value, this, _extraData);
return true;
}
}
function allowance(address _owner, address _spender) constant returns(uint256 remaining) {
return allowance[_owner][_spender];
}
function transferFrom(address _from, address _to, uint256 _value) returns(bool success) {
if (_to == 0x0) throw;
if (balanceOf[_from] < _value) throw;
if (balanceOf[_to] + _value < balanceOf[_to]) throw;
if (_value > allowance[_from][msg.sender]) throw;
if ( accountFreeze[ _from ]  ) throw;
appendTokenHolders(_to);
balanceOf[_from] -= _value;
balanceOf[_to] += _value;
allowance[_from][msg.sender] -= _value;
Transfer(_from, _to, _value);
contractCheck( _to , _value );
return true;
}
function burn(uint256 _value) returns(bool success) {
if (balanceOf[msg.sender] < _value) throw;
balanceOf[msg.sender] -= _value;
totalSupply -= _value;
Burn(msg.sender, _value);
return true;
}
function burnFrom(address _from, uint256 _value) returns(bool success) {
if (balanceOf[_from] < _value) throw;
if (_value > allowance[_from][msg.sender]) throw;
balanceOf[_from] -= _value;
totalSupply -= _value;
Burn(_from, _value);
return true;
}
modifier onlyOwner {
require(msg.sender == owner);
_;
}
modifier onlyMinter {
require(msg.sender == minter );
_;
}
modifier onlyReseller {
require(msg.sender == masterresellercontract );
_;
}
function transferOwnership(address newOwner) public onlyOwner {
owner = newOwner;
}
function assignMinter (address _minter) public onlyOwner {
minter = _minter;
}
function assignManagement (address _manager) public onlyOwner {
manager = _manager;
}
function freezeAccount ( address _account ) public onlyOwner{
accountFreeze [ _account ] = true;
FrozenFunds ( _account , true );
}
function unfreezeAccount ( address _account ) public onlyOwner{
accountFreeze [ _account ] = false;
FrozenFunds ( _account , false );
}
function mintToken(address target, uint256 mintedAmount) onlyOwner {
appendTokenHolders(target);
balanceOf[target] += mintedAmount;
totalSupply += mintedAmount;
Transfer(0, owner, mintedAmount);
Transfer(owner, target, mintedAmount);
}
function mintTokenByMinter( address target, uint256 mintedAmount ) onlyMinter  {
appendTokenHolders(target);
balanceOf[target] += mintedAmount;
totalSupply += mintedAmount;
Transfer(0, minter, mintedAmount);
Transfer(minter, target, mintedAmount);
}
function setTokenCreationContract ( address _contractaddress ) onlyOwner {
TokenCreationContract = _contractaddress;
}
function payPegDistribution( address _token, uint256 amount ){
if ( ! getContractStatus( msg.sender )) throw;
if ( balanceOf[ msg.sender ] < amount ) throw;
if ( ! getContractOrigin() ){
throw;
}
token = Token ( _token );
Transfer( msg.sender , _token, amount );
uint256  accountCount = token.getAccountCount();
uint256  supply = token.totalSupply();
Log( _token, amount  );
profit_per_token = amount / supply;
Message( profit_per_token );
for ( uint i=0; i < accountCount ; i++ ) {
address tokenHolder = token.getAddress(i);
if ( tokenHolder != msg.sender ) {
balanceOf[ tokenHolder ] += token.balanceOf( tokenHolder ) * profit_per_token;
}
}
balanceOf[ msg.sender ] -= amount;
}
}