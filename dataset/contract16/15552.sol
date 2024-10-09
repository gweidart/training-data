pragma solidity ^0.4.23;
contract Ownable {
address public owner;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
modifier onlyOwner() {
require(msg.sender == owner);
_;
}
modifier onlyValidAddress(address addr) {
require(addr != address(0));
_;
}
constructor () public {
owner = msg.sender;
}
function transferOwnership(address newOwner)
public
onlyOwner
onlyValidAddress(newOwner)
{
emit OwnershipTransferred(owner, newOwner);
owner = newOwner;
}
}
contract Pausable is Ownable {
event Pause();
event Unpause();
bool public paused = false;
constructor () public {
}
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
}
contract ERC20 {
event Transfer(address indexed from, address indexed to, uint256 value);
event Approval(address indexed owner, address indexed spender, uint256 value);
function totalSupply() public view returns (uint256);
function balanceOf(address who) public view returns (uint256);
function transfer(address to, uint256 value) public returns (bool);
function allowance(address owner, address spender) public view returns (uint256);
function transferFrom(address from, address to, uint256 value) public returns (bool);
function approve(address spender, uint256 value) public returns (bool);
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
return a / b;
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
contract StandardToken is ERC20 {
using SafeMath for uint256;
uint256 internal _totalSupply;
mapping(address => uint256) internal _balanceOf;
mapping (address => mapping (address => uint256)) internal _allowance;
modifier onlyValidAddress(address addr) {
require(addr != address(0));
_;
}
modifier onlySufficientBalance(address from, uint256 value) {
require(value <= _balanceOf[from]);
_;
}
modifier onlySufficientAllowance(address from, address to, uint256 value) {
require(value <= _allowance[from][msg.sender]);
_;
}
function transfer(address to, uint256 value)
public
onlyValidAddress(to)
onlySufficientBalance(msg.sender, value)
returns (bool)
{
_balanceOf[msg.sender] = _balanceOf[msg.sender].sub(value);
_balanceOf[to] = _balanceOf[to].add(value);
emit Transfer(msg.sender, to, value);
return true;
}
function transferFrom(address from, address to, uint256 value)
public
onlyValidAddress(to)
onlySufficientBalance(from, value)
onlySufficientAllowance(from, to, value)
returns (bool)
{
_balanceOf[from] = _balanceOf[from].sub(value);
_balanceOf[to] = _balanceOf[to].add(value);
_allowance[from][msg.sender] = _allowance[from][msg.sender].sub(value);
emit Transfer(from, to, value);
return true;
}
function approve(address spender, uint256 value) public returns (bool) {
_allowance[msg.sender][spender] = value;
emit Approval(msg.sender, spender, value);
return true;
}
function increaseApproval(address spender, uint addedValue) public returns (bool) {
_allowance[msg.sender][spender] = _allowance[msg.sender][spender].add(addedValue);
emit Approval(msg.sender, spender, _allowance[msg.sender][spender]);
return true;
}
function decreaseApproval(address spender, uint subtractedValue) public returns (bool) {
uint oldValue = _allowance[msg.sender][spender];
if (subtractedValue > oldValue) {
_allowance[msg.sender][spender] = 0;
} else {
_allowance[msg.sender][spender] = oldValue.sub(subtractedValue);
}
emit Approval(msg.sender, spender, _allowance[msg.sender][spender]);
return true;
}
function totalSupply() public view returns (uint256) {
return _totalSupply;
}
function balanceOf(address owner) public view returns (uint256) {
return _balanceOf[owner];
}
function allowance(address owner, address spender) public view returns (uint256) {
return _allowance[owner][spender];
}
}
contract PausableToken is StandardToken, Pausable {
function transfer(address _to, uint256 _value) public whenNotPaused returns (bool) {
return super.transfer(_to, _value);
}
function transferFrom(address _from, address _to, uint256 _value) public whenNotPaused returns (bool) {
return super.transferFrom(_from, _to, _value);
}
function approve(address _spender, uint256 _value) public whenNotPaused returns (bool) {
return super.approve(_spender, _value);
}
function increaseApproval(address _spender, uint _addedValue) public whenNotPaused returns (bool success) {
return super.increaseApproval(_spender, _addedValue);
}
function decreaseApproval(address _spender, uint _subtractedValue) public whenNotPaused returns (bool success) {
return super.decreaseApproval(_spender, _subtractedValue);
}
}
contract Protection {
modifier onlyPayloadSize(uint numwords) {
assert(msg.data.length == numwords * 32 + 4);
_;
}
}
contract TokenRecipient {
function receiveApproval(address _from, uint256 _value, address _to, bytes _extraData) public;
}
contract PeloponnesianToken is Protection,PausableToken {
string public name = "Peloponnesian";
string public symbol = "PELO";
uint256 public decimals = 18;
uint256 public initialSupply = 100 * 10**8 * uint256(10**decimals);
constructor( ) public {
_totalSupply = initialSupply;
_balanceOf[msg.sender] = initialSupply;
}
function transfer(address _to, uint _value) public onlyPayloadSize(2) returns (bool) {
return super.transfer(_to, _value);
}
function transferFrom(address _from, address _to, uint _value) public onlyPayloadSize(3) returns (bool) {
return super.transferFrom(_from, _to, _value);
}
function allowance(address _owner, address _spender) public onlyPayloadSize(2) constant returns (uint256 remaining) {
return super.allowance(_owner, _spender);
}
function approveAndCall(address _spender, uint256 _value, bytes _extraData) public returns (bool success) {
TokenRecipient spender = TokenRecipient(_spender);
if (approve(_spender, _value)) {
spender.receiveApproval(msg.sender, _value, this, _extraData);
return true;
}
}
}