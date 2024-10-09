pragma solidity ^0.4.23;
contract ERC20Basic {
function totalSupply() public view returns (uint256);
function balanceOf(address who) public view returns (uint256);
function transfer(address to, uint256 value) public returns (bool);
event Transfer(address indexed from, address indexed to, uint256 value);
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
contract BasicToken is ERC20Basic {
using SafeMath for uint256;
mapping(address => uint256) balances;
uint256 totalSupply_;
function totalSupply() public view returns (uint256) {
return totalSupply_;
}
function transfer(address _to, uint256 _value) public returns (bool) {
require(_to != address(0));
require(_value <= balances[msg.sender]);
balances[msg.sender] = balances[msg.sender].sub(_value);
balances[_to] = balances[_to].add(_value);
emit Transfer(msg.sender, _to, _value);
return true;
}
function balanceOf(address _owner) public view returns (uint256) {
return balances[_owner];
}
}
contract BurnableToken is BasicToken {
event Burn(address indexed burner, uint256 value);
function burn(uint256 _value) public {
_burn(msg.sender, _value);
}
function _burn(address _who, uint256 _value) internal {
require(_value <= balances[_who]);
balances[_who] = balances[_who].sub(_value);
totalSupply_ = totalSupply_.sub(_value);
emit Burn(_who, _value);
emit Transfer(_who, address(0), _value);
}
}
contract ERC20 is ERC20Basic {
function allowance(address owner, address spender)
public view returns (uint256);
function transferFrom(address from, address to, uint256 value)
public returns (bool);
function approve(address spender, uint256 value) public returns (bool);
event Approval(
address indexed owner,
address indexed spender,
uint256 value
);
}
contract StandardToken is ERC20, BasicToken {
mapping (address => mapping (address => uint256)) internal allowed;
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
function approve(address _spender, uint256 _value) public returns (bool) {
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
allowed[msg.sender][_spender] = (
allowed[msg.sender][_spender].add(_addedValue));
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
}
contract StandardBurnableToken is BurnableToken, StandardToken {
function burnFrom(address _from, uint256 _value) public {
require(_value <= allowed[_from][msg.sender]);
allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
_burn(_from, _value);
}
}
contract SlyrideToken is StandardBurnableToken {
string public constant name = "SlyRide";
string public constant symbol = "SLYN";
uint8 public constant decimals = 18;
uint256 public constant INITIAL_SUPPLY = 800000000e18;
constructor() public {
totalSupply_ = INITIAL_SUPPLY;
balances[0xdC216125b75462e6A2607A706bc0a07aE74E4Aa6] = 8600000e18;
balances[0x6002A5fA2B7197723591F3f09e900C6D22C39ad7] = 6000000e18;
balances[0x9d71B8CAed3E5C2A17AE09248DDF6705CCC1c5D5] = 4000000e18;
balances[0xbE250634C07054E6a53a8b58f940941Bf8AD5BB0] = 56800000e18;
balances[0x19051c86C923704084Ab198c6C1611E925973d92] = 144000000e18;
balances[0x52E72f58978939F51d97245aB1dac9B846f1946f] = 520000000e18;
balances[0x436447A3b504de71B65582b57B9ed74877C7e4ba] = 8000000e18;
balances[0x4cBf77Ac0D0d5e19e25422DdC8f28916b8361e18] = 52600000e18;
emit Transfer(0x0, 0xdC216125b75462e6A2607A706bc0a07aE74E4Aa6, 8600000e18);
emit Transfer(0x0, 0x6002A5fA2B7197723591F3f09e900C6D22C39ad7, 6000000e18);
emit Transfer(0x0, 0x9d71B8CAed3E5C2A17AE09248DDF6705CCC1c5D5, 4000000e18);
emit Transfer(0x0, 0xbE250634C07054E6a53a8b58f940941Bf8AD5BB0, 56800000e18);
emit Transfer(0x0, 0x19051c86C923704084Ab198c6C1611E925973d92, 144000000e18);
emit Transfer(0x0, 0x52E72f58978939F51d97245aB1dac9B846f1946f, 520000000e18);
emit Transfer(0x0, 0x436447A3b504de71B65582b57B9ed74877C7e4ba, 8000000e18);
emit Transfer(0x0, 0x4cBf77Ac0D0d5e19e25422DdC8f28916b8361e18, 52600000e18);
}
}