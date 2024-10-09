pragma solidity ^0.4.16;
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
require(newOwner != 0x0);
owner = newOwner;
}
}
contract SafeMath {
function mul(uint a, uint b) internal returns (uint) {
uint c = a * b;
assert(a == 0 || c / a == b);
return c;
}
function div(uint a, uint b) internal returns (uint) {
assert(b > 0);
uint c = a / b;
assert(a == b * c + a % b);
return c;
}
function sub(uint a, uint b) internal returns (uint) {
assert(b <= a);
return a - b;
}
function add(uint a, uint b) internal returns (uint) {
uint c = a + b;
assert(c>=a && c>=b);
return c;
}
}
interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) public; }
contract TokenPAD is owned, SafeMath {
string public name = "Platform for Air Drops";
string public symbol = "PAD";
uint8 public decimals = 18;
uint256 public totalSupply = 15000000000000000000000000;
mapping (address => uint256) public balanceOf;
mapping (address => mapping (address => uint256)) public allowance;
event Transfer(address indexed from, address indexed to, uint256 value);
event Burn(address indexed from, uint256 value);
function TokenPAD(
) public {
balanceOf[msg.sender] = totalSupply;
}
function _transfer(address _from, address _to, uint _value) internal {
require(_to != 0x0);
require(balanceOf[_from] >= _value);
require(add(balanceOf[_to],_value) > balanceOf[_to]);
uint previousBalances = add(balanceOf[_from], balanceOf[_to]);
balanceOf[_from] = sub(balanceOf[_from],_value);
balanceOf[_to] =add(balanceOf[_to],_value);
Transfer(_from, _to, _value);
assert(add(balanceOf[_from],balanceOf[_to]) == previousBalances);
}
function transfer(address _to, uint _value) public {
_transfer(msg.sender, _to, _value);
}
function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
require(_value <= allowance[_from][msg.sender]);
allowance[_from][msg.sender] = sub(allowance[_from][msg.sender],_value);
_transfer(_from, _to, _value);
return true;
}
function approve(address _spender, uint256 _value) public
returns (bool success) {
allowance[msg.sender][_spender] = _value;
return true;
}
function approveAndCall(address _spender, uint256 _value, bytes _extraData) onlyOwner
public
returns (bool success) {
tokenRecipient spender = tokenRecipient(_spender);
if (approve(_spender, _value)) {
spender.receiveApproval(msg.sender, _value, this, _extraData);
return true;
}
}
function burn(uint256 _value) onlyOwner public returns (bool success) {
require(balanceOf[msg.sender] >= _value);
balanceOf[msg.sender] = sub( balanceOf[msg.sender],_value);
totalSupply =sub(totalSupply,_value);
Burn(msg.sender, _value);
return true;
}
}