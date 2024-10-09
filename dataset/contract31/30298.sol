pragma solidity ^0.4.17;
contract SafeMath {
function SafeMath() {
}
function safeAdd(uint256 _x, uint256 _y) internal returns (uint256) {
uint256 z = _x + _y;
assert(z >= _x);
return z;
}
function safeSub(uint256 _x, uint256 _y) internal returns (uint256) {
assert(_x >= _y);
return _x - _y;
}
function safeMul(uint256 _x, uint256 _y) internal returns (uint256) {
uint256 z = _x * _y;
assert(_x == 0 || z / _x == _y);
return z;
}
}
contract IERC20Token {
function name() public constant returns (string name) { name; }
function symbol() public constant returns (string symbol) { symbol; }
function decimals() public constant returns (uint8 decimals) { decimals; }
function totalSupply() public constant returns (uint256 totalSupply) { totalSupply; }
function balanceOf(address _owner) public constant returns (uint256 balance) { _owner; balance; }
function allowance(address _owner, address _spender) public constant returns (uint256 remaining) { _owner; _spender; remaining; }
function transfer(address _to, uint256 _value) public returns (bool success);
function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
function approve(address _spender, uint256 _value) public returns (bool success);
}
contract HackToken is IERC20Token, SafeMath {
string public standard = 'HACK';
string public name = 'HACK';
string public symbol = 'HACK';
uint8 public decimals = 18;
mapping (address => uint256) public balanceOf;
mapping (address => mapping (address => uint256)) public allowance;
address public owner;
event Transfer(address indexed _from, address indexed _to, uint256 _value);
event Approval(address indexed _owner, address indexed _spender, uint256 _value);
struct bounty {
uint256 amount;
string repository;
string issue;
uint256 deadline;
address creatorAddress;
address closerAddress;
string status;
}
uint256 public decimalMultiplier = 1000000000000000000;
function HackToken() {
owner = msg.sender;
}
function issueTokens(address _target,uint256 _amount) onlyOwner public {
balanceOf[_target] = _amount;
}
modifier validAddress(address _address) {
require(_address != 0x0);
_;
}
modifier onlyOwner() {
require(msg.sender == owner);
_;
}
function transfer(address _to, uint256 _value)
public
validAddress(_to)
returns (bool success)
{
balanceOf[msg.sender] = safeSub(balanceOf[msg.sender], _value);
balanceOf[_to] = safeAdd(balanceOf[_to], _value);
Transfer(msg.sender, _to, _value);
return true;
}
function transferFrom(address _from, address _to, uint256 _value)
public
validAddress(_from)
validAddress(_to)
returns (bool success)
{
allowance[_from][msg.sender] = safeSub(allowance[_from][msg.sender], _value);
balanceOf[_from] = safeSub(balanceOf[_from], _value);
balanceOf[_to] = safeAdd(balanceOf[_to], _value);
Transfer(_from, _to, _value);
return true;
}
function approve(address _spender, uint256 _value)
public
validAddress(_spender)
returns (bool success)
{
require(_value == 0 || allowance[msg.sender][_spender] == 0);
allowance[msg.sender][_spender] = _value;
Approval(msg.sender, _spender, _value);
return true;
}
}