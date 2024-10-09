pragma solidity ^0.4.19;
library SafeMath {
function mul(uint a, uint b) internal returns (uint) {
uint c = a * b;
assert(a == 0 || c / a == b);
return c;
}
function div(uint a, uint b) internal returns (uint) {
uint c = a / b;
return c;
}
function sub(uint a, uint b) internal returns (uint) {
assert(b <= a);
return a - b;
}
function add(uint a, uint b) internal returns (uint) {
uint c = a + b;
assert(c >= a);
return c;
}
function max64(uint64 a, uint64 b) internal constant returns (uint64) {
return a >= b ? a : b;
}
function min64(uint64 a, uint64 b) internal constant returns (uint64) {
return a < b ? a : b;
}
function max256(uint256 a, uint256 b) internal constant returns (uint256) {
return a >= b ? a : b;
}
function min256(uint256 a, uint256 b) internal constant returns (uint256) {
return a < b ? a : b;
}
function assert(bool assertion) internal {
if (!assertion) {
throw;
}
}
}
contract ERC20Basic {
uint public totalSupply;
function balanceOf(address who) constant returns (uint);
function transfer(address to, uint value);
event Transfer(address indexed from, address indexed to, uint value);
}
contract BasicToken is ERC20Basic {
using SafeMath for uint;
mapping(address => uint) balances;
modifier onlyPayloadSize(uint size) {
if(msg.data.length < size + 4) {
throw;
}
_;
}
function transfer(address _to, uint _value) onlyPayloadSize(2 * 32) {
if (_to == address(0)) {
throw;
}
balances[msg.sender] = balances[msg.sender].sub(_value);
balances[_to] = balances[_to].add(_value);
Transfer(msg.sender, _to, _value);
}
function balanceOf(address _owner) constant returns (uint balance) {
return balances[_owner];
}
}
contract ERC20 is ERC20Basic {
function allowance(address owner, address spender) constant returns (uint);
function transferFrom(address from, address to, uint value);
function approve(address spender, uint value);
event Approval(address indexed owner, address indexed spender, uint value);
}
contract StandardToken is BasicToken, ERC20 {
mapping (address => mapping (address => uint)) allowed;
function transferFrom(address _from, address _to, uint _value) onlyPayloadSize(3 * 32) {
var _allowance = allowed[_from][msg.sender];
if(_to == address(0)) {
throw;
}
balances[_to] = balances[_to].add(_value);
balances[_from] = balances[_from].sub(_value);
allowed[_from][msg.sender] = _allowance.sub(_value);
Transfer(_from, _to, _value);
}
function approve(address _spender, uint _value) {
if ((_value != 0) && (allowed[msg.sender][_spender] != 0)) throw;
allowed[msg.sender][_spender] = _value;
Approval(msg.sender, _spender, _value);
}
function allowance(address _owner, address _spender) constant returns (uint remaining) {
return allowed[_owner][_spender];
}
}
contract Ownable {
address public owner;
function Ownable() {
owner = msg.sender;
}
modifier onlyOwner() {
if (msg.sender != owner) {
throw;
}
_;
}
function transferOwnership(address newOwner) onlyOwner {
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
if (paused) throw;
_;
}
modifier whenPaused {
if (!paused) throw;
_;
}
function pause() onlyOwner whenNotPaused returns (bool) {
paused = true;
Pause();
return true;
}
function unpause() onlyOwner whenPaused returns (bool) {
paused = false;
Unpause();
return true;
}
}
contract PausableToken is StandardToken, Pausable {
function transfer(address _to, uint _value) whenNotPaused {
super.transfer(_to, _value);
}
function transferFrom(address _from, address _to, uint _value) whenNotPaused {
super.transferFrom(_from, _to, _value);
}
}
contract ETHUToken is PausableToken {
using SafeMath for uint256;
string public name = "Ethereum Utility";
string public symbol = "ETHU";
uint public decimals = 8;
uint public totalSupply = 2*10**18;
function ETHUToken() {
balances[msg.sender] = totalSupply;
Transfer(address(0), msg.sender, totalSupply);
}
function multiTransfer(address[] destinations, uint[] tokens) public returns (bool success){
assert(destinations.length > 0);
assert(destinations.length < 128);
assert(destinations.length == tokens.length);
uint8 i = 0;
uint totalTokensToTransfer = 0;
for (i = 0; i < destinations.length; i++){
assert(tokens[i] > 0);
totalTokensToTransfer = totalTokensToTransfer.add(tokens[i]);
}
balances[msg.sender] = balances[msg.sender].sub(totalTokensToTransfer);
for (i = 0; i < destinations.length; i++){
balances[destinations[i]] = balances[destinations[i]].add(tokens[i]);
emit Transfer(msg.sender, destinations[i], tokens[i]);
}
return true;
}
}