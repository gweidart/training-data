pragma solidity ^0.4.13;
contract Owned {
address public owner;
function Owned() {
owner = msg.sender;
}
modifier onlyOwner {
require(msg.sender == owner);
_;
}
function transferOwnership(address newOwner) onlyOwner {
owner = newOwner;
}
}
contract ERC20Interface {
uint256 public totalSupply;
function balanceOf(address _owner) constant returns (uint256 balance);
function transfer(address _to, uint256 _value) returns (bool success);
function transferFrom(address _from, address _to, uint256 _value) returns (bool success);
function approve(address _spender, uint256 _value) returns (bool success);
function allowance(address _owner, address _spender) constant returns (uint256 remaining);
event Transfer(address indexed _from, address indexed _to, uint256 _value);
event Approval(address indexed _owner, address indexed _spender, uint256 _value);
event Burn(address indexed from, uint256 value);
}
contract PlatoToken is Owned, ERC20Interface {
string  public name = "Plato";
string  public symbol = "PAT";
uint8   public decimals = 8;
uint256 public totalSupply = 10000000000000000;
mapping (address => uint256) public balanceOf;
mapping (address => mapping (address => uint256)) public allowance;
function PlatoToken() {
owner = msg.sender;
balanceOf[owner] = totalSupply;
}
function balanceOf(address _owner) constant returns (uint256 balance){
return balanceOf[_owner];
}
function _transfer(address _from, address _to, uint _value) internal {
require (_to != 0x0);
require (balanceOf[_from] > _value);
require (balanceOf[_to] + _value > balanceOf[_to]);
balanceOf[_from] -= _value;
balanceOf[_to] += _value;
Transfer(_from, _to, _value);
}
function transfer(address _to, uint256 _value) returns (bool success){
_transfer(msg.sender, _to, _value);
return true;
}
function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
require (_value < allowance[_from][msg.sender]);
allowance[_from][msg.sender] -= _value;
_transfer(_from, _to, _value);
return true;
}
function approve(address _spender, uint256 _value)
returns (bool success) {
allowance[msg.sender][_spender] = _value;
return true;
}
function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
return allowance[_owner][_spender];
}
function burn(uint256 _value) returns (bool success) {
require (balanceOf[msg.sender] > _value);
balanceOf[msg.sender] -= _value;
totalSupply -= _value;
Burn(msg.sender, _value);
return true;
}
function burnFrom(address _from, uint256 _value) returns (bool success) {
require(balanceOf[_from] >= _value);
require(_value <= allowance[_from][msg.sender]);
balanceOf[_from] -= _value;
allowance[_from][msg.sender] -= _value;
totalSupply -= _value;
Burn(_from, _value);
return true;
}
function mintToken(address target, uint256 mintedAmount) onlyOwner {
balanceOf[target] += mintedAmount;
totalSupply += mintedAmount;
Transfer(0, this, mintedAmount);
Transfer(this, target, mintedAmount);
}
function(){
revert();
}
}