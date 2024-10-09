pragma solidity 0.4.19;
contract ERC20Basic {
uint256 public totalSupply;
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
contract BasicToken is ERC20Basic {
using SafeMath for uint256;
mapping(address => uint256) internal balances;
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
contract BurnableToken is StandardToken, Ownable {
event Burn(address indexed burner, uint256 value);
function burn(uint256 _value) public onlyOwner {
require(_value > 0);
require(_value <= balances[msg.sender]);
address burner = msg.sender;
balances[burner] = balances[burner].sub(_value);
totalSupply = totalSupply.sub(_value);
Burn(burner, _value);
}
}
contract WePoolToken is BurnableToken {
string public constant name = "WePool";
string public constant symbol = "WPL";
uint32 public constant decimals = 18;
function WePoolToken() public {
totalSupply = 200000000 * 1E18;
balances[owner] = totalSupply;
}
}
contract WePoolCrowdsale is Ownable {
using SafeMath for uint256;
uint256 public hardCap;
uint256 public reserved;
uint256 public tokensSold;
uint256 public weiRaised;
uint256 public minPurchase;
uint256 public preIcoRate;
uint256 public icoRate;
address public wallet;
address public tokenWallet;
uint256 public icoStartTime;
uint256 public preIcoStartTime;
address[] public investorsArray;
mapping (address => uint256) public investors;
WePoolToken public token;
modifier icoEnded() {
require(now > (icoStartTime + 30 days));
_;
}
function WePoolCrowdsale(uint256 _preIcoStartTime, uint256 _icoStartTime) public {
require(_preIcoStartTime > now);
require(_icoStartTime > _preIcoStartTime + 7 days);
preIcoStartTime = _preIcoStartTime;
icoStartTime = _icoStartTime;
minPurchase = 0.1 ether;
preIcoRate = 0.00008 ether;
icoRate = 0.0001 ether;
hardCap = 200000000 * 1E18;
token = new WePoolToken();
reserved = hardCap.mul(35).div(100);
hardCap = hardCap.sub(reserved);
wallet = owner;
tokenWallet = owner;
}
function changeWallet(address newWallet) public onlyOwner {
require(newWallet != address(0));
wallet = newWallet;
}
function changeTokenWallet(address newAddress) public onlyOwner {
require(newAddress != address(0));
tokenWallet = newAddress;
}
function changePreIcoRate(uint256 newRate) public onlyOwner {
require(newRate > 0);
preIcoRate = newRate;
}
function changeIcoRate(uint256 newRate) public onlyOwner {
require(newRate > 0);
icoRate = newRate;
}
function changePreIcoStartTime(uint256 newTime) public onlyOwner {
require(now < preIcoStartTime);
require(newTime > now);
require(icoStartTime > newTime + 7 days);
preIcoStartTime = newTime;
}
function changeIcoStartTime(uint256 newTime) public onlyOwner {
require(now < icoStartTime);
require(newTime > now);
require(newTime > preIcoStartTime + 7 days);
icoStartTime = newTime;
}
function burnUnsoldTokens() public onlyOwner icoEnded {
token.burn(token.balanceOf(this));
}
function withdrawal() public onlyOwner icoEnded {
wallet.transfer(this.balance);
}
function getReservedTokens() public onlyOwner icoEnded {
require(reserved > 0);
uint256 amount = reserved;
reserved = 0;
token.transfer(tokenWallet, amount);
}
function() public payable {
buyTokens();
}
function buyTokens() public payable {
address inv = msg.sender;
uint256 weiAmount = msg.value;
require(weiAmount >= minPurchase);
uint256 rate;
uint256 tokens;
uint256 cleanWei;
uint256 change;
if (now > preIcoStartTime && now < (preIcoStartTime + 7 days)) {
rate = preIcoRate;
} else if (now > icoStartTime && now < (icoStartTime + 30 days)) {
rate = icoRate;
}
require(rate > 0);
tokens = (weiAmount.mul(1E18)).div(rate);
if (tokensSold.add(tokens) > hardCap) {
tokens = hardCap.sub(tokensSold);
cleanWei = tokens.mul(rate).div(1E18);
change = weiAmount.sub(cleanWei);
} else {
cleanWei = weiAmount;
}
if (investors[inv] == 0) {
investorsArray.push(inv);
investors[inv] = tokens;
} else {
investors[inv] = investors[inv].add(tokens);
}
tokensSold = tokensSold.add(tokens);
weiRaised = weiRaised.add(cleanWei);
token.transfer(inv, tokens);
if (change > 0) {
inv.transfer(change);
}
}
function getInvestorsLength() public view returns(uint256) {
return investorsArray.length;
}
}