pragma solidity ^0.4.15;
library SafeMath {
function mul(uint256 a, uint256 b) internal pure returns(uint256) {
uint256 c = a * b;
assert(a == 0 || c / a == b);
return c;
}
function div(uint256 a, uint256 b) internal pure returns(uint256) {
uint256 c = a / b;
return c;
}
function sub(uint256 a, uint256 b) internal pure returns(uint256) {
assert(b <= a);
return a - b;
}
function add(uint256 a, uint256 b) internal pure returns(uint256) {
uint256 c = a + b;
assert(c >= a);
return c;
}
}
contract Ownable {
address public owner;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
function Ownable() public {
owner = msg.sender;
}
modifier onlyOwner() {
require(msg.sender == owner);
_;
}
function transferOwnership(address newOwner) onlyOwner public {
require(newOwner != address(0));
OwnershipTransferred(owner, newOwner);
owner = newOwner;
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
function pause() onlyOwner whenNotPaused public {
paused = true;
Pause();
}
function unpause() onlyOwner whenPaused public {
paused = false;
Unpause();
}
}
contract ContractReceiver {
function tokenFallback(address from, uint value, bytes data) public;
}
contract ERC223 {
using SafeMath for uint256;
mapping(address => uint256) balances;
mapping(address => mapping (address => uint256)) allowed;
string public name;
string public symbol;
uint8 public decimals;
uint256 public totalSupply;
event Approval(address owner, address spender, uint256 amount);
event Transfer(address from, address to, uint256 value);
event Transfer(address from, address to, uint256 value, bytes data);
function transfer(address to, uint256 value) public returns (bool _success) {
require(to != address(0));
require(value != 0);
bytes memory emptyData;
if (isContract(to)) {
return transferToContract(to, value, emptyData);
} else {
return transferToAddress(to, value, emptyData);
}
}
function transfer(address to, uint256 value, bytes data) public returns (bool _success) {
require(to != address(0));
require(value != 0);
require(data.length != 0);
if (isContract(to)) {
return transferToContract(to, value, data);
} else {
return transferToAddress(to, value, data);
}
}
function transferFrom(address from, address to, uint256 value) public returns (bool _success) {
require(from != address(0));
require(to != address(0));
require(value != 0);
uint256 allowance = allowed[from][msg.sender];
balances[from] = balances[from].sub(value);
allowed[from][msg.sender] = allowance.sub(value);
balances[to] = balances[to].add(value);
Transfer(from, to, value);
return true;
}
function approve(address spender, uint256 value) public returns (bool _success) {
require(spender != address(0));
require(value != 0);
allowed[msg.sender][spender] = value;
Approval(msg.sender, spender, value);
return true;
}
function transferToAddress(address to, uint256 value, bytes data) public returns (bool _success) {
require(to != address(0));
require(value <= balances[msg.sender]);
balances[msg.sender] = balances[msg.sender].sub(value);
balances[to] = balances[to].add(value);
Transfer(msg.sender, to, value, data);
return true;
}
function transferToContract(address to, uint256 value, bytes data) public returns (bool _success) {
require(to != address(0));
require(value <= balances[msg.sender]);
balances[msg.sender] = balances[msg.sender].sub(value);
balances[to] = balances[to].add(value);
ContractReceiver(to).tokenFallback(msg.sender, value, data);
Transfer(msg.sender, to, value, data);
return true;
}
function allowance(address _owner, address _spender) public constant returns(uint256 remaining) {
return allowed[_owner][_spender];
}
function balanceOf(address owner) public constant returns (uint256 _balance) {
require(owner != address(0));
return balances[owner];
}
function isContract(address addr) public constant returns (bool _isContract) {
require(addr != address(0));
uint256 length;
assembly {
length := extcodesize(addr)
}
return (length > 0);
}
}
contract Topcoin is ERC223, Pausable {
string public constant name = 'Topcoin';
string public constant symbol = 'TPC';
uint8 public constant decimals = 18;
uint256 public constant totalSupply = 3000e24;
uint256 public constant crowdsaleTokens = 1000e24;
uint256 public ICOEndTime;
address public crowdsale;
uint256 public tokensRaised;
modifier afterCrowdsale() {
require(now >= ICOEndTime);
_;
}
modifier onlyCrowdsale() {
require(msg.sender == crowdsale);
_;
}
modifier onlyOwnerOrCrowdsale() {
require(msg.sender == owner || msg.sender == crowdsale);
_;
}
function Topcoin(uint256 _ICOEndTime) public {
require(_ICOEndTime > 0 && _ICOEndTime > now);
ICOEndTime = _ICOEndTime;
balances[msg.sender] = totalSupply;
}
function setCrowdsaleAddress(address _crowdsale) public onlyOwner {
require(_crowdsale != address(0));
crowdsale = _crowdsale;
}
function distributeTokens(address _to, uint256 _amount) public onlyOwnerOrCrowdsale {
require(_to != address(0));
require(_amount > 0);
require(tokensRaised.add(_amount) <= crowdsaleTokens);
tokensRaised = tokensRaised.add(_amount);
balances[msg.sender] = balances[msg.sender].sub(_amount);
balances[_to] = balances[_to].add(_amount);
}
function convertOldTokens(address _receiver, uint256 _oldAmount) external onlyOwner {
require(_receiver != address(0));
require(_oldAmount > 0);
uint256 amountNewTokens = _oldAmount.mul(2);
balances[owner] = balances[owner].sub(amountNewTokens);
balances[_receiver] = balances[_receiver].add(amountNewTokens);
}
function transfer(address _to, uint256 _value) public whenNotPaused afterCrowdsale returns(bool) {
return super.transfer(_to, _value);
}
function transfer(address to, uint256 value, bytes data) public whenNotPaused afterCrowdsale returns (bool _success) {
return super.transfer(to, value, data);
}
function transferFrom(address _from, address _to, uint256 _value) public whenNotPaused afterCrowdsale returns(bool) {
return super.transferFrom(_from, _to, _value);
}
function approve(address _spender, uint256 _value) public whenNotPaused afterCrowdsale returns(bool) {
return super.approve(_spender, _value);
}
function transferToAddress(address to, uint256 value, bytes data) public whenNotPaused afterCrowdsale returns (bool _success) {
return super.transferToAddress(to, value, data);
}
function transferToContract(address to, uint256 value, bytes data) public whenNotPaused afterCrowdsale returns (bool _success) {
return super.transferToContract(to, value, data);
}
}