pragma solidity ^0.4.15;
contract ERC20Basic {
uint256 public totalSupply;
function balanceOf(address who) public constant returns (uint256);
function transfer(address to, uint256 value) public returns (bool);
event Transfer(address indexed from, address indexed to, uint256 value);
}
contract ERC20 is ERC20Basic {
function allowance(address owner, address spender) public constant returns (uint256);
function transferFrom(address from, address to, uint256 value) public returns (bool);
function approve(address spender, uint256 value) public returns (bool);
event Approval(address indexed owner, address indexed spender, uint256 value);
}
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
contract BasicToken is ERC20Basic {
using SafeMath for uint256;
mapping(address => uint256) balances;
function transfer(address _to, uint256 _value) public returns (bool) {
balances[msg.sender] = balances[msg.sender].sub(_value);
balances[_to] = balances[_to].add(_value);
Transfer(msg.sender, _to, _value);
return true;
}
function balanceOf(address _owner) public constant returns (uint256 balance) {
return balances[_owner];
}
}
contract StandardToken is ERC20, BasicToken {
mapping (address => mapping (address => uint256)) allowed;
function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
var _allowance = allowed[_from][msg.sender];
balances[_to] = balances[_to].add(_value);
balances[_from] = balances[_from].sub(_value);
allowed[_from][msg.sender] = _allowance.sub(_value);
Transfer(_from, _to, _value);
return true;
}
function approve(address _spender, uint256 _value) public returns (bool) {
require((_value == 0) || (allowed[msg.sender][_spender] == 0));
allowed[msg.sender][_spender] = _value;
Approval(msg.sender, _spender, _value);
return true;
}
function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
return allowed[_owner][_spender];
}
}
contract Ownable {
address public owner;
function Ownable() public {
owner = msg.sender;
}
modifier onlyOwner() {
require(msg.sender == owner);
_;
}
function transferOwnership(address newOwner) public onlyOwner {
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
function mint(address _to, uint256 _amount) public onlyOwner canMint returns (bool) {
totalSupply = totalSupply.add(_amount);
balances[_to] = balances[_to].add(_amount);
Mint(_to, _amount);
return true;
}
function finishMinting() public onlyOwner returns (bool) {
mintingFinished = true;
MintFinished();
return true;
}
}
contract Articoin is MintableToken {
string public constant name = "articoin";
string public constant symbol = "ARTN";
uint32 public constant decimals = 4;
}
contract Crowdsale is Ownable {
using SafeMath for uint;
address public multisig;
uint public restrictedPercent;
address public restricted;
Articoin public token = new Articoin();
uint public start;
uint public period;
uint public hardcap;
uint public rate;
uint public softcap;
mapping(address => uint) public balances;
function Crowdsale() public {
multisig = 0x06B1De369c5A663C256ca70E78775F6a18f63f0a;
restricted = 0x06B1De369c5A663C256ca70E78775F6a18f63f0a;
restrictedPercent = 20;
rate = 1000000000000000000000;
start = 1530489600;
period = 60;
hardcap = 80000000000000000000000;
softcap = 100000000000000000000;
}
modifier saleIsOn() {
require(now > start && now < start + period * 1 days);
_;
}
modifier isUnderHardCap() {
require(multisig.balance <= hardcap);
_;
}
function refund() public {
require(this.balance < softcap && now > start + period * 1 days);
uint value = balances[msg.sender];
balances[msg.sender] = 0;
msg.sender.transfer(value);
}
function finishMinting() public onlyOwner {
if(this.balance > softcap) {
multisig.transfer(this.balance);
uint issuedTokenSupply = token.totalSupply();
uint restrictedTokens = issuedTokenSupply.mul(restrictedPercent).div(100 - restrictedPercent);
token.mint(restricted, restrictedTokens);
token.finishMinting();
}
}
function createTokens() public isUnderHardCap saleIsOn payable {
uint tokens = rate.mul(msg.value).div(1 ether);
uint bonusTokens = 0;
if(now < start + (period * 1 days).div(4)) {
bonusTokens = tokens.div(4);
} else if(now >= start + (period * 1 days).div(4) && now < start + (period * 1 days).div(4).mul(2)) {
bonusTokens = tokens.div(5);
} else if(now >= start + (period * 1 days).div(4).mul(2) && now < start + (period * 1 days).div(4).mul(3)) {
bonusTokens = tokens.div(10);
}
tokens += bonusTokens;
token.mint(msg.sender, tokens);
balances[msg.sender] = balances[msg.sender].add(msg.value);
}
function() external payable {
createTokens();
}
}