pragma solidity ^0.4.8;
contract SafeContract {
function safeMul(uint256 a, uint256 b) internal returns (uint256) {
uint256 c = a * b;
assert(a == 0 || c / a == b);
return c;
}
function safeDiv(uint256 a, uint256 b) internal returns (uint256) {
assert(b > 0);
uint256 c = a / b;
assert(a == b * c + a % b);
return c;
}
function safeSub(uint256 a, uint256 b) internal returns (uint256) {
assert(b <= a);
return a - b;
}
function safeAdd(uint256 a, uint256 b) internal returns (uint256) {
uint256 c = a + b;
assert(c>=a && c>=b);
return c;
}
function assert(bool assertion) internal {
if (!assertion) {
throw;
}
}
}
contract ATC is SafeContract{
string public name;
string public symbol;
uint8 public decimals;
uint256 public totalSupply;
address public owner;
mapping (address => uint256) public balanceOf;
mapping (address => uint256) public freezeOf;
mapping (address => mapping (address => uint256)) public allowance;
event Transfer(address indexed from, address indexed to, uint256 value);
event Burn(address indexed from, uint256 value);
event Freeze(address indexed from, uint256 value);
event Unfreeze(address indexed from, uint256 value);
function ATC(
uint256 initialSupply,
string tokenName,
uint8 decimalUnits,
string tokenSymbol
) {
balanceOf[msg.sender] = initialSupply;
totalSupply = initialSupply;
name = tokenName;
symbol = tokenSymbol;
decimals = decimalUnits;
owner = msg.sender;
}
function transfer(address _to, uint256 _value) {
if (_to == 0x0) throw;
if (_value <= 0) throw;
if (balanceOf[msg.sender] < _value) throw;
if (balanceOf[_to] + _value < balanceOf[_to]) throw;
balanceOf[msg.sender] = SafeContract.safeSub(balanceOf[msg.sender], _value);
balanceOf[_to] = SafeContract.safeAdd(balanceOf[_to], _value);
Transfer(msg.sender, _to, _value);
}
function approve(address _spender, uint256 _value)
returns (bool success) {
if (_value <= 0) throw;
allowance[msg.sender][_spender] = _value;
return true;
}
function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
if (_to == 0x0) throw;
if (_value <= 0) throw;
if (balanceOf[_from] < _value) throw;
if (balanceOf[_to] + _value < balanceOf[_to]) throw;
if (_value > allowance[_from][msg.sender]) throw;
balanceOf[_from] = SafeContract.safeSub(balanceOf[_from], _value);
balanceOf[_to] = SafeContract.safeAdd(balanceOf[_to], _value);
allowance[_from][msg.sender] = SafeContract.safeSub(allowance[_from][msg.sender], _value);
Transfer(_from, _to, _value);
return true;
}
function freeze(uint256 _value) returns (bool success) {
if (balanceOf[msg.sender] < _value) throw;
if (_value <= 0) throw;
balanceOf[msg.sender] = SafeContract.safeSub(balanceOf[msg.sender], _value);
freezeOf[msg.sender] = SafeContract.safeAdd(freezeOf[msg.sender], _value);
Freeze(msg.sender, _value);
return true;
}
function unfreeze(uint256 _value) returns (bool success) {
if (freezeOf[msg.sender] < _value) throw;
if (_value <= 0) throw;
freezeOf[msg.sender] = SafeContract.safeSub(freezeOf[msg.sender], _value);
balanceOf[msg.sender] = SafeContract.safeAdd(balanceOf[msg.sender], _value);
Unfreeze(msg.sender, _value);
return true;
}
function burn(uint256 _value) returns (bool success) {
if (balanceOf[msg.sender] < _value) throw;
if (_value <= 0) throw;
balanceOf[msg.sender] = SafeContract.safeSub(balanceOf[msg.sender], _value);
totalSupply = SafeContract.safeSub(totalSupply,_value);
Burn(msg.sender, _value);
return true;
}
function withdrawEther(uint256 amount) {
if(msg.sender != owner)throw;
owner.transfer(amount);
}
}