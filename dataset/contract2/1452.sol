pragma solidity ^0.4.24;
contract Ownable {
address public owner;
event OwnershipRenounced(address indexed previousOwner);
event OwnershipTransferred(
address indexed previousOwner,
address indexed newOwner
);
constructor () public {
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
contract Pausable is Ownable {
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
}
library SafeMath {
function mul(uint256 a, uint256 b) internal pure returns (uint256) {
uint256 c = a * b;
assert(a == 0 || c / a == b);
return c;
}
function div(uint256 a, uint256 b) internal pure returns (uint256) {
assert(b > 0);
uint256 c = a / b;
assert(a == b * c + a % b);
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
contract TokenERC20 {
function balanceOf(address who) public constant returns (uint);
function allowance(address owner, address spender) public constant returns (uint);
function transfer(address to, uint value) public  returns (bool ok);
function transferFrom(address from, address to, uint value) public  returns (bool ok);
function approve(address spender, uint value) public returns (bool ok);
function burn(uint256 _value) public returns (bool success);
function burnFrom(address _from, uint256 _value) public returns (bool success);
event Transfer(address indexed from, address indexed to, uint value);
event Approval(address indexed owner, address indexed spender, uint value);
event Burn(address indexed from, uint256 value);
}
contract TokenERC20Standart is TokenERC20, Pausable{
using SafeMath for uint256;
string public name;
uint256 public decimals;
string public symbol;
string public version;
uint256 public totalSupply;
mapping(address => uint) public balances;
mapping(address => mapping(address => uint)) public allowed;
modifier onlyPayloadSize(uint size) {
require(msg.data.length >= size + 4) ;
_;
}
function balanceOf(address tokenOwner) public constant whenNotPaused  returns (uint balance) {
return balances[tokenOwner];
}
function transfer(address to, uint256 tokens) public  whenNotPaused onlyPayloadSize(2*32) returns (bool success) {
_transfer(msg.sender, to, tokens);
return true;
}
function approve(address spender, uint tokens) public whenNotPaused returns (bool success) {
allowed[msg.sender][spender] = tokens;
emit Approval(msg.sender, spender, tokens);
return true;
}
function transferFrom(address from, address to, uint tokens) public whenNotPaused onlyPayloadSize(3*32) returns (bool success) {
balances[from] = balances[from].sub(tokens);
allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);
balances[to] = balances[to].add(tokens);
emit Transfer(from, to, tokens);
return true;
}
function allowance(address tokenOwner, address spender) public  whenNotPaused constant returns (uint remaining) {
return allowed[tokenOwner][spender];
}
function sell(address _recipient, uint256 _value) internal whenNotPaused returns (bool success) {
_transfer (owner, _recipient, _value);
return true;
}
function _transfer(address _from, address _to, uint _value) internal {
assert(_value > 0);
require (_to != 0x0);
require (balances[_from] >= _value);
require (balances[_to] + _value >= balances[_to]);
balances[_from] = balances[_from].sub(_value);
balances[_to] = balances[_to].add(_value);
emit Transfer(_from, _to, _value);
}
function burn(uint256 _value) public returns (bool success) {
require(balances[msg.sender] >= _value);
balances[msg.sender] =  balances[msg.sender].sub(_value);
totalSupply = totalSupply.sub(_value);
emit Burn(msg.sender, _value);
return true;
}
function burnFrom(address _from, uint256 _value) public returns (bool success) {
require(balances[_from] >= _value);
require(_value <= allowed[_from][msg.sender]);
balances[_from] =  balances[_from].sub(_value);
allowed[_from][msg.sender] =   allowed[_from][msg.sender].sub(_value);
totalSupply = totalSupply.sub(_value);
emit Burn(_from, _value);
return true;
}
}
contract BexProContract is TokenERC20Standart{
using SafeMath for uint256;
mapping (address => bool) public frozenAccount;
event FrozenFunds(address target, bool frozen);
constructor () public {
name = "BEXPRO";
decimals = 18;
symbol = "BPRO";
owner = msg.sender;
version = "1";
totalSupply = 502000000 * 10 ** uint256(decimals);
balances[msg.sender] = totalSupply;
emit Transfer(address(0x0), msg.sender, totalSupply);
}
function _transfer(address _from, address _to, uint _value) internal {
require (_to != 0x0);
require (balances[_from] >= _value);
require (balances[_to] + _value >= balances[_to]);
require(!frozenAccount[_from]);
require(!frozenAccount[_to]);
balances[_from] = balances[_from].sub(_value);
balances[_to] = balances[_to].add(_value);
emit Transfer(_from, _to, _value);
}
function transfer(address _to, uint _value) public returns (bool) {
super._transfer(msg.sender, _to, _value);
return true;
}
function transferFrom(address _from, address _to, uint _value) public returns (bool) {
require(!frozenAccount[_from]);
require(!frozenAccount[_to]);
return super.transferFrom(_from, _to, _value);
}
function () public payable {
revert();
}
function freezeAccount(address target, bool freeze) onlyOwner public {
frozenAccount[target] = freeze;
emit FrozenFunds(target, freeze);
}
}