pragma solidity^0.4.11;
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
contract ERC20 is ERC20Basic {
function allowance(address owner, address spender) constant returns (uint);
function transferFrom(address from, address to, uint value);
function approve(address spender, uint value);
event Approval(address indexed owner, address indexed spender, uint value);
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
contract StandardToken is BasicToken, ERC20 {
mapping (address => mapping (address => uint)) allowed;
function transferFrom(address _from, address _to, uint _value) onlyPayloadSize(3 * 32) {
var _allowance = allowed[_from][msg.sender];
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
}
contract EthsMePresale is StandardToken {
string public constant name = "EthsMe Presale token";
string public constant symbol = "ETME";
uint256   public constant decimals = 18;
uint256 public constant PRICE = 1000;
uint256 public constant TOKEN_SUPPLY_LIMIT = 2500 * 10000 * (1 ether / 1 wei);
uint256 public constant SECURITY_ETHER_CAP = 35 ether;
uint256 public totalSupply = 0;
uint256 public totalETHRaised;
enum Phase {
Created,
Running,
Paused,
Migrating,
Migrated
}
Phase public currentPhase = Phase.Running;
address public tokenManager;
address public escrow;
address public crowdsaleManager;
mapping (address => uint256) private balance;
modifier onlyTokenManager()     { if(msg.sender != tokenManager) throw; _; }
modifier onlyCrowdsaleManager() { if(msg.sender != crowdsaleManager) throw; _; }
event LogBuy(address indexed owner, uint value);
event LogBurn(address indexed owner, uint value);
event LogPhaseSwitch(Phase newPhase);
function EthsMePresale(address _tokenManager, address _escrow) {
tokenManager = _tokenManager;
escrow = _escrow;
totalETHRaised = 0;
}
function() payable {
buyTokens(msg.sender);
}
function buyTokens(address _buyer) public payable {
uint256 newEtherBalance = totalETHRaised.add(msg.value);
if(currentPhase != Phase.Running) throw;
if (newEtherBalance > SECURITY_ETHER_CAP) throw;
if(msg.value == 0) throw;
uint newTokens = msg.value * PRICE;
if (totalSupply + newTokens > TOKEN_SUPPLY_LIMIT) throw;
balance[_buyer] += newTokens;
totalSupply += newTokens;
totalETHRaised = newEtherBalance;
LogBuy(_buyer, newTokens);
}
function burnTokens(address _owner) public
onlyCrowdsaleManager
{
if(currentPhase != Phase.Migrating) throw;
uint tokens = balance[_owner];
if(tokens == 0) throw;
balance[_owner] = 0;
totalSupply -= tokens;
LogBurn(_owner, tokens);
if(totalSupply == 0) {
currentPhase = Phase.Migrated;
LogPhaseSwitch(Phase.Migrated);
}
}
function balanceOf(address _owner) constant returns (uint256) {
return balance[_owner];
}
function setPresalePhase(Phase _nextPhase) public
onlyTokenManager
{
bool canSwitchPhase
=  (currentPhase == Phase.Created && _nextPhase == Phase.Running)
|| (currentPhase == Phase.Running && _nextPhase == Phase.Paused)
|| ((currentPhase == Phase.Running || currentPhase == Phase.Paused)
&& _nextPhase == Phase.Migrating
&& crowdsaleManager != 0x0)
|| (currentPhase == Phase.Paused && _nextPhase == Phase.Running)
|| (currentPhase == Phase.Migrating && _nextPhase == Phase.Migrated
&& totalSupply == 0);
if(!canSwitchPhase) throw;
currentPhase = _nextPhase;
LogPhaseSwitch(_nextPhase);
}
function withdrawEther() public
onlyTokenManager
{
if(this.balance > 0) {
if(!escrow.send(this.balance)) throw;
}
}
function setCrowdsaleManager(address _mgr) public
onlyTokenManager
{
if(currentPhase == Phase.Migrating) throw;
crowdsaleManager = _mgr;
}
function transfer(address _to, uint _value) {
super.transfer(_to, _value);
}
function transferFrom(address _from, address _to, uint _value) {
super.transferFrom(_from, _to, _value);
}
}