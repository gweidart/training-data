pragma solidity ^0.4.15;
contract ERC20Basic {
uint256 public totalSupply;
function balanceOf(address who) constant returns (uint256);
function transfer(address to, uint256 value) returns (bool);
event Transfer(address indexed from, address indexed to, uint256 value);
}
contract ERC20 is ERC20Basic {
function allowance(address owner, address spender) constant returns (uint256);
function transferFrom(address from, address to, uint256 value) returns (bool);
function approve(address spender, uint256 value) returns (bool);
event Approval(address indexed owner, address indexed spender, uint256 value);
}
contract BasicToken is ERC20Basic {
using SafeMath for uint256;
mapping (address => uint256) balances;
function transfer(address _to, uint256 _value) returns (bool) {
balances[msg.sender] = balances[msg.sender].sub(_value);
balances[_to] = balances[_to].add(_value);
Transfer(msg.sender, _to, _value);
return true;
}
function balanceOf(address _owner) constant returns (uint256 balance) {
return balances[_owner];
}
}
contract StandardToken is ERC20, BasicToken {
mapping (address => mapping (address => uint256)) allowed;
function transferFrom(address _from, address _to, uint256 _value) returns (bool) {
var _allowance = allowed[_from][msg.sender];
balances[_to] = balances[_to].add(_value);
balances[_from] = balances[_from].sub(_value);
allowed[_from][msg.sender] = _allowance.sub(_value);
Transfer(_from, _to, _value);
return true;
}
function approve(address _spender, uint256 _value) returns (bool) {
require((_value == 0) || (allowed[msg.sender][_spender] == 0));
allowed[msg.sender][_spender] = _value;
Approval(msg.sender, _spender, _value);
return true;
}
function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
return allowed[_owner][_spender];
}
}
library SafeMath {
function mul(uint256 a, uint256 b) internal constant returns (uint256) {
uint256 c = a * b;
assert(a == 0 || c / a == b);
return c;
}
function div(uint256 a, uint256 b) internal constant returns (uint256) {
uint256 c = a / b;
return c;
}
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
contract Ownable {
mapping (address => bool) owners;
address god;
modifier onlyOwner() {
if (isOwner(msg.sender) || isGod(msg.sender)) _;
}
modifier onlyGod() {
if (isGod(msg.sender)) _;
}
function isOwner(address _owner) internal returns (bool) {
return owners[_owner];
}
function isGod(address _owner) internal returns (bool) {
return god == _owner;
}
function addOwner(address _owner) onlyGod external {
owners[_owner] = true;
}
function removeOwner(address _owner) onlyGod external {
delete owners[_owner];
}
function Ownable() {
god = msg.sender;
}
}
contract Mintable is Ownable, StandardToken {
event Mint(address indexed to, uint256 amount);
event Burn(address indexed from, uint256 value);
modifier noBurn(address _to) {
require(_to != 0x0);
_;
}
function mint(address _to, uint256 _amount) onlyOwner external returns (bool) {
totalSupply = totalSupply.add(_amount);
balances[_to] = balances[_to].add(_amount);
Mint(_to, _amount);
return true;
}
function burn(uint256 _value) returns (bool success) {
balances[msg.sender] = balances[msg.sender].sub(_value);
totalSupply = totalSupply.sub(_value);
Burn(msg.sender, _value);
return true;
}
}
contract BarToken is Mintable {
string public name = 'ICObazaar token';
string public symbol = 'BAR';
uint8 public decimals = 4;
function BarToken(uint256 _totalSupply) {
totalSupply = _totalSupply;
balances[msg.sender] = totalSupply;
}
function() payable {
revert();
}
}