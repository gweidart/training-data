pragma solidity ^0.4.17;
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
address public saleAgent;
function setSaleAgent(address newSaleAgnet) {
require(msg.sender == saleAgent || msg.sender == owner);
saleAgent = newSaleAgnet;
}
function mint(address _to, uint256 _amount) returns (bool) {
require(msg.sender == saleAgent && !mintingFinished);
totalSupply = totalSupply.add(_amount);
balances[_to] = balances[_to].add(_amount);
Mint(_to, _amount);
return true;
}
function finishMinting() returns (bool) {
require((msg.sender == saleAgent || msg.sender == owner) && !mintingFinished);
mintingFinished = true;
MintFinished();
return true;
}
}
contract Pausable is Ownable {
event Pause();
event Unpause();
bool public paused = false;
modifier whenNotPaused() {
require(!paused);
_;
}
modifier whenPaused() {
require(paused);
_;
}
function pause() onlyOwner whenNotPaused {
paused = true;
Pause();
}
function unpause() onlyOwner whenPaused {
paused = false;
Unpause();
}
}
contract CovestingToken is MintableToken {
string public constant name = "Covesting";
string public constant symbol = "COV";
uint32 public constant decimals = 18;
mapping (address => uint) public locked;
function transfer(address _to, uint256 _value) returns (bool) {
require(locked[msg.sender] < now);
return super.transfer(_to, _value);
}
function transferFrom(address _from, address _to, uint256 _value) returns (bool) {
require(locked[_from] < now);
return super.transferFrom(_from, _to, _value);
}
function lock(address addr, uint periodInDays) {
require(locked[addr] < now && (msg.sender == saleAgent || msg.sender == addr));
locked[addr] = now + periodInDays * 1 days;
}
function () payable {
revert();
}
}
contract CovestingFinish is Ownable {
CovestingToken public token = CovestingToken(0xE2FB6529EF566a080e6d23dE0bd351311087D567);
function mint(address to, uint256 tokens) public onlyOwner {
token.mint(this, tokens);
token.transfer(to, tokens);
}
function finishMinting() public onlyOwner {
token.finishMinting();
}
function lock(address to, uint date)  public onlyOwner {
token.lock(to, date);
}
}