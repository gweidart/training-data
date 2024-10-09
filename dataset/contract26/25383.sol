pragma solidity ^0.4.13;
contract DSMath {
function add(uint x, uint y) internal pure returns (uint z) {
require((z = x + y) >= x);
}
function sub(uint x, uint y) internal pure returns (uint z) {
require((z = x - y) <= x);
}
function mul(uint x, uint y) internal pure returns (uint z) {
require(y == 0 || (z = x * y) / y == x);
}
function min(uint x, uint y) internal pure returns (uint z) {
return x <= y ? x : y;
}
function max(uint x, uint y) internal pure returns (uint z) {
return x >= y ? x : y;
}
function imin(int x, int y) internal pure returns (int z) {
return x <= y ? x : y;
}
function imax(int x, int y) internal pure returns (int z) {
return x >= y ? x : y;
}
uint constant WAD = 10 ** 18;
uint constant RAY = 10 ** 27;
function wmul(uint x, uint y) internal pure returns (uint z) {
z = add(mul(x, y), WAD / 2) / WAD;
}
function rmul(uint x, uint y) internal pure returns (uint z) {
z = add(mul(x, y), RAY / 2) / RAY;
}
function wdiv(uint x, uint y) internal pure returns (uint z) {
z = add(mul(x, WAD), y / 2) / y;
}
function rdiv(uint x, uint y) internal pure returns (uint z) {
z = add(mul(x, RAY), y / 2) / y;
}
function rpow(uint x, uint n) internal pure returns (uint z) {
z = n % 2 != 0 ? x : RAY;
for (n /= 2; n != 0; n /= 2) {
x = rmul(x, x);
if (n % 2 != 0) {
z = rmul(z, x);
}
}
}
}
interface AssetInterface {
event Transfer(address indexed _from, address indexed _to, uint _value);
event Approval(address indexed _owner, address indexed _spender, uint _value);
function transfer(address _to, uint _value, bytes _data) public returns (bool success);
function transfer(address _to, uint _value) public returns (bool success);
function transferFrom(address _from, address _to, uint _value) public returns (bool success);
function approve(address _spender, uint _value) public returns (bool success);
function balanceOf(address _owner) view public returns (uint balance);
function allowance(address _owner, address _spender) public view returns (uint remaining);
}
interface ERC223Interface {
function balanceOf(address who) constant returns (uint);
function transfer(address to, uint value) returns (bool);
function transfer(address to, uint value, bytes data) returns (bool);
event Transfer(address indexed from, address indexed to, uint value, bytes data);
}
contract Asset is DSMath, AssetInterface, ERC223Interface {
mapping (address => uint) balances;
mapping (address => mapping (address => uint)) allowed;
uint public totalSupply;
function transfer(address _to, uint _value)
public
returns (bool success)
{
uint codeLength;
bytes memory empty;
assembly {
codeLength := extcodesize(_to)
}
require(balances[msg.sender] >= _value);
require(balances[_to] + _value >= balances[_to]);
balances[msg.sender] = sub(balances[msg.sender], _value);
balances[_to] = add(balances[_to], _value);
Transfer(msg.sender, _to, _value, empty);
return true;
}
function transfer(address _to, uint _value, bytes _data)
public
returns (bool success)
{
uint codeLength;
assembly {
codeLength := extcodesize(_to)
}
require(balances[msg.sender] >= _value);
require(balances[_to] + _value >= balances[_to]);
balances[msg.sender] = sub(balances[msg.sender], _value);
balances[_to] = add(balances[_to], _value);
Transfer(msg.sender, _to, _value);
return true;
}
function transferFrom(address _from, address _to, uint _value)
public
returns (bool)
{
require(_from != 0x0);
require(_to != 0x0);
require(_to != address(this));
require(balances[_from] >= _value);
require(allowed[_from][msg.sender] >= _value);
require(balances[_to] + _value >= balances[_to]);
balances[_to] += _value;
balances[_from] -= _value;
allowed[_from][msg.sender] -= _value;
Transfer(_from, _to, _value);
return true;
}
function approve(address _spender, uint _value) public returns (bool) {
require(_spender != 0x0);
allowed[msg.sender][_spender] = _value;
Approval(msg.sender, _spender, _value);
return true;
}
function allowance(address _owner, address _spender)
constant
public
returns (uint)
{
return allowed[_owner][_spender];
}
function balanceOf(address _owner) constant public returns (uint) {
return balances[_owner];
}
}
interface ERC223ReceivingContract {
function tokenFallback(address _from, uint256 _value, bytes _data) public;
}
interface RiskMgmtInterface {
function isMakePermitted(
uint orderPrice,
uint referencePrice,
address sellAsset,
address buyAsset,
uint sellQuantity,
uint buyQuantity
) view returns (bool);
function isTakePermitted(
uint orderPrice,
uint referencePrice,
address sellAsset,
address buyAsset,
uint sellQuantity,
uint buyQuantity
) view returns (bool);
}
contract RMMakeOrders is DSMath, RiskMgmtInterface {
uint public constant RISK_LEVEL = 10 ** uint256(17);
function isMakePermitted(
uint orderPrice,
uint referencePrice,
address sellAsset,
address buyAsset,
uint sellQuantity,
uint buyQuantity
)
view
returns (bool)
{
if (orderPrice < sub(referencePrice, wmul(RISK_LEVEL, referencePrice))) {
return false;
}
return true;
}
function isTakePermitted(
uint orderPrice,
uint referencePrice,
address sellAsset,
address buyAsset,
uint sellQuantity,
uint buyQuantity
)
view
returns (bool)
{
if (orderPrice < sub(referencePrice, wmul(RISK_LEVEL, referencePrice))) {
return false;
}
return true;
}
}