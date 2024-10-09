pragma solidity ^0.4.13;
contract SafeMath {
function safeMul(uint256 a, uint256 b) internal constant returns (uint256 ) {
uint256 c = a * b;
assert(a == 0 || c / a == b);
return c;
}
function safeDiv(uint256 a, uint256 b) internal constant returns (uint256 ) {
assert(b > 0);
uint256 c = a / b;
assert(a == b * c + a % b);
return c;
}
function safeSub(uint256 a, uint256 b) internal constant returns (uint256 ) {
assert(b <= a);
return a - b;
}
function safeAdd(uint256 a, uint256 b) internal constant returns (uint256 ) {
uint256 c = a + b;
assert(c >= a);
return c;
}
}
contract ERC20 {
uint256 public totalSupply;
function balanceOf(address _owner) constant returns (uint256 balance);
function transfer(address _to, uint256 _value) returns (bool success);
function transferFrom(address _from, address _to, uint256 _value) returns (bool success);
function approve(address _spender, uint256 _value) returns (bool success);
function allowance(address _owner, address _spender) constant returns (uint256 remaining);
event Transfer(address indexed _from, address indexed _to, uint256 _value);
event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}
contract StandardToken is ERC20, SafeMath {
mapping(address => uint256) balances;
mapping(address => mapping(address => uint256)) allowed;
function balanceOf(address _owner) constant returns (uint256 balance) {
return balances[_owner];
}
function transfer(address _to, uint256 _value) returns (bool) {
if (balances[msg.sender] >= _value && _value > 0) {
balances[msg.sender] = safeSub(balances[msg.sender], _value);
balances[_to] = safeAdd(balances[_to], _value);
Transfer(msg.sender, _to, _value);
return true;
} else return false;
}
function transferFrom(address _from, address _to, uint256 _value) returns (bool) {
if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0) {
balances[_to] = safeAdd(balances[_to], _value);
balances[_from] = safeSub(balances[_from], _value);
allowed[_from][msg.sender] = safeSub(allowed[_from][msg.sender], _value);
Transfer(_from, _to, _value);
return true;
} else return false;
}
function approve(address _spender, uint256 _value) returns (bool) {
allowed[msg.sender][_spender] = _value;
Approval(msg.sender, _spender, _value);
return true;
}
function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
return allowed[_owner][_spender];
}
}
contract Ownable {
address public owner;
address public pendingOwner;
function Ownable() {
owner = msg.sender;
}
modifier onlyOwner() {
require(msg.sender == owner);
_;
}
function transferOwnership(address newOwner) onlyOwner {
pendingOwner = newOwner;
}
function claimOwnership() {
if (msg.sender == pendingOwner) {
owner = pendingOwner;
pendingOwner = 0;
}
}
}
contract MultiOwnable {
mapping (address => bool) ownerMap;
address[] public owners;
event OwnerAdded(address indexed _newOwner);
event OwnerRemoved(address indexed _oldOwner);
modifier onlyOwner() {
require(isOwner(msg.sender));
_;
}
function MultiOwnable() {
address owner = msg.sender;
ownerMap[owner] = true;
owners.push(owner);
}
function ownerCount() public constant returns (uint256) {
return owners.length;
}
function isOwner(address owner) public constant returns (bool) {
return ownerMap[owner];
}
function addOwner(address owner) onlyOwner returns (bool) {
if (!isOwner(owner) && owner != 0) {
ownerMap[owner] = true;
owners.push(owner);
OwnerAdded(owner);
return true;
} else return false;
}
function removeOwner(address owner) onlyOwner returns (bool) {
if (isOwner(owner)) {
ownerMap[owner] = false;
for (uint i = 0; i < owners.length - 1; i++) {
if (owners[i] == owner) {
owners[i] = owners[owners.length - 1];
break;
}
}
owners.length -= 1;
OwnerRemoved(owner);
return true;
} else return false;
}
}
contract Pausable is Ownable {
bool public paused;
modifier ifNotPaused {
require(!paused);
_;
}
modifier ifPaused {
require(paused);
_;
}
function pause() external onlyOwner {
paused = true;
}
function resume() external onlyOwner ifPaused {
paused = false;
}
}
contract TokenSpender {
function receiveApproval(address _from, uint256 _value);
}
contract CommonBsToken is StandardToken, MultiOwnable {
string public name;
string public symbol;
uint256 public totalSupply;
uint8 public decimals = 18;
string public version = 'v0.1';
address public creator;
address public seller;
uint256 public saleLimit;
uint256 public tokensSold;
uint256 public totalSales;
bool public locked;
event Sell(address indexed _seller, address indexed _buyer, uint256 _value);
event SellerChanged(address indexed _oldSeller, address indexed _newSeller);
event Lock();
event Unlock();
event Burn(address indexed _burner, uint256 _value);
modifier onlyUnlocked() {
require(isOwner(msg.sender) || !locked);
_;
}
function CommonBsToken(
address _seller,
string _name,
string _symbol,
uint256 _totalSupplyNoDecimals,
uint256 _saleLimitNoDecimals
) public MultiOwnable() {
locked = true;
creator = msg.sender;
seller = _seller;
name = _name;
symbol = _symbol;
totalSupply = _totalSupplyNoDecimals * 1e18;
saleLimit = _saleLimitNoDecimals * 1e18;
balances[seller] = totalSupply;
Transfer(0x0, seller, totalSupply);
}
function changeSeller(address newSeller) onlyOwner public returns (bool) {
require(newSeller != 0x0 && seller != newSeller);
address oldSeller = seller;
uint256 unsoldTokens = balances[oldSeller];
balances[oldSeller] = 0;
balances[newSeller] = safeAdd(balances[newSeller], unsoldTokens);
Transfer(oldSeller, newSeller, unsoldTokens);
seller = newSeller;
SellerChanged(oldSeller, newSeller);
return true;
}
function sellNoDecimals(address _to, uint256 _value) public returns (bool) {
return sell(_to, _value * 1e18);
}
function sell(address _to, uint256 _value) onlyOwner public returns (bool) {
if (saleLimit > 0) require(safeSub(saleLimit, safeAdd(tokensSold, _value)) >= 0);
require(_to != address(0));
require(_value > 0);
require(_value <= balances[seller]);
balances[seller] = safeSub(balances[seller], _value);
balances[_to] = safeAdd(balances[_to], _value);
Transfer(seller, _to, _value);
tokensSold = safeAdd(tokensSold, _value);
totalSales = safeAdd(totalSales, 1);
Sell(seller, _to, _value);
return true;
}
function transfer(address _to, uint256 _value) onlyUnlocked public returns (bool) {
return super.transfer(_to, _value);
}
function transferFrom(address _from, address _to, uint256 _value) onlyUnlocked public returns (bool) {
return super.transferFrom(_from, _to, _value);
}
function lock() onlyOwner public {
locked = true;
Lock();
}
function unlock() onlyOwner public {
locked = false;
Unlock();
}
function burn(uint256 _value) public returns (bool) {
require(_value > 0);
require(_value <= balances[msg.sender]);
balances[msg.sender] = safeSub(balances[msg.sender], _value) ;
totalSupply = safeSub(totalSupply, _value);
Transfer(msg.sender, 0x0, _value);
Burn(msg.sender, _value);
return true;
}
function approveAndCall(address _spender, uint256 _value) public {
TokenSpender spender = TokenSpender(_spender);
if (approve(_spender, _value)) {
spender.receiveApproval(msg.sender, _value);
}
}
function () payable {
revert();
}
}
contract CommonBsCrowdsale is SafeMath, Ownable, Pausable {
struct Backer {
uint256 weiReceived;
uint256 tokensSent;
}
mapping(address => Backer) public backers;
CommonBsToken public token;
address public beneficiary;
uint256 public minContributionWei = 0.0001 ether;
uint256 public maxCapWei = 120000 ether;
uint256 public tokensPerWei = 50;
uint256 public bonusTokensLeft = 1200000 ether;
struct Stage {
uint256 fromTokens;
uint256 toTokens;
uint256 price;
}
Stage[] public stages;
uint public startTime = now;
uint public endTime   = 1516881600;
uint256 public totalInWei         = 0;
uint256 public totalTokensSold    = 0;
uint256 public totalEthSales      = 0;
uint256 public weiReceived        = 0;
uint public finalizedTime = 0;
bool public saleEnabled = true;
event BeneficiaryChanged(address indexed _oldAddress, address indexed _newAddress);
event EthReceived(address indexed _buyer, uint256 _amountWei);
modifier ifUnderMaxCap() {
require(!isMaxCapReached());
_;
}
function CommonBsCrowdsale(address _token, address _beneficiary, address _owner) {
token = CommonBsToken(_token);
beneficiary = _beneficiary;
owner = _owner != 0 ? _owner : msg.sender;
addNextStage(1, 75);
addNextStage(2, 67);
addNextStage(3, 60);
addNextStage(4, 55);
addNextStage(5, 52);
addNextStage(6, 50);
}
function addNextStage(uint _maxMilTokens, uint256 _stagePrice) internal {
stages.push(Stage(
toMilTokens(_maxMilTokens - 1),
toMilTokens(_maxMilTokens),
_stagePrice
));
}
function toMilTokens(uint _num) internal view returns (uint256) {
return safeMul(_num, 1000000 ether);
}
function getNow() public constant returns (uint) {
return now;
}
function setSaleEnabled(bool _enabled) public onlyOwner {
saleEnabled = _enabled;
}
function setBeneficiary(address _beneficiary) public onlyOwner {
BeneficiaryChanged(beneficiary, _beneficiary);
beneficiary = _beneficiary;
}
function() public payable {
if (saleEnabled) sellTokensForEth(msg.sender, msg.value);
}
function sellTokensForEth(address _buyer, uint256 _amountWei) internal ifNotPaused ifUnderMaxCap {
require(_amountWei >= minContributionWei);
totalInWei = safeAdd(totalInWei, _amountWei);
weiReceived = safeAdd(weiReceived, _amountWei);
require(totalInWei <= maxCapWei);
uint256 tokensE18 = weiToTokens(_amountWei);
require(token.sell(_buyer, tokensE18));
totalTokensSold = safeAdd(totalTokensSold, tokensE18);
totalEthSales++;
Backer backer = backers[_buyer];
backer.tokensSent = safeAdd(backer.tokensSent, tokensE18);
backer.weiReceived = safeAdd(backer.weiReceived, _amountWei);
EthReceived(_buyer, _amountWei);
}
function weiToTokens(uint256 _amountWei) public constant returns (uint256) {
uint256 price = tokensPerWei;
if (isSaleOn()) {
for (uint i = 0; i < stages.length; i++) {
var s = stages[i];
if (s.fromTokens <= totalTokensSold && totalTokensSold <= s.toTokens) {
price = s.price;
break;
}
}
}
return safeMul(_amountWei, price);
}
function stageCount() public constant returns (uint) {
return stages.length;
}
function isMaxCapReached() public constant returns (bool) {
return totalInWei >= maxCapWei;
}
function isSaleOn() public constant returns (bool) {
uint _now = getNow();
return startTime <= _now && _now <= endTime;
}
function isSaleOver() public constant returns (bool) {
return getNow() > endTime;
}
function isFinalized() public constant returns (bool) {
return finalizedTime > 0;
}
function finalize() public onlyOwner {
require(isMaxCapReached() || isSaleOver());
beneficiary.transfer(this.balance);
finalizedTime = getNow();
}
}
contract CrowdsaleDeployer {
CommonBsToken public token;
CommonBsCrowdsale public crowdsale;
function CrowdsaleDeployer() public {
token = new CommonBsToken(
0x48eF88089e5A7C6f538E90E0d5Fffa38277fD98A,
'X full',
'X',
10000000,
7200000
);
crowdsale = new CommonBsCrowdsale(
token,
0x3dfa0bDDb80f771f715DEA1A7592Ce3Fc9bF2E69,
msg.sender
);
token.addOwner(msg.sender);
token.addOwner(crowdsale);
}
}