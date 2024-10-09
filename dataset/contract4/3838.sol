pragma solidity ^0.4.11;
contract ERC20Basic {
uint256 public totalSupply;
function balanceOf(address who) public constant returns (uint256);
function transfer(address to, uint256 value) public returns (bool);
event Transfer(address indexed from, address indexed to, uint256 value);
}
contract Ownable {
address public owner;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
function Ownable() {
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
contract ERC20 is ERC20Basic {
function allowance(address owner, address spender) public constant returns (uint256);
function transferFrom(address from, address to, uint256 value) public returns (bool);
function approve(address spender, uint256 value) public returns (bool);
event Approval(address indexed owner, address indexed spender, uint256 value);
}
contract StandardToken is ERC20, SafeMath {
contract UpgradeAgent {
uint public originalSupply;
contract UpgradeableToken is StandardToken {
enum UpgradeState {Unknown, NotAllowed, WaitingForAgent, ReadyToUpgrade, Upgrading}
event Upgrade(address indexed _from, address indexed _to, uint256 _value);
event UpgradeAgentSet(address agent);
function UpgradeableToken(address _upgradeMaster) {
upgradeMaster = _upgradeMaster;
}
function upgrade(uint256 value) public {
UpgradeState state = getUpgradeState();
if(!(state == UpgradeState.ReadyToUpgrade || state == UpgradeState.Upgrading)) {
throw;
}
if (value == 0) throw;
balances[msg.sender] = safeSub(balances[msg.sender], value);
totalSupply = safeSub(totalSupply, value);
totalUpgraded = safeAdd(totalUpgraded, value);
upgradeAgent.upgradeFrom(msg.sender, value);
Upgrade(msg.sender, upgradeAgent, value);
}
function setUpgradeAgent(address agent) external {
if(!canUpgrade()) {
throw;
}
if (agent == 0x0) throw;
if (msg.sender != upgradeMaster) throw;
if (getUpgradeState() == UpgradeState.Upgrading) throw;
upgradeAgent = UpgradeAgent(agent);
if(!upgradeAgent.isUpgradeAgent()) throw;
if (upgradeAgent.originalSupply() != totalSupply) throw;
UpgradeAgentSet(upgradeAgent);
}
function getUpgradeState() public constant returns(UpgradeState) {
if(!canUpgrade()) return UpgradeState.NotAllowed;
else if(address(upgradeAgent) == 0x00) return UpgradeState.WaitingForAgent;
else if(totalUpgraded == 0) return UpgradeState.ReadyToUpgrade;
else return UpgradeState.Upgrading;
}
function setUpgradeMaster(address master) public {
if (master == 0x0) throw;
if (msg.sender != upgradeMaster) throw;
upgradeMaster = master;
}
function canUpgrade() public constant returns(bool) {
return true;
}
}
contract ReleasableToken is ERC20, Ownable {
modifier canTransfer(address _sender) {
if(!released) {
if(!transferAgents[_sender]) {
throw;
}
}
_;
}
function setReleaseAgent(address addr) onlyOwner inReleaseState(false) public {
releaseAgent = addr;
}
function setTransferAgent(address addr, bool state) onlyOwner inReleaseState(false) public {
transferAgents[addr] = state;
}
function releaseTokenTransfer() public onlyReleaseAgent {
released = true;
}
library SafeMathLibExt {
function times(uint a, uint b) returns (uint) {
uint c = a * b;
assert(a == 0 || c / a == b);
return c;
}
function divides(uint a, uint b) returns (uint) {
assert(b > 0);
uint c = a / b;
assert(a == b * c + a % b);
return c;
}
function minus(uint a, uint b) returns (uint) {
assert(b <= a);
return a - b;
}
function plus(uint a, uint b) returns (uint) {
uint c = a + b;
assert(c>=a);
return c;
}
}
contract MintableTokenExt is StandardToken, Ownable {
using SafeMathLibExt for uint;
bool public mintingFinished = false;
struct ReservedTokensData {
uint inTokens;
uint inPercentageUnit;
uint inPercentageDecimals;
bool isReserved;
bool isDistributed;
}
mapping (address => ReservedTokensData) public reservedTokensList;
address[] public reservedTokensDestinations;
uint public reservedTokensDestinationsLen = 0;
bool reservedTokensDestinationsAreSet = false;
modifier onlyMintAgent() {
if(!mintAgents[msg.sender]) {
throw;
}
_;
}
function mint(address receiver, uint amount) onlyMintAgent canMint public {
totalSupply = totalSupply.plus(amount);
balances[receiver] = balances[receiver].plus(amount);
Transfer(0, receiver, amount);
}
function setMintAgent(address addr, bool state) onlyOwner canMint public {
mintAgents[addr] = state;
MintingAgentChanged(addr, state);
}
function setReservedTokensList(address addr, uint inTokens, uint inPercentageUnit, uint inPercentageDecimals) private canMint onlyOwner {
assert(addr != address(0));
if (!isAddressReserved(addr)) {
reservedTokensDestinations.push(addr);
reservedTokensDestinationsLen++;
}
reservedTokensList[addr] = ReservedTokensData({
inTokens: inTokens,
inPercentageUnit: inPercentageUnit,
inPercentageDecimals: inPercentageDecimals,
isReserved: true,
isDistributed: false
});
}
}
contract CrowdsaleTokenExt is ReleasableToken, MintableTokenExt, UpgradeableToken {
function CrowdsaleTokenExt(string _name, string _symbol, uint _initialSupply, uint _decimals, bool _mintable, uint _globalMinCap)
UpgradeableToken(msg.sender) {
owner = msg.sender;
name = _name;
symbol = _symbol;
totalSupply = _initialSupply;
decimals = _decimals;
minCap = _globalMinCap;
balances[owner] = totalSupply;
if(totalSupply > 0) {
Minted(owner, totalSupply);
}
if(!_mintable) {
mintingFinished = true;
if(totalSupply == 0) {
throw;
}
}
}
function releaseTokenTransfer() public onlyReleaseAgent {
mintingFinished = true;
super.releaseTokenTransfer();
}
function canUpgrade() public constant returns(bool) {
return released && super.canUpgrade();
}
function setTokenInformation(string _name, string _symbol) onlyOwner {
name = _name;
symbol = _symbol;
UpdatedTokenInformation(name, symbol);
}
function claimTokens(address _token) public onlyOwner {
require(_token != address(0));
ERC20 token = ERC20(_token);
uint balance = token.balanceOf(this);
token.transfer(owner, balance);
ClaimedTokens(_token, owner, balance);
}
}