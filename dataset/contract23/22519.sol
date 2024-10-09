pragma solidity ^0.4.18;
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
interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) public; }
contract TOKENERC20 {
string public name;
string public symbol;
uint8 public decimals = 18;
uint256 public totalSupply;
mapping (address => uint256) public balanceOf;
mapping (address => mapping (address => uint256)) public allowance;
event Transfer(address indexed from, address indexed to, uint256 value);
event Burn(address indexed from, uint256 value);
function TOKENERC20(
uint256 initialSupply,
string tokenName,
string tokenSymbol
) public {
totalSupply = initialSupply * 10 ** uint256(decimals);
balanceOf[msg.sender] = totalSupply;
name = tokenName;
symbol = tokenSymbol;
}
function _transfer(address _from, address _to, uint _value) internal {
require(_to != 0x0);
require(balanceOf[_from] >= _value);
require(balanceOf[_to] + _value > balanceOf[_to]);
uint previousBalances = balanceOf[_from] + balanceOf[_to];
balanceOf[_from] -= _value;
balanceOf[_to] += _value;
Transfer(_from, _to, _value);
assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
}
function transfer(address _to, uint256 _value) public {
_transfer(msg.sender, _to, _value);
}
function approve(address _spender, uint256 _value) public
returns (bool success) {
allowance[msg.sender][_spender] = _value;
return true;
}
function approveAndCall(address _spender, uint256 _value, bytes _extraData)
public
returns (bool success) {
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
Burn(msg.sender, _value);
return true;
}
}
contract FideliumToken is owned, TOKENERC20 {
event ApprovedFunds(address target, bool approved);
function FideliumToken (
uint256 initialSupply,
string tokenName,
string tokenSymbol
) TOKENERC20(initialSupply, tokenName, tokenSymbol) public {}
function _transfer(address _from, address _to, uint256 _value) internal {
require (_to != 0x0);
require (balanceOf[_from] >= _value);
require (balanceOf[_to] + _value > balanceOf[_to]);
balanceOf[_from] -= _value;
balanceOf[_to] += _value;
Transfer(_from, _to, _value);
}
}