pragma solidity ^0.4.21;
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
function toUINT112(uint256 a) internal pure returns(uint112) {
assert(uint112(a) == a);
return uint112(a);
}
function toUINT120(uint256 a) internal pure returns(uint120) {
assert(uint120(a) == a);
return uint120(a);
}
function toUINT128(uint256 a) internal pure returns(uint128) {
assert(uint128(a) == a);
return uint128(a);
}
}
contract ERC20Basic {
string public name;
string public symbol;
uint256 public totalSupply;
uint8 public constant decimals = 18;
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
contract BasicToken is ERC20Basic {
using SafeMath for uint256;
mapping(address => uint256) balances;
uint256 airdropTotalSupply;
uint256 airdropCurrentSupply;
uint256 airdropNum;
mapping(address => bool) touched;
function _transfer(address _from, address _to, uint _value) internal {
initialize(_from);
require(_to != address(0));
require(_value <= balances[_from]);
initialize(_to);
balances[_from] = balances[_from].sub(_value);
balances[_to] = balances[_to].add(_value);
}
function transfer(address _to, uint256 _value) public returns (bool) {
_transfer(msg.sender, _to, _value);
emit Transfer(msg.sender, _to, _value);
return true;
}
function balanceOf(address _owner) public view returns (uint256 balance) {
return getBalance(_owner);
}
function initialize(address _address) internal returns (bool success) {
if (airdropCurrentSupply < airdropTotalSupply && !touched[_address]) {
touched[_address] = true;
airdropCurrentSupply = airdropCurrentSupply.add(airdropNum);
balances[_address] = balances[_address].add(airdropNum);
totalSupply = totalSupply.add(airdropNum);
}
return true;
}
function getBalance(address _address) internal view returns (uint256) {
if (airdropCurrentSupply < airdropTotalSupply && !touched[_address]) {
return balances[_address].add(airdropNum);
} else {
return balances[_address];
}
}
}
interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) external; }
contract StandardToken is ERC20, BasicToken {
mapping (address => mapping (address => uint256)) internal allowed;
function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
require(_value <= allowed[_from][msg.sender]);
_transfer(_from, _to, _value);
allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
emit Transfer(_from, _to, _value);
return true;
}
function approve(address _spender, uint256 _value) public returns (bool) {
allowed[msg.sender][_spender] = _value;
emit Approval(msg.sender, _spender, _value);
return true;
}
function approveAndCall(address _spender, uint256 _value, bytes _extraData) public returns (bool success) {
tokenRecipient spender = tokenRecipient(_spender);
if (approve(_spender, _value)) {
spender.receiveApproval(msg.sender, _value, this, _extraData);
return true;
}
}
function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
return allowed[_owner][_spender];
}
event Burn(address indexed from, uint256 value);
function burn(uint256 _value) public returns (bool success) {
require(balanceOf(msg.sender) >= _value);
balances[msg.sender] = balances[msg.sender].sub(_value);
totalSupply = totalSupply.sub(_value);
emit Burn(msg.sender, _value);
return true;
}
function burnFrom(address _from, uint256 _value) public returns (bool success) {
require(balanceOf(_from) >= _value);
require(_value <= allowance(_from, msg.sender));
balances[_from] = balances[_from].sub(_value);
allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
totalSupply = totalSupply.sub(_value);
emit Burn(_from, _value);
return true;
}
}
contract BCD is StandardToken {
constructor(
uint256 _initialSupply,
string _tokenName,
string _tokenSymbol,
uint _airdropTotalSupply,
uint256 _airdropNum
) public {
touched[msg.sender] = true;
totalSupply = _initialSupply * 10 ** uint256(decimals);
balances[msg.sender] = totalSupply;
name = _tokenName;
symbol = _tokenSymbol;
airdropTotalSupply = _airdropTotalSupply * 10 ** uint256(decimals);
airdropNum = _airdropNum * 10 ** uint256(decimals);
}
}