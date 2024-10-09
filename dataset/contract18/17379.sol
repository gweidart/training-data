pragma solidity ^0.4.22;
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
OwnershipTransferred(owner, newOwner);
owner = newOwner;
}
}
contract MainFabric is Ownable {
using SafeMath for uint256;
struct Contract {
address addr;
address owner;
address fabric;
string contractType;
uint256 index;
}
struct Fabric {
address addr;
address owner;
bool isActive;
uint256 index;
}
struct Admin {
address addr;
address[] contratcs;
uint256 numContratcs;
uint256 index;
}
mapping(address => Contract) public contracts;
address[] public contractsAddr;
function numContracts() public view returns (uint256)
{ return contractsAddr.length; }
mapping(address => Admin) public admins;
address[] public adminsAddr;
function numAdmins() public view returns (uint256)
{ return adminsAddr.length; }
function getAdminContract(address _adminAddress, uint256 _index) public view returns (
address
) {
return (
admins[_adminAddress].contratcs[_index]
);
}
mapping(address => Fabric) public fabrics;
address[] public fabricsAddr;
function numFabrics() public view returns (uint256)
{ return fabricsAddr.length; }
modifier onlyFabric() {
require(fabrics[msg.sender].isActive);
_;
}
function MainFabric() public {
}
function addFabric(
address _address
)
public
onlyOwner
returns (bool)
{
fabrics[_address].addr = _address;
fabrics[_address].owner = msg.sender;
fabrics[_address].isActive = true;
fabrics[_address].index = fabricsAddr.push(_address) - 1;
return true;
}
function removeFabric(
address _address
)
public
onlyOwner
returns (bool)
{
require(fabrics[_address].isActive);
fabrics[_address].isActive = false;
uint rowToDelete = fabrics[_address].index;
address keyToMove   = fabricsAddr[fabricsAddr.length-1];
fabricsAddr[rowToDelete] = keyToMove;
fabrics[keyToMove].index = rowToDelete;
fabricsAddr.length--;
return true;
}
function addContract(
address _address,
address _owner,
string _contractType
)
public
onlyFabric
returns (bool)
{
contracts[_address].addr = _address;
contracts[_address].owner = _owner;
contracts[_address].fabric = msg.sender;
contracts[_address].contractType = _contractType;
contracts[_address].index = contractsAddr.push(_address) - 1;
if (admins[_owner].addr != _owner) {
admins[_owner].addr = _owner;
admins[_owner].index = adminsAddr.push(_owner) - 1;
}
admins[_owner].contratcs.push(contracts[_address].addr);
admins[_owner].numContratcs++;
return true;
}
}
contract ERC20Basic {
function totalSupply() public view returns (uint256);
function balanceOf(address who) public view returns (uint256);
function transfer(address to, uint256 value) public returns (bool);
event Transfer(address indexed from, address indexed to, uint256 value);
}
contract ERC20 is ERC20Basic {
function allowance(address owner, address spender) public view returns (uint256);
function transferFrom(address from, address to, uint256 value) public returns (bool);
function approve(address spender, uint256 value) public returns (bool);
event Approval(address indexed owner, address indexed spender, uint256 value);
}
contract Crowdsale {
using SafeMath for uint256;
ERC20 public token;
address public wallet;
uint256 public rate;
uint256 public weiRaised;
event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);
function Crowdsale(uint256 _rate, address _wallet, ERC20 _token) public {
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
TokenPurchase(msg.sender, _beneficiary, weiAmount, tokens);
_updatePurchasingState(_beneficiary, weiAmount);
_forwardFunds();
_postValidatePurchase(_beneficiary, weiAmount);
}
function _preValidatePurchase(address _beneficiary, uint256 _weiAmount) internal {
require(_beneficiary != address(0));
require(_weiAmount != 0);
}
function _postValidatePurchase(address _beneficiary, uint256 _weiAmount) internal {
}
function _deliverTokens(address _beneficiary, uint256 _tokenAmount) internal {
token.transfer(_beneficiary, _tokenAmount);
}
function _processPurchase(address _beneficiary, uint256 _tokenAmount) internal {
_deliverTokens(_beneficiary, _tokenAmount);
}
function _updatePurchasingState(address _beneficiary, uint256 _weiAmount) internal {
}
function _getTokenAmount(uint256 _weiAmount) internal view returns (uint256) {
return _weiAmount.mul(rate);
}
function _forwardFunds() internal {
wallet.transfer(msg.value);
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
function balanceOf(address _owner) public view returns (uint256 balance) {
return balances[_owner];
}
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
Mint(_to, _amount);
Transfer(address(0), _to, _amount);
return true;
}
function finishMinting() onlyOwner canMint public returns (bool) {
mintingFinished = true;
MintFinished();
return true;
}
}
contract MintedCrowdsale is Crowdsale {
function _deliverTokens(address _beneficiary, uint256 _tokenAmount) internal {
require(MintableToken(token).mint(_beneficiary, _tokenAmount));
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
require(weiRaised.add(_weiAmount) <= cap);
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
contract RefundCrowdsale is TimedCrowdsale, MintedCrowdsale, CappedCrowdsale {
using SafeMath for uint256;
function RefundCrowdsale(
uint256 _rate,
address _wallet,
ERC20 _token,
uint256 _cap,
uint256 _openingTime,
uint256 _closingTime
)
Crowdsale(_rate, _wallet, _token)
TimedCrowdsale(_openingTime, _closingTime)
CappedCrowdsale(_cap)
public
{
}
}
contract ERC223ReceivingContract {
function tokenFallback(address _from, uint _value, bytes _data);
}
contract ERC223 is StandardToken {
event Transfer(address indexed from, address indexed to, uint value, bytes data);
function transfer(address _to, uint _value) public returns (bool) {
bytes memory empty;
return transfer(_to, _value, empty);
}
function transfer(address _to, uint _value, bytes _data) public returns (bool) {
super.transfer(_to, _value);
if (isContract(_to)) {
ERC223ReceivingContract receiver = ERC223ReceivingContract(_to);
receiver.tokenFallback(msg.sender, _value, _data);
Transfer(msg.sender, _to, _value, _data);
}
return true;
}
function transferFrom(address _from, address _to, uint _value) public returns (bool) {
bytes memory empty;
return transferFrom(_from, _to, _value, empty);
}
function transferFrom(address _from, address _to, uint _value, bytes _data) public returns (bool) {
super.transferFrom(_from, _to, _value);
if (isContract(_to)) {
ERC223ReceivingContract receiver = ERC223ReceivingContract(_to);
receiver.tokenFallback(_from, _value, _data);
}
Transfer(_from, _to, _value, _data);
return true;
}
function isContract(address _addr) private view returns (bool) {
uint length;
assembly {
length := extcodesize(_addr)
}
return (length>0);
}
}
contract ERC223MintableToken is MintableToken, ERC223 {
string public name = "";
string public symbol = "";
uint public decimals = 18;
function ERC223MintableToken(string _name, string _symbol, uint8 _decimals, address _owner) public {
name = _name;
symbol = _symbol;
decimals = _decimals;
owner = _owner;
}
}
contract BaseFactory {
address public mainFabricAddress;
string public title;
struct Parameter {
string title;
string paramType;
}
Parameter[] public params;
function numParameters() public view returns (uint256)
{
return params.length;
}
function getParam(uint _i) public view returns (
string title,
string paramType
) {
return (
params[_i].title,
params[_i].paramType
);
}
}
contract RefundCrowdsaleFactory is BaseFactory {
function RefundCrowdsaleFactory(address _mainFactory) public {
require(_mainFactory != 0x0);
mainFabricAddress = _mainFactory;
title = "RefundCrowdsale";
params.push(Parameter({
title: "Token name",
paramType: "string"
}));
params.push(Parameter({
title: "Token symbol",
paramType: "string"
}));
params.push(Parameter({
title: "Decimals",
paramType: "uint8"
}));
params.push(Parameter({
title: "Token Rate",
paramType: "uint256"
}));
params.push(Parameter({
title: "Wallet",
paramType: "address"
}));
params.push(Parameter({
title: "Hard cap in ETH",
paramType: "uint256"
}));
params.push(Parameter({
title: "Opening time",
paramType: "uint256"
}));
params.push(Parameter({
title: "Closing time",
paramType: "uint256"
}));
}
function create(
string _name,
string _symbol,
uint8 _decimals,
uint256 _rate,
address _wallet,
uint256 _cap,
uint256 _openingTime,
uint256 _closingTime
) public returns (RefundCrowdsale) {
ERC223MintableToken newToken = new ERC223MintableToken(_name, _symbol, _decimals, address(this));
RefundCrowdsale newCrowdsale = new RefundCrowdsale(
_rate,
_wallet,
ERC20(newToken),
_cap,
_openingTime,
_closingTime
);
newToken.transferOwnership(newCrowdsale);
MainFabric fabric = MainFabric(mainFabricAddress);
fabric.addContract(address(newToken), msg.sender, 'ERC223MintableToken');
fabric.addContract(address(newCrowdsale), msg.sender, title);
return newCrowdsale;
}
}