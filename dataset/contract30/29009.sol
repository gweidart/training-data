pragma solidity ^0.4.16;
library SafeMath {
function mul(uint a, uint b) internal returns (uint) {
uint c = a * b;
assert(a == 0 || c / a == b);
return c;
}
function div(uint a, uint b) internal returns (uint) {
uint c = a / b;
return c;
}
function sub(uint a, uint b) internal returns (uint) {
assert(b <= a);
return a - b;
}
function add(uint a, uint b) internal returns (uint) {
uint c = a + b;
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
contract ERC20Basic {
uint public totalSupply;
function balanceOf(address who) constant returns (uint);
function transfer(address to, uint value);
event Transfer(address indexed from, address indexed to, uint value);
}
contract BasicToken is ERC20Basic {
using SafeMath for uint;
mapping(address => uint) balances;
modifier onlyPayloadSize(uint size) {
if(msg.data.length < size + 4) {
throw;
}
_;
}
function transfer(address _to, uint _value) onlyPayloadSize(2 * 32) {
balances[msg.sender] = balances[msg.sender].sub(_value);
balances[_to] = balances[_to].add(_value);
Transfer(msg.sender, _to, _value);
}
function balanceOf(address _owner) constant returns (uint balance) {
return balances[_owner];
}
}
contract ERC20 is ERC20Basic {
function allowance(address owner, address spender) constant returns (uint);
function transferFrom(address from, address to, uint value);
function approve(address spender, uint value);
event Approval(address indexed owner, address indexed spender, uint value);
}
contract StandardToken is BasicToken, ERC20 {
mapping (address => mapping (address => uint)) allowed;
mapping (address => uint256) public freezeOf;
event Burn(address indexed from, uint256 value);
event Freeze(address indexed from, uint256 value);
event Unfreeze(address indexed from, uint256 value);
function transferFrom(address _from, address _to, uint _value) onlyPayloadSize(3 * 32) {
var _allowance = allowed[_from][msg.sender];
if (_value > _allowance) throw;
balances[_to] = balances[_to].add(_value);
balances[_from] = balances[_from].sub(_value);
allowed[_from][msg.sender] = _allowance.sub(_value);
Transfer(_from, _to, _value);
}
function approve(address _spender, uint _value) {
if ((_value != 0) && (allowed[msg.sender][_spender] != 0)) throw;
allowed[msg.sender][_spender] = _value;
Approval(msg.sender, _spender, _value);
}
function allowance(address _owner, address _spender) constant returns (uint remaining) {
return allowed[_owner][_spender];
}
function burn(uint256 _value) returns (bool success) {
if (balances[msg.sender] < _value) throw;
if (_value <= 0) throw;
balances[msg.sender] = balances[msg.sender].sub(_value);
totalSupply = totalSupply.sub(_value);
Burn(msg.sender, _value);
return true;
}
function freeze(uint256 _value) returns (bool success) {
if (balances[msg.sender] < _value) throw;
if (_value <= 0) throw;
balances[msg.sender] = balances[msg.sender].sub(_value);
freezeOf[msg.sender] = freezeOf[msg.sender].add(_value);
Freeze(msg.sender, _value);
return true;
}
function unfreeze(uint256 _value) returns (bool success) {
if (freezeOf[msg.sender] < _value) throw;
if (_value <= 0) throw;
freezeOf[msg.sender] = freezeOf[msg.sender].sub(_value);
balances[msg.sender] = balances[msg.sender].add(_value);
Unfreeze(msg.sender, _value);
return true;
}
}
contract Ownable {
address public owner;
function Ownable() {
owner = msg.sender;
}
modifier onlyOwner() {
if (msg.sender != owner) {
throw;
}
_;
}
function transferOwnership(address newOwner) onlyOwner {
if (newOwner != address(0)) {
owner = newOwner;
}
}
function withdrawEther(uint256 amount) onlyOwner{
owner.transfer(amount);
}
}
contract MintableToken is StandardToken, Ownable {
event Mint(address indexed to, uint value);
event MintFinished();
bool public mintingFinished = false;
modifier canMint() {
if(mintingFinished) throw;
_;
}
function mint(address _to, uint _amount) onlyOwner canMint returns (bool) {
totalSupply = totalSupply.add(_amount);
balances[_to] = balances[_to].add(_amount);
Mint(_to, _amount);
return true;
}
function finishMinting() onlyOwner returns (bool) {
mintingFinished = true;
MintFinished();
return true;
}
}
contract ETHONOM is StandardToken, MintableToken {
using SafeMath for uint256;
string public name;
uint8 public decimals;
string public symbol;
string public version = 'H1.0';
function ETHONOM() {
balances[msg.sender] = 50000000000000000000000000;
totalSupply = 50000000000000000000000000;
name = "ETHONOM";
decimals = 18;
symbol = "ETHO";
}
function() payable{
}
}