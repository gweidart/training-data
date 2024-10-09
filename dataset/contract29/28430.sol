pragma solidity ^0.4.18;
contract SafeMath {
function safeMul(uint256 a, uint256 b) internal pure returns (uint256) {
uint256 c = a * b;
require(a == 0 || c / a == b);
return c;
}
function safeDiv(uint256 a, uint256 b) internal pure returns (uint256) {
require(b > 0);
uint256 c = a / b;
require(a == b * c + a % b);
return c;
}
function safeSub(uint256 a, uint256 b) internal pure returns (uint256) {
require(b <= a);
return a - b;
}
function safeAdd(uint256 a, uint256 b) internal pure returns (uint256) {
uint256 c = a + b;
require(c>=a && c>=b);
return c;
}
}
contract ERC20 {
uint256 public totalSupply;
function balanceOf(address _owner) public constant returns (uint256 _balance);
function allowance(address _owner, address _spender) public constant returns (uint256 _allowance);
function transfer(address _to, uint256 _value) public returns (bool _succes);
function transferFrom(address _from, address _to, uint256 _value) public returns (bool _succes);
function approve(address _spender, uint256 _value) public returns (bool _succes);
event Transfer(address indexed _from, address indexed _to, uint256 _value);
event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}
contract StandardToken is ERC20, SafeMath {
mapping (address => uint256) public balanceOf;
mapping (address => mapping (address => uint256)) public allowance;
function balanceOf(address _owner) public constant returns (uint256){
return balanceOf[_owner];
}
function allowance(address _owner, address _spender) public constant returns (uint256){
return allowance[_owner][_spender];
}
modifier onlyPayloadSize(uint size) {
require(!(msg.data.length < size + 4));
_;
}
function safeTransfer(address _from, address _to, uint256 _value) internal {
require(_to != 0x0);
require(_to != address(this));
balanceOf[_from] = safeSub(balanceOf[_from], _value);
balanceOf[_to] = safeAdd(balanceOf[_to], _value);
Transfer(_from, _to, _value);
}
function transfer(address _to, uint256 _value) onlyPayloadSize(2 * 32) public returns (bool) {
safeTransfer(msg.sender, _to, _value);
return true;
}
function transferFrom(address _from, address _to, uint256 _value) onlyPayloadSize(3 * 32) public returns (bool) {
uint256 _allowance = allowance[_from][msg.sender];
allowance[_from][msg.sender] = safeSub(_allowance, _value);
safeTransfer(_from, _to, _value);
return true;
}
function approve(address _spender, uint256 _value) public returns (bool) {
require((_value == 0) || (allowance[msg.sender][_spender] == 0));
allowance[msg.sender][_spender] = _value;
Approval(msg.sender, _spender, _value);
return true;
}
}
contract UpgradeAgent {
uint256 public originalSupply;
function isUpgradeAgent() public pure returns (bool) {
return true;
}
function upgradeFrom(address _from, uint256 _value) public;
}
contract UpgradeableToken is StandardToken {
address public upgradeMaster;
UpgradeAgent public upgradeAgent;
uint256 public totalUpgraded;
enum UpgradeState {Unknown, NotAllowed, WaitingForAgent, ReadyToUpgrade, Upgrading}
event Upgrade(address indexed _from, address indexed _to, uint256 _value);
event UpgradeAgentSet(address agent);
function UpgradeableToken(address _upgradeMaster) public {
upgradeMaster = _upgradeMaster;
}
function upgrade(uint256 value) public {
UpgradeState state = getUpgradeState();
require(state == UpgradeState.ReadyToUpgrade || state == UpgradeState.Upgrading);
require(value != 0);
balanceOf[msg.sender] = safeSub(balanceOf[msg.sender], value);
totalSupply = safeSub(totalSupply, value);
totalUpgraded = safeAdd(totalUpgraded, value);
upgradeAgent.upgradeFrom(msg.sender, value);
Upgrade(msg.sender, upgradeAgent, value);
}
function setUpgradeAgent(address agent) external {
require(canUpgrade());
require(agent != 0x0);
require(msg.sender == upgradeMaster);
require(getUpgradeState() != UpgradeState.Upgrading);
upgradeAgent = UpgradeAgent(agent);
require(upgradeAgent.isUpgradeAgent());
require(upgradeAgent.originalSupply() == totalSupply);
UpgradeAgentSet(upgradeAgent);
}
function getUpgradeState() public constant returns (UpgradeState) {
if(!canUpgrade()) return UpgradeState.NotAllowed;
else if(address(upgradeAgent) == 0x00) return UpgradeState.WaitingForAgent;
else if(totalUpgraded == 0) return UpgradeState.ReadyToUpgrade;
else return UpgradeState.Upgrading;
}
function setUpgradeMaster(address master) public {
require(master != 0x0);
require(msg.sender == upgradeMaster);
upgradeMaster = master;
}
function canUpgrade() public pure returns (bool) {
return true;
}
}
contract Ownable {
address public ownerOne;
address public ownerTwo;
function Ownable() public {
ownerOne = msg.sender;
ownerTwo = msg.sender;
}
modifier onlyOwner {
require(msg.sender == ownerOne || msg.sender == ownerTwo);
_;
}
function transferOwnership(address newOwner, bool replaceOwnerOne, bool replaceOwnerTwo) onlyOwner public {
require(newOwner != 0x0);
require(replaceOwnerOne || replaceOwnerTwo);
if(replaceOwnerOne) ownerOne = newOwner;
if(replaceOwnerTwo) ownerTwo = newOwner;
}
}
contract Pausable is Ownable {
event Pause();
event Unpause();
bool public paused = false;
modifier whenNotPaused {
require(!paused);
_;
}
modifier whenPaused {
require(paused);
_;
}
function pause() onlyOwner whenNotPaused public returns (bool) {
paused = true;
Pause();
return true;
}
function unpause() onlyOwner whenPaused public returns (bool) {
paused = false;
Unpause();
return true;
}
}
contract PausableToken is StandardToken, Pausable {
function transfer(address _to, uint256 _value) whenNotPaused public returns (bool) {
super.transfer(_to, _value);
return true;
}
function transferFrom(address _from, address _to, uint256 _value) whenNotPaused public returns (bool) {
super.transferFrom(_from, _to, _value);
return true;
}
}
contract PurchasableToken is PausableToken {
event PurchaseUnlocked();
event PurchaseLocked();
event UpdatedExchangeRate(uint256 newPrice);
event Purchase(address buyer, uint256 etherAmount, uint256 tokenAmount);
bool public purchasable = false;
uint256 public minimumEtherAmount;
address public vendorWallet;
uint256 public exchangeRate;
modifier isPurchasable {
require(purchasable && exchangeRate > 0 && minimumEtherAmount > 0);
_;
}
function lockPurchase() onlyOwner public returns (bool) {
require(purchasable == true);
purchasable = false;
PurchaseLocked();
return true;
}
function unlockPurchase() onlyOwner public returns (bool) {
require(purchasable == false);
purchasable = true;
PurchaseUnlocked();
return true;
}
function setExchangeRate(uint256 newExchangeRate) onlyOwner public returns (bool) {
require(newExchangeRate > 0);
exchangeRate = newExchangeRate;
UpdatedExchangeRate(newExchangeRate);
return true;
}
function setMinimumEtherAmount(uint256 newMinimumEtherAmount) onlyOwner public returns (bool) {
require(newMinimumEtherAmount > 0);
minimumEtherAmount = newMinimumEtherAmount;
return true;
}
function setVendorWallet(address newVendorWallet) onlyOwner public returns (bool) {
require(newVendorWallet != 0x0);
vendorWallet = newVendorWallet;
return true;
}
function buyIPC() payable isPurchasable whenNotPaused public returns (uint256) {
require(msg.value >= minimumEtherAmount);
uint256 tokenAmount = safeMul(msg.value, exchangeRate);
tokenAmount = safeDiv(tokenAmount, 1 ether);
require(allowance[vendorWallet][this] >= tokenAmount);
balanceOf[msg.sender] = safeAdd(balanceOf[msg.sender], tokenAmount);
balanceOf[vendorWallet] = safeSub(balanceOf[vendorWallet], tokenAmount);
Purchase(msg.sender, msg.value, tokenAmount);
return tokenAmount;
}
function () payable public {
buyIPC();
}
}
contract Withdrawable is Ownable {
function withdrawToken(address beneficiary, address _token) onlyOwner public {
ERC20 token = ERC20(_token);
uint256 amount = token.balanceOf(this);
require(amount>0);
token.transfer(beneficiary, amount);
}
function withdrawEther(address beneficiary, uint256 etherAmount) onlyOwner public {
beneficiary.transfer(etherAmount);
}
}
contract IPCToken is UpgradeableToken, PurchasableToken, Withdrawable {
string public name = "International PayReward Coin";
string public symbol = "IPC";
uint8 public decimals = 12;
uint256 public cr = 264000000 * (10 ** uint256(decimals));
uint256 public rew = 110000000 * (10 ** uint256(decimals));
uint256 public dev = 66000000 * (10 ** uint256(decimals));
uint256 public totalSupply = cr + dev + rew;
event UpdatedTokenInformation(string newName, string newSymbol);
function IPCToken (
address addressOfCrBen,
address addressOfRew,
address addressOfDev
) public UpgradeableToken(msg.sender) {
balanceOf[addressOfCrBen] = cr;
balanceOf[addressOfRew] = rew;
balanceOf[addressOfDev] = dev;
}
function setTokenInformation(string _name, string _symbol) onlyOwner public {
name = _name;
symbol = _symbol;
UpdatedTokenInformation(name, symbol);
}
}