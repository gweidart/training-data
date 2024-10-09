pragma solidity ^0.4.15;
library SafeMath {
function mul(uint256 a, uint256 b) internal constant returns (uint256) {
if (a == 0) {
return 0;
}
uint256 c = a * b;
assert(c / a == b);
return c;
}
function div(uint256 a, uint256 b) internal constant returns (uint256) {
uint256 c = a / b;
return c;
}
function sub(uint256 a, uint256 b) internal constant returns (uint256) {
assert(b <= a);
return a - b;
}
function add(uint256 a, uint256 b) internal constant returns (uint256) {
uint256 c = a + b;
assert(c >= a);
return c;
}
}
contract ERC20Basic {
uint256 public totalSupply;
function balanceOf(address who) public constant returns (uint256);
function transfer(address to, uint256 value) public returns (bool);
event Transfer(address indexed from, address indexed to, uint256 value);
}
contract ERC20 is ERC20Basic {
function allowance(address owner, address spender) public constant returns (uint256);
function transferFrom(address from, address to, uint256 value) public returns (bool);
function approve(address spender, uint256 value) public returns (bool);
event Approval(address indexed owner, address indexed spender, uint256 value);
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
function balanceOf(address _owner) public constant returns (uint256 balance) {
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
function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
return allowed[_owner][_spender];
}
function increaseApproval (address _spender, uint _addedValue) public returns (bool success) {
allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
return true;
}
function decreaseApproval (address _spender, uint _subtractedValue) public returns (bool success) {
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
contract HadaCoinIco is StandardToken {
using SafeMath for uint256;
string public name = "HADACoin";
string public symbol = "HADA";
uint256 public decimals = 18;
uint256 public totalSupply = 500000000 * (uint256(10) ** decimals);
uint256 public totalRaised;
uint256 public startTimestamp;
uint256 public durationSeconds = 60 * 60 * 24 * 31;
uint256 public minCap;
uint256 public maxCap;
address public fundsWallet;
function HadaCoinIco(
address _fundsWallet,
uint256 _startTimestamp,
uint256 _minCap,
uint256 _maxCap) {
fundsWallet = _fundsWallet;
startTimestamp = _startTimestamp;
minCap = _minCap;
maxCap = _maxCap;
balances[fundsWallet] = totalSupply;
Transfer(0x0, fundsWallet, totalSupply);
}
function() isIcoOpen payable {
totalRaised = totalRaised.add(msg.value);
uint256 tokenAmount = calculateTokenAmount(msg.value);
balances[fundsWallet] = balances[fundsWallet].sub(tokenAmount);
balances[msg.sender] = balances[msg.sender].add(tokenAmount);
Transfer(fundsWallet, msg.sender, tokenAmount);
fundsWallet.transfer(msg.value);
}
function calculateTokenAmount(uint256 weiAmount) constant returns(uint256) {
uint256 tokenAmount = weiAmount.mul(400);
if (now <= startTimestamp + 7 days) {
return tokenAmount.mul(250).div(100);
} else
if (now >= startTimestamp + 7 days && now <= startTimestamp + 14 days) {
return tokenAmount.mul(210).div(100);
} else
if (now >= startTimestamp + 14 days && now <= startTimestamp + 21 days) {
return tokenAmount.mul(1725).div(1000);
} else
if (now >= startTimestamp + 21 days && now <= startTimestamp + 28 days) {
return tokenAmount.mul(1375).div(1000);
} else {
return tokenAmount;
}
}
function transfer(address _to, uint _value) isIcoFinished returns (bool) {
return super.transfer(_to, _value);
}
function transferFrom(address _from, address _to, uint _value) isIcoFinished returns (bool) {
return super.transferFrom(_from, _to, _value);
}
modifier isIcoOpen() {
require(now >= startTimestamp);
require(now <= (startTimestamp + durationSeconds) || totalRaised < minCap);
require(totalRaised <= maxCap);
_;
}
modifier isIcoFinished() {
require(now >= startTimestamp);
require(totalRaised >= maxCap || (now >= (startTimestamp + durationSeconds) && totalRaised >= minCap));
_;
}
}
contract Factory {
function createContract(
address _fundsWallet,
uint256 _startTimestamp,
uint256 _minCapEth,
uint256 _maxCapEth) returns(address created)
{
return new HadaCoinIco(
_fundsWallet,
_startTimestamp,
_minCapEth * 1 ether,
_maxCapEth * 1 ether
);
}
}