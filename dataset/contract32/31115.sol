pragma solidity ^0.4.15;
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
uint256 public totalSupply;
function balanceOf(address who) public view returns (uint256);
function transfer(address to, uint256 value) public returns (bool);
event Transfer(address indexed from, address indexed to, uint256 value);
}
contract BasicToken is ERC20Basic {
using SafeMath for uint256;
mapping(address => uint256) balances;
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
contract RecereumToken is StandardToken, Ownable {
string public name = 'Recereum Token';
string public symbol = 'RCR';
uint256 public decimals = 18;
function RecereumToken() public {
totalSupply = 7999000 * (10**decimals);
balances[msg.sender] = totalSupply;
}
}
contract RecereumPreSale is Ownable {
using SafeMath for uint256;
uint256 public preSaleStartDate = 0;
uint256 public preSaleEndDate = 0;
uint256 public preSaleTokenCap = 0;
uint256 public preSaleTokenSold = 0;
enum State {
BeforePreSale,
PreSale,
PreSaleDone
}
address public fundsWallet = 0x0;
RecereumToken public token = RecereumToken(0x0);
uint256 tokenPriceWei = 1 ether / uint256(420);
uint256 minimalPurchaseWei = 1 ether;
function RecereumPreSale(
address _token,
address _fundsWallet,
uint256 _preSaleStartDate,
uint256 _preSaleEndDate,
uint256 _preSaleTokenCap
) public {
require(_token != 0x0);
token = RecereumToken(_token);
require(_fundsWallet != 0x0);
fundsWallet = _fundsWallet;
require(_preSaleStartDate != 0);
preSaleStartDate = _preSaleStartDate;
require(_preSaleEndDate != 0);
preSaleEndDate = _preSaleEndDate;
require(_preSaleTokenCap != 0);
preSaleTokenCap = _preSaleTokenCap;
}
function getTime() public returns (uint256) {
return now;
}
function() public payable {
buyTokens(msg.sender);
}
function buyTokens(address recipient) public payable {
require(msg.value >= minimalPurchaseWei);
State state = getState();
require(state == State.PreSale);
require(preSaleTokenSold < preSaleTokenCap);
uint256 tokenAmount = msg.value.div(tokenPriceWei).mul(10**token.decimals());
uint256 weiAccepted = 0;
uint256 change = 0;
if (preSaleTokenSold.add(tokenAmount) <= preSaleTokenCap) {
weiAccepted = msg.value;
change = 0;
} else {
tokenAmount = preSaleTokenCap.sub(preSaleTokenSold);
weiAccepted = tokenAmount.mul(tokenPriceWei).div(10**token.decimals());
change = msg.value - weiAccepted;
}
preSaleTokenSold = preSaleTokenSold.add(tokenAmount);
fundsWallet.transfer(weiAccepted);
token.transferFrom(owner, recipient, tokenAmount);
if (change > 0) {
msg.sender.transfer(change);
}
}
function getState() public view returns (State) {
uint256 _date = getTime();
if (_date < preSaleStartDate) {
return State.BeforePreSale;
}
if (_date >= preSaleStartDate && _date < preSaleEndDate) {
return State.PreSale;
}
return State.PreSaleDone;
}
}