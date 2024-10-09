pragma solidity 0.4.21;
library StringUtil {
function stringToBytes12(string str)
internal
pure
returns (bytes12 result)
{
assembly {
result := mload(add(str, 32))
}
}
function stringToBytes10(string str)
internal
pure
returns (bytes10 result)
{
assembly {
result := mload(add(str, 32))
}
}
function checkStringLength(string name, uint min, uint max)
internal
pure
returns (bool)
{
bytes memory temp = bytes(name);
return temp.length >= min && temp.length <= max;
}
}
library AddressUtil {
function isContract(
address addr
)
internal
view
returns (bool)
{
if (addr == 0x0) {
return false;
} else {
uint size;
assembly { size := extcodesize(addr) }
return size > 0;
}
}
}
contract ERC20 {
function balanceOf(
address who
)
view
public
returns (uint256);
function allowance(
address owner,
address spender
)
view
public
returns (uint256);
function transfer(
address to,
uint256 value
)
public
returns (bool);
function transferFrom(
address from,
address to,
uint256 value
)
public
returns (bool);
function approve(
address spender,
uint256 value
)
public
returns (bool);
}
library MathUint {
function mul(
uint a,
uint b
)
internal
pure
returns (uint c)
{
c = a * b;
require(a == 0 || c / a == b);
}
function sub(
uint a,
uint b
)
internal
pure
returns (uint)
{
require(b <= a);
return a - b;
}
function add(
uint a,
uint b
)
internal
pure
returns (uint c)
{
c = a + b;
require(c >= a);
}
function tolerantSub(
uint a,
uint b
)
internal
pure
returns (uint c)
{
return (a >= b) ? a - b : 0;
}
function cvsquare(
uint[] arr,
uint scale
)
internal
pure
returns (uint)
{
uint len = arr.length;
require(len > 1);
require(scale > 0);
uint avg = 0;
for (uint i = 0; i < len; i++) {
avg = add(avg, arr[i]);
}
avg = avg / len;
if (avg == 0) {
return 0;
}
uint cvs = 0;
uint s;
uint item;
for (i = 0; i < len; i++) {
item = arr[i];
s = item > avg ? item - avg : avg - item;
cvs = add(cvs, mul(s, s));
}
return ((mul(mul(cvs, scale), scale) / avg) / avg) / (len - 1);
}
}
contract ERC20Token is ERC20 {
using MathUint for uint;
string  public name;
string  public symbol;
uint8   public decimals;
uint    public totalSupply_;
mapping (address => uint256) balances;
mapping (address => mapping (address => uint256)) internal allowed;
event Transfer(
address indexed from,
address indexed to,
uint256 value
);
event Approval(
address indexed owner,
address indexed spender,
uint256 value
);
function ERC20Token(
string  _name,
string  _symbol,
uint8   _decimals,
uint    _totalSupply,
address _firstHolder
)
public
{
require(_totalSupply > 0);
require(_firstHolder != 0x0);
checkSymbolAndName(_symbol,_name);
name = _name;
symbol = _symbol;
decimals = _decimals;
totalSupply_ = _totalSupply;
balances[_firstHolder] = totalSupply_;
}
function ()
payable
public
{
revert();
}
function totalSupply()
public
view
returns (uint256)
{
return totalSupply_;
}
function transfer(
address _to,
uint256 _value
)
public
returns (bool)
{
require(_to != address(0));
require(_value <= balances[msg.sender]);
balances[msg.sender] = balances[msg.sender].sub(_value);
balances[_to] = balances[_to].add(_value);
emit Transfer(msg.sender, _to, _value);
return true;
}
function balanceOf(
address _owner
)
public
view
returns (uint256 balance)
{
return balances[_owner];
}
function transferFrom(
address _from,
address _to,
uint256 _value
)
public
returns (bool)
{
require(_to != address(0));
require(_value <= balances[_from]);
require(_value <= allowed[_from][msg.sender]);
balances[_from] = balances[_from].sub(_value);
balances[_to] = balances[_to].add(_value);
allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
emit Transfer(_from, _to, _value);
return true;
}
function approve(
address _spender,
uint256 _value
)
public
returns (bool)
{
allowed[msg.sender][_spender] = _value;
emit Approval(msg.sender, _spender, _value);
return true;
}
function allowance(
address _owner,
address _spender
)
public
view
returns (uint256)
{
return allowed[_owner][_spender];
}
function increaseApproval(
address _spender,
uint _addedValue
)
public
returns (bool)
{
allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
return true;
}
function decreaseApproval(
address _spender,
uint _subtractedValue
)
public
returns (bool)
{
uint oldValue = allowed[msg.sender][_spender];
if (_subtractedValue > oldValue) {
allowed[msg.sender][_spender] = 0;
} else {
allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
}
emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
return true;
}
function checkSymbolAndName(
string memory _symbol,
string memory _name
)
internal
pure
{
bytes memory s = bytes(_symbol);
require(s.length >= 3 && s.length <= 8);
for (uint i = 0; i < s.length; i++) {
require(
s[i] == 0x2E || (
s[i] == 0x5F) || (
s[i] >= 0x41 && s[i] <= 0x5A) || (
s[i] >= 0x61 && s[i] <= 0x7A)
);
}
bytes memory n = bytes(_name);
require(n.length >= s.length && n.length <= 128);
for (i = 0; i < n.length; i++) {
require(n[i] >= 0x20 && n[i] <= 0x7E);
}
}
}
contract TokenFactory {
event TokenCreated(
address indexed addr,
string  name,
string  symbol,
uint8   decimals,
uint    totalSupply,
address firstHolder
);
function createToken(
string  name,
string  symbol,
uint8   decimals,
uint    totalSupply
)
external
returns (address addr);
}
contract TokenFactoryImpl is TokenFactory {
using AddressUtil for address;
using StringUtil for string;
mapping(bytes10 => address) public tokens;
function ()
payable
public
{
revert();
}
function createToken(
string  name,
string  symbol,
uint8   decimals,
uint    totalSupply
)
external
returns (address addr)
{
require(symbol.checkStringLength(3, 10));
bytes10 symbolBytes = symbol.stringToBytes10();
require(tokens[symbolBytes] == 0x0);
ERC20Token token = new ERC20Token(
name,
symbol,
decimals,
totalSupply,
tx.origin
);
addr = address(token);
tokens[symbolBytes] = addr;
emit TokenCreated(
addr,
name,
symbol,
decimals,
totalSupply,
tx.origin
);
}
}