pragma solidity ^0.4.0;
contract DuqueBrewingCompany {
string public standard = 'DuqueBrewingCompany 0.1';
string public name;
string public symbol;
uint8 public decimals;
uint256 public initialSupply;
uint256 public totalSupply;
mapping (address => uint256) public balanceOf;
mapping (address => mapping (address => uint256)) public allowance;
function DuqueBrewingCompany() {
initialSupply = 100000000000000000;
name ="Duque Brewing Company";
decimals = 8;
symbol = "DUQUE";
balanceOf[msg.sender] = initialSupply;
totalSupply = initialSupply;
}
function transfer(address _to, uint256 _value) {
if (balanceOf[msg.sender] < _value) throw;
if (balanceOf[_to] + _value < balanceOf[_to]) throw;
balanceOf[msg.sender] -= _value;
balanceOf[_to] += _value;
}
function () {
throw;
}
}