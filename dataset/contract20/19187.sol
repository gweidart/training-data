pragma solidity ^0.4.19;
contract ERC20Basic {
function totalSupply() public view returns (uint256);
function balanceOf(address who) public view returns (uint256);
function transfer(address to, uint256 value) public returns (bool);
event Transfer(address indexed from, address indexed to, uint256 value);
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
contract BurnableToken is BasicToken {
event Burn(address indexed burner, uint256 value);
function burn(uint256 _value) public {
require(_value <= balances[msg.sender]);
address burner = msg.sender;
balances[burner] = balances[burner].sub(_value);
totalSupply_ = totalSupply_.sub(_value);
Burn(burner, _value);
Transfer(burner, address(0), _value);
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
contract GooToken is StandardToken, BurnableToken {
using SafeMath for uint256;
string public constant symbol = "GOO";
string public constant name = "GooToken";
uint8 public constant decimals = 18;
uint256 public constant INITIAL_SUPPLY = 2178600000000 * (10 ** uint256(decimals));
uint256 vestingTime = 0;
address reserved = 0x9F247b7eB363d56A76AA26F27b06FD4f58F93D13;
address team     = 0xc94d0A828990B6b2aB77672bB2656bE14b4718fb;
address reward   = 0x51b2F589Ee7F48AF82118790a6f3F2B17eAf8b02;
address bounty   = 0xC7AF623f1682d7CFCbc8f53aFec7dBd4767C7eCB;
function GooToken(uint256 _vestingTime) public {
vestingTime = _vestingTime;
totalSupply_ = INITIAL_SUPPLY;
preSale(msg.sender, fromPercentage(INITIAL_SUPPLY, 43));
preSale(team,       fromPercentage(INITIAL_SUPPLY, 15));
preSale(reserved,   fromPercentage(INITIAL_SUPPLY, 30));
preSale(reward,     fromPercentage(INITIAL_SUPPLY, 7));
preSale(bounty,     fromPercentage(INITIAL_SUPPLY, 5));
}
function preSale(address _address, uint256 _amount) internal returns (bool) {
balances[_address] = _amount;
Transfer(address(0x0), _address, _amount);
}
function checkPermissions(address _from) internal constant returns (bool) {
if (_from == team && now < vestingTime) {
return false;
}
return true;
}
function transfer(address _to, uint256 _value) public returns (bool) {
require(checkPermissions(msg.sender));
super.transfer(_to, _value);
}
function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
require(checkPermissions(_from));
super.transferFrom(_from, _to, _value);
}
function fromPercentage(uint256 value, uint256 percentage) internal pure returns (uint256) {
return (value*percentage)/100;
}
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
contract TimedCrowdsale is Crowdsale {
using SafeMath for uint256;
uint256 public openingTime;
uint256 public closingTime;
modifier onlyWhileOpen {
require(now >= openingTime && now <= closingTime);
_;
}
function TimedCrowdsale(uint256 _openingTime, uint256 _closingTime) public {
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
contract GooCrowdsale is TimedCrowdsale, Ownable {
using SafeMath for uint256;
bool public isBonus = true;
bool public isPreICO = true;
uint256 public rate;
uint256 public vestingTime;
ERC20 public token;
function GooCrowdsale(uint256 _startTime, uint256 _endTime, uint256 _vestingTime, uint256 _rate, address _wallet) public Crowdsale(_rate, _wallet, token = new GooToken(_vestingTime)) TimedCrowdsale(_startTime, _endTime) {
vestingTime = _vestingTime;
rate = _rate;
}
function _getTokenAmount(uint256 _weiAmount) internal view returns (uint256) {
uint256 tokens = _weiAmount.mul(rate);
if (isBonus) {
uint256 bonusTokens = _getBonusTokenAmount(_weiAmount, tokens);
tokens = tokens.add(bonusTokens);
}
return tokens;
}
function _getBonusTokenAmount(uint256 _weiAmount, uint256 _tokens) internal view returns (uint256) {
uint256 percentage = 0;
if (_weiAmount >= 50 ether) {
percentage = 100;
} else if (_weiAmount >= 20 ether) {
percentage = 75;
} else if (_weiAmount >= 10 ether) {
percentage = 50;
} else if (_weiAmount >= 5 ether) {
percentage = 20;
} else if (_weiAmount >= 1 ether) {
percentage = 10;
}
if (percentage > 0) {
if (isPreICO) {
percentage = percentage.mul(2);
}
return fromPercentage(_tokens, percentage);
} else {
return 0;
}
}
function setBonus(bool _isBonus) external onlyOwner {
isBonus = _isBonus;
}
function setPreICO(bool _isPreICO) external onlyOwner {
isPreICO = _isPreICO;
}
function setRate(uint256 _rate) external onlyOwner {
rate = _rate;
}
function fromPercentage(uint256 value, uint256 percentage) internal pure returns (uint256) {
return (value*percentage)/100;
}
}