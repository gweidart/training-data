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
contract ERC20Interface {
function totalSupply() public constant returns (uint);
function balanceOf(address tokenOwner) public constant returns (uint balance);
function allowance(address tokenOwner, address spender) public constant returns (uint remaining);
function transfer(address to, uint tokens) public returns (bool success);
function approve(address spender, uint tokens) public returns (bool success);
function transferFrom(address from, address to, uint tokens) public returns (bool success);
event Transfer(address indexed from, address indexed to, uint tokens);
event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}
contract Asset is DSMath, ERC20Interface {
mapping (address => uint) balances;
mapping (address => mapping (address => uint)) allowed;
uint public _totalSupply;
function transfer(address _to, uint _value)
public
returns (bool success)
{
require(balances[msg.sender] >= _value);
require(balances[_to] + _value >= balances[_to]);
balances[msg.sender] = sub(balances[msg.sender], _value);
balances[_to] = add(balances[_to], _value);
emit Transfer(msg.sender, _to, _value);
return true;
}
function transferFrom(address _from, address _to, uint _value)
public
returns (bool)
{
require(_from != address(0));
require(_to != address(0));
require(_to != address(this));
require(balances[_from] >= _value);
require(allowed[_from][msg.sender] >= _value);
require(balances[_to] + _value >= balances[_to]);
balances[_to] += _value;
balances[_from] -= _value;
allowed[_from][msg.sender] -= _value;
emit Transfer(_from, _to, _value);
return true;
}
function approve(address _spender, uint _value) public returns (bool) {
require(_spender != address(0));
allowed[msg.sender][_spender] = _value;
emit Approval(msg.sender, _spender, _value);
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
function totalSupply() view public returns (uint) {
return _totalSupply;
}
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