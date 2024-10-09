pragma solidity ^0.4.13;
contract ERC20 {
function balanceOf(address who) constant returns (uint);
function allowance(address owner, address spender) constant returns (uint);
function transfer(address to, uint value) returns (bool ok);
function transferFrom(address from, address to, uint value) returns (bool ok);
function approve(address spender, uint value) returns (bool ok);
event Transfer(address indexed from, address indexed to, uint value);
event Approval(address indexed owner, address indexed spender, uint value);
}
contract SafeMath {
function safeMul(uint a, uint b) internal returns (uint) {
uint c = a * b;
assert(a == 0 || c / a == b);
return c;
}
function safeDiv(uint a, uint b) internal returns (uint) {
assert(b > 0);
uint c = a / b;
assert(a == b * c + a % b);
return c;
}
function safeSub(uint a, uint b) internal returns (uint) {
assert(b <= a);
return a - b;
}
function safeAdd(uint a, uint b) internal returns (uint) {
uint c = a + b;
assert(c>=a && c>=b);
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
}
contract StandardToken is ERC20, SafeMath {
event Minted(address receiver, uint amount);
mapping(address => uint) balances;
mapping (address => mapping (address => uint)) allowed;
function isToken() public constant returns (bool Yes) {
return true;
}
function transfer(address _to, uint _value) returns (bool success) {
balances[msg.sender] = safeSub(balances[msg.sender], _value);
balances[_to] = safeAdd(balances[_to], _value);
Transfer(msg.sender, _to, _value);
return true;
}
function transferFrom(address _from, address _to, uint _value) returns (bool success) {
uint _allowance = allowed[_from][msg.sender];
balances[_to] = safeAdd(balances[_to], _value);
balances[_from] = safeSub(balances[_from], _value);
allowed[_from][msg.sender] = safeSub(_allowance, _value);
Transfer(_from, _to, _value);
return true;
}
function balanceOf(address _address) constant returns (uint balance) {
return balances[_address];
}
function approve(address _spender, uint _value) returns (bool success) {
require((_value == 0) || (allowed[msg.sender][_spender] == 0));
allowed[msg.sender][_spender] = _value;
Approval(msg.sender, _spender, _value);
return true;
}
function allowance(address _owner, address _spender) constant returns (uint remaining) {
return allowed[_owner][_spender];
}
}
contract CBZToken is StandardToken {
string public name = "CryptoBazar Token";
string public symbol = "CBZ";
uint8 public decimals = 8;
uint256 public totalSupply = 1000000000 * (10 ** uint256(decimals));
uint public sellPrice = 1000000000000000 wei;
mapping (address => bool) public allowedTransfer;
bool public TransferAllowed = true;
bool public CrowdsalePaused = false;
uint public StatsEthereumRaised = 0 wei;
uint public StatsSold = 0;
uint public StatsMinted = 0;
uint public StatsTotal = 0;
event Buy(address indexed sender, uint eth, uint tokens);
event Mint(address indexed from, uint tokens);
event Burn(address indexed from, uint tokens);
event PriceChanged(string _text, uint _tokenPrice);
address public owner = 0x0;
address public minter = 0x0;
address public wallet = 0x0;
function CBZToken(address _owner, address _minter, address _wallet) payable {
owner = _owner;
minter = _minter;
wallet = _wallet;
balances[owner] = 0;
balances[minter] = 0;
balances[wallet] = 0;
allowedTransfer[owner] = true;
allowedTransfer[minter] = true;
allowedTransfer[wallet] = true;
}
modifier onlyOwner() {
require(msg.sender == owner);
_;
}
modifier onlyMinter() {
require(msg.sender == minter);
_;
}
function() payable {
buy();
}
function price() constant returns (uint) {
return sellPrice;
}
function setTokenPrice(uint _tokenPrice) external onlyOwner {
sellPrice = _tokenPrice;
PriceChanged("New price is ", _tokenPrice);
}
function setTransferAllowance(bool _allowance) external onlyOwner {
TransferAllowed = _allowance;
}
function eventPause(bool _pause) external onlyOwner {
CrowdsalePaused = _pause;
}
function mintTokens(address _target, uint _amount) onlyMinter external returns (bool) {
require(_amount > 0);
require(safeAdd(StatsTotal, _amount) <= totalSupply);
balances[_target] = safeAdd(balances[_target], _amount);
StatsMinted = safeAdd(StatsMinted, _amount);
StatsTotal = safeAdd(StatsTotal, _amount);
Transfer(0, this, _amount);
Transfer(this, _target, _amount);
Mint(_target, _amount);
return true;
}
function decreaseTokens(address _target, uint _amount) onlyMinter external returns (bool) {
require(_amount > 0);
balances[_target] = safeSub(balances[_target], _amount);
StatsMinted = safeSub(StatsMinted, _amount);
StatsTotal = safeSub(StatsTotal, _amount);
Transfer(_target, 0, _amount);
Burn(_target, _amount);
return true;
}
function allowTransfer(address _target, bool _allow) external onlyOwner {
allowedTransfer[_target] = _allow;
}
function buy() public payable returns(bool) {
require(msg.sender != owner);
require(msg.sender != minter);
require(msg.sender != wallet);
require(!CrowdsalePaused);
require(msg.value >= price());
uint tokens = msg.value/price();
require(tokens > 0);
require(safeAdd(StatsTotal, tokens) <= totalSupply);
wallet.transfer(msg.value);
balances[msg.sender] = safeAdd(balances[msg.sender], tokens);
StatsSold = safeAdd(StatsSold, tokens);
StatsTotal = safeAdd(StatsTotal, tokens);
Transfer(0, this, tokens);
Transfer(this, msg.sender, tokens);
StatsEthereumRaised = safeAdd(StatsEthereumRaised, msg.value);
Buy(msg.sender, msg.value, tokens);
return true;
}
function transfer(address _to, uint _value) returns (bool success) {
if(!TransferAllowed){
require(allowedTransfer[msg.sender]);
}
return super.transfer(_to, _value);
}
function transferFrom(address _from, address _to, uint _value) returns (bool success) {
if(!TransferAllowed){
require(allowedTransfer[msg.sender]);
}
return super.transferFrom(_from, _to, _value);
}
function changeOwner(address _to) external onlyOwner() {
balances[_to] = balances[owner];
balances[owner] = 0;
owner = _to;
}
function changeMinter(address _to) external onlyOwner() {
balances[_to] = balances[minter];
balances[minter] = 0;
minter = _to;
}
function changeWallet(address _to) external onlyOwner() {
balances[_to] = balances[wallet];
balances[wallet] = 0;
wallet = _to;
}
}