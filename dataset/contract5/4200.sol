pragma solidity ^0.4.19;
contract SafeMath {
function safeMul(uint a, uint b) internal returns (uint) {
uint c = a * b;
assert(a == 0 || c / a == b);
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
}
contract CreatorEnabled {
address public creator = 0x0;
modifier onlyCreator() { require(msg.sender==creator); _; }
function changeCreator(address _to) public onlyCreator {
creator = _to;
}
}
contract StdToken is SafeMath {
mapping(address => uint256) public balances;
mapping (address => mapping (address => uint256)) internal allowed;
uint public totalSupply = 0;
event Transfer(address indexed _from, address indexed _to, uint256 _value);
event Approval(address indexed _owner, address indexed _spender, uint256 _value);
function transfer(address _to, uint256 _value) onlyPayloadSize(2 * 32) returns(bool) {
require(0x0!=_to);
balances[msg.sender] = safeSub(balances[msg.sender],_value);
balances[_to] = safeAdd(balances[_to],_value);
Transfer(msg.sender, _to, _value);
return true;
}
function transferFrom(address _from, address _to, uint256 _value) returns(bool) {
require(0x0!=_to);
balances[_to] = safeAdd(balances[_to],_value);
balances[_from] = safeSub(balances[_from],_value);
allowed[_from][msg.sender] = safeSub(allowed[_from][msg.sender],_value);
Transfer(_from, _to, _value);
return true;
}
function balanceOf(address _owner) constant returns (uint256) {
return balances[_owner];
}
function approve(address _spender, uint256 _value) returns (bool) {
require((_value == 0) || (allowed[msg.sender][_spender] == 0));
allowed[msg.sender][_spender] = _value;
Approval(msg.sender, _spender, _value);
return true;
}
function allowance(address _owner, address _spender) constant returns (uint256) {
return allowed[_owner][_spender];
}
modifier onlyPayloadSize(uint _size) {
require(msg.data.length >= _size + 4);
_;
}
}
contract IGoldFee {
function calculateFee(address _sender, bool _isMigrationStarted, bool _isMigrationFinished, uint _mntpBalance, uint _value) public constant returns(uint);
}
contract GoldFee is CreatorEnabled {
mapping(address => bool) exceptAddresses;
function GoldFee() {
creator = msg.sender;
}
function getMin(uint out)returns (uint) {
uint minFee = (2 * 1 ether) / 1000;
if (out < minFee) {
return minFee;
}
return out;
}
function getMax(uint out)returns (uint) {
uint maxFee = (2 * 1 ether) / 100;
if (out >= maxFee) {
return maxFee;
}
return out;
}
function calculateFee(address _sender, bool _isMigrationStarted, bool _isMigrationFinished, uint _mntpBalance, uint _value) public constant returns(uint)
{
return 0;
if (exceptAddresses[_sender]) {
return 0;
}
if (_isMigrationFinished) {
return (_value / 100);
}
if (_mntpBalance >= (10000 * 1 ether)) {
return getMax((_value / 100) / 30);
}
if (_mntpBalance >= (1000 * 1 ether)) {
return getMin((_value / 100) / 30);
}
if (_mntpBalance >= (10 * 1 ether)) {
return getMin((_value / 100) / 3);
}
return getMin(_value / 100);
}
function addExceptAddress(address _address) public onlyCreator {
exceptAddresses[_address] = true;
}
function removeExceptAddress(address _address) public onlyCreator {
exceptAddresses[_address] = false;
}
function isAddressExcept(address _address) public constant returns(bool) {
return exceptAddresses[_address];
}
}
contract Gold is StdToken, CreatorEnabled {
string public constant name = "GoldMint GOLD cryptoasset";
string public constant symbol = "GOLD";
uint8 public constant decimals = 18;
address public migrationAddress = 0x0;
address public storageControllerAddress = 0x0;
address public goldmintTeamAddress = 0x0;
IMNTP public mntpToken;
IGoldFee public goldFee;
bool public transfersLocked = false;
bool public contractLocked = false;
bool public migrationStarted = false;
bool public migrationFinished = false;
uint public totalIssued = 0;
uint public totalBurnt = 0;
modifier onlyMigration() { require(msg.sender == migrationAddress); _; }
modifier onlyMigrationOrStorageController() { require(msg.sender == migrationAddress || msg.sender == storageControllerAddress); _; }
modifier onlyCreatorOrStorageController() { require(msg.sender == creator || msg.sender == storageControllerAddress); _; }
modifier onlyIfUnlocked() { require(!transfersLocked); _; }
function Gold(address _mntpContractAddress, address _goldmintTeamAddress, address _goldFeeAddress) public {
creator = msg.sender;
mntpToken = IMNTP(_mntpContractAddress);
goldmintTeamAddress = _goldmintTeamAddress;
goldFee = IGoldFee(_goldFeeAddress);
}
function setCreator(address _address) public onlyCreator {
creator = _address;
}
function lockContract(bool _contractLocked) public onlyCreator {
contractLocked = _contractLocked;
}
function setStorageControllerContractAddress(address _address) public onlyCreator {
storageControllerAddress = _address;
}
function setMigrationContractAddress(address _migrationAddress) public onlyCreator {
migrationAddress = _migrationAddress;
}
function setGoldmintTeamAddress(address _teamAddress) public onlyCreator {
goldmintTeamAddress = _teamAddress;
}
function setGoldFeeAddress(address _goldFeeAddress) public onlyCreator {
goldFee = IGoldFee(_goldFeeAddress);
}
function issueTokens(address _who, uint _tokens) public onlyCreatorOrStorageController {
require(!contractLocked);
balances[_who] = safeAdd(balances[_who],_tokens);
totalSupply = safeAdd(totalSupply,_tokens);
totalIssued = safeAdd(totalIssued,_tokens);
Transfer(0x0, _who, _tokens);
}
function burnTokens(address _who, uint _tokens) public onlyMigrationOrStorageController {
require(!contractLocked);
balances[_who] = safeSub(balances[_who],_tokens);
totalSupply = safeSub(totalSupply,_tokens);
totalBurnt = safeAdd(totalBurnt,_tokens);
}
function startMigration() public onlyMigration {
require(false == migrationStarted);
migrationStarted = true;
}
function finishMigration() public onlyMigration {
require(true == migrationStarted);
migrationFinished = true;
}
function lockTransfer(bool _lock) public onlyMigration {
transfersLocked = _lock;
}
function transfer(address _to, uint256 _value) public onlyIfUnlocked onlyPayloadSize(2 * 32) returns(bool) {
uint yourCurrentMntpBalance = mntpToken.balanceOf(msg.sender);
uint fee = goldFee.calculateFee(msg.sender, migrationStarted, migrationFinished, yourCurrentMntpBalance, _value);
uint sendThis = _value;
if (0 != fee) {
sendThis = safeSub(_value,fee);
if (migrationStarted) {
super.transfer(goldmintTeamAddress, fee);
} else {
super.transfer(migrationAddress, fee);
}
}
return super.transfer(_to, sendThis);
}
function transferFrom(address _from, address _to, uint256 _value) public onlyIfUnlocked returns(bool) {
uint yourCurrentMntpBalance = mntpToken.balanceOf(_from);
uint fee = goldFee.calculateFee(msg.sender, migrationStarted, migrationFinished, yourCurrentMntpBalance, _value);
if (0 != fee) {
if (migrationStarted) {
super.transferFrom(_from, goldmintTeamAddress, fee);
} else {
super.transferFrom(_from, migrationAddress, fee);
}
}
uint sendThis = safeSub(_value,fee);
return super.transferFrom(_from, _to, sendThis);
}
function transferRewardWithoutFee(address _to, uint _value) public onlyMigration onlyPayloadSize(2*32) {
require(0x0!=_to);
balances[migrationAddress] = safeSub(balances[migrationAddress],_value);
balances[_to] = safeAdd(balances[_to],_value);
Transfer(migrationAddress, _to, _value);
}
function rescueAllRewards(address _to) public onlyCreator {
require(0x0!=_to);
uint totalReward = balances[migrationAddress];
balances[_to] = safeAdd(balances[_to],totalReward);
balances[migrationAddress] = 0;
Transfer(migrationAddress, _to, totalReward);
}
function getTotalIssued() public constant returns (uint) {
return totalIssued;
}
function getTotalBurnt() public constant returns (uint) {
return totalBurnt;
}
}
contract IMNTP is StdToken {
function lockTransfer(bool _lock);
function issueTokens(address _who, uint _tokens);
function burnTokens(address _who, uint _tokens);
}
contract GoldmintMigration is CreatorEnabled {
IMNTP public mntpToken;
Gold public goldToken;
address public managerAddress = 0x0;
event MntpHold(address _ethAddress, string _gmAddress, uint256 _amount);
event MntpUnhold(address _ethAddress, uint256 _amount);
event GoldHold(address _ethAddress, string _gmAddress, uint256 _amount);
event GoldUnhold(address _ethAddress, uint256 _amount);
modifier onlyManagerOrCreator() { require(msg.sender == managerAddress || msg.sender == creator); _; }
function GoldmintMigration(address _mntpContractAddress, address _goldContractAddress) public {
creator = msg.sender;
require(_mntpContractAddress != 0);
require(_goldContractAddress != 0);
mntpToken = IMNTP(_mntpContractAddress);
goldToken = Gold(_goldContractAddress);
}
function setManagerAddress(address _address) public onlyCreator {
managerAddress = _address;
}
function lockMntpTransfers(bool _lock) public onlyCreator {
mntpToken.lockTransfer(_lock);
}
function lockGoldTransfers(bool _lock) public onlyCreator {
goldToken.lockTransfer(_lock);
}
function unholdMntp(address _ethAddress, uint _amount) public onlyManagerOrCreator {
uint balance = mntpToken.balanceOf(address(this));
require(balance >= _amount);
mntpToken.transfer(_ethAddress, _amount);
MntpUnhold(_ethAddress, _amount);
}
function unholdGold(address _ethAddress, uint _amount) public onlyManagerOrCreator {
uint balance = goldToken.balanceOf(address(this));
require(balance >= _amount);
goldToken.transfer(_ethAddress, _amount);
GoldUnhold(_ethAddress, _amount);
}
function() external payable {
revert();
}
}