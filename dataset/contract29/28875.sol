pragma solidity ^0.4.18;
contract ERC20Basic {
function totalSupply() public view returns (uint256);
function balanceOf(address who) public view returns (uint256);
function transfer(address to, uint256 value) public returns (bool);
event Transfer(address indexed from, address indexed to, uint256 value);
}
contract ERC20 is ERC20Basic {
function allowance(address tokenOwner, address spender) public constant returns (uint remaining);
function transferFrom(address from, address to, uint tokens) public returns (bool success);
function approve(address spender, uint tokens) public returns (bool success);
event Approval(address indexed owner, address indexed spender, uint256 value);
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
contract owned {
address public owner;
function owned() public {
owner = msg.sender;
}
modifier onlyOwner {
require(msg.sender == owner);
_;
}
function transferOwnership(address newOwner) onlyOwner public {
owner = newOwner;
}
}
contract BasicToken is ERC20 {
using SafeMath for uint256;
mapping(address => uint256) balances;
uint256 totalSupply_;
function totalSupply() public view returns (uint256) {
return totalSupply_;
}
function balanceOf(address _owner) public view returns (uint256 balance) {
return balances[_owner];
}
}
contract StandardToken is  BasicToken ,owned{
mapping (address => mapping (address => uint256)) internal allowed;
function approve(address _spender, uint256 _value)onlyOwner public  returns (bool) {
allowed[msg.sender][_spender] = _value;
Approval(msg.sender, _spender, _value);
return true;
}
function allowance(address _owner, address _spender)public view returns (uint256) {
return allowed[_owner][_spender];
}
function increaseApproval(address _spender, uint _addedValue)onlyOwner public returns (bool) {
allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
return true;
}
function decreaseApproval(address _spender, uint _subtractedValue)onlyOwner public returns (bool) {
uint oldValue = allowed[msg.sender][_spender];
if (_subtractedValue > oldValue) {
allowed[msg.sender][_spender] = 0;
} else {
allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
}
Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
return true;
}
}
contract StateofTaiwanToken is StandardToken{
string public name;
string public symbol;
uint256 public totalSupply;
uint8 public decimals=6;
mapping (address => bool) public frozenAccount;
event Burn(address indexed from, uint256 value);
event FrozenFunds(address target, bool frozen);
function StateofTaiwanToken() public onlyOwner{
totalSupply = (189500000000 *10**uint256(decimals));
balances[msg.sender] = totalSupply;
name = "TaiwanIsaCountry";
symbol = "TOK";
}
function burn(uint256 _value) public returns (bool success) {
require(balances[msg.sender] >= _value);
balances[msg.sender] -= _value;
totalSupply -= _value;
Burn(msg.sender, _value);
return true;
}
function freezeAccount(address target, bool freeze) onlyOwner public {
frozenAccount[target] = freeze;
FrozenFunds(target, freeze);
}
function _transfer(address _from, address _to, uint256 _value) internal{
require(_to != address(0));
require(_value <= balances[_from]);
require(!frozenAccount[_from]);
require(!frozenAccount[_to]);
balances[msg.sender] = balances[msg.sender].sub(_value);
balances[_to] = balances[_to].add(_value);
Transfer(msg.sender, _to, _value);
}
function transfer(address _to, uint256 _value) public returns(bool){
_transfer(msg.sender, _to, _value);
return true;
}
function transferFrom(address _from, address _to, uint tokens) public returns (bool success) {
require(_to != address(0));
require(tokens <= balances[_from]);
require(tokens <= allowed[_from][msg.sender]);
require(!frozenAccount[_from]);
require(!frozenAccount[_to]);
balances[_from] = balances[_from].sub(tokens);
allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(tokens);
balances[_to] = balances[_to].add(tokens);
Transfer(_from, _to, tokens);
return true;
}
}