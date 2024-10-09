pragma solidity ^0.4.15;
pragma solidity ^0.4.15;
contract Token {
uint256 public totalSupply;
function balanceOf(address _owner) constant returns (uint256 balance);
function transfer(address _to, uint256 _value) returns (bool success);
function transferFrom(address _from, address _to, uint256 _value) returns (bool success);
function approve(address _spender, uint256 _value) returns (bool success);
function allowance(address _owner, address _spender) constant returns (uint256 remaining);
event Transfer(address indexed _from, address indexed _to, uint256 _value);
event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}
contract StandardToken is Token {
mapping (address => uint256) balances;
mapping (address => mapping (address => uint256)) allowed;
function transfer(address _to, uint256 _value) returns (bool success) {
if (balances[msg.sender] >= _value && _value > 0) {
balances[msg.sender] -= _value;
balances[_to] += _value;
Transfer(msg.sender, _to, _value);
return true;
} else {
return false;
}
}
function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0) {
balances[_to] += _value;
balances[_from] -= _value;
allowed[_from][msg.sender] -= _value;
Transfer(_from, _to, _value);
return true;
} else {
return false;
}
}
function balanceOf(address _owner) constant returns (uint256 balance) {
return balances[_owner];
}
function approve(address _spender, uint256 _value) returns (bool success) {
allowed[msg.sender][_spender] = _value;
Approval(msg.sender, _spender, _value);
return true;
}
function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
return allowed[_owner][_spender];
}
}
pragma solidity ^0.4.15;
pragma solidity ^0.4.15;
contract Ownable {
address public owner;
function Ownable() {
owner = msg.sender;
}
modifier onlyOwner() {
if (msg.sender == owner)
_;
}
function transferOwnership(address newOwner) onlyOwner {
if (newOwner != address(0)) owner = newOwner;
}
}
contract Pausable is Ownable {
bool public stopped;
modifier stopInEmergency {
if (stopped) {
throw;
}
_;
}
modifier onlyInEmergency {
if (!stopped) {
throw;
}
_;
}
function emergencyStop() external onlyOwner {
stopped = true;
}
function release() external onlyOwner onlyInEmergency {
stopped = false;
}
}
pragma solidity ^0.4.15;
contract Utils{
modifier greaterThanZero(uint256 _value){
require(_value>0);
_;
}
modifier validAddress(address _add){
require(_add!=0x0);
_;
}
}
pragma solidity ^0.4.15;
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
contract Crowdsale is StandardToken, Pausable, SafeMath, Utils{
string public constant name = "BlockAim Token";
string public constant symbol = "BA";
uint256 public constant decimals = 18;
string public version = "1.0";
bool public tradingStarted = false;
modifier hasStartedTrading() {
require(tradingStarted);
_;
}
function startTrading() onlyOwner() {
tradingStarted = true;
}
function transfer(address _to, uint _value) hasStartedTrading returns (bool success) {super.transfer(_to, _value);}
function transferFrom(address _from, address _to, uint _value) hasStartedTrading returns (bool success) {super.transferFrom(_from, _to, _value);}
enum State{
Inactive,
Funding,
Success,
Failure
}
uint256 public investmentETH;
mapping(uint256 => bool) transactionsClaimed;
uint256 public initialSupply;
address wallet;
uint256 public constant _totalSupply = 100 * (10**6) * 10 ** decimals;
uint256 public fundingStartBlock;
uint256 public tokensPerEther = 300;
uint256 public constant tokenCreationMax = 10 * (10**6) * 10 ** decimals;
address[] public investors;
function investorsCount() constant external returns(uint) { return investors.length; }
function Crowdsale(uint256 _fundingStartBlock, address _owner, address _wallet){
owner = _owner;
fundingStartBlock =_fundingStartBlock;
totalSupply = _totalSupply;
initialSupply = 0;
wallet = _wallet;
if (
tokensPerEther == 0
|| owner == 0x0
|| wallet == 0x0
|| fundingStartBlock == 0
|| totalSupply == 0
|| tokenCreationMax == 0
|| fundingStartBlock <= block.number)
throw;
}
function getState() constant public returns(State){
if(block.number<fundingStartBlock) return State.Inactive;
else if(block.number>fundingStartBlock && initialSupply<tokenCreationMax) return State.Funding;
else if (initialSupply >= tokenCreationMax) return State.Success;
else return State.Failure;
}
function getTokens(address addr) public returns(uint256){
return balances[addr];
}
function() external payable stopInEmergency{
if(getState() == State.Success) throw;
if (msg.value == 0) throw;
uint256 newCreatedTokens = safeMul(msg.value,tokensPerEther);
initialSupply = safeAdd(initialSupply,newCreatedTokens);
if(initialSupply>tokenCreationMax) throw;
if (balances[msg.sender] == 0) investors.push(msg.sender);
investmentETH += msg.value;
balances[msg.sender] = safeAdd(balances[msg.sender],newCreatedTokens);
Transfer(this, msg.sender, newCreatedTokens);
if(!wallet.send(msg.value)) throw;
}
function tokenMint(address addr,uint256 tokens)
external
stopInEmergency
onlyOwner()
{
if(getState() == State.Success) throw;
if(addr == 0x0) throw;
if (tokens == 0) throw;
uint256 newCreatedTokens = tokens * 1 ether;
initialSupply = safeAdd(initialSupply,newCreatedTokens);
if(initialSupply>tokenCreationMax) throw;
if (balances[addr] == 0) investors.push(addr);
balances[addr] = safeAdd(balances[addr],newCreatedTokens);
Transfer(this, addr, newCreatedTokens);
}
function changeExchangeRate(uint256 eth)
external
onlyOwner()
{
if(eth == 0) throw;
tokensPerEther = eth;
}
function blacklist(address addr)
external
onlyOwner()
{
balances[addr] = 0;
}
}