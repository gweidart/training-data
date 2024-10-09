pragma solidity ^0.4.11;
contract MaptPresale2Token {
uint256 constant MAPT_IN_ETH = 100;
uint constant MIN_TRANSACTION_AMOUNT_ETH = 0 ether;
uint public PRESALE_START_DATE = 1506834000;
uint public PRESALE_END_DATE = 1508198401;
function MaptPresale2Token(address _tokenManager, address _escrow) {
tokenManager = _tokenManager;
escrow = _escrow;
PRESALE_START_DATE = now;
}
*  Constants
string public constant name = "MAT Presale2 Token";
string public constant symbol = "MAPT2";
uint   public constant decimals = 18;
uint public constant TOKEN_SUPPLY_LIMIT = 2700000 * 1 ether / 1 wei;
*  Token state
enum Phase {
Created,
Running,
Paused,
Migrating,
Migrated
}
Phase public currentPhase = Phase.Created;
uint public totalSupply = 0;
address public tokenManager;
address public escrow;
address public crowdsaleManager;
mapping (address => uint256) private balanceTable;
* Modifiers
modifier onlyTokenManager()     { if(msg.sender != tokenManager) throw; _; }
modifier onlyCrowdsaleManager() { if(msg.sender != crowdsaleManager) throw; _; }
*  Events
event LogBuy(address indexed owner, uint etherWeiIncoming, uint tokensSold);
event LogBurn(address indexed owner, uint value);
event LogPhaseSwitch(Phase newPhase);
event LogEscrowWei(uint balanceWei);
event LogEscrowWeiReq(uint balanceWei);
event LogEscrowEth(uint balanceEth);
event LogEscrowEthReq(uint balanceEth);
event LogStartDate(uint newdate, uint oldDate);
function calculatePrice(uint valueWei) private constant returns (uint tokenAmount) {
uint res = valueWei * MAPT_IN_ETH;
return res;
}
*  Public functions
function() payable {
buyTokens(msg.sender);
}
function burnTokens(address _owner)
public
onlyCrowdsaleManager
returns (uint)
{
if(currentPhase != Phase.Migrating) return 1;
uint tokens = balanceTable[_owner];
if(tokens == 0) return 2;
totalSupply -= tokens;
balanceTable[_owner] = 0;
LogBurn(_owner, tokens);
if(totalSupply == 0) {
currentPhase = Phase.Migrated;
LogPhaseSwitch(Phase.Migrated);
}
return 0;
}
function balanceOf(address _owner) constant returns (uint256) {
return balanceTable[_owner];
}
*  Administrative functions
function setPresalePhaseUInt(uint phase)
public
onlyTokenManager
{
require( uint(Phase.Migrated) >= phase && phase >= 0 );
setPresalePhase(Phase(phase));
}
function setPresalePhase(Phase _nextPhase)
public
onlyTokenManager
{
_setPresalePhase(_nextPhase);
}
function _setPresalePhase(Phase _nextPhase)
private
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
function setCrowdsaleManager(address _mgr)
public
onlyTokenManager
{
if(currentPhase == Phase.Migrating) throw;
crowdsaleManager = _mgr;
}
function buyTokens(address _buyer)
public
payable
{
require(totalSupply < TOKEN_SUPPLY_LIMIT);
uint valueWei = msg.value;
require(currentPhase == Phase.Running);
require(valueWei >= MIN_TRANSACTION_AMOUNT_ETH);
require(now >= PRESALE_START_DATE);
require(now <= PRESALE_END_DATE);
uint newTokens = calculatePrice(valueWei);
require(newTokens > 0);
require(totalSupply + newTokens <= TOKEN_SUPPLY_LIMIT);
totalSupply += newTokens;
balanceTable[_buyer] += newTokens;
LogBuy(_buyer, valueWei, newTokens);
}
function withdrawWei(uint balWei)
public
onlyTokenManager
returns (uint)
{
LogEscrowWeiReq(balWei);
if(this.balance >= balWei) {
escrow.transfer(balWei);
LogEscrowWei(balWei);
return 0;
}
return 1;
}
function withdrawEther(uint sumEther)
public
onlyTokenManager
returns (uint)
{
LogEscrowEthReq(sumEther);
uint sumWei = sumEther * 1 ether / 1 wei;
if(this.balance >= sumWei) {
escrow.transfer(sumWei);
LogEscrowWei(sumWei);
return 0;
}
return 1;
}
}