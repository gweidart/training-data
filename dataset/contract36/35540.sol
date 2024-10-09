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
require( msg.sender == owner || msg.sender == manager );
_;
}
}
contract Token {
function balanceOf(address tokenHolder) constant returns(uint256)  {}
function totalSupply() constant returns(uint256) {}
function getAccountCount() constant returns(uint256) {}
function getAddress(uint slot) constant returns(address) {}
}
contract tokenRecipient {
function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData);
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
contract SubToken {
function SubTokenCreate ( uint256 _initialSupply, uint8 decimalUnits, string  _name, string   _symbol, address _tokenowner )returns (address){}
function transfer ( address _address , uint256 amount ){}
function share()returns(uint256){}
function totalSupply()returns(uint256){}
function initialSupply()returns(uint256){}
}
contract Cents is ERC20 {
using strings for *;
string public standard = 'Token 1.0';
string public name;
string public symbol;
uint8 public decimals;
uint256 public totalSupply;
uint256 public initialSupply;
address public _owner;
address public owner;
address public manager;
address public Centspooladdress;
mapping( address => uint256) public balanceOf;
mapping( uint => address) public accountIndex;
mapping( address =>bool ) public accountFreeze;
uint accountCount;
mapping(address => mapping(address => uint256)) public allowance;
event Transfer(address indexed from, address indexed to, uint256 value);
event Approval(address indexed owner, address indexed spender, uint value);
event FrozenFunds ( address target, bool frozen );
event TTLAccounts ( uint accounts );
event TTLSupply ( uint supply ) ;
event Burn(address indexed from, uint256 value);
function Cents() {
uint256 _initialSupply = 100000000 ;
uint8 decimalUnits = 0;
appendTokenHolders(msg.sender);
balanceOf[msg.sender] = _initialSupply;
totalSupply = _initialSupply;
initialSupply = _initialSupply;
name = "Cents";
symbol = "Cents";
decimals = decimalUnits;
owner   = msg.sender;
}
function setCentsPoolAddress( address _Centspooladdress ) {
Centspooladdress = _Centspooladdress;
}
function distributionSync( address _tokenholder , bool slowsync ) private {
CentsPool Centspool = CentsPool (  Centspooladdress );
Centspool.syncsync ( _tokenholder, false );
}
function setZeroMarker( address _tokenholder  ) private {
if (balanceOf[ _tokenholder ]  >0 ) return;
CentsPool Centspool = CentsPool (  Centspooladdress );
Centspool.setZeroMarker ( _tokenholder );
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
setZeroMarker( _to );
distributionSync( _to , false );
distributionSync( msg.sender , false );
balanceOf[msg.sender] -= _value;
balanceOf[_to] += _value;
Transfer(msg.sender, _to, _value);
return true;
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
setZeroMarker( _to );
setZeroMarker( _from );
distributionSync( _to , false );
distributionSync(_from , false );
balanceOf[_from] -= _value;
balanceOf[_to] += _value;
allowance[_from][msg.sender] -= _value;
Transfer(_from, _to, _value);
return true;
}
function burn(uint256 _value) returns(bool success) {
if (balanceOf[msg.sender] < _value) throw;
if ( (totalSupply - _value) <  ( initialSupply / 2 ) ) throw;
balanceOf[msg.sender] -= _value;
totalSupply -= _value;
Burn(msg.sender, _value);
return true;
}
function burnFrom(address _from, uint256 _value) returns(bool success) {
if (balanceOf[_from] < _value) throw;
if (_value > allowance[_from][msg.sender]) throw;
if ( (totalSupply - _value) <  ( initialSupply / 2 )) throw;
balanceOf[_from] -= _value;
totalSupply -= _value;
Burn(_from, _value);
return true;
}
modifier onlyOwner {
require(msg.sender == owner);
_;
}
function transferOwnership(address newOwner) public onlyOwner {
owner = newOwner;
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
}
contract peg  {  function TokenCreationContract()returns(address); }
contract pegc {  function tokenCount()returns(uint256);
function getTokenAddress( uint256 ) returns(address);
}
contract CentsPool{
address public CentsTokenAddress;
address public pegaddress;
Cents CentsToken;
peg PEG;
pegc PEGC;
address public pegcaddress;
address owner;
uint256 slowsyncamount;
struct tokenHolderBalances {
uint256 balance;
uint256 marker;
}
event ThBalance (address _address , uint256 _bal);
event Share ( uint256 _bal);
event CentsTokenSupply ( uint256 _bal);
event TokenAddress ( address __tokenaddress );
event TokenHolderShare ( uint256 tokenholdershare  );
event TokenHolderCentsBalance ( uint256 __balance  );
event Loop ( uint256 _i  );
event ZeroBalance ( string _i  , uint256 loopcount );
mapping ( uint256 => address ) public tokenAddress;
mapping ( address => string ) public tokenSymbol;
mapping ( address => uint256 ) public tokenBalance;
mapping ( address => tokenHolderBalances[] ) public thBalances;
mapping ( address => bool ) public zeromarker;
mapping ( address => uint256 ) public tokenHolderInfoSync;
mapping ( address => uint256 ) public tokenHolderPaymentSync;
function CentsPool( address _pegaddress,  address _CentsToken ){
CentsTokenAddress = _CentsToken;
CentsToken = Cents( _CentsToken );
pegaddress = _pegaddress;
PEG = peg( _pegaddress);
owner = msg.sender;
slowsyncamount = 100;
}
modifier onlyOwner {
require(msg.sender == owner);
_;
}
function transferOwnership( address _newowner ) onlyOwner {
owner = _newowner;
}
function setSlowSync( uint256 _slowsyncamount ) onlyOwner {
slowsyncamount = _slowsyncamount;
}
function setZeroMarker ( address _tokenholder ){
zeromarker[ _tokenholder] = true;
}
function syncsync( address __tokenholder , bool slowsync ){
address _tokenholder;
PEGC = pegc( PEG.TokenCreationContract());
uint256 tokens =  PEGC.tokenCount();
if ( msg.sender == CentsTokenAddress ){ _tokenholder = __tokenholder;} else _tokenholder=msg.sender;
uint256 count = PEGC.tokenCount() - tokenHolderInfoSync [ _tokenholder ] ;
if ( count < 1 ) return;
uint256 _balance = CentsToken.balanceOf( _tokenholder );
count = PEGC.tokenCount();
if ( zeromarker[ _tokenholder ] == true ){
thBalances[ _tokenholder ].push ( tokenHolderBalances (  0 , count  ) );
zeromarker[ _tokenholder ] = false;
tokenHolderInfoSync [ _tokenholder ] = count;
ZeroBalance ( "HadZeroBalance" ,  0 );
return;  }
uint256 _totalCentssupply = CentsToken.initialSupply();
if ( slowsync ){  if ( count < slowsyncamount ) throw;
count = slowsyncamount + tokenHolderInfoSync [ _tokenholder ];
}
uint256 tokensperCents;
for ( uint i = tokenHolderInfoSync [ _tokenholder ]  ; i< count; i++){
ZeroBalance ( "NotAZeroBalance" , i );
SubToken subtoken = SubToken ( PEGC.getTokenAddress ( i ));
uint256 share = subtoken.share();
tokensperCents = share/_totalCentssupply;
uint256 tokenholdershare = _balance *  tokensperCents;
thBalances[ _tokenholder ].push ( tokenHolderBalances (  tokenholdershare , 0  ) );
TokenAddress( PEGC.getTokenAddress ( i ) );
}
Loop ( i );
tokenHolderInfoSync [ _tokenholder ] = count  ;
}
function withdrawTokens(  bool slowsync ){
PEGC = pegc( PEG.TokenCreationContract());
uint256 tokens =  PEGC.tokenCount();
uint256 count = tokenHolderInfoSync [ msg.sender ] - tokenHolderPaymentSync [ msg.sender ] ;
if ( count < 1 ) return;
uint256 _balance = CentsToken.balanceOf( msg.sender );
uint256 _totalCentssupply = CentsToken.initialSupply();
count = tokenHolderInfoSync [ msg.sender ];
if ( slowsync ){  if ( count < slowsyncamount ) throw;
count = slowsyncamount + tokenHolderPaymentSync [ msg.sender ];
}
uint256 tokensperCents;
for ( uint i = tokenHolderPaymentSync [ msg.sender ]  ; i< count; i++){
if ( thBalances[msg.sender ][ i ].balance == 0 ) i = i + thBalances[msg.sender ][ i ].marker -1 ;
SubToken subtoken = SubToken ( PEGC.getTokenAddress ( i ));
uint256 share = subtoken.share();
tokensperCents = share/_totalCentssupply;
uint256 tokenholdershare = _balance *  tokensperCents;
uint256 sendamount = thBalances[msg.sender ][ i ].balance;
subtoken.transfer ( msg.sender, sendamount  );
}
Loop ( i );
tokenHolderPaymentSync [ msg.sender ] = count  ;
}
}