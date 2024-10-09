pragma solidity ^0.4.24;
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
contract Ownable {
address public owner;
event OwnershipRenounced(address indexed previousOwner);
event OwnershipTransferred(
address indexed previousOwner,
address indexed newOwner
);
constructor() public {
owner = msg.sender;
}
modifier onlyOwner() {
require(msg.sender == owner);
_;
}
function transferOwnership(address _newOwner) public onlyOwner {
_transferOwnership(_newOwner);
}
function _transferOwnership(address _newOwner) internal {
require(_newOwner != address(0));
emit OwnershipTransferred(owner, _newOwner);
owner = _newOwner;
}
}
contract ERC20Basic {
function totalSupply() public view returns (uint256);
function balanceOf(address who) public view returns (uint256);
function transfer(address to, uint256 value) public returns (bool);
event Transfer(address indexed from, address indexed to, uint256 value);
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
uint256 _addedValue
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
uint256 _subtractedValue
)
public
returns (bool)
{
uint256 oldValue = allowed[msg.sender][_spender];
if (_subtractedValue > oldValue) {
allowed[msg.sender][_spender] = 0;
} else {
allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
}
emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
return true;
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
contract YINCToken is StandardToken, BurnableToken, Ownable {
using SafeMath for uint256;
string public constant name = "YINC Token";
string public constant symbol = "YINC";
string public constant standard = "ERC20";
uint256 public constant decimals = 18;
bool public released = false;
event Release();
address public tokensWallet;
mapping(address => uint) public lockedAddresses;
modifier isReleased () {
require(released || msg.sender == tokensWallet || msg.sender == owner);
require(lockedAddresses[msg.sender] <= now);
_;
}
constructor() public {
owner = 0x643040c46bD5b758525065eFBca5cABF7aeF691a;
tokensWallet = 0x431636DA20bf63CE46091C08922ecD285c3215Ae;
totalSupply_ = 1000000000 * (10 ** decimals);
balances[tokensWallet] = totalSupply_;
emit Transfer(0x0, tokensWallet, totalSupply_);
}
function lockAddress(address _lockedAddress, uint256 _time) public onlyOwner returns (bool) {
require(balances[_lockedAddress] == 0 && lockedAddresses[_lockedAddress] == 0 && _time > now);
lockedAddresses[_lockedAddress] = _time;
return true;
}
function release() onlyOwner public returns (bool) {
require(!released);
released = true;
emit Release();
return true;
}
function getOwner() public view returns (address) {
return owner;
}
function transfer(address _to, uint256 _value) public isReleased returns (bool) {
return super.transfer(_to, _value);
}
function transferFrom(address _from, address _to, uint256 _value) public isReleased returns (bool) {
return super.transferFrom(_from, _to, _value);
}
function approve(address _spender, uint256 _value) public isReleased returns (bool) {
return super.approve(_spender, _value);
}
function increaseApproval(address _spender, uint _addedValue) public isReleased returns (bool success) {
return super.increaseApproval(_spender, _addedValue);
}
function decreaseApproval(address _spender, uint _subtractedValue) public isReleased returns (bool success) {
return super.decreaseApproval(_spender, _subtractedValue);
}
function transferOwnership(address newOwner) public onlyOwner {
address oldOwner = owner;
super.transferOwnership(newOwner);
if (oldOwner != tokensWallet) {
allowed[tokensWallet][oldOwner] = 0;
emit Approval(tokensWallet, oldOwner, 0);
}
if (owner != tokensWallet) {
allowed[tokensWallet][owner] = balances[tokensWallet];
emit Approval(tokensWallet, owner, balances[tokensWallet]);
}
}
}