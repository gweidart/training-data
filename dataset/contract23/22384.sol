pragma solidity ^0.4.11;
library SafeMath {
function mul(uint256 a, uint256 b) internal constant returns (uint256) {
uint256 c = a * b;
assert(a == 0 || c / a == b);
return c;
}
function div(uint256 a, uint256 b) internal constant returns (uint256) {
uint256 c = a / b;
return c;
}
function sub(uint256 a, uint256 b) internal constant returns (uint256) {
assert(b <= a);
return a - b;
}
function add(uint256 a, uint256 b) internal constant returns (uint256) {
uint256 c = a + b;
assert(c >= a);
return c;
}
}
contract ERC20Basic {
uint256 public totalSupply;
function balanceOf(address who) constant returns (uint256);
function transfer(address to, uint256 value) returns (bool);
event Transfer(address indexed from, address indexed to, uint256 value);
}
contract BasicToken is ERC20Basic {
using SafeMath for uint256;
mapping(address => uint256) balances;
function transfer(address _to, uint256 _value) returns (bool) {
balances[msg.sender] = balances[msg.sender].sub(_value);
balances[_to] = balances[_to].add(_value);
Transfer(msg.sender, _to, _value);
return true;
}
function balanceOf(address _owner) constant returns (uint256 balance) {
return balances[_owner];
}
}
contract ERC20 is ERC20Basic {
function allowance(address owner, address spender) constant returns (uint256);
function transferFrom(address from, address to, uint256 value) returns (bool);
function approve(address spender, uint256 value) returns (bool);
event Approval(address indexed _owner, address indexed _spender, uint _value);
}
contract StandardToken is ERC20, BasicToken {
mapping (address => mapping (address => uint256)) allowed;
function transferFrom(address _from, address _to, uint256 _value) returns (bool) {
var _allowance = allowed[_from][msg.sender];
balances[_from] = balances[_from].sub(_value);
balances[_to] = balances[_to].add(_value);
allowed[_from][msg.sender] = _allowance.sub(_value);
Transfer(_from, _to, _value);
return true;
}
function approve(address _spender, uint256 _value) returns (bool) {
require((_value == 0) || (allowed[msg.sender][_spender] == 0));
allowed[msg.sender][_spender] = _value;
Approval(msg.sender, _spender, _value);
return true;
}
function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
return allowed[_owner][_spender];
}
}
contract TCGC is StandardToken {
string public constant name = "TRILLION CLOUD GOLD";
string public constant symbol = "TCGC";
uint public constant decimals = 18;
uint public freezeTime = now + 1 years;
address public owner;
mapping(address=>bool) public freezeList;
uint public freezeSupply;
uint public distributeSupply;
uint public distributed;
uint public exchangeSupply;
uint public exchanged;
uint public price ;
uint public mintTimes;
event DoMint(uint256 n,uint256 number);
event Burn(address from, uint256 value);
modifier onlyOwner() {
require(msg.sender == owner);
_;
}
function TCGC(address _owner){
owner = _owner;
price =700;
totalSupply=17*(10**7)*10**decimals;
freezeSupply = totalSupply/2;
distributeSupply = totalSupply*2/5;
exchangeSupply = totalSupply/10;
balances[owner] = totalSupply;
Transfer(address(0x0), owner, totalSupply);
}
modifier validUser(address addr){
require(!freezeList[addr]);
_;
}
function addFreeze(address addr) onlyOwner returns(bool){
require(!freezeList[addr]);
freezeList[addr] =true;
return true;
}
function unFreeze(address addr) onlyOwner returns(bool){
require(freezeList[addr]);
delete freezeList[addr];
return true;
}
function setPrice(uint _price) onlyOwner{
require( _price > 0);
price= _price;
}
function transfer(address _to, uint _value) validUser(msg.sender) returns (bool){
if(msg.sender == owner && now < freezeTime){
require(balances[owner] >_value && balances[owner] - _value >= freezeSupply);
require (distributed + _value <= distributeSupply);
distributed = distributed.add(_value);
super.transfer(_to,_value);
}else{
super.transfer(_to,_value);
}
}
function mint(uint256 num) onlyOwner{
balances[owner] = balances[owner].add(num);
totalSupply = totalSupply.add(num);
distributeSupply = distributeSupply.add(num);
Transfer( address(0x0),msg.sender, num);
DoMint(mintTimes++,num);
}
function burn(uint256 _value) public returns (bool success) {
require(balances[msg.sender] >= _value);
balances[msg.sender] = balances[msg.sender].sub(_value);
totalSupply = totalSupply.sub(_value);
Transfer(msg.sender, address(0x0), _value);
Burn(msg.sender, _value);
return true;
}
function() payable {
uint tokens = price.mul(msg.value);
require(tokens  <= balances[owner] && exchanged+tokens <= exchangeSupply);
balances[owner] = balances[owner].sub(tokens);
balances[msg.sender] = balances[msg.sender].add(tokens);
exchanged =  exchanged.add(tokens);
owner.transfer(msg.value);
Transfer(owner, msg.sender, tokens);
}
}