pragma solidity ^0.4.21;
contract Ownable {
address public owner;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
function Ownable() public {
owner = msg.sender;
}
modifier onlyOwner() {
require(msg.sender == owner);
_;
}
function transferOwnership(address newOwner) public onlyOwner {
require(newOwner != address(0));
emit OwnershipTransferred(owner, newOwner);
owner = newOwner;
}
}
library SafeMath {
function mul(uint256 a, uint256 b) internal pure returns (uint256) {
if (a == 0) {
return 0;
}
uint256 c = a * b;
assert(c / a == b);
return c;
}
function div(uint256 a, uint256 b) internal pure returns (uint256) {
uint256 c = a / b;
return c;
}
function sub(uint256 a, uint256 b) internal pure returns (uint256) {
assert(b <= a);
return a - b;
}
function add(uint256 a, uint256 b) internal pure returns (uint256) {
uint256 c = a + b;
assert(c >= a);
return c;
}
}
contract ERC20Basic {
function totalSupply() public view returns (uint256);
function balanceOf(address who) public view returns (uint256);
function transfer(address to, uint256 value) public returns (bool);
event Transfer(address indexed from, address indexed to, uint256 value);
}
contract BasicToken is ERC20Basic {
using SafeMath for uint256;
mapping(address => uint256) balances;
uint256 totalSupply_;
function totalSupply() public view returns (uint256) {
return totalSupply_;
}
function transfer(address _to, uint256 _value) public returns (bool) {
require(_to != address(0));
require(_value <= balances[msg.sender]);
balances[msg.sender] = balances[msg.sender].sub(_value);
balances[_to] = balances[_to].add(_value);
emit Transfer(msg.sender, _to, _value);
return true;
}
function balanceOf(address _owner) public view returns (uint256 balance) {
return balances[_owner];
}
}
contract ERC20 is ERC20Basic {
function allowance(address owner, address spender) public view returns (uint256);
function transferFrom(address from, address to, uint256 value) public returns (bool);
function approve(address spender, uint256 value) public returns (bool);
event Approval(address indexed owner, address indexed spender, uint256 value);
}
contract StandardToken is ERC20, BasicToken {
mapping (address => mapping (address => uint256)) internal allowed;
function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
require(_to != address(0));
require(_value <= balances[_from]);
require(_value <= allowed[_from][msg.sender]);
balances[_from] = balances[_from].sub(_value);
balances[_to] = balances[_to].add(_value);
allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
emit Transfer(_from, _to, _value);
return true;
}
function approve(address _spender, uint256 _value) public returns (bool) {
allowed[msg.sender][_spender] = _value;
emit Approval(msg.sender, _spender, _value);
return true;
}
function allowance(address _owner, address _spender) public view returns (uint256) {
return allowed[_owner][_spender];
}
function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
return true;
}
function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
uint oldValue = allowed[msg.sender][_spender];
if (_subtractedValue > oldValue) {
allowed[msg.sender][_spender] = 0;
} else {
allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
}
emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
return true;
}
}
contract MintableToken is StandardToken, Ownable {
event Mint(address indexed to, uint256 amount);
event MintFinished();
bool public mintingFinished = false;
modifier canMint() {
require(!mintingFinished);
_;
}
function mint(address _to, uint256 _amount) onlyOwner canMint public returns (bool) {
totalSupply_ = totalSupply_.add(_amount);
balances[_to] = balances[_to].add(_amount);
emit Mint(_to, _amount);
emit Transfer(address(0), _to, _amount);
return true;
}
function finishMinting() onlyOwner canMint public returns (bool) {
mintingFinished = true;
emit MintFinished();
return true;
}
}
contract BurnableToken is MintableToken {
event Burn(address indexed burner, uint256 value);
function burn(uint256 _value) public {
require(_value <= balances[msg.sender]);
address burner = msg.sender;
balances[burner] = balances[burner].sub(_value);
totalSupply_ = totalSupply_.sub(_value);
emit Burn(burner, _value);
emit Transfer(burner, address(0), _value);
}
}
contract PPToken is BurnableToken{
using SafeMath for uint256;
string public constant name = "PayPortalToken";
string public constant symbol = "PPTL";
uint32 public constant decimals = 18;
uint256 public freezTime;
address internal saleAgent;
mapping(address => uint256) preSaleBalances;
event PreSaleTransfer(address indexed from, address indexed to, uint256 value);
function PPToken(uint256 initialSupply, uint256 _freezTime) public{
require(initialSupply > 0 && now <= _freezTime);
totalSupply_ = initialSupply * 10 ** uint256(decimals);
balances[owner] = totalSupply_;
emit Mint(owner, totalSupply_);
emit Transfer(0x0, owner, totalSupply_);
freezTime = _freezTime;
saleAgent = owner;
}
modifier onlySaleAgent() {
require(msg.sender == saleAgent);
_;
}
function burnRemain() public onlySaleAgent {
uint256 _remSupply = balances[owner];
balances[owner] = 0;
totalSupply_ = totalSupply_.sub(_remSupply);
emit Burn(owner, _remSupply);
emit Transfer(owner, address(0), _remSupply);
mintingFinished = true;
emit MintFinished();
}
function setSaleAgent(address _saleAgent) public onlyOwner{
require(_saleAgent != address(0));
saleAgent = _saleAgent;
}
function setFreezTime(uint256 _freezTime) public onlyOwner{
freezTime = _freezTime;
}
function saleTokens(address _to, uint256 _value) public onlySaleAgent returns (bool)
{
require(_to != address(0));
require(_value <= balances[owner]);
balances[owner] = balances[owner].sub(_value);
if(now > freezTime){
balances[_to] = balances[_to].add(_value);
}
else{
preSaleBalances[_to] = preSaleBalances[_to].add(_value);
}
emit Transfer(msg.sender, _to, _value);
return true;
}
function preSaleBalancesOf(address _owner) public view returns (uint256)
{
return preSaleBalances[_owner];
}
function transferPreSaleBalance(address _to, uint256 _value)public returns (bool){
require(now > freezTime);
require(_to != address(0));
require(_value <= preSaleBalances[msg.sender]);
preSaleBalances[msg.sender] = preSaleBalances[msg.sender].sub(_value);
balances[_to] = balances[_to].add(_value);
emit Transfer(msg.sender, _to, _value);
return true;
}
}
contract Crowdsale {
using SafeMath for uint256;
PPToken public token;
address public wallet;
uint256 public rate;
uint256 public weiRaised;
event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);
function Crowdsale(uint256 _rate, address _wallet, PPToken _token) public {
require(_rate > 0);
require(_wallet != address(0));
require(_token != address(0));
rate = _rate;
wallet = _wallet;
token = _token;
}
function () external payable {
buyTokens(msg.sender);
}
function buyTokens(address _beneficiary) public payable {
uint256 weiAmount = msg.value;
_preValidatePurchase(_beneficiary, weiAmount);
uint256 totalTokens = _getTokenAmount(weiAmount);
weiRaised = weiRaised.add(weiAmount);
_processPurchase(_beneficiary, totalTokens);
emit TokenPurchase(msg.sender, _beneficiary, weiAmount, totalTokens);
_updatePurchasingState(_beneficiary, weiAmount);
_forwardFunds();
_postValidatePurchase(_beneficiary, weiAmount);
}
function _preValidatePurchase(address _beneficiary, uint256 _weiAmount) internal
{
require(_beneficiary != address(0));
require(_weiAmount != 0);
}
function _postValidatePurchase(address _beneficiary, uint256 _weiAmount) internal
{}
function _deliverTokens(address _beneficiary, uint256 _tokenAmount) internal {
token.transfer(_beneficiary, _tokenAmount);
}
function _processPurchase(address _beneficiary, uint256 _tokenAmount) internal {
_deliverTokens(_beneficiary, _tokenAmount);
}
function _updatePurchasingState(address _beneficiary, uint256 _weiAmount) internal
{}
function _getTokenAmount(uint256 _weiAmount) internal returns (uint256)
{
uint256 tokens = _weiAmount.mul(rate);
return tokens;
}
function _forwardFunds() internal {
wallet.transfer(msg.value);
}
}
contract AllowanceCrowdsale is Crowdsale {
using SafeMath for uint256;
address public tokenWallet;
function AllowanceCrowdsale(address _tokenWallet) public {
require(_tokenWallet != address(0));
tokenWallet = _tokenWallet;
}
function remainingTokens() public view returns (uint256) {
return token.balanceOf(tokenWallet);
}
function _deliverTokens(address _beneficiary, uint256 _tokenAmount) internal {
token.saleTokens(_beneficiary, _tokenAmount);
}
}
contract CappedCrowdsale is Crowdsale {
using SafeMath for uint256;
uint256 public cap;
function CappedCrowdsale(uint256 _cap) public {
require(_cap > 0);
cap = _cap;
}
function capReached() public view returns (bool) {
return weiRaised >= cap;
}
function _preValidatePurchase(address _beneficiary, uint256 _weiAmount) internal {
super._preValidatePurchase(_beneficiary, _weiAmount);
require(!capReached());
}
}
contract TimedCrowdsale is Crowdsale {
using SafeMath for uint256;
uint256 public openingTime;
uint256 public closingTime;
modifier onlyWhileOpen {
require(now >= openingTime && now <= closingTime);
_;
}
function TimedCrowdsale(uint256 _openingTime, uint256 _closingTime) public {
require(_openingTime >= now);
require(_closingTime >= _openingTime);
openingTime = _openingTime;
closingTime = _closingTime;
}
function hasClosed() public view returns (bool) {
return now > closingTime;
}
function _preValidatePurchase(address _beneficiary, uint256 _weiAmount) internal onlyWhileOpen {
super._preValidatePurchase(_beneficiary, _weiAmount);
}
}
contract FinalizableCrowdsale is TimedCrowdsale, Ownable {
using SafeMath for uint256;
bool public isFinalized = false;
event Finalized();
function finalize() onlyOwner public {
require(!isFinalized);
require(hasClosed());
finalization();
emit Finalized();
isFinalized = true;
}
function finalization() internal
{
}
}
contract WhitelistedCrowdsale is Crowdsale, Ownable {
mapping(address => bool) public whitelist;
address whiteListAgent;
function setWhiteListAgent(address _agent) public onlyOwner{
require(_agent != address(0));
whiteListAgent = _agent;
}
modifier OnlyWhiteListAgent() {
require(msg.sender == whiteListAgent);
_;
}
modifier isWhitelisted(address _beneficiary) {
require(whitelist[_beneficiary]);
_;
}
function inWhiteList(address _beneficiary) public view returns(bool){
return whitelist[_beneficiary];
}
function addToWhitelist(address _beneficiary) external OnlyWhiteListAgent {
whitelist[_beneficiary] = true;
}
function addManyToWhitelist(address[] _beneficiaries) external OnlyWhiteListAgent {
for (uint256 i = 0; i < _beneficiaries.length; i++) {
whitelist[_beneficiaries[i]] = true;
}
}
function removeFromWhitelist(address _beneficiary) external OnlyWhiteListAgent {
whitelist[_beneficiary] = false;
}
function _preValidatePurchase(address _beneficiary, uint256 _weiAmount) internal isWhitelisted(_beneficiary) {
super._preValidatePurchase(_beneficiary, _weiAmount);
}
}
contract PPTL_PrivateCrowdsale is  FinalizableCrowdsale, CappedCrowdsale, WhitelistedCrowdsale, AllowanceCrowdsale{
using SafeMath for uint256;
uint256 public bonusPercent;
uint256 public minWeiAmount;
function PPTL_PrivateCrowdsale( PPToken _token) public
Crowdsale(500, msg.sender, _token)
CappedCrowdsale((4000 ether))
TimedCrowdsale(1523836800, 1525564800)
AllowanceCrowdsale(msg.sender)
{
bonusPercent = 30;
minWeiAmount = 100 ether;
}
function finalization() internal
{
wallet.transfer(this.balance);
super.finalization();
}
function _forwardFunds() internal {
}
function _getTokenAmount(uint256 _weiAmount) internal returns (uint256) {
uint256 tokens = super._getTokenAmount(_weiAmount);
uint256 bonus = tokens.mul(bonusPercent).div(100);
tokens = tokens.add(bonus);
return tokens;
}
function _preValidatePurchase(address _beneficiary, uint256 _weiAmount) internal {
super._preValidatePurchase(_beneficiary, _weiAmount);
require(_weiAmount >= minWeiAmount);
}
}