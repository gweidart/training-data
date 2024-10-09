pragma solidity ^0.4.17;
contract Ownable {
address public owner;
function Ownable() internal {
owner = msg.sender;
}
modifier onlyOwner() {
require(msg.sender == owner);
_;
}
function transferOwnership(address newOwner) public onlyOwner {
require(newOwner != address(0));
owner = newOwner;
}
}
contract Authorizable {
address[] authorizers;
mapping(address => uint256) authorizerIndex;
modifier onlyAuthorized {
require(isAuthorized(msg.sender));
_;
}
function Authorizable() internal {
authorizers.length = 2;
authorizers[1] = msg.sender;
authorizerIndex[msg.sender] = 1;
}
function getAuthorizer(uint256 authIndex) external constant returns(address) {
return address(authorizers[authIndex + 1]);
}
function isAuthorized(address _addr) public constant returns(bool) {
return authorizerIndex[_addr] > 0;
}
function addAuthorized(address _addr) external onlyAuthorized {
authorizerIndex[_addr] = authorizers.length;
authorizers.length++;
authorizers[authorizers.length - 1] = _addr;
}
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
using SafeMath for uint;
mapping(address => uint256) balances;
modifier onlyPayloadSize(uint256 size) {
require(msg.data.length >= size + 4);
_;
}
function transfer(address _to, uint256 _value) onlyPayloadSize(2 * 32) public returns (bool) {
balances[msg.sender] = balances[msg.sender].sub(_value);
balances[_to] = balances[_to].add(_value);
Transfer(msg.sender, _to, _value);
return true;
}
function balanceOf(address _owner) public constant returns (uint256 balance) {
return balances[_owner];
}
}
contract StandardToken is BasicToken, ERC20 {
mapping (address => mapping (address => uint256)) allowed;
function transferFrom(address _from, address _to, uint256 _value) onlyPayloadSize(3 * 32) public returns (bool) {
var _allowance = allowed[_from][msg.sender];
balances[_to] = balances[_to].add(_value);
balances[_from] = balances[_from].sub(_value);
allowed[_from][msg.sender] = _allowance.sub(_value);
Transfer(_from, _to, _value);
return true;
}
function approve(address _spender, uint256 _value) public returns (bool) {
require((_value == 0) || (allowed[msg.sender][_spender] == 0));
allowed[msg.sender][_spender] = _value;
Approval(msg.sender, _spender, _value);
return true;
}
function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
return allowed[_owner][_spender];
}
}
contract MintableToken is StandardToken, Ownable {
event Mint(address indexed to, uint256 value);
event MintFinished();
bool public mintingFinished = false;
modifier canMint() {
require(!mintingFinished);
_;
}
function mint(address _to, uint256 _amount) public onlyOwner canMint returns (bool) {
totalSupply = totalSupply.add(_amount);
balances[_to] = balances[_to].add(_amount);
Mint(_to, _amount);
return true;
}
function finishMinting() public onlyOwner returns (bool) {
mintingFinished = true;
MintFinished();
return true;
}
}
contract StockBetToken is MintableToken {
string public name = "StockBet Token";
string public symbol = "XSB";
uint public decimals = 18;
bool public tradingStarted = false;
modifier hasStartedTrading() {
require(tradingStarted);
_;
}
function startTrading(bool _startStop) public onlyOwner {
tradingStarted = _startStop;
}
function transfer(address _to, uint256 _value) public hasStartedTrading returns (bool) {
super.transfer(_to, _value);
return true;
}
function transferFrom(address _from, address _to, uint256 _value) public hasStartedTrading returns (bool) {
super.transferFrom(_from, _to, _value);
return true;
}
}