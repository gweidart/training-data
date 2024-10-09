pragma solidity ^0.4.18;
contract Controlled {
address public controller;
function Controlled() public {
controller = msg.sender;
}
modifier onlyController() {
require(msg.sender == controller);
_;
}
function changeController(address _newController) public onlyController {
controller = _newController;
}
}
library SafeMath {
function mul(uint a, uint b) internal pure returns (uint) {
uint c = a * b;
assert(a == 0 || c / a == b);
return c;
}
function div(uint a, uint b) internal pure returns (uint) {
uint c = a / b;
return c;
}
function sub(uint a, uint b) internal pure returns (uint) {
assert(b <= a);
return a - b;
}
function add(uint a, uint b) internal pure returns (uint) {
uint c = a + b;
assert(c >= a);
return c;
}
}
contract tokenRecipient {
function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) public;
}
contract ERC20Token {
uint256 public totalSupply;
function balanceOf(address _owner) constant public returns (uint256 balance);
function transfer(address _to, uint256 _value) public returns (bool success);
function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
function approve(address _spender, uint256 _value) public returns (bool success);
function allowance(address _owner, address _spender) constant public returns (uint256 remaining);
event Transfer(address indexed _from, address indexed _to, uint256 _value);
event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}
contract AddressLimit {
modifier notContractAddress(address _addr) {
require (!isContractAddress(_addr));
_;
}
function isContractAddress(address _addr) internal constant returns(bool) {
uint256 size;
assembly {
size := extcodesize(_addr)
}
return size > 0;
}
}
contract standardToken is ERC20Token, AddressLimit {
mapping (address => uint256) balances;
mapping (address => mapping (address => uint256)) allowances;
bool public tokenFrozen = true;
function balanceOf(
address _owner)
constant
public
returns (uint256)
{
return balances[_owner];
}
function transfer(
address _to,
uint256 _value)
public
notContractAddress(_to)
returns (bool success)
{
require (!tokenFrozen);
require (balances[msg.sender] >= _value);
require (balances[_to] + _value >= balances[_to]);
balances[msg.sender] -= _value;
balances[_to] += _value;
Transfer(msg.sender, _to, _value);
return true;
}
function approve(
address _spender,
uint256 _value)
public
returns (bool success)
{
require (!tokenFrozen);
allowances[msg.sender][_spender] = _value;
Approval(msg.sender, _spender, _value);
return true;
}
function approveAndCall(
address _spender,
uint256 _value,
bytes _extraData)
public
returns (bool success)
{
require (!tokenFrozen);
tokenRecipient spender = tokenRecipient(_spender);
approve(_spender, _value);
spender.receiveApproval(msg.sender, _value, this, _extraData);
return true;
}
function transferFrom(
address _from,
address _to,
uint256 _value)
public
notContractAddress(_to)
returns (bool success)
{
require (!tokenFrozen);
require (balances[_from] >= _value);
require (balances[_to] + _value >= balances[_to]);
require (_value <= allowances[_from][msg.sender]);
balances[_from] -= _value;
balances[_to] += _value;
allowances[_from][msg.sender] -= _value;
Transfer(_from, _to, _value);
return true;
}
function allowance(
address _owner,
address _spender)
constant
public
returns (uint256)
{
return allowances[_owner][_spender];
}
}
contract UseChainToken is standardToken, Controlled {
using SafeMath for uint;
string constant public name   = "UseChainToken";
string constant public symbol = "UST";
uint constant public decimals = 18;
uint256 public totalSupply = 0;
uint256 constant public topTotalSupply = 2*10**7*10**decimals;
uint public corporateSupply        = percent(topTotalSupply, 20);
uint public privatePlacementSupply = percent(topTotalSupply, 8);
uint public privatePresaleSupply   = percent(topTotalSupply, 12);
uint public publicSaleSupply       = percent(topTotalSupply, 10);
uint public ecoFundSupply          = percent(topTotalSupply, 50);
uint public softCap                = percent(topTotalSupply, 6);
uint public startCrowdsaleTime;
uint public stopCrowdsaleTime;
address public walletAddress;
bool    public finalized;
enum stageAt {
notStart,
privatePlacement,
privatePresale,
publicSale,
finalState
}
modifier onlyWalletAddr() {
require (walletAddress == msg.sender);
_;
}
function() public payable {
require(!finalized);
depositToken(msg.value);
if(this.balance >= 10 ether) {
walletAddress.transfer(this.balance);
}
}
function UseChainToken(uint _startCrowdsaleTime, uint _stopCrowdsaleTime, address _walletAddress) public {
controller = msg.sender;
startCrowdsaleTime = _startCrowdsaleTime;
stopCrowdsaleTime = _stopCrowdsaleTime;
walletAddress = _walletAddress;
}
function depositToken(uint _value) internal {
require(_value >= minimalRequire());
uint tokenAlloc = buyPriceAt(exchangePrice * _value);
require (tokenAlloc != 0);
mintTokens(msg.sender, tokenAlloc);
}
function mintTokens(address _to, uint _amount) internal {
require (balances[_to] + _amount >= balances[_to]);
totalSupply = totalSupply.add(_amount);
require(totalSupply <= topTotalSupply);
balances[_to] = balances[_to].add(_amount);
Transfer(0x0, _to, _amount);
}
function minimalRequire() internal constant returns(uint) {
if (stageNow() == stageAt.publicSale) {
return 1 ether;
}
if (stageNow() == stageAt.privatePresale) {
return 10 ether;
}
if (stageNow() == stageAt.privatePlacement) {
return 100 ether;
}
}
uint public publicAllocatingToken;
uint public privatePlacementAllocatingToken;
uint public privatePresaleAllocatingToken;
function buyPriceAt(uint256 _tokenAllocWithoutDiscount) internal returns(uint) {
if (stageNow() == stageAt.publicSale) {
publicAllocatingToken = publicAllocatingToken.add(_tokenAllocWithoutDiscount);
require(publicAllocatingToken <= publicSaleSupply);
return _tokenAllocWithoutDiscount;
}
if (stageNow() == stageAt.privatePresale) {
uint _privatePresaleAlloc = _tokenAllocWithoutDiscount + percent(_tokenAllocWithoutDiscount, 5);
privatePresaleAllocatingToken = privatePresaleAllocatingToken.add(_privatePresaleAlloc);
require(privatePresaleAllocatingToken <= privatePresaleSupply);
return _privatePresaleAlloc;
}
if (stageNow() == stageAt.privatePlacement) {
uint _privatePlacementAlloc = _tokenAllocWithoutDiscount + percent(_tokenAllocWithoutDiscount, 10);
privatePlacementAllocatingToken = privatePlacementAllocatingToken.add(_privatePlacementAlloc);
require(privatePlacementAllocatingToken <= privatePlacementSupply);
return _privatePlacementAlloc;
}
if (stageNow() == stageAt.notStart) {
return 0;
}
if (stageNow() == stageAt.finalState) {
return 0;
}
}
function stageNow() constant internal returns (stageAt) {
if (getTimestamp() < startCrowdsaleTime) {
return stageAt.notStart;
}
else if(getTimestamp() < startCrowdsaleTime + 27 days) {
return stageAt.privatePlacement;
}
else if(getTimestamp() < startCrowdsaleTime + 71 days) {
return stageAt.privatePresale;
}
else if(getTimestamp() < stopCrowdsaleTime) {
return stageAt.publicSale;
}
else {
return stageAt.finalState;
}
}
function percent(uint _token, uint _percentage) internal pure returns (uint) {
return _percentage.mul(_token).div(100);
}
uint public exchangePrice = 90;
function setExchangePrice( uint _price) public onlyController returns(uint) {
exchangePrice = _price;
}
function getTimestamp() internal constant returns(uint) {
return now;
}
function withDraw() public payable onlyController {
require (walletAddress != address(0));
walletAddress.transfer(this.balance);
}
function unfreezeTokenTransfer(bool _freeze) public onlyController {
tokenFrozen = !_freeze;
}
function setWalletAddress(address _walletAddress) public onlyWalletAddr {
walletAddress = _walletAddress;
}
function allocateTokens(address[] _owners, uint256[] _values) public onlyController {
require (_owners.length == _values.length);
for(uint i = 0; i < _owners.length ; i++){
address owner = _owners[i];
uint value = _values[i];
mintTokens(owner, value);
}
}
function allocateCorporateToken(address _corAccount, uint256 _amount) public onlyController {
require(_corAccount != address(0));
require(balances[_corAccount] + _amount <= corporateSupply);
mintTokens(_corAccount, _amount);
}
uint public ecoFundingSupply;
function allocateEcoFundToken(address[] _owners, uint256[] _values) public onlyController {
require (_owners.length == _values.length);
for(uint i = 0; i < _owners.length ; i++){
address owner = _owners[i];
uint256 value = _values[i];
ecoFundingSupply = ecoFundingSupply.add(value);
require(ecoFundingSupply <= ecoFundSupply);
mintTokens(owner, value);
}
}
function finalize() public onlyController {
require(stageNow() == stageAt.finalState);
require(totalSupply + ecoFundSupply >= softCap);
finalized = true;
}
}