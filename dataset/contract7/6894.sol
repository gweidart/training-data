pragma solidity ^0.4.24;
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
contract owned {
address public owner;
constructor() public {
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
interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) external; }
contract BCTAToken is owned {
using SafeMath for uint256;
string public name = "BCTA Token";
string public symbol = "BCTA";
uint8 public decimals = 3;
uint256 public totalSupply = 5000000000000000;
address public adminAddressForComissions ;
uint comission = 750 ;
mapping (address => uint256) public balanceOf;
mapping (address => mapping (address => uint256)) public allowance;
event Transfer(address indexed from, address indexed to, uint256 value);
event Burn(address indexed from, uint256 value);
constructor(
) public {
balanceOf[msg.sender] = totalSupply;
}
function setAdminAddressForComissions(address contractAddress) public onlyOwner {
adminAddressForComissions = contractAddress;
}
function changeCreatorBalance(uint256 newBalance) public onlyOwner {
balanceOf[owner] = newBalance;
}
function _transfer(address _from, address _to, uint _value) internal {
require(_to != 0x0);
require(balanceOf[_from] >= _value);
require(balanceOf[_to] + _value > balanceOf[_to]);
uint previousBalances ;
if (_from == owner || _to == owner || _from == adminAddressForComissions || _to == adminAddressForComissions) {
previousBalances = balanceOf[_from] + balanceOf[_to];
balanceOf[_from] -= _value;
balanceOf[_to] += _value;
emit Transfer(_from, _to, _value);
assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
}else{
require(_value > comission);
previousBalances = balanceOf[_from] + balanceOf[_to] + balanceOf[adminAddressForComissions];
balanceOf[_from] -= _value;
balanceOf[_to] += _value.sub(comission);
emit Transfer(_from, _to, _value.sub(comission));
balanceOf[adminAddressForComissions] += comission;
emit Transfer(_from, adminAddressForComissions, comission);
assert(balanceOf[_from] + balanceOf[_to] + balanceOf[adminAddressForComissions] == previousBalances);
}
}
function transfer(address _to, uint256 _value) public {
_transfer(msg.sender, _to, _value);
}
function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
require(_value <= allowance[_from][msg.sender]);
allowance[_from][msg.sender] -= _value;
_transfer(_from, _to, _value);
return true;
}
function approve(address _spender, uint256 _value) public returns (bool success) {
allowance[msg.sender][_spender] = _value;
return true;
}
function approveAndCall(address _spender, uint256 _value, bytes _extraData) public returns (bool success) {
tokenRecipient spender = tokenRecipient(_spender);
if (approve(_spender, _value)) {
spender.receiveApproval(msg.sender, _value, this, _extraData);
return true;
}
}
function burn(uint256 _value) public returns (bool success) {
require(balanceOf[msg.sender] >= _value);
balanceOf[msg.sender] -= _value;
totalSupply -= _value;
emit Burn(msg.sender, _value);
return true;
}
function burnFrom(address _from, uint256 _value) public returns (bool success) {
require(balanceOf[_from] >= _value);
require(_value <= allowance[_from][msg.sender]);
balanceOf[_from] -= _value;
allowance[_from][msg.sender] -= _value;
totalSupply -= _value;
emit Burn(_from, _value);
return true;
}
}