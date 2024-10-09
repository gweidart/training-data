pragma solidity ^0.4.21;
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
contract BasicToken is ERC20Basic {
using SafeMath for uint256;
mapping(address => uint256) balances;
function transfer(address _to, uint256 _value) public returns (bool) {
require(_to != address(0));
require(_value <= balances[msg.sender]);
balances[msg.sender] = balances[msg.sender].sub(_value);
balances[_to] = balances[_to].add(_value);
emit Transfer(msg.sender, _to, _value);
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
emit Transfer(_from, _to, _value);
return true;
}
function approve(address _spender, uint256 _value) public returns (bool) {
allowed[msg.sender][_spender] = _value;
emit Approval(msg.sender, _spender, _value);
return true;
}
function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
return allowed[_owner][_spender];
}
function increaseApproval (address _spender, uint _addedValue) public returns (bool success) {
allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
return true;
}
function decreaseApproval (address _spender, uint _subtractedValue) public returns (bool success) {
uint oldValue = allowed[msg.sender][_spender];
if (_subtractedValue > oldValue) {
allowed[msg.sender][_spender] = 0;
} else {
allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
}
emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
return true;
}
function () public payable {
revert();
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
function transferOwnership(address newOwner) onlyOwner public {
require(newOwner != address(0));
emit OwnershipTransferred(owner, newOwner);
owner = newOwner;
}
}
contract PausableToken is Ownable, StandardToken {
event Pause();
event Unpause();
bool public paused = false;
modifier whenNotPaused() {
require(!paused);
_;
}
modifier whenPaused() {
require(paused);
_;
}
function pause() onlyOwner whenNotPaused public {
paused = true;
emit Pause();
}
function unpause() onlyOwner whenPaused public {
paused = false;
emit Unpause();
}
function transfer(address _to, uint256 _value) public whenNotPaused returns (bool) {
return super.transfer(_to, _value);
}
function transferFrom(address _from, address _to, uint256 _value) public whenNotPaused returns (bool) {
return super.transferFrom(_from, _to, _value);
}
}
contract Configurable {
uint256 public constant totalSaleLimit = 70000000;
uint256 public constant privateSaleLimit = 27300000;
uint256 public constant preSaleLimit = 38500000;
uint256 public constant saleLimit = 4200000;
uint256 public creationDate = now;
uint256 public constant teamLimit = 8000000;
uint256 teamReleased;
address public constant teamAddress = 0x7a615d4158202318750478432743cA615d0D83aF;
}
contract Staged is Ownable, Configurable {
using SafeMath for uint256;
enum Stages {PrivateSale, PreSale, Sale}
Stages currentStage;
uint256 privateSale;
uint256 preSale;
uint256 sale;
function Staged() public {
currentStage = Stages.PrivateSale;
}
function setPrivateSale() public onlyOwner returns (bool) {
currentStage = Stages.PrivateSale;
return true;
}
function setPreSale() public onlyOwner returns (bool) {
currentStage = Stages.PreSale;
return true;
}
function setSale() public onlyOwner returns (bool) {
currentStage = Stages.Sale;
return true;
}
function tokensAmount(uint256 _wei) public view returns (uint256) {
if (_wei < 100000000000000000) return 0;
uint256 amount = _wei.mul(14005).div(1 ether);
if (currentStage == Stages.PrivateSale) {
if (_wei < 50000000000000000000) return 0;
if (_wei > 3000000000000000000000) return 0;
amount = amount.mul(130).div(100);
if (amount > privateSaleLimit.sub(privateSale)) return 0;
}
if (currentStage == Stages.PreSale) {
if (_wei > 30000000000000000000) return 0;
amount = amount.mul(110).div(100);
if (amount > preSaleLimit.sub(preSale)) return 0;
}
if (currentStage == Stages.Sale) {
if (amount > saleLimit.sub(sale)) return 0;
}
return amount;
}
function addStageAmount(uint256 _amount) public {
if (currentStage == Stages.PrivateSale) {
require(_amount < privateSaleLimit.sub(privateSale));
privateSale = privateSale.add(_amount);
}
if (currentStage == Stages.PreSale) {
require(_amount < preSaleLimit.sub(preSale));
privateSale = privateSale.add(_amount);
}
if (currentStage == Stages.Sale) {
require(_amount < saleLimit.sub(sale));
sale = sale.add(_amount);
}
}
}
contract MintableToken is PausableToken, Configurable {
function mint(address _to, uint256 _amount) public onlyOwner returns (bool) {
require(totalSaleLimit.add(30000000) > totalSupply.add(_amount));
totalSupply = totalSupply.add(_amount);
balances[_to] = balances[_to].add(_amount);
emit Transfer(address(this), _to, _amount);
return true;
}
}
contract CrowdsaleToken is MintableToken, Staged {
function CrowdsaleToken() internal {
balances[owner] = 22000000;
totalSupply.add(22000000);
}
function() public payable {
uint256 tokens = tokensAmount(msg.value);
require (tokens > 0);
addStageAmount(tokens);
owner.transfer(msg.value);
balances[msg.sender] = balances[msg.sender].add(tokens);
emit Transfer(address(this), msg.sender, tokens);
}
function releaseTeamTokens() public {
uint256 timeSinceCreation = now.sub(creationDate);
uint256 teamTokens = timeSinceCreation.div(7776000).mul(1000000);
require (teamReleased < teamTokens);
teamTokens = teamTokens.sub(teamReleased);
if (teamReleased.add(teamTokens) > teamLimit) {
teamTokens = teamLimit.sub(teamReleased);
}
require (teamTokens > 0);
teamReleased = teamReleased.add(teamTokens);
balances[teamAddress] = balances[teamAddress].add(teamTokens);
totalSupply = totalSupply.add(teamTokens);
emit Transfer(address(this), teamAddress, teamTokens);
}
}
contract WorkChain is CrowdsaleToken {
string public constant name = "WorkChain";
string public constant symbol = "WCH";
uint32 public constant decimals = 0;
}