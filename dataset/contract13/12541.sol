pragma solidity ^0.4.23;
library SafeMath {
function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
if (a == 0) {
return 0;
}
c = a * b;
assert(c / a == b);
return c;
}
function div(uint256 a, uint256 b) internal pure returns (uint256) {
return a / b;
}
function sub(uint256 a, uint256 b) internal pure returns (uint256) {
assert(b <= a);
return a - b;
}
function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
c = a + b;
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
contract ERC20 is ERC20Basic {
function allowance(address owner, address spender)
public view returns (uint256);
function transferFrom(address from, address to, uint256 value)
public returns (bool);
function approve(address spender, uint256 value) public returns (bool);
event Approval(
address indexed owner,
address indexed spender,
uint256 value
);
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
emit Transfer(msg.sender, _to, _value);
return true;
}
function balanceOf(address _owner) public view returns (uint256) {
return balances[_owner];
}
}
contract StandardToken is ERC20, BasicToken {
mapping (address => mapping (address => uint256)) internal allowed;
function transferFrom(
address _from,
address _to,
uint256 _value
)
public
returns (bool)
{
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
function allowance(
address _owner,
address _spender
)
public
view
returns (uint256)
{
return allowed[_owner][_spender];
}
function increaseApproval(
address _spender,
uint _addedValue
)
public
returns (bool)
{
allowed[msg.sender][_spender] = (
allowed[msg.sender][_spender].add(_addedValue));
emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
return true;
}
function decreaseApproval(
address _spender,
uint _subtractedValue
)
public
returns (bool)
{
uint oldValue = allowed[msg.sender][_spender];
if (_subtractedValue > oldValue) {
allowed[msg.sender][_spender] = 0;
} else {
allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
}
emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
return true;
}
}
contract Ownable {
address public owner;
event OwnershipRenounced(address indexed previousOwner);
event OwnershipTransferred(
address indexed previousOwner,
address indexed newOwner
);
constructor() public {
owner = msg.sender;
}
modifier onlyOwner() {
require(msg.sender == owner);
_;
}
function transferOwnership(address newOwner) public onlyOwner {
require(newOwner != address(0));
emit OwnershipTransferred(owner, newOwner);
owner = newOwner;
}
function renounceOwnership() public onlyOwner {
emit OwnershipRenounced(owner);
owner = address(0);
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
modifier hasMintPermission() {
require(msg.sender == owner);
_;
}
function mint(
address _to,
uint256 _amount
)
hasMintPermission
canMint
public
returns (bool)
{
totalSupply_ = totalSupply_.add(_amount);
balances[_to] = balances[_to].add(_amount);
emit Mint(_to, _amount);
emit Transfer(address(0), _to, _amount);
return true;
}
function finishMinting() onlyOwner canMint public returns (bool) {
mintingFinished = true;
emit MintFinished();
return true;
}
}
contract CrowdsaleToken is MintableToken {
uint256 public cap = 300000000;
uint256 public crowdSaleCap = 210000000;
uint256 public basePrice = 15000000000000;
uint32 public privateSaleStartDate = 1526342400;
uint32 public privateSaleEndDate = 1529107199;
uint32 public preIcoStartDate = 1529107200;
uint32 public preIcoEndDate = 1531785599;
uint32 public icoStartDate = 1533081600;
uint32 public icoBonus1EndDate = 1533437999;
uint32 public icoBonus2EndDate = 1533945599;
uint32 public icoBonus3EndDate = 1534377599;
uint32 public icoBonus4EndDate = 1534809599;
uint32 public icoBonus5EndDate = 1535846399;
enum Stages {PrivateSale, PreIco, Ico}
Stages currentStage;
constructor() public {
uint256 team = cap.sub(crowdSaleCap);
balances[owner] = team;
totalSupply_ = team;
emit Transfer(address(this), owner, team);
currentStage = Stages.PrivateSale;
}
function getStage () internal returns (uint8) {
if (now > preIcoEndDate && currentStage != Stages.Ico) currentStage = Stages.Ico;
if (now > privateSaleEndDate && now <= preIcoEndDate && currentStage != Stages.PreIco) currentStage = Stages.PreIco;
return uint8(currentStage);
}
function getBonuses (uint256 _tokens) public returns (uint8) {
uint8 _currentStage = getStage();
if (_currentStage == 0) {
if (_tokens > 70000) return 60;
if (_tokens > 45000) return 50;
if (_tokens > 30000) return 42;
if (_tokens > 10000) return 36;
if (_tokens > 3000) return 30;
if (_tokens > 1000) return 25;
}
if (_currentStage == 1) {
if (_tokens > 45000) return 45;
if (_tokens > 30000) return 35;
if (_tokens > 10000) return 30;
if (_tokens > 3000) return 25;
if (_tokens > 1000) return 20;
if (_tokens > 25) return 15;
}
if (_currentStage == 2) {
if (now <= icoBonus1EndDate) return 30;
if (now <= icoBonus2EndDate) return 25;
if (now <= icoBonus3EndDate) return 20;
if (now <= icoBonus4EndDate) return 15;
if (now <= icoBonus5EndDate) return 10;
}
return 0;
}
function mint (address _to, uint256 _amount) public returns (bool) {
require(totalSupply_.add(_amount) <= cap);
return super.mint(_to, _amount);
}
function () public payable {
uint256 tokens = msg.value.div(basePrice);
uint8 bonuses = getBonuses(tokens);
uint256 extraTokens = tokens.mul(bonuses).div(100);
tokens = tokens.add(extraTokens);
require(totalSupply_.add(tokens) <= cap);
owner.transfer(msg.value);
balances[msg.sender] = balances[msg.sender].add(tokens);
totalSupply_ = totalSupply_.add(tokens);
emit Transfer(address(this), msg.sender, tokens);
}
}
contract FBC is CrowdsaleToken {
string public constant name = "Feon Bank Coin";
string public constant symbol = "FBC";
uint32 public constant decimals = 0;
}