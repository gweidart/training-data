pragma solidity ^0.4.15;
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
contract HasNoEther is Ownable {
function HasNoEther() payable {
require(msg.value == 0);
}
function() external {
}
function reclaimEther() external onlyOwner {
assert(owner.send(this.balance));
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
contract IRntToken {
uint256 public decimals = 18;
uint256 public totalSupply = 1000000000 * (10 ** 18);
string public name = "RNT Token";
string public code = "RNT";
function balanceOf() public constant returns (uint256 balance);
function transfer(address _to, uint _value) public returns (bool success);
function transferFrom(address _from, address _to, uint _value) public returns (bool success);
}
contract RntTokenVault is HasNoEther, Pausable {
using SafeMath for uint256;
IRntToken public rntToken;
uint256 public accountsCount = 0;
uint256 public tokens = 0;
mapping (bytes16 => bool) public accountsStatuses;
mapping (bytes16 => uint256) public balances;
mapping (address => bool) public allowedAddresses;
mapping (address => bytes16) public tokenTransfers;
function RntTokenVault(address _rntTokenAddress){
rntToken = IRntToken(_rntTokenAddress);
}
modifier onlyAllowedAddresses {
require(msg.sender == owner || allowedAddresses[msg.sender] == true);
_;
}
modifier onlyRegisteredAccount(bytes16 _uuid) {
require(accountsStatuses[_uuid] == true);
_;
}
function getVaultBalance() onlyAllowedAddresses public constant returns (uint256) {
return rntToken.balanceOf();
}
function getTokenTransferUuid(address _address) onlyAllowedAddresses public constant returns (bytes16) {
return tokenTransfers[_address];
}
function isAllowedAddress(address _address) onlyAllowedAddresses public constant returns (bool) {
return allowedAddresses[_address];
}
function isRegisteredAccount(address _address) onlyAllowedAddresses public constant returns (bool) {
return allowedAddresses[_address];
}
function registerAccount(bytes16 _uuid) public {
accountsStatuses[_uuid] = true;
accountsCount = accountsCount.add(1);
}
function allowAddress(address _address, bool _allow) onlyOwner {
allowedAddresses[_address] = _allow;
}
function addTokensToAccount(bytes16 _uuid, uint256 _tokensCount) onlyAllowedAddresses whenNotPaused public returns (bool) {
registerAccount(_uuid);
balances[_uuid] = balances[_uuid].add(_tokensCount);
tokens = tokens.add(_tokensCount);
return true;
}
function removeTokensFromAccount(bytes16 _uuid, uint256 _tokensCount) onlyAllowedAddresses
onlyRegisteredAccount(_uuid) whenNotPaused internal returns (bool) {
balances[_uuid] = balances[_uuid].sub(_tokensCount);
return true;
}
function transferTokensToAccount(bytes16 _from, bytes16 _to, uint256 _tokensCount) onlyAllowedAddresses
onlyRegisteredAccount(_from) whenNotPaused public returns (bool) {
registerAccount(_to);
balances[_from] = balances[_from].sub(_tokensCount);
balances[_to] = balances[_to].add(_tokensCount);
return true;
}
function moveAllTokensToAddress(bytes16 _uuid, address _address) onlyAllowedAddresses
onlyRegisteredAccount(_uuid) whenNotPaused public returns (bool) {
uint256 accountBalance = balances[_uuid];
removeTokensFromAccount(_uuid, accountBalance);
rntToken.transfer(_address, accountBalance);
tokens = tokens.sub(accountBalance);
tokenTransfers[_address] = _uuid;
return true;
}
function moveTokensToAddress(bytes16 _uuid, address _address, uint256 _tokensCount) onlyAllowedAddresses
onlyRegisteredAccount(_uuid) whenNotPaused public returns (bool) {
removeTokensFromAccount(_uuid, _tokensCount);
rntToken.transfer(_address, _tokensCount);
tokens = tokens.sub(_tokensCount);
tokenTransfers[_address] = _uuid;
return true;
}
function transferTokensFromVault(address _to, uint256 _tokensCount) onlyOwner public returns (bool) {
rntToken.transfer(_to, _tokensCount);
return true;
}
}
contract Destructible is Ownable {
function Destructible() payable { }
function destroy() onlyOwner public {
selfdestruct(owner);
}
function destroyAndSend(address _recipient) onlyOwner public {
selfdestruct(_recipient);
}
}
contract ICrowdsale {
function allocateTokens(address _receiver, bytes16 _customerUuid, uint256 _weiAmount) public;
}
contract RntTokenProxy is Destructible, Pausable, HasNoEther {
IRntToken public rntToken;
ICrowdsale public crowdsale;
RntTokenVault public rntTokenVault;
mapping (address => bool) public allowedAddresses;
function RntTokenProxy(address _tokenAddress, address _vaultAddress, address _defaultAllowed, address _crowdsaleAddress) {
rntToken = IRntToken(_tokenAddress);
rntTokenVault = RntTokenVault(_vaultAddress);
crowdsale = ICrowdsale(_crowdsaleAddress);
allowedAddresses[_defaultAllowed] = true;
}
modifier onlyAllowedAddresses {
require(msg.sender == owner || allowedAddresses[msg.sender] == true);
_;
}
function allowAddress(address _address, bool _allow) onlyOwner external {
allowedAddresses[_address] = _allow;
}
function addTokens(bytes16 _uuid, uint256 _tokensCount) onlyAllowedAddresses whenNotPaused external {
rntTokenVault.addTokensToAccount(_uuid, _tokensCount);
rntToken.transferFrom(owner, address(rntTokenVault), _tokensCount);
}
function moveTokens(address _to, bytes16 _uuid, uint256 _tokensCount) onlyAllowedAddresses whenNotPaused external {
rntTokenVault.moveTokensToAddress(_uuid, _to, _tokensCount);
}
function moveAllTokens(address _to, bytes16 _uuid) onlyAllowedAddresses whenNotPaused external {
rntTokenVault.moveAllTokensToAddress(_uuid, _to);
}
function allocate(address _receiver, bytes16 _customerUuid, uint256 _weiAmount) onlyAllowedAddresses whenNotPaused external {
crowdsale.allocateTokens(_receiver, _customerUuid, _weiAmount);
}
}