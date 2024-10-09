pragma solidity 0.4.19;
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
contract ERC20 is ERC20Basic {
function allowance(address owner, address spender) public view returns (uint256);
function transferFrom(address from, address to, uint256 value) public returns (bool);
function approve(address spender, uint256 value) public returns (bool);
event Approval(address indexed owner, address indexed spender, uint256 value);
}
contract ShortAddressProtection {
modifier onlyPayloadSize(uint256 numwords) {
assert(msg.data.length >= numwords * 32 + 4);
_;
}
}
contract BasicToken is ERC20Basic, ShortAddressProtection {
using SafeMath for uint256;
mapping(address => uint256) public balances;
function transfer(address _to, uint256 _value) onlyPayloadSize(2) public returns (bool) {
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
mapping(address => mapping(address => uint256)) internal allowed;
function transferFrom(address _from, address _to, uint256 _value) onlyPayloadSize(3) public returns (bool) {
require(_to != address(0));
require(_value <= balances[_from]);
require(_value <= allowed[_from][msg.sender]);
balances[_from] = balances[_from].sub(_value);
balances[_to] = balances[_to].add(_value);
allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
Transfer(_from, _to, _value);
return true;
}
function approve(address _spender, uint256 _value) onlyPayloadSize(2) public returns (bool) {
require((_value == 0) || (allowed[msg.sender][_spender] == 0));
allowed[msg.sender][_spender] = _value;
Approval(msg.sender, _spender, _value);
return true;
}
function allowance(address _owner, address _spender) public view returns (uint256) {
return allowed[_owner][_spender];
}
function increaseApproval(address _spender, uint _addedValue) onlyPayloadSize(2) public returns (bool) {
allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
return true;
}
function decreaseApproval(address _spender, uint _subtractedValue) onlyPayloadSize(2) public returns (bool) {
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
contract Showcoin is Ownable, StandardToken {
string public constant name = "Showcoin";
string public constant symbol = "SHC";
uint8 public constant decimals = 18;
uint256 public constant INITIAL_SUPPLY = 69000000 * (10 ** uint256(decimals));
function Showcoin() public {
totalSupply = INITIAL_SUPPLY;
balances[msg.sender] = INITIAL_SUPPLY;
Transfer(address(0), msg.sender, INITIAL_SUPPLY);
}
}
contract PreICO is Ownable {
using SafeMath for uint256;
Showcoin public token;
uint256 public constant rate = 2000;
uint256 public endTime;
address public wallet;
uint256 public constant tokenSaleLimit = 3000000 * (10 ** 18);
uint256 public tokenRaised;
bool public finished;
event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);
event Finish();
function PreICO(address _token, uint256 _endTime, address _wallet) public {
require(_token != address(0));
require(_wallet != address(0));
require(_endTime > now);
token = Showcoin(_token);
wallet = _wallet;
endTime = _endTime;
}
function setStopDate(uint256 _endTime) onlyOwner public {
require(_endTime > endTime);
endTime = _endTime;
}
function transferTokens(address _to, uint256 _amount) onlyOwner public {
require(_to != address(0));
tokenRaised = tokenRaised.add(_amount);
require(!hasEnded());
token.transfer(_to, _amount);
}
function setWallet(address _wallet) onlyOwner public {
require(_wallet != address(0));
wallet = _wallet;
}
function claimLeftTokens() onlyOwner public {
require(hasEnded());
require(!finished);
uint256 balance = token.balanceOf(this);
token.transfer(owner, balance);
finished = true;
Finish();
}
function() external payable {
buyTokens(msg.sender);
}
function buyTokens(address beneficiary) public payable {
require(beneficiary != address(0));
require(validPurchase());
uint256 weiAmount = msg.value;
uint256 tokens = weiAmount.mul(rate);
tokenRaised = tokenRaised.add(tokens);
require(!hasEnded());
token.transfer(beneficiary, tokens);
TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);
forwardFunds();
}
function forwardFunds() internal {
wallet.transfer(msg.value);
}
function validPurchase() internal view returns (bool) {
bool nonZeroPurchase = msg.value != 0;
return nonZeroPurchase;
}
function hasEnded() public view returns (bool) {
return now > endTime || tokenRaised >= tokenSaleLimit;
}
}