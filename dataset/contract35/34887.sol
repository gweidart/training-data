pragma solidity ^0.4.13;
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
contract MintableToken is StandardToken, Ownable {
event Mint(address indexed to, uint256 amount);
event MintFinished();
bool public mintingFinished = false;
modifier canMint() {
require(!mintingFinished);
_;
}
function mint(address _to, uint256 _amount) onlyOwner canMint returns (bool) {
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
contract SimpleTokenCoin is MintableToken {
string public constant name = "Just another Test token for AMICO 2.0";
string public constant symbol = "AMICOTEST20";
uint32 public constant decimals = 18;
}
contract Crowdsale is Ownable {
address owner;
enum State {
init,
pre_ico_w1,
pre_ico_w2,
pre_ico_w3,
pre_ico_w4,
ico,
paused,
finished
}
State public currentState = State.paused;
uint constant PRE_ICO_BONUS_W1 = 40;
uint constant RPE_ICO_BONUS_W2 = 30;
uint constant RPE_ICO_BONUS_W3 = 20;
uint constant RPE_ICO_BONUS_W4 = 10;
uint constant PRE_ICO_DEFAULT_BONUS = 10;
uint constant PRICE = 1000;
SimpleTokenCoin public token = new SimpleTokenCoin();
function Crowdsale() {
owner = msg.sender;
}
function setIcoState(State _newState) onlyOwner {
currentState = _newState;
}
function() external payable {
assert(msg.sender != 0x0);
require(msg.value > 0);
require(currentState <= State.ico);
uint bonus = PRE_ICO_DEFAULT_BONUS;
if(currentState == State.pre_ico_w1) {
bonus = PRE_ICO_BONUS_W1;
}
if(currentState == State.pre_ico_w2) {
bonus = RPE_ICO_BONUS_W2;
}
if(currentState == State.pre_ico_w3) {
bonus = RPE_ICO_BONUS_W3;
}
if(currentState == State.pre_ico_w4) {
bonus = RPE_ICO_BONUS_W4;
}
uint tokensRevard = msg.value * PRICE + msg.value * PRICE * bonus / 100;
owner.transfer(msg.value);
token.mint(msg.sender, tokensRevard);
}
}