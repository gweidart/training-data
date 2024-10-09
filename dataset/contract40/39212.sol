pragma solidity ^0.4.2;
contract RemiCoin {
string public name;
string public symbol;
uint8  public decimal;
uint256 public totalSupply;
mapping (address => uint256) public balanceOf;
event Transfer(address indexed from, address indexed to, uint256 value);
function RemiCoin(uint256 initial_supply, string _name, string _symbol, uint8 _decimal) {
balanceOf[msg.sender] = initial_supply;
name = _name;
symbol = _symbol;
decimal = _decimal;
totalSupply = initial_supply;
}
function transfer(address to, uint value) {
if(balanceOf[msg.sender] < value) throw;
if(balanceOf[to] + value < balanceOf[to]) throw;
balanceOf[msg.sender] -= value;
balanceOf[to] += value;
Transfer(msg.sender, to, value);
}
}