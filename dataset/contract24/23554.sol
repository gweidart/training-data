pragma solidity ^0.4.18;
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
library SafeERC20 {
function safeTransfer(ERC20Basic token, address to, uint256 value) internal {
assert(token.transfer(to, value));
}
function safeTransferFrom(ERC20 token, address from, address to, uint256 value) internal {
assert(token.transferFrom(from, to, value));
}
function safeApprove(ERC20 token, address spender, uint256 value) internal {
assert(token.approve(spender, value));
}
}
contract TokenTimelock {
using SafeERC20 for ERC20Basic;
ERC20Basic public token;
address public beneficiary;
uint256 public releaseTime;
function TokenTimelock(ERC20Basic _token, address _beneficiary, uint256 _releaseTime) public {
require(_releaseTime > now);
token = _token;
beneficiary = _beneficiary;
releaseTime = _releaseTime;
}
function release() public {
require(now >= releaseTime);
uint256 amount = token.balanceOf(this);
require(amount > 0);
token.safeTransfer(beneficiary, amount);
}
}
contract BitrustToken is StandardToken, Ownable {
string public name = "BITRUST Token";
string public symbol = "BTF";
uint8 public decimals = 18;
bool icoFinished = false;
address advisorsAddress;
TokenTimelock public teamTimelock;
TokenTimelock public reserveTimelock;
uint256 public constant INITIAL_SUPPLY = 250000000 * (10 ** uint256(decimals));
function BitrustToken(address _teamAddress,
address _advisorsAddress, address _reserveAddress, uint256 releaseTime) public {
require(_teamAddress != address(0));
require(_advisorsAddress != address(0));
require(_reserveAddress != address(0));
teamTimelock = new TokenTimelock(this, _teamAddress, releaseTime);
reserveTimelock = new TokenTimelock(this, _reserveAddress, releaseTime);
advisorsAddress = _advisorsAddress;
}
function issueTokens(uint256 tokensSold) external onlyOwner {
require(!icoFinished);
require(tokensSold <= uint256(170000000).mul(10 ** uint256(decimals)));
require(tokensSold > 0);
uint256 teamBonuses = INITIAL_SUPPLY.mul(15).div(100);
balances[teamTimelock] = teamBonuses;
uint256 advisorsTokens = INITIAL_SUPPLY.mul(7).div(100);
balances[advisorsAddress] = advisorsTokens;
uint256 reserveTokens = INITIAL_SUPPLY.mul(10).div(100);
balances[reserveTimelock] = reserveTokens;
balances[msg.sender] = tokensSold;
totalSupply_ = tokensSold.add(teamBonuses).add(advisorsTokens).add(reserveTokens);
icoFinished = true;
}
}