pragma solidity ^0.4.19;
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
owner = 0x3A9158Cf4b90D502D1A197699aa6B14edbcE9Ce5;
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
contract ERC20 is ERC20Basic {
function allowance(address owner, address spender) public view returns (uint256);
function transferFrom(address from, address to, uint256 value) public returns (bool);
function approve(address spender, uint256 value) public returns (bool);
event Approval(address indexed owner, address indexed spender, uint256 value);
}
contract BasicToken is ERC20Basic, Ownable {
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
bool public purchasingAllowed = true;
uint256 public totalContribution = 0;
uint multiplier = 35;
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
function() public payable {
if (!purchasingAllowed) { throw; }
if (msg.value == 0) { return; }
owner.transfer(msg.value);
totalContribution += msg.value;
uint tokensIssued = (msg.value/1000000000000000)*multiplier;
balances[msg.sender] += tokensIssued;
Transfer(address(this), msg.sender, tokensIssued);
}
function enablePurchasing() {
if (msg.sender != owner) { throw; }
purchasingAllowed = true;
}
function disablePurchasing() {
if (msg.sender != owner) { throw; }
purchasingAllowed = false;
}
function preICO() {
if (msg.sender != owner) { throw; }
multiplier = 35;
}
function startICO() {
if (msg.sender != owner) { throw; }
multiplier = 45;
}
function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns (bool success) {
return BasicToken(tokenAddress).transfer(owner, tokens);
}
function multiSend(address[] _toAddresses, uint256[] _amounts) public {
require(_toAddresses.length <= 255);
require(_toAddresses.length == _amounts.length);
for (uint8 i = 0; i < _toAddresses.length; i++) {
transfer(_toAddresses[i], _amounts[i]);
}
}
function multiSendFrom(address _from, address[] _toAddresses, uint256[] _amounts) public {
require(_toAddresses.length <= 255);
require(_toAddresses.length == _amounts.length);
for (uint8 i = 0; i < _toAddresses.length; i++) {
transferFrom(_from, _toAddresses[i], _amounts[i]);
}
}
}
contract PurgeCoin is StandardToken {
string public constant name = "Purge Coin";
string public constant symbol = "PGC";
uint8 public constant decimals = 0;
uint256 public constant INITIAL_SUPPLY = 200000000 * (10 ** uint256(decimals));
function PurgeCoin() public {
totalSupply_ = INITIAL_SUPPLY;
balances[0x3A9158Cf4b90D502D1A197699aa6B14edbcE9Ce5] = 130000000;
Transfer(0x0, 0x3A9158Cf4b90D502D1A197699aa6B14edbcE9Ce5, 130000000);
}
}