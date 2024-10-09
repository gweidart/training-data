pragma solidity ^0.4.13;
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
contract SpoutCrowdsale is Ownable {
using SafeMath for uint256;
uint256 private constant APRIL_23_2018 = 1524441600;
uint256 private constant MAY_01_2018 = 1525132800;
uint256 private constant MAY_08_2018 = 1525737600;
uint256 private constant MAY_15_2018 = 1526342400;
uint256 private constant JUN_01_2018 = 1527811200;
uint256 private constant JUN_15_2018 = 1529020800;
uint256 private constant JULY_01_2018 = 1530403200;
MintableToken public token;
uint256 public presaleRate;
uint256 public icoRate;
address public wallet;
event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount, uint256 tokenRate, uint256 bonusRate);
function SpoutCrowdsale(
address _token,
uint256 _presaleRate,
uint256 _icoRate,
address _wallet
) {
require(_token != address(0));
require(_wallet != address(0));
token = SpoutMintableToken(_token);
presaleRate = _presaleRate;
icoRate = _icoRate;
wallet = _wallet;
}
function () external payable {
require(msg.sender != address(0));
require(isPresalePeriod() || isICOPeriod());
uint256 tokenRate = getCurrentTokenRate();
uint256 tokens = msg.value.mul(tokenRate);
uint256 bonusRate = getCurrentBonus();
uint256 bonusTokens = bonusRate.mul(tokens.div(100));
tokens = tokens.add(bonusTokens);
TokenPurchase(msg.sender, msg.sender, msg.value, tokens, tokenRate, bonusRate);
token.mint(msg.sender, tokens);
forwardFunds();
}
function forwardFunds() internal {
wallet.transfer(msg.value);
}
function getCurrentTokenRate() public view returns (uint256) {
if (now >= APRIL_23_2018 && now < MAY_15_2018) {
return presaleRate;
} else {
return icoRate;
}
}
function isPresalePeriod() public view returns (bool) {
if (now >= APRIL_23_2018 && now < MAY_15_2018) {
return true;
}
return false;
}
function isICOPeriod() public view returns (bool) {
if (now >= MAY_15_2018 && now < JULY_01_2018) {
return true;
}
return false;
}
function getCurrentBonus() public view returns (uint256) {
if (now >= APRIL_23_2018 && now < MAY_01_2018) {
return 15;
}
if (now >= MAY_01_2018 && now < MAY_08_2018) {
return 10;
}
if (now >= MAY_08_2018 && now < MAY_15_2018) {
return 5;
}
if (now >= MAY_15_2018 && now < JUN_01_2018) {
return 5;
}
if (now >= JUN_01_2018 && now < JUN_15_2018) {
return 3;
}
if (now >= JUN_15_2018 && now < JULY_01_2018) {
return 2;
}
return 0;
}
function mintTo(address beneficiary, uint256 _amount) onlyOwner public returns (bool) {
return token.mint(beneficiary, _amount);
}
}
contract SpoutMintableToken is MintableToken {
string public constant name = "SpoutToken";
string public constant symbol = "SPT";
uint8 public constant decimals = 18;
address originalOwner;
bool public transferEnabled = false;
function SpoutMintableToken() public {
originalOwner = msg.sender;
}
function setTransferStatus(bool _enable)  public {
require(originalOwner == msg.sender);
transferEnabled = _enable;
}
function getTransferStatus() public view returns (bool){
return transferEnabled;
}
function getOriginalOwner() public view returns(address) {
return originalOwner;
}
function transfer(address _to, uint256 _value) public returns (bool) {
require(transferEnabled);
return super.transfer(_to, _value);
}
}