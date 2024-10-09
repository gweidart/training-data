pragma solidity ^0.4.16;
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
contract BasicToken is ERC20Basic {
using SafeMath for uint256;
mapping(address => uint256) balances;
modifier onlyPayloadSize(uint size) {
require(msg.data.length >= size + 4);
_;
}
function transfer(address _to, uint256 _value) onlyPayloadSize(32*2) returns (bool) {
require(_to != address(0));
require(_value <= balances[msg.sender]);
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
require (_value <= _allowance);
require(_to != address(0));
require(_value <= balances[_from]);
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
address public candidate;
function Ownable() {
owner = msg.sender;
}
modifier onlyOwner() {
require(msg.sender == owner);
_;
}
function changeOwner(address _owner) onlyOwner {
candidate = _owner;
}
function confirmOwner() public {
require(candidate == msg.sender);
owner = candidate;
}
}
contract MintableToken is StandardToken, Ownable {
event Mint(address indexed to, uint256 amount);
event MintFinished();
bool public mintingFinished = false;
uint256 public lastTotalSupply = 0;
address public saleAgent = 0;
modifier canMint() {
require(!mintingFinished);
_;
}
function setSaleAgent(address newSaleAgent) public {
require(msg.sender == saleAgent || msg.sender == owner);
saleAgent = newSaleAgent;
}
function mint(address _to, uint256 _amount) canMint returns (bool) {
require(msg.sender == saleAgent);
totalSupply = totalSupply.add(_amount);
balances[_to] = balances[_to].add(_amount);
Mint(_to, _amount);
Transfer(address(0), _to, _amount);
return true;
}
function finishMinting() returns (bool) {
require((msg.sender == saleAgent) || (msg.sender == owner));
lastTotalSupply = totalSupply;
mintingFinished = true;
MintFinished();
return mintingFinished;
}
function startMinting()  returns (bool) {
require((msg.sender == saleAgent) || (msg.sender == owner));
mintingFinished = false;
return mintingFinished;
}
}
contract BetOnCryptToken is MintableToken {
string public constant name = "BetOnCrypt_Token";
string public constant symbol = "BEC";
uint32 public constant decimals = 18;
}