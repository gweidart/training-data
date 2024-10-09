pragma solidity ^0.4.18;
library SafeMath {
function mul(uint a, uint b) pure internal returns (uint) {
uint c = a * b;
assert(a == 0 || c / a == b);
return c;
}
function div(uint a, uint b) pure internal returns (uint) {
uint c = a / b;
return c;
}
function sub(uint a, uint b) pure internal returns (uint) {
assert(b <= a);
return a - b;
}
function add(uint a, uint b) pure internal returns (uint) {
uint c = a + b;
assert(c >= a);
return c;
}
function max64(uint64 a, uint64 b) pure internal returns (uint64) {
return a >= b ? a : b;
}
function min64(uint64 a, uint64 b) pure internal returns (uint64) {
return a < b ? a : b;
}
function max256(uint256 a, uint256 b) pure internal returns (uint256) {
return a >= b ? a : b;
}
function min256(uint256 a, uint256 b) pure internal returns (uint256) {
return a < b ? a : b;
}
}
contract ERC20Basic {
uint public totalSupply;
function balanceOf(address who) public constant returns (uint);
function transfer(address to, uint value) public;
event Transfer(address indexed from, address indexed to, uint value);
}
contract BasicToken is ERC20Basic {
using SafeMath for uint;
mapping(address => uint) public balances;
modifier onlyPayloadSize(uint size) {
assert(msg.data.length >= size + 4);
_;
}
function transfer(address _to, uint _value) public onlyPayloadSize(2 * 32) {
balances[msg.sender] = balances[msg.sender].sub(_value);
balances[_to] = balances[_to].add(_value);
Transfer(msg.sender, _to, _value);
}
function balanceOf(address _owner) public constant returns (uint balance) {
return balances[_owner];
}
}
contract ERC20 is ERC20Basic {
function allowance(address owner, address spender) public constant returns (uint);
function transferFrom(address from, address to, uint value) public;
function approve(address spender, uint value) public;
event Approval(address indexed owner, address indexed spender, uint value);
}
contract StandardToken is BasicToken, ERC20 {
mapping (address => mapping (address => uint)) allowed;
function transferFrom(address _from, address _to, uint _value) public onlyPayloadSize(3 * 32) {
var _allowance = allowed[_from][msg.sender];
balances[_to] = balances[_to].add(_value);
balances[_from] = balances[_from].sub(_value);
allowed[_from][msg.sender] = _allowance.sub(_value);
Transfer(_from, _to, _value);
}
function approve(address _spender, uint _value) public {
require((_value == 0) || (allowed[msg.sender][_spender] == 0));
allowed[msg.sender][_spender] = _value;
Approval(msg.sender, _spender, _value);
}
function allowance(address _owner, address _spender) public constant returns (uint remaining) {
return allowed[_owner][_spender];
}
}
contract Ownable {
address public owner;
function Ownable() public {
owner = msg.sender;
}
modifier onlyOwner() {
require (msg.sender == owner);
_;
}
function transferOwnership(address newOwner) public onlyOwner {
if (newOwner != address(0)) {
owner = newOwner;
}
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
modifier whenPaused {
require(paused);
_;
}
function pause() public onlyOwner whenNotPaused returns (bool) {
paused = true;
Pause();
return true;
}
function unpause() public onlyOwner whenPaused returns (bool) {
paused = false;
Unpause();
return true;
}
}
contract PausableToken is StandardToken, Pausable {
function transfer(address _to, uint _value) public whenNotPaused {
super.transfer(_to, _value);
}
function transferFrom(address _from, address _to, uint _value) public whenNotPaused {
super.transferFrom(_from, _to, _value);
}
}
contract MintableToken is StandardToken, PausableToken {
event Mint(address indexed to, uint value);
event MintFinished();
bool public mintingFinished = false;
modifier canMint() {
require(!mintingFinished);
_;
}
function mint(address _to, uint _amount) public onlyOwner canMint returns (bool) {
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
contract BurnableToken is StandardToken, PausableToken {
using SafeMath for uint;
event Burn(address indexed from, uint value);
function burn(address _from, uint _amount) public onlyOwner returns (bool) {
totalSupply = totalSupply.sub(_amount);
balances[_from] = balances[_from].sub(_amount);
Burn(_from, _amount);
return true;
}
}
contract DealToken is MintableToken, BurnableToken {
using SafeMath for uint256;
string public constant name = "Deal Token";
string public constant symbol = "DEAL";
uint8 public constant decimals = 8;
uint public constant initialSupply = 30000000000000000;
function DealToken() public {
totalSupply = initialSupply;
balances[msg.sender] = totalSupply;
}
}