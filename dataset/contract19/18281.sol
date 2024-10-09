pragma solidity ^0.4.18;
contract ERC20Basic {
function totalSupply() public view returns (uint256);
function balanceOf(address who) public view returns (uint256);
function transfer(address to, uint256 value) public returns (bool);
event Transfer(address indexed from, address indexed to, uint256 value);
}
library SafeMath {
function mul(uint256 a, uint256 b) internal pure returns (uint256) {
uint256 c = a * b;
assert(a == 0 || c / a == b);
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
contract ERC20 is ERC20Basic {
function allowance(address owner, address spender) public view returns (uint256);
function transferFrom(address from, address to, uint256 value) public returns (bool);
function approve(address spender, uint256 value) public returns (bool);
event Approval(address indexed owner, address indexed spender, uint256 value);
}
contract Hive is ERC20 {
using SafeMath for uint;
string public constant name = "UHIVE";
string public constant symbol = "HVE";
uint256 public constant decimals = 18;
uint256 _totalSupply = 80000000000 * (10**decimals);
mapping (address => bool) public frozenAccount;
event FrozenFunds(address target, bool frozen);
mapping(address => uint256) balances;
mapping(address => mapping (address => uint256)) allowed;
address public owner;
modifier onlyOwner() {
require(msg.sender == owner);
_;
}
function changeOwner(address _newOwner) onlyOwner public {
require(_newOwner != address(0));
owner = _newOwner;
}
function freezeAccount(address target, bool freeze) onlyOwner public {
frozenAccount[target] = freeze;
FrozenFunds(target, freeze);
}
function isFrozenAccount(address _addr) public constant returns (bool) {
return frozenAccount[_addr];
}
function destroyCoins(address addressToDestroy, uint256 amount) onlyOwner public {
require(addressToDestroy != address(0));
require(amount > 0);
require(amount <= balances[addressToDestroy]);
balances[addressToDestroy] -= amount;
_totalSupply -= amount;
}
function Hive() public {
owner = msg.sender;
balances[owner] = _totalSupply;
}
function totalSupply() public constant returns (uint256 supply) {
supply = _totalSupply;
}
function balanceOf(address _owner) public constant returns (uint256 balance) {
return balances[_owner];
}
function transfer(address _to, uint256 _value) public returns (bool success) {
if (_to != address(0) && isFrozenAccount(msg.sender) == false && balances[msg.sender] >= _value && _value > 0 && balances[_to].add(_value) > balances[_to]) {
balances[msg.sender] = balances[msg.sender].sub(_value);
balances[_to] = balances[_to].add(_value);
Transfer(msg.sender, _to, _value);
return true;
} else {
return false;
}
}
function transferFrom(address _from,address _to, uint256 _value) public returns (bool success) {
if (_to != address(0) && isFrozenAccount(_from) == false && balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0 && balances[_to].add(_value) > balances[_to]) {
balances[_from] = balances[_from].sub(_value);
allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
balances[_to] = balances[_to].add(_value);
Transfer(_from, _to, _value);
return true;
} else {
return false;
}
}
function approve(address _spender, uint256 _value) public returns (bool success) {
allowed[msg.sender][_spender] = _value;
Approval(msg.sender, _spender, _value);
return true;
}
function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
return allowed[_owner][_spender];
}
}
contract UhiveVest {
using SafeMath for uint256;
Hive public token;
address public owner;
uint256 public releaseDate;
modifier onlyWhenReleased {
require(now >= releaseDate);
_;
}
modifier onlyOwner() {
require(msg.sender == owner);
_;
}
function UhiveVest(Hive _token, uint256 _releaseDate) public {
token = _token;
owner = msg.sender;
releaseDate = _releaseDate;
}
function () external payable {
_forwardFunds();
}
function _forwardFunds() private {
owner.transfer(msg.value);
}
event TokenTransfer(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);
function forwardTokens(address _beneficiary, uint256 totalTokens) onlyOwner onlyWhenReleased public {
_preValidateTokenTransfer(_beneficiary, totalTokens);
_deliverTokens(_beneficiary, totalTokens);
}
function withdrawTokens() onlyOwner onlyWhenReleased public {
uint256 unsold = token.balanceOf(this);
token.transfer(owner, unsold);
}
function changeOwner(address _newOwner) onlyOwner public {
require(_newOwner != address(0));
owner = _newOwner;
}
function terminate() public onlyOwner onlyWhenReleased {
selfdestruct(owner);
}
function _preValidateTokenTransfer(address _beneficiary, uint256 _tokenAmount) internal pure {
require(_beneficiary != address(0));
require(_tokenAmount > 0);
}
function _deliverTokens(address _beneficiary, uint256 _tokenAmount) internal {
token.transfer(_beneficiary, _tokenAmount);
TokenTransfer(msg.sender, _beneficiary, 0, _tokenAmount);
}
}