pragma solidity ^0.4.15;
contract PresaleToken {
function PresaleToken() public {
address tokenManager = 0xE2e16E48B09602b3E6Ba50B7fed950254cBE895d;
address escrow = 0xBD4CB8e76D58Cc7E6D53aD475d599e8f4c110C19;
balanceOf[escrow] += 60000000000000000000000000;
totalSupply += 60000000000000000000000000;
}
*  Constants
string public name = "Just Wallet";
string public  symbol = "JWT";
uint   public decimals = 18;
uint public constant PRICE = 5000;
uint public constant TOKEN_SUPPLY_LIMIT = PRICE * 150000 * (1 ether / 1 wei);
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
mapping (address => uint256) public balanceOf;
mapping (address => bool) public isSaler;
mapping (address => mapping (address => uint256)) public allowance;
modifier onlyTokenManager() {
require(msg.sender == tokenManager);
_;
}
modifier onlyCrowdsaleManager() {
require(msg.sender == crowdsaleManager);
_;
}
modifier onlyEscrow() {
require(msg.sender == escrow);
_;
}
*  Events
event LogBuy(address indexed owner, uint value);
event LogBurn(address indexed owner, uint value);
event LogPhaseSwitch(Phase newPhase);
event Transfer(address indexed from, address indexed to, uint256 value);
*  Public functions
function _transfer(address _from, address _to, uint _value) internal {
require(_to != 0x0);
require(_value > 0);
require(balanceOf[_from] > _value);
require(balanceOf[_to] + _value > balanceOf[_to]);
require(balanceOf[msg.sender] - _value < balanceOf[msg.sender]);
balanceOf[_from] -= _value;
balanceOf[_to] += _value;
Transfer(_from, _to, _value);
}
function transfer(address _to, uint256 _value) public
onlyEscrow
{
_transfer(msg.sender, _to, _value);
}
function getBonus(uint value) internal returns (uint bonus) {
require(value != 0);
if (value >= (3000 * 10**18)) {
return value * 2550;
} else if (value >= (300 * 10**18)) {
return value * 1350;
}
return 0;
}
function() payable public {
buy(msg.sender);
}
function buy(address _buyer) payable public {
require(currentPhase == Phase.Running);
require(msg.value != 0);
uint newTokens = msg.value * PRICE + getBonus(msg.value);
require (totalSupply + newTokens < TOKEN_SUPPLY_LIMIT);
balanceOf[_buyer] += newTokens;
totalSupply += newTokens;
LogBuy(_buyer, newTokens);
}
function buyTokens(address _saler) payable public {
require(isSaler[_saler] == true);
require(currentPhase == Phase.Running);
require(msg.value != 0);
uint newTokens = msg.value * PRICE + getBonus(msg.value);
uint tokenForSaler = newTokens / 20;
require(totalSupply + newTokens + tokenForSaler <= TOKEN_SUPPLY_LIMIT);
balanceOf[_saler] += tokenForSaler;
balanceOf[msg.sender] += newTokens;
totalSupply += newTokens;
totalSupply += tokenForSaler;
LogBuy(msg.sender, newTokens);
}
function burnTokens(address _owner) public
onlyCrowdsaleManager
{
require(currentPhase == Phase.Migrating);
uint tokens = balanceOf[_owner];
require(tokens != 0);
balanceOf[_owner] = 0;
totalSupply -= tokens;
LogBurn(_owner, tokens);
if (totalSupply == 0) {
currentPhase = Phase.Migrated;
LogPhaseSwitch(Phase.Migrated);
}
}
*  Administrative functions
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
require(canSwitchPhase);
currentPhase = _nextPhase;
LogPhaseSwitch(_nextPhase);
}
function withdrawEther() public
onlyTokenManager
{
require(escrow != 0x0);
if (this.balance > 0) {
escrow.transfer(this.balance);
}
}
function setCrowdsaleManager(address _mgr) public
onlyTokenManager
{
require(currentPhase != Phase.Migrating);
crowdsaleManager = _mgr;
}
function addSaler(address _mgr) public
onlyTokenManager
{
require(currentPhase != Phase.Migrating);
isSaler[_mgr] = true;
}
function removeSaler(address _mgr) public
onlyTokenManager
{
require(currentPhase != Phase.Migrating);
isSaler[_mgr] = false;
}
function mintToken(address target, uint256 mintedAmount) public onlyCrowdsaleManager {
balanceOf[target] += mintedAmount;
totalSupply += mintedAmount;
Transfer(0, tokenManager, mintedAmount);
Transfer(tokenManager, target, mintedAmount);
}
function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
require(_value <= allowance[_from][msg.sender]);
allowance[_from][msg.sender] -= _value;
_transfer(_from, _to, _value);
return true;
}
function approve(address _spender, uint256 _value) public
returns (bool success) {
allowance[msg.sender][_spender] = _value;
return true;
}
}