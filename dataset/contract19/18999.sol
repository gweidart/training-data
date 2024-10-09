pragma solidity 0.4.21;
library TokenLib {
using BasicMathLib for uint256;
struct TokenStorage {
bool initialized;
mapping (address => uint256) balances;
mapping (address => mapping (address => uint256)) allowed;
string name;
string symbol;
uint256 totalSupply;
uint256 initialSupply;
address owner;
uint8 decimals;
bool stillMinting;
}
event Transfer(address indexed from, address indexed to, uint256 value);
event Approval(address indexed owner, address indexed spender, uint256 value);
event OwnerChange(address from, address to);
event Burn(address indexed burner, uint256 value);
event MintingClosed(bool mintingClosed);
function init(TokenStorage storage self,
address _owner,
string _name,
string _symbol,
uint8 _decimals,
uint256 _initial_supply,
bool _allowMinting)
public
{
require(!self.initialized);
self.initialized = true;
self.name = _name;
self.symbol = _symbol;
self.totalSupply = _initial_supply;
self.initialSupply = _initial_supply;
self.decimals = _decimals;
self.owner = _owner;
self.stillMinting = _allowMinting;
self.balances[_owner] = _initial_supply;
}
function transfer(TokenStorage storage self, address _to, uint256 _value) public returns (bool) {
require(_to != address(0));
bool err;
uint256 balance;
(err,balance) = self.balances[msg.sender].minus(_value);
require(!err);
self.balances[msg.sender] = balance;
self.balances[_to] = self.balances[_to] + _value;
emit Transfer(msg.sender, _to, _value);
return true;
}
function transferFrom(TokenStorage storage self,
address _from,
address _to,
uint256 _value)
public
returns (bool)
{
uint256 _allowance = self.allowed[_from][msg.sender];
bool err;
uint256 balanceOwner;
uint256 balanceSpender;
(err,balanceOwner) = self.balances[_from].minus(_value);
require(!err);
(err,balanceSpender) = _allowance.minus(_value);
require(!err);
self.balances[_from] = balanceOwner;
self.allowed[_from][msg.sender] = balanceSpender;
self.balances[_to] = self.balances[_to] + _value;
emit Transfer(_from, _to, _value);
return true;
}
function balanceOf(TokenStorage storage self, address _owner) public view returns (uint256 balance) {
return self.balances[_owner];
}
function approve(TokenStorage storage self, address _spender, uint256 _value) public returns (bool) {
require((_value == 0) || (self.allowed[msg.sender][_spender] == 0));
self.allowed[msg.sender][_spender] = _value;
emit Approval(msg.sender, _spender, _value);
return true;
}
function allowance(TokenStorage storage self, address _owner, address _spender)
public
view
returns (uint256 remaining) {
return self.allowed[_owner][_spender];
}
function approveChange (TokenStorage storage self, address _spender, uint256 _valueChange, bool _increase)
public returns (bool)
{
uint256 _newAllowed;
bool err;
if(_increase) {
(err, _newAllowed) = self.allowed[msg.sender][_spender].plus(_valueChange);
require(!err);
self.allowed[msg.sender][_spender] = _newAllowed;
} else {
if (_valueChange > self.allowed[msg.sender][_spender]) {
self.allowed[msg.sender][_spender] = 0;
} else {
_newAllowed = self.allowed[msg.sender][_spender] - _valueChange;
self.allowed[msg.sender][_spender] = _newAllowed;
}
}
emit Approval(msg.sender, _spender, _newAllowed);
return true;
}
function changeOwner(TokenStorage storage self, address _newOwner) public returns (bool) {
require((self.owner == msg.sender) && (_newOwner > 0));
self.owner = _newOwner;
emit OwnerChange(msg.sender, _newOwner);
return true;
}
function mintToken(TokenStorage storage self, uint256 _amount) public returns (bool) {
require((self.owner == msg.sender) && self.stillMinting);
uint256 _newAmount;
bool err;
(err, _newAmount) = self.totalSupply.plus(_amount);
require(!err);
self.totalSupply =  _newAmount;
self.balances[self.owner] = self.balances[self.owner] + _amount;
emit Transfer(0x0, self.owner, _amount);
return true;
}
function closeMint(TokenStorage storage self) public returns (bool) {
require(self.owner == msg.sender);
self.stillMinting = false;
emit MintingClosed(true);
return true;
}
function burnToken(TokenStorage storage self, uint256 _amount) public returns (bool) {
uint256 _newBalance;
bool err;
(err, _newBalance) = self.balances[msg.sender].minus(_amount);
require(!err);
self.balances[msg.sender] = _newBalance;
self.totalSupply = self.totalSupply - _amount;
emit Burn(msg.sender, _amount);
emit Transfer(msg.sender, 0x0, _amount);
return true;
}
}
library BasicMathLib {
function times(uint256 a, uint256 b) public pure returns (bool err,uint256 res) {
assembly{
res := mul(a,b)
switch or(iszero(b), eq(div(res,b), a))
case 0 {
err := 1
res := 0
}
}
}
function dividedBy(uint256 a, uint256 b) public pure returns (bool err,uint256 i) {
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
function plus(uint256 a, uint256 b) public pure returns (bool err, uint256 res) {
assembly{
res := add(a,b)
switch and(eq(sub(res,b), a), or(gt(res,b),eq(res,b)))
case 0 {
err := 1
res := 0
}
}
}
function minus(uint256 a, uint256 b) public pure returns (bool err,uint256 res) {
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