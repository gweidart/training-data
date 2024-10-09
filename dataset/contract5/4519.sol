pragma solidity ^0.4.24;
contract Token {
uint256 public totalSupply;
function balanceOf(address _owner) public view returns (uint256 balance);
function transfer(address _to, uint256 _value) public returns (bool success);
function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
function approve(address _spender, uint256 _value) public returns (bool success);
function allowance(address _owner, address _spender) public view returns (uint256 remaining);
event Transfer(address indexed _from, address indexed _to, uint256 _value);
event Approval(address indexed _owner, address indexed _spender, uint256 _value);
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
contract StandardToken is Token {
uint256 constant MAX_UINT256 = 2**256 - 1;
bool transferEnabled = false;
function transfer(address _to, uint256 _value) public returns (bool success) {
require(balances[msg.sender] >= _value);
require(transferEnabled);
balances[msg.sender] -= _value;
balances[_to] += _value;
Transfer(msg.sender, _to, _value);
return true;
}
function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
uint256 allowance = allowed[_from][msg.sender];
require(balances[_from] >= _value && allowance >= _value);
require(transferEnabled);
balances[_to] += _value;
balances[_from] -= _value;
if (allowance < MAX_UINT256) {
allowed[_from][msg.sender] -= _value;
}
Transfer(_from, _to, _value);
return true;
}
function balanceOf(address _owner) view public returns (uint256 balance) {
return balances[_owner];
}
function approve(address _spender, uint256 _value) public returns (bool success) {
allowed[msg.sender][_spender] = _value;
Approval(msg.sender, _spender, _value);
return true;
}
function allowance(address _owner, address _spender) view public returns (uint256 remaining) {
return allowed[_owner][_spender];
}
mapping (address => uint256) balances;
mapping (address => mapping (address => uint256)) allowed;
}
contract AWAToken is StandardToken {
using SafeMath for uint;
uint8 public constant decimals = 6;
uint256 public totalSupply = 500000000*10**6;
string public constant symbol = "AWA";
string public constant name = "AWA Token";
address public contractOwner;
address public futureOwner;
function AWAToken() public {
balances[0xb604312C372FbC942B56151BedD76435ECBd7666] = totalSupply;
contractOwner = 0xb604312C372FbC942B56151BedD76435ECBd7666;
transferEnabled = true;
}
function enableTransfers() onlyOwner public {
transferEnabled = true;
}
function disableTransfers() onlyOwner public {
transferEnabled = false;
}
modifier onlyOwner() {
require(msg.sender == contractOwner);
_;
}
function destroyToken() public onlyOwner{
balances[msg.sender] = 0;
}
function transferOwnership(address _newOwner) public onlyOwner {
require(_newOwner != address(0));
futureOwner = _newOwner;
}
function claimOwnership() public {
require(msg.sender == futureOwner);
contractOwner = msg.sender;
futureOwner = address(0);
}
}