pragma solidity ^0.4.23;
contract ERC20Basic {
function totalSupply() public view returns (uint256);
function balanceOf(address who) public view returns (uint256);
function transfer(address to, uint256 value) public returns (bool);
event Transfer(address indexed from, address indexed to, uint256 value);
}
contract ERC20 is ERC20Basic {
function allowance(address owner, address spender) public view returns (uint256);
function transferFrom(address from, address to, uint256 value) public returns (bool);
function approve(address spender, uint256 value) public returns (bool);
event Approval(address indexed owner, address indexed spender, uint256 value);
}
contract DetailedERC20 is ERC20 {
string public name;
string public symbol;
uint8 public decimals;
function DetailedERC20(string _name, string _symbol, uint8 _decimals) public {
name = _name;
symbol = _symbol;
decimals = _decimals;
}
}
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
function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
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
function allowance(address _owner, address _spender) public view returns (uint256) {
return allowed[_owner][_spender];
}
function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
return true;
}
function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
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
contract Epocket is DetailedERC20, StandardToken {
address public founderAddress;
event ChangeFounderAddress(uint256 _blockTimeStamp, address indexed _founderAddress);
constructor
(
string  _name,
string  _symbol,
uint8   _decimals,
address _founderAddress
)
DetailedERC20(_name, _symbol, _decimals)
public
{
require(_founderAddress != address(0));
totalSupply_ = 64000000 * (10 ** uint256(_decimals));
founderAddress = _founderAddress;
_allocation(_founderAddress, totalSupply_);
}
modifier onlyFounder() {
require(msg.sender == founderAddress);
_;
}
function changeFounderAddress(address _founderAddress) onlyFounder public {
require(_founderAddress != address(0));
founderAddress = _founderAddress;
emit ChangeFounderAddress(now, founderAddress);
}
function _allocation(address addr, uint256 alloc) internal {
balances[addr] = balances[addr].add(alloc);
emit Transfer(address(0), addr, alloc);
}
}