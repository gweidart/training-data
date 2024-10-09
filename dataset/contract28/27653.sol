pragma solidity ^0.4.18;
library SafeMath {
function mul(uint256 a, uint256 b) internal pure returns (uint256) {
uint256 c = a * b;
assert(a == 0 || c / a == b);
return c;
}
function div(uint256 a, uint256 b) internal pure returns (uint256) {
uint256 c = a / b;
return c;
}
function sub(uint256 a, uint256 b) internal pure returns (uint256) {
assert(b <= a);
return a - b;
}
function add(uint256 a, uint256 b) internal pure returns (uint256) {
uint256 c = a + b;
assert(c >= a);
return c;
}
}
interface TokenUpgraderInterface{
function upgradeFor(address _for, uint256 _value) public returns (bool success);
function upgradeFrom(address _by, address _for, uint256 _value) public returns (bool success);
}
contract Token {
using SafeMath for uint256;
address public owner = msg.sender;
string public name = "Trago Project Token";
string public symbol = "TGO";
bool public upgradable = false;
bool public upgraderSet = false;
TokenUpgraderInterface public upgrader;
bool public locked = false;
uint8 public decimals = 18;
uint256 public decimalMultiplier = 10**(uint256(decimals));
modifier unlocked() {
require(!locked);
_;
}
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
modifier onlyOwner() {
require(msg.sender == owner);
_;
}
function transferOwnership(address newOwner) public onlyOwner returns (bool success) {
require(newOwner != address(0));
OwnershipTransferred(owner, newOwner);
owner = newOwner;
return true;
}
uint256 public totalSupply = 0;
mapping(address => uint256) balances;
mapping(address => mapping (address => uint256)) allowed;
event Transfer(address indexed _from, address indexed _to, uint256 _value);
event Approval(address indexed _owner, address indexed _spender, uint256 _value);
function transfer(address _to, uint256 _value) unlocked public returns (bool) {
require(_to != address(0));
balances[msg.sender] = balances[msg.sender].sub(_value);
balances[_to] = balances[_to].add(_value);
Transfer(msg.sender, _to, _value);
return true;
}
function balanceOf(address _owner) view public returns (uint256 bal) {
return balances[_owner];
}
function transferFrom(address _from, address _to, uint256 _value) unlocked public returns (bool) {
require(_to != address(0));
uint256 _allowance = allowed[_from][msg.sender];
require(_allowance >= _value);
balances[_from] = balances[_from].sub(_value);
balances[_to] = balances[_to].add(_value);
allowed[_from][msg.sender] = _allowance.sub(_value);
Transfer(_from, _to, _value);
return true;
}
function approve(address _spender, uint256 _value) unlocked public returns (bool) {
require((_value == 0) || (allowed[msg.sender][_spender] == 0));
allowed[msg.sender][_spender] = _value;
Approval(msg.sender, _spender, _value);
return true;
}
function allowance(address _owner, address _spender) view public returns (uint256 remaining) {
return allowed[_owner][_spender];
}
function increaseApproval (address _spender, uint _addedValue) unlocked public
returns (bool success) {
allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
return true;
}
function decreaseApproval (address _spender, uint _subtractedValue) unlocked public
returns (bool success) {
uint oldValue = allowed[msg.sender][_spender];
if (_subtractedValue > oldValue) {
allowed[msg.sender][_spender] = 0;
} else {
allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
}
Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
return true;
}
function Token () public {
uint256 supply = 210*100000000;
address tokenExchangeReserveAddress = 0x285f0C1668AEf68756543DF1449DA86F8aD588c8;
mint(tokenExchangeReserveAddress, supply*35/100);
address teamReserveAddress = 0x18Cb5a595239Ca923169516373c7B24010b13c32;
mint(teamReserveAddress, supply*12/100);
address marketingReserveAddress = 0x57eCBa7d605C645Ee5006132B5FF1DB5e95BB056;
mint(marketingReserveAddress, supply*10/100);
address foundationReserveAddress = 0x3095Ff610e6f56bF35cF6cA0246d94135708CD6E;
mint(foundationReserveAddress, supply*33/100);
address PoCRewordsReserveAddress = 0xFD262223E18391981Bf047378c5AE5c25C11a672;
mint(PoCRewordsReserveAddress, supply*10/100);
assert(totalSupply == supply*decimalMultiplier);
}
function mint(address _for, uint256 _amount) internal returns (bool success) {
_amount = _amount*decimalMultiplier;
balances[_for] = balances[_for].add(_amount);
totalSupply = totalSupply.add(_amount);
Transfer(0, _for, _amount);
return true;
}
function setLock(bool _newLockState) onlyOwner public returns (bool success) {
require(_newLockState != locked);
locked = _newLockState;
return true;
}
function allowUpgrading(bool _newState) onlyOwner public returns (bool success) {
upgradable = _newState;
return true;
}
function setUpgrader(address _upgraderAddress) onlyOwner public returns (bool success) {
require(!upgraderSet);
require(_upgraderAddress != address(0));
upgraderSet = true;
upgrader = TokenUpgraderInterface(_upgraderAddress);
return true;
}
function upgrade() public returns (bool success) {
require(upgradable);
require(upgraderSet);
require(upgrader != TokenUpgraderInterface(0));
uint256 value = balances[msg.sender];
assert(value > 0);
delete balances[msg.sender];
totalSupply = totalSupply.sub(value);
assert(upgrader.upgradeFor(msg.sender, value));
return true;
}
function upgradeFor(address _for, uint256 _value) public returns (bool success) {
require(upgradable);
require(upgraderSet);
require(upgrader != TokenUpgraderInterface(0));
uint256 _allowance = allowed[_for][msg.sender];
require(_allowance >= _value);
balances[_for] = balances[_for].sub(_value);
allowed[_for][msg.sender] = _allowance.sub(_value);
totalSupply = totalSupply.sub(_value);
assert(upgrader.upgradeFrom(msg.sender, _for, _value));
return true;
}
function () payable external {
if (upgradable) {
assert(upgrade());
return;
}
revert();
}
}