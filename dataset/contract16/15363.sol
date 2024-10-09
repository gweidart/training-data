pragma solidity ^0.4.15;
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
contract GRAD {
using SafeMath for uint256;
string public name = "Gadus";
string public symbol = "GRAD";
uint public decimals = 18;
uint256 public totalSupply;
address owner;
mapping(address => uint256) balances;
mapping (address => mapping (address => uint256)) allowed;
event Approval(address indexed tokenOwner, address indexed spender, uint256 value);
event Mint (address indexed to, uint256  amount);
event Transfer(address indexed from, address indexed to, uint256 value);
function GRAD() public{
owner = msg.sender;
}
function mint(address _to, uint256 _value) onlyOwner public returns (bool){
balances[_to] = balances[_to].add(_value);
totalSupply = totalSupply.add(_value);
Mint(_to, _value);
return true;
}
function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
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
function transfer(address _to, uint256 _value) public returns (bool) {
balances[msg.sender] = balances[msg.sender].sub(_value);
balances[_to] = balances[_to].add(_value);
Transfer(msg.sender, _to, _value);
return true;
}
function balanceOf(address _owner) public constant returns (uint256 balance) {
return balances[_owner];
}
modifier onlyOwner() {
require(msg.sender == owner);
_;
}
}