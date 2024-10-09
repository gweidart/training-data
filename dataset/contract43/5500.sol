pragma solidity ^0.4.24;
contract ERC20Basic {
function totalSupply() public view returns (uint256);
function balanceOf(address _who) public view returns (uint256);
function transfer(address _to, uint256 _value) public returns (bool);
event Transfer(address indexed from, address indexed to, uint256 value);
}
library SafeERC20 {
function safeTransfer(
ERC20Basic _token,
address _to,
uint256 _value
)
internal
{
require(_token.transfer(_to, _value));
}
function safeTransferFrom(
ERC20 _token,
address _from,
address _to,
uint256 _value
)
internal
{
require(_token.transferFrom(_from, _to, _value));
}
function safeApprove(
ERC20 _token,
address _spender,
uint256 _value
)
internal
{
require(_token.approve(_spender, _value));
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
contract ERC20 is ERC20Basic {
function allowance(address _owner, address _spender)
public view returns (uint256);
function transferFrom(address _from, address _to, uint256 _value)
public returns (bool);
function approve(address _spender, uint256 _value) public returns (bool);
event Approval(
address indexed owner,
address indexed spender,
uint256 value
);
}
library SafeMath {
function mul(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
if (_a == 0) {
return 0;
}
c = _a * _b;
assert(c / _a == _b);
return c;
}
function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
return _a / _b;
}
function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
assert(_b <= _a);
return _a - _b;
}
function add(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
c = _a + _b;
assert(c >= _a);
return c;
}
}
contract Crowdsale {
using SafeMath for uint256;
using SafeERC20 for ERC20;
ERC20 public token;
address public wallet;
uint256 public rate;
uint256 public weiRaised;
event TokenPurchase(
address indexed purchaser,
address indexed beneficiary,
uint256 value,
uint256 amount
);
constructor(uint256 _rate, address _wallet, ERC20 _token) public {
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
uint256 tokens = _getTokenAmount(weiAmount);
weiRaised = weiRaised.add(weiAmount);
_processPurchase(_beneficiary, tokens);
emit TokenPurchase(
msg.sender,
_beneficiary,
weiAmount,
tokens
);
_updatePurchasingState(_beneficiary, weiAmount);
_forwardFunds();
_postValidatePurchase(_beneficiary, weiAmount);
}
function _preValidatePurchase(
address _beneficiary,
uint256 _weiAmount
)
internal
{
require(_beneficiary != address(0));
require(_weiAmount != 0);
}
function _postValidatePurchase(
address _beneficiary,
uint256 _weiAmount
)
internal
{
}
function _deliverTokens(
address _beneficiary,
uint256 _tokenAmount
)
internal
{
token.safeTransfer(_beneficiary, _tokenAmount);
}
function _processPurchase(
address _beneficiary,
uint256 _tokenAmount
)
internal
{
_deliverTokens(_beneficiary, _tokenAmount);
}
function _updatePurchasingState(
address _beneficiary,
uint256 _weiAmount
)
internal
{
}
function _getTokenAmount(uint256 _weiAmount)
internal view returns (uint256)
{
return _weiAmount.mul(rate);
}
function _forwardFunds() internal {
wallet.transfer(msg.value);
}
}
contract CappedCrowdsale is Crowdsale {
using SafeMath for uint256;
uint256 public cap;
constructor(uint256 _cap) public {
require(_cap > 0);
cap = _cap;
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
contract MintedCrowdsale is Crowdsale {
function _deliverTokens(
address _beneficiary,
uint256 _tokenAmount
)
internal
{
require(MintableToken(address(token)).mint(_beneficiary, _tokenAmount));
}
}
contract BasicToken is ERC20Basic {
using SafeMath for uint256;
mapping(address => uint256) internal balances;
uint256 internal totalSupply_;
function totalSupply() public view returns (uint256) {
return totalSupply_;
}
function transfer(address _to, uint256 _value) public returns (bool) {
require(_value <= balances[msg.sender]);
require(_to != address(0));
balances[msg.sender] = balances[msg.sender].sub(_value);
balances[_to] = balances[_to].add(_value);
emit Transfer(msg.sender, _to, _value);
return true;
}
function balanceOf(address _owner) public view returns (uint256) {
return balances[_owner];
}
}
contract StandardToken is ERC20, BasicToken {
mapping (address => mapping (address => uint256)) internal allowed;
function transferFrom(
address _from,
address _to,
uint256 _value
)
public
returns (bool)
{
require(_value <= balances[_from]);
require(_value <= allowed[_from][msg.sender]);
require(_to != address(0));
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
function allowance(
address _owner,
address _spender
)
public
view
returns (uint256)
{
return allowed[_owner][_spender];
}
function increaseApproval(
address _spender,
uint256 _addedValue
)
public
returns (bool)
{
allowed[msg.sender][_spender] = (
allowed[msg.sender][_spender].add(_addedValue));
emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
return true;
}
function decreaseApproval(
address _spender,
uint256 _subtractedValue
)
public
returns (bool)
{
uint256 oldValue = allowed[msg.sender][_spender];
if (_subtractedValue >= oldValue) {
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
modifier hasMintPermission() {
require(msg.sender == owner);
_;
}
function mint(
address _to,
uint256 _amount
)
public
hasMintPermission
canMint
returns (bool)
{
totalSupply_ = totalSupply_.add(_amount);
balances[_to] = balances[_to].add(_amount);
emit Mint(_to, _amount);
emit Transfer(address(0), _to, _amount);
return true;
}
function finishMinting() public onlyOwner canMint returns (bool) {
mintingFinished = true;
emit MintFinished();
return true;
}
}
contract ALMToken is MintableToken {
string public constant name = "Almee Token";
string public constant symbol = "ALM";
uint8 public constant decimals = 18;
}
contract ALMCrowdsale is CappedCrowdsale, MintedCrowdsale, Ownable {
constructor (uint256 _rate, address _wallet, MintableToken _token, uint256 _cap)
public
Crowdsale(_rate, _wallet, _token)
CappedCrowdsale(_cap)
{
}
function createTokenContract() internal returns (MintableToken) {
return new ALMToken();
}
}