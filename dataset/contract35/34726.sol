pragma solidity ^0.4.11;
library SafeMath {
function sub(uint256 a, uint256 b) internal constant returns (uint256) {
assert(b <= a);
return a - b;
}
function add(uint256 a, uint256 b) internal constant returns (uint256) {
uint256 c = a + b;
assert(c >= a);
return c;
}
}
contract admined {
address public admin;
uint public lockThreshold;
address public allowedAddr;
function admined() internal {
admin = msg.sender;
Admined(admin);
}
modifier onlyAdmin() {
require(msg.sender == admin);
_;
}
modifier endOfLock() {
require(now > lockThreshold || msg.sender == allowedAddr);
_;
}
function transferAdminship(address _newAdmin) onlyAdmin public {
admin = _newAdmin;
TransferAdminship(admin);
}
function addAllowedToTransfer (address _allowedAddr) onlyAdmin public {
allowedAddr = _allowedAddr;
AddAllowedToTransfer (allowedAddr);
}
function setLock(uint _timeInMins) onlyAdmin public {
require(_timeInMins > 0);
uint mins = _timeInMins * 1 minutes;
lockThreshold = SafeMath.add(now,mins);
SetLock(lockThreshold);
}
event SetLock(uint timeInMins);
event AddAllowedToTransfer (address allowedAddress);
event TransferAdminship(address newAdminister);
event Admined(address administer);
}
contract Token is admined {
uint256 public totalSupply;
mapping (address => uint256) balances;
mapping (address => mapping (address => uint256)) allowed;
function balanceOf(address _owner) public constant returns (uint256 bal) {
return balances[_owner];
}
function transfer(address _to, uint256 _value) endOfLock public returns (bool success) {
require(balances[msg.sender] >= _value);
balances[msg.sender] = SafeMath.sub(balances[msg.sender], _value);
balances[_to] = SafeMath.add(balances[_to], _value);
Transfer(msg.sender, _to, _value);
return true;
}
function transferFrom(address _from, address _to, uint256 _value) endOfLock public returns (bool success) {
require(balances[_from] >= _value && allowed[_from][msg.sender] >= _value);
balances[_to] = SafeMath.add(balances[_to], _value);
balances[_from] = SafeMath.sub(balances[_from], _value);
allowed[_from][msg.sender] = SafeMath.sub(allowed[_from][msg.sender], _value);
Transfer(_from, _to, _value);
return true;
}
function approve(address _spender, uint256 _value) endOfLock public returns (bool success) {
allowed[msg.sender][_spender] = _value;
Approval(msg.sender, _spender, _value);
return true;
}
function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
return allowed[_owner][_spender];
}
function mintToken(address _target, uint256 _mintedAmount) onlyAdmin endOfLock public {
balances[_target] = SafeMath.add(balances[_target], _mintedAmount);
totalSupply = SafeMath.add(totalSupply, _mintedAmount);
Transfer(0, this, _mintedAmount);
Transfer(this, _target, _mintedAmount);
}
function burnToken(address _target, uint256 _burnedAmount) onlyAdmin endOfLock public {
balances[_target] = SafeMath.sub(balances[_target], _burnedAmount);
totalSupply = SafeMath.sub(totalSupply, _burnedAmount);
Burned(_target, _burnedAmount);
}
function batch(address[] data,uint256 amount) onlyAdmin public {
require(balances[this] >= data.length*amount);
for (uint i=0; i<data.length; i++) {
address target = data[i];
balances[target] = SafeMath.add(balances[target], amount);
balances[this] = SafeMath.sub(balances[this], amount);
allowed[this][msg.sender] = SafeMath.sub(allowed[this][msg.sender], amount);
Transfer(this, target, amount);
}
}
event Transfer(address indexed _from, address indexed _to, uint256 _value);
event Approval(address indexed _owner, address indexed _spender, uint256 _value);
event Burned(address indexed _target, uint256 _value);
}
contract Asset is admined, Token {
string public name;
uint8 public decimals = 18;
string public symbol;
string public version = '0.1';
uint256 initialAmount = 80000000000000000000000000;
function Asset(
string _tokenName,
string _tokenSymbol
) public {
balances[this] = 79920000000000000000000000;
balances[0xFAB6368b0F7be60c573a6562d82469B5ED9e7eE6] = 80000000000000000000000;
allowed[this][msg.sender] = 79920000000000000000000000;
totalSupply = initialAmount;
name = _tokenName;
symbol = _tokenSymbol;
Transfer(0, this, initialAmount);
Transfer(this, 0xFAB6368b0F7be60c573a6562d82469B5ED9e7eE6, 80000000000000000000000);
Approval(this, msg.sender, 79920000000000000000000000);
}
function() {
revert();
}
}