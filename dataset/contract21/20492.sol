pragma solidity ^0.4.21;
contract SafeMath
{
function mul(uint256 a, uint256 b) internal pure returns (uint256) {
uint c = a * b;
assert(a == 0 || c / a == b);
return c;
}
function div(uint256 a, uint256 b) internal pure returns (uint256) {
assert(b > 0);
uint c = a / b;
assert(a == b * c + a % b);
return c;
}
function sub(uint256 a, uint256 b) internal pure returns (uint256) {
assert(b <= a);
return a - b;
}
function add(uint256 a, uint256 b) internal pure returns (uint256) {
uint c = a + b;
assert(c >= a);
return c;
}
function pow(uint256 a, uint256 b) internal pure returns (uint256) {
uint c = a ** b;
assert(a == 0 || c / a == b);
return c;
}
}
contract Ownable
{
event NewOwner(address old, address current);
event NewPotentialOwner(address old, address potential);
address public owner = msg.sender;
address public potentialOwner;
modifier onlyOwner {
require(msg.sender == owner);
_;
}
modifier onlyPotentialOwner {
require(msg.sender == potentialOwner);
_;
}
function setOwner(address _new) public onlyOwner {
emit NewPotentialOwner(owner, _new);
potentialOwner = _new;
}
function confirmOwnership() public onlyPotentialOwner {
emit NewOwner(owner, potentialOwner);
owner = potentialOwner;
potentialOwner = 0;
}
}
contract ERC20I
{
function name() constant public returns (string);
function symbol() constant public returns (string);
function decimals() constant public returns (uint8);
function totalSupply() constant public returns (uint256);
function balanceOf(address owner) public view returns (uint256);
function transfer(address to, uint256 value) public returns (bool);
function transferFrom(address from, address to, uint256 value) public returns (bool);
function approve(address spender, uint256 value) public returns (bool);
function allowance(address owner, address spender) public view returns (uint256);
event Transfer(address indexed from, address indexed to, uint256 value);
event Approval(address indexed owner, address indexed spender, uint256 value);
}
contract ERC20 is ERC20I, SafeMath
{
string  public name;
string  public symbol;
uint8   public decimals;
uint256 public totalSupply;
string  public version;
mapping (address => uint256) balances;
mapping (address => mapping (address => uint256)) allowed;
function name() public view returns (string) {
return name;
}
function symbol() public view returns (string) {
return symbol;
}
function decimals() public view returns (uint8) {
return decimals;
}
function totalSupply() public view returns (uint256) {
return totalSupply;
}
function balanceOf(address _owner) public view returns (uint256 balance) {
return balances[_owner];
}
function transfer(address _to, uint256 _value) public returns (bool) {
require(_to != address(0x0));
require(_value <= balances[msg.sender]);
balances[msg.sender] = sub(balances[msg.sender], _value);
balances[_to] = add(balances[_to], _value);
emit Transfer(msg.sender, _to, _value);
return true;
}
function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
require(_to != address(0));
require(_value <= balances[_from]);
require(_value <= allowed[_from][msg.sender]);
balances[_from] = sub(balances[_from], _value);
balances[_to] = add(balances[_to], _value);
allowed[_from][msg.sender] = sub( allowed[_from][msg.sender], _value);
emit Transfer(_from, _to, _value);
return true;
}
function approve(address _spender, uint256 _value) public returns (bool) {
allowed[msg.sender][_spender] = _value;
emit Approval(msg.sender, _spender, _value);
return true;
}
function allowance(address _owner, address _spender) public view returns (uint256) {
return allowed[_owner][_spender];
}
function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
allowed[msg.sender][_spender] = add(allowed[msg.sender][_spender], _addedValue);
emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
return true;
}
function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
uint oldValue = allowed[msg.sender][_spender];
if (_subtractedValue > oldValue) {
allowed[msg.sender][_spender] = 0;
} else {
allowed[msg.sender][_spender] = sub(oldValue, _subtractedValue);
}
emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
return true;
}
}
contract Pausable is Ownable {
event EPause();
event EUnpause();
bool public paused = true;
modifier whenNotPaused()
{
require(!paused);
_;
}
function pause() public onlyOwner
{
paused = true;
emit EPause();
}
function unpause() public onlyOwner
{
paused = false;
emit EUnpause();
}
}
contract MintableToken is ERC20, Ownable
{
uint256 maxSupply = 1e25;
event Issuance(uint256 _amount);
event Destruction(uint256 _amount);
function issue(address _to, uint256 _amount) public onlyOwner {
require(maxSupply >= totalSupply + _amount);
totalSupply +=  _amount;
balances[_to] += _amount;
emit Issuance(_amount);
emit Transfer(this, _to, _amount);
}
function destroy(address _from, uint256 _amount) public onlyOwner {
balances[_from] -= _amount;
totalSupply -= _amount;
emit Transfer(_from, this, _amount);
emit Destruction(_amount);
}
}
contract PausableToken is MintableToken, Pausable {
function transferFrom(address _from, address _to, uint256 _value)
public
whenNotPaused
returns (bool)
{
return super.transferFrom(_from, _to, _value);
}
function approve(address _spender, uint256 _value)
public
whenNotPaused
returns (bool)
{
return super.approve(_spender, _value);
}
function increaseApproval(address _spender, uint _addedValue)
public
whenNotPaused
returns (bool)
{
return super.increaseApproval(_spender, _addedValue);
}
function decreaseApproval(address _spender, uint _subtractedValue)
public
whenNotPaused
returns (bool)
{
return super.decreaseApproval(_spender, _subtractedValue);
}
}
contract Workcoin is PausableToken {
address internal seller;
function transfer(address _to, uint256 _value) public
returns (bool)
{
if(paused) {
require(seller == msg.sender);
return super.transfer(_to, _value);
} else {
return super.transfer(_to, _value);
}
}
function sendToken(address _to, uint256 _value) public onlyOwner
returns (bool)
{
require(_to != address(0x0));
require(_value <= balances[this]);
balances[this] = sub(balances[this], _value);
balances[_to] = add(balances[_to], _value);
emit Transfer(this, _to, _value);
return true;
}
function setSeller(address _seller) public onlyOwner {
seller = _seller;
}
function transferEther(address _to, uint256 _value)
public
onlyOwner
returns (bool)
{
_to.transfer(_value);
return true;
}
function transferERC20Token(address tokenAddress, address to, uint256 tokens)
public
onlyOwner
returns (bool)
{
return ERC20(tokenAddress).transfer(to, tokens);
}
function massTransfer(address [] _holders, uint256 [] _payments)
public
onlyOwner
returns (bool)
{
uint256 hl = _holders.length;
uint256 pl = _payments.length;
require(hl <= 100 && hl == pl);
for (uint256 i = 0; i < hl; i++) {
transfer(_holders[i], _payments[i]);
}
return true;
}
function Workcoin() public
{
name = "Workcoin";
symbol = "WRR";
decimals = 18;
version = "1.3";
issue(this, 1e7 * 1e18);
}
function() public payable {}
}