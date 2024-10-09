pragma solidity ^0.4.24;
contract ERC20Basic {
function totalSupply() public view returns (uint256);
function balanceOf(address who) public view returns (uint256);
function transfer(address to, uint256 value) public returns (bool);
event Transfer(address indexed from, address indexed to, uint256 value);
}
contract ERC20 is ERC20Basic {
function allowance(address owner, address spender)
public view returns (uint256);
function transferFrom(address from, address to, uint256 value)
public returns (bool);
function approve(address spender, uint256 value) public returns (bool);
event Approval(
address indexed owner,
address indexed spender,
uint256 value
);
}
library SafeMath {
function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
if (a == 0) {
return 0;
}
c = a * b;
assert(c / a == b);
return c;
}
function div(uint256 a, uint256 b) internal pure returns (uint256) {
return a / b;
}
function sub(uint256 a, uint256 b) internal pure returns (uint256) {
assert(b <= a);
return a - b;
}
function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
c = a + b;
assert(c >= a);
return c;
}
}
contract Ownable {
address public owner;
event OwnershipRenounced(address indexed previousOwner);
event OwnershipTransferred(
address indexed previousOwner,
address indexed newOwner
);
constructor() public {
owner = msg.sender;
}
modifier onlyOwner() {
require(msg.sender == owner);
_;
}
function renounceOwnership() public onlyOwner {
emit OwnershipRenounced(owner);
owner = address(0);
}
function transferOwnership(address _newOwner) public onlyOwner {
_transferOwnership(_newOwner);
}
function _transferOwnership(address _newOwner) internal {
require(_newOwner != address(0));
emit OwnershipTransferred(owner, _newOwner);
owner = _newOwner;
}
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
Transfer(msg.sender, _to, _value);
return true;
}
function balanceOf(address _owner) public view returns (uint256) {
return balances[_owner];
}
}
contract BurnableToken is BasicToken {
event Burn(address indexed burner, uint256 value);
function burn(uint256 _value) public {
_burn(msg.sender, _value);
}
function _burn(address _who, uint256 _value) internal {
require(_value <= balances[_who]);
balances[_who] = balances[_who].sub(_value);
totalSupply_ = totalSupply_.sub(_value);
emit Burn(_who, _value);
emit Transfer(_who, address(0), _value);
}
}
contract StandardToken is ERC20, BurnableToken {
mapping (address => mapping (address => uint256)) internal allowed;
function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
require(_to != address(0));
require(_value <= balances[_from]);
require(_value <= allowed[_from][msg.sender]);
balances[_from] = balances[_from].sub(_value);
balances[_to] = balances[_to].add(_value);
allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
Transfer(_from, _to, _value);
return true;
}
function approve(address _spender, uint256 _value) public returns (bool) {
allowed[msg.sender][_spender] = _value;
Approval(msg.sender, _spender, _value);
return true;
}
function allowance(address _owner, address _spender) public view returns (uint256) {
return allowed[_owner][_spender];
}
function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
return true;
}
function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
uint oldValue = allowed[msg.sender][_spender];
if (_subtractedValue > oldValue) {
allowed[msg.sender][_spender] = 0;
} else {
allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
}
Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
return true;
}
}
contract EVOAIToken is StandardToken {
string public name;
string public symbol;
uint8 public decimals;
constructor() public {
name = "EVOAI";
symbol = "EVOT";
decimals = 18;
totalSupply_ = 10000000000000000000000000;
balances[msg.sender] = totalSupply_;
}
}
library Roles {
struct Role {
mapping (address => bool) bearer;
}
function add(Role storage role, address addr)
internal
{
role.bearer[addr] = true;
}
function remove(Role storage role, address addr)
internal
{
role.bearer[addr] = false;
}
function check(Role storage role, address addr)
view
internal
{
require(has(role, addr));
}
function has(Role storage role, address addr)
view
internal
returns (bool)
{
return role.bearer[addr];
}
}
contract Crowdsale is Ownable {
using SafeMath for uint256;
EVOAIToken public token;
address public walletForETH;
uint256 public rate;
uint256 public weiRaised;
uint256 public weiRaisedRound;
uint256 public tokensRaisedRound;
uint256 public unsoldTokens;
bool public privateStage;
bool public preICOStage;
bool public icoRound1;
bool public icoRound2;
bool public icoRound3;
bool public icoRound4;
bool public icoRound5;
bool public icoRound6;
event TokenPurchase(
address indexed purchaser,
address indexed beneficiary,
uint256 value,
uint256 amount
);
constructor(address _wallet, address _walletForETH) public {
require(_wallet != address(0));
require(_walletForETH != address(0));
walletForETH = _walletForETH;
token = new EVOAIToken();
token.transfer(_wallet, 3200000000000000000000000);
privateStage = true;
}
function changeWalletForETH(address _walletForETH) onlyOwner public {
require(_walletForETH != address(0));
walletForETH = _walletForETH;
}
function () external payable {
buyTokens(msg.sender);
}
function buyTokens(address _beneficiary) public payable {
uint256 weiAmount = msg.value;
_preValidatePurchase(_beneficiary, weiAmount);
uint256 tokens = _getTokenAmount(weiAmount);
if (privateStage) {
require(tokensRaisedRound.add(tokens) < 300000000000000000000000);
require (tokens >= 5000000000000000000000 && tokens <= 25000000000000000000000);
tokensRaisedRound = tokensRaisedRound.add(tokens);
}
else if (preICOStage) {
require(tokensRaisedRound.add(tokens) < 500000000000000000000000);
tokensRaisedRound = tokensRaisedRound.add(tokens);
}
else if (icoRound1) {
require (tokensRaisedRound.add(tokens) < 1000000000000000000000000);
tokensRaisedRound = tokensRaisedRound.add(tokens);
}
else if (icoRound2) {
require (tokensRaisedRound.add(tokens) < 1000000000000000000000000);
tokensRaisedRound = tokensRaisedRound.add(tokens);
}
else if (icoRound3) {
require (tokensRaisedRound.add(tokens) < 1000000000000000000000000);
tokensRaisedRound = tokensRaisedRound.add(tokens);
}
else if (icoRound4) {
require (tokensRaisedRound.add(tokens) < 1000000000000000000000000);
tokensRaisedRound = tokensRaisedRound.add(tokens);
}
else if (icoRound5) {
require (tokensRaisedRound.add(tokens) < 1000000000000000000000000);
tokensRaisedRound = tokensRaisedRound.add(tokens);
}
else if (icoRound6) {
require (tokensRaisedRound.add(tokens) < 1000000000000000000000000);
tokensRaisedRound = tokensRaisedRound.add(tokens);
}
weiRaised = weiRaised.add(weiAmount);
_processPurchase(_beneficiary, tokens);
emit TokenPurchase(
msg.sender,
_beneficiary,
weiAmount,
tokens
);
_forwardFunds();
}
function burnUnsoldTokens() onlyOwner public {
require (unsoldTokens > 0);
token.burn(unsoldTokens);
unsoldTokens = 0;
}
function _preValidatePurchase(
address _beneficiary,
uint256 _weiAmount
)
internal
{
require(_beneficiary != address(0));
require(_weiAmount != 0);
if (privateStage && weiRaisedRound.add(_weiAmount) <= 276000000000000000000) {
rate = 1087;
weiRaisedRound = weiRaisedRound.add(_weiAmount);
}
else if (preICOStage && weiRaisedRound.add(_weiAmount) <= 775000000000000000000) {
rate = 870;
weiRaisedRound = weiRaisedRound.add(_weiAmount);
}
else if (icoRound1 && weiRaisedRound.add(_weiAmount) <= 1380000000000000000000) {
rate = 725;
weiRaisedRound = weiRaisedRound.add(_weiAmount);
}
else if (icoRound2 && weiRaisedRound.add(_weiAmount) <= 1610000000000000000000) {
rate = 621;
weiRaisedRound = weiRaisedRound.add(_weiAmount);
}
else if (icoRound3 && weiRaisedRound.add(_weiAmount) <= 1840000000000000000000) {
rate = 544;
weiRaisedRound = weiRaisedRound.add(_weiAmount);
}
else if (icoRound4 && weiRaisedRound.add(_weiAmount) <= 2070000000000000000000) {
rate = 484;
weiRaisedRound = weiRaisedRound.add(_weiAmount);
}
else if (icoRound5 && weiRaisedRound.add(_weiAmount) <= 2300000000000000000000) {
rate = 435;
weiRaisedRound = weiRaisedRound.add(_weiAmount);
}
else if (icoRound6 && weiRaisedRound.add(_weiAmount) <= 2530000000000000000000) {
rate = 396;
weiRaisedRound = weiRaisedRound.add(_weiAmount);
}
}
function nextRound() onlyOwner public {
if(privateStage){
privateStage = false;
preICOStage = true;
weiRaisedRound = 0;
unsoldTokens = unsoldTokens.add(276000000000000000000 - tokensRaisedRound);
tokensRaisedRound = 0;
}
else if(preICOStage){
preICOStage = false;
icoRound1 = true;
weiRaisedRound = 0;
unsoldTokens = unsoldTokens.add(775000000000000000000 - tokensRaisedRound);
tokensRaisedRound = 0;
}
else if(icoRound1){
icoRound1 = false;
icoRound2 = true;
weiRaisedRound = 0;
unsoldTokens = unsoldTokens.add(1380000000000000000000 - tokensRaisedRound);
tokensRaisedRound = 0;
}
else if(icoRound2){
icoRound2 = false;
icoRound3 = true;
weiRaisedRound = 0;
unsoldTokens = unsoldTokens.add(1610000000000000000000 - tokensRaisedRound);
tokensRaisedRound = 0;
}
else if(icoRound3){
icoRound3 = false;
icoRound4 = true;
weiRaisedRound = 0;
unsoldTokens = unsoldTokens.add(1840000000000000000000 - tokensRaisedRound);
tokensRaisedRound = 0;
}
else if(icoRound4){
icoRound4 = false;
icoRound5 = true;
weiRaisedRound = 0;
unsoldTokens = unsoldTokens.add(2070000000000000000000 - tokensRaisedRound);
tokensRaisedRound = 0;
}
else if(icoRound5){
icoRound5 = false;
icoRound6 = true;
weiRaisedRound = 0;
unsoldTokens = unsoldTokens.add(2300000000000000000000 - tokensRaisedRound);
tokensRaisedRound = 0;
}
else if(icoRound6){
icoRound6 = false;
unsoldTokens = unsoldTokens.add(2530000000000000000000 - tokensRaisedRound);
}
}
function _deliverTokens(
address _beneficiary,
uint256 _tokenAmount
)
internal
{
token.transfer(_beneficiary, _tokenAmount);
}
function _processPurchase(
address _beneficiary,
uint256 _tokenAmount
)
internal
{
_deliverTokens(_beneficiary, _tokenAmount);
}
function _getTokenAmount(uint256 _weiAmount)
internal view returns (uint256)
{
return _weiAmount.mul(rate);
}
function _forwardFunds() internal {
walletForETH.transfer(msg.value);
}
}
contract CappedCrowdsale is Crowdsale {
using SafeMath for uint256;
uint256 public cap;
constructor(address _wallet, address _walletForETH) public Crowdsale(_wallet, _walletForETH){
cap = 12781000000000000000000;
}
function capReached() public view returns (bool) {
return weiRaised >= cap;
}
function _preValidatePurchase(
address _beneficiary,
uint256 _weiAmount
)
internal
{
super._preValidatePurchase(_beneficiary, _weiAmount);
require(weiRaised.add(_weiAmount) <= cap);
}
}
contract AdminCrowdsale is CappedCrowdsale {
using SafeMath for uint256;
bool public open;
modifier onlyWhileOpen {
require(open);
_;
}
constructor(address _wallet, address _walletForETH) public CappedCrowdsale(_wallet, _walletForETH){
open = false;
}
function endCrowdsale() onlyOwner public {
open = false;
}
function startCrowdsale() onlyOwner public {
open = true;
}
function _preValidatePurchase(
address _beneficiary,
uint256 _weiAmount
)
internal
onlyWhileOpen
{
super._preValidatePurchase(_beneficiary, _weiAmount);
}
}