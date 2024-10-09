pragma solidity ^0.4.16;
contract owned {
address public owner;
event TransferOwnership (address indexed _owner, address indexed _newOwner);
function owned() public {
owner = msg.sender;
}
function transferOwnership(address newOwner) onlyOwner() public {
TransferOwnership (owner, newOwner);
owner = newOwner;
}
modifier onlyOwner {
require(msg.sender == owner);
_;
}
modifier onlyPayloadSize(uint size) {
assert(msg.data.length >= size + 4);
_;
}
}
contract YourMomToken is owned {
mapping (address => uint256) public balanceOf;
mapping (address => mapping (address => uint256)) public allowance;
uint256 public totalSupply;
string public name;
string public symbol;
uint8 public decimals;
event Transfer(address indexed from, address indexed to, uint256 value);
event Approval(address indexed _owner, address indexed _spender, uint _value);
event Burn(address indexed from, uint256 value);
function YourMomToken(string tokenName, string tokenSymbol, uint256 initialSupplyInEther) public {
name = tokenName;
symbol = tokenSymbol;
decimals = 18;
totalSupply = initialSupplyInEther * 10**18;
balanceOf[msg.sender] = totalSupply;
}
function name() public constant returns (string) { return name; }
function symbol() public constant returns (string) { return symbol; }
function decimals() public constant returns (uint8) { return decimals; }
function totalSupply() public constant returns (uint256) { return totalSupply; }
function balanceOf(address _owner) public constant returns (uint256 balance) { return balanceOf[_owner]; }
function allowance(address _owner, address _spender) public constant returns (uint256 remaining) { return allowance[_owner][_spender]; }
function transfer(address _to, uint256 _value) onlyPayloadSize (2 * 32) public returns (bool success) {
_transfer(msg.sender, _to, _value);
return true;
}
function transferFrom(address _from, address _to, uint256 _value) onlyPayloadSize (3 * 32) public returns (bool success) {
require(_value <= allowance[_from][msg.sender]);
_transfer(_from, _to, _value);
allowance[_from][msg.sender] -= _value;
return true;
}
function _transfer(address _from, address _to, uint _value) internal returns (bool success) {
require(_to != 0x0);
require(balanceOf[_from] >= _value);
require(balanceOf[_to] + _value >= balanceOf[_to]);
require(_value != 0);
require(_from != _to);
balanceOf[_from] -= _value;
balanceOf[_to] += _value;
Transfer(_from, _to, _value);
return true;
}
function approve(address _spender, uint256 _value) public returns (bool success) {
require((_value == 0) || (allowance[msg.sender][_spender] == 0));
require(_value != allowance[msg.sender][_spender]);
allowance[msg.sender][_spender] = _value;
Approval(msg.sender, _spender, _value);
return true;
}
function burn(uint256 _value) public returns (bool success) {
require(balanceOf[msg.sender] >= _value);
require(_value != 0);
balanceOf[msg.sender] -= _value;
totalSupply -= _value;
Burn(msg.sender, _value);
return true;
}
}