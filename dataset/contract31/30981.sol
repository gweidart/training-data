pragma solidity ^0.4.19;
contract ERC20i {
uint256 public totalSupply;
function balanceOf(address who) constant returns (uint256);
function transfer(address to, uint256 value) returns (bool);
event Transfer(address indexed from, address indexed to, uint256 value);
}
contract ERC20 is ERC20i {
function allowance(address owner, address spender) constant returns (uint256);
function transferFrom(address from, address to, uint256 value) returns (bool);
function approve(address spender, uint256 value) returns (bool);
event Approval(address indexed owner, address indexed spender, uint256 value);
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
contract SuperToken is ERC20i {
address EthDev = 0xde0B295669a9FD93d5F28D9Ec85E40f4cb697BAe;
using SafeMath for uint256;
mapping(address => uint256) balances;
modifier onlyPayloadSize(uint size) {
if(msg.data.length < size + 4) {
throw;
}
_;
}
function transfer(address _to, uint256 _value) onlyPayloadSize(2 * 32) returns (bool) {
balances[msg.sender] = balances[msg.sender].sub(_value);
balances[_to] = balances[_to].add(_value);
Transfer(msg.sender, _to, _value);
return true;
}
function balanceOf(address _owner) constant returns (uint256 balance) {
return balances[_owner];
}
}
contract StandardToken is ERC20, SuperToken {
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
contract Ownable {
address public owner;
function Ownable() {
owner = msg.sender;
}
modifier onlyOwner() {
require(msg.sender == owner);
_;
}
function transferOwnership(address newOwner) onlyOwner {
require(newOwner != address(0));
owner = newOwner;
}
}
contract TaurToken is StandardToken, Ownable {
string public Supply = '20 Million Taur Tokens';
string public constant name = "Taur Token";
string public constant symbol = "TAR";
uint public constant decimals = 3;
string public price = '0.8 USD';
uint256 initialSupply;
function TaurToken () {
totalSupply = 20000000 * 10 ** decimals;
balances[owner] = totalSupply;
initialSupply = totalSupply;
Transfer(EthDev, this, totalSupply);
Transfer(this, owner, totalSupply);
}
function changePrice (string newPrice) {
if (msg.sender == owner) price = newPrice;
}
}
contract selfBurn is TaurToken {
function burnAll() public onlyOwner  {
selfdestruct(owner);
}
}