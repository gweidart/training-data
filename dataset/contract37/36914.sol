pragma solidity ^0.4.11;
contract SafeMath {
function safeMul(uint256 a, uint256 b) internal returns (uint256 ) {
uint256 c = a * b;
assert(a == 0 || c / a == b);
return c;
}
function safeDiv(uint256 a, uint256 b) internal returns (uint256 ) {
assert(b > 0);
uint256 c = a / b;
assert(a == b * c + a % b);
return c;
}
function safeSub(uint256 a, uint256 b) internal returns (uint256 ) {
assert(b <= a);
return a - b;
}
function safeAdd(uint256 a, uint256 b) internal returns (uint256 ) {
uint256 c = a + b;
assert(c >= a);
return c;
}
function max64(uint64 a, uint64 b) internal constant returns (uint64) {
return a >= b ? a : b;
}
function min64(uint64 a, uint64 b) internal constant returns (uint64) {
return a < b ? a : b;
}
function max256(uint256 a, uint256 b) internal constant returns (uint256) {
return a >= b ? a : b;
}
function min256(uint256 a, uint256 b) internal constant returns (uint256) {
return a < b ? a : b;
}
function assert(bool assertion) internal {
if (!assertion) {
throw;
}
}
}
contract ERC20 {
uint256 public totalSupply;
function balanceOf(address _owner) constant returns (uint256 balance);
function transfer(address _to, uint256 _value) returns (bool success);
function transferFrom(address _from, address _to, uint256 _value) returns (bool success);
function approve(address _spender, uint256 _value) returns (bool success);
function allowance(address _owner, address _spender) constant returns (uint256 remaining);
event Transfer(address indexed _from, address indexed _to, uint256 _value);
event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}
contract StandardToken is ERC20, SafeMath {
mapping(address => uint256) balances;
mapping(address => mapping(address => uint256)) allowed;
function balanceOf(address _owner) constant returns (uint256 balance) {
return balances[_owner];
}
function transfer(address _to, uint256 _value) returns (bool) {
if (balances[msg.sender] >= _value && _value > 0) {
balances[msg.sender] = safeSub(balances[msg.sender], _value);
balances[_to] = safeAdd(balances[_to], _value);
Transfer(msg.sender, _to, _value);
return true;
} else return false;
}
function transferFrom(address _from, address _to, uint256 _value) returns (bool) {
if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0) {
balances[_to] = safeAdd(balances[_to], _value);
balances[_from] = safeSub(balances[_from], _value);
allowed[_from][msg.sender] = safeSub(allowed[_from][msg.sender], _value);
Transfer(_from, _to, _value);
return true;
} else return false;
}
function approve(address _spender, uint256 _value) returns (bool) {
allowed[msg.sender][_spender] = _value;
Approval(msg.sender, _spender, _value);
return true;
}
function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
return allowed[_owner][_spender];
}
}
contract MultiOwnable {
mapping (address => bool) ownerMap;
address[] public owners;
event OwnerAdded(address indexed newOwner);
event OwnerRemoved(address indexed oldOwner);
modifier onlyOwner() {
if (!isOwner(msg.sender)) throw;
_;
}
function MultiOwnable() {
address owner = msg.sender;
ownerMap[owner] = true;
owners.push(owner);
}
function isOwner(address owner) constant returns (bool) {
return ownerMap[owner];
}
function addOwner(address owner) onlyOwner returns (bool) {
if (!isOwner(owner) && owner != 0) {
ownerMap[owner] = true;
owners.push(owner);
OwnerAdded(owner);
return true;
} else return false;
}
function removeOwner(address owner) onlyOwner returns (bool) {
if (isOwner(owner)) {
ownerMap[owner] = false;
for (uint i = 0; i < owners.length - 1; i++) {
if (owners[i] == owner) {
owners[i] = owners[owners.length - 1];
break;
}
}
owners.length -= 1;
OwnerRemoved(owner);
return true;
} else return false;
}
}
contract TokenSpender {
function receiveApproval(address _from, uint256 _value);
}
contract BsToken is StandardToken, MultiOwnable {
bool public locked;
string public name;
string public symbol;
uint256 public totalSupply;
uint8 public decimals = 18;
string public version = 'v0.1';
address public creator;
address public seller;
uint256 public tokensSold;
uint256 public totalSales;
event Sell(address indexed seller, address indexed buyer, uint256 value);
event SellerChanged(address indexed oldSeller, address indexed newSeller);
modifier onlyUnlocked() {
if (!isOwner(msg.sender) && locked) throw;
_;
}
function BsToken(string _name, string _symbol, uint256 _totalSupply, address _seller) MultiOwnable() {
locked = true;
creator = msg.sender;
seller = _seller;
name = _name;
symbol = _symbol;
totalSupply = _totalSupply;
balances[seller] = totalSupply;
}
function changeSeller(address newSeller) onlyOwner returns (bool) {
if (newSeller == 0x0 || seller == newSeller) throw;
address oldSeller = seller;
uint256 unsoldTokens = balances[oldSeller];
balances[oldSeller] = 0;
balances[newSeller] = safeAdd(balances[newSeller], unsoldTokens);
seller = newSeller;
SellerChanged(oldSeller, newSeller);
return true;
}
function sell(address _to, uint256 _value) onlyOwner returns (bool) {
if (balances[seller] >= _value && _value > 0) {
balances[seller] = safeSub(balances[seller], _value);
balances[_to] = safeAdd(balances[_to], _value);
tokensSold = safeAdd(tokensSold, _value);
totalSales = safeAdd(totalSales, 1);
Sell(seller, _to, _value);
Transfer(seller, _to, _value);
return true;
} else return false;
}
function transfer(address _to, uint256 _value) onlyUnlocked returns (bool) {
return super.transfer(_to, _value);
}
function transferFrom(address _from, address _to, uint256 _value) onlyUnlocked returns (bool) {
return super.transferFrom(_from, _to, _value);
}
function lock() onlyOwner {
locked = true;
}
function unlock() onlyOwner {
locked = false;
}
function burn(uint256 _value) returns (bool) {
if (balances[msg.sender] >= _value && _value > 0) {
balances[msg.sender] = safeSub(balances[msg.sender], _value) ;
totalSupply = safeSub(totalSupply, _value);
Transfer(msg.sender, 0x0, _value);
return true;
} else return false;
}
function approveAndCall(address _spender, uint256 _value) {
TokenSpender spender = TokenSpender(_spender);
if (approve(_spender, _value)) {
spender.receiveApproval(msg.sender, _value);
}
}
}
contract BsToken_STN is BsToken {
function BsToken_STN()
BsToken(
'SToken',
'STN',
20000000,
0xbEC7599FA247E3ABb423A76e74a7D4E575F559c3
) { }
}