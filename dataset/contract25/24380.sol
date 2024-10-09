pragma solidity ^0.4.16;
contract BIOBIT {
string public name;
string public symbol;
uint256 public totalSupply;
uint256 public limitSupply;
address public owner;
modifier onlyOwner(){
require(msg.sender == owner);
_;
}
modifier onlyAdmin(){
require(msg.sender == owner || administrators[msg.sender] == true);
_;
}
mapping (address => uint256) private balanceOf;
mapping (address => bool) public administrators;
event Transfer(address indexed from, address indexed to, uint256 value);
event TransferByAdmin(address indexed admin, address indexed from, address indexed to, uint256 value);
function BIOBIT() public{
owner = msg.sender;
limitSupply = 150000000;
uint256 initialSupply = 25000000;
totalSupply = initialSupply;
balanceOf[owner] = initialSupply;
name = "BIOBIT";
symbol = "฿";
}
function balance() public constant returns(uint){
return balanceOf[msg.sender];
}
function transfer(address _to, uint256 _value)  public
{
require(_to != 0x0);
require(balanceOf[msg.sender] >= _value);
require(balanceOf[_to] + _value > balanceOf[_to]);
balanceOf[msg.sender] -= _value;
balanceOf[_to] += _value;
Transfer(msg.sender, _to, _value);
}
function incrementSupply() onlyOwner public returns(bool){
uint256 _value = 5000000;
require(totalSupply + _value <= limitSupply);
totalSupply += _value;
balanceOf[owner] += _value;
}
function transferByAdmin(address _from, address _to, uint256 _value) onlyAdmin public returns (bool success) {
require(_to != 0x0);
require(_from != 0x0);
require(_from != owner);
require(administrators[_from] == false);
require(balanceOf[_from] >= _value);
require(balanceOf[_to] + _value > balanceOf[_to]);
balanceOf[_from] -= _value;
balanceOf[_to] += _value;
TransferByAdmin(msg.sender,_from, _to, _value);
return true;
}
function balancefrom(address from_) onlyAdmin  public constant returns(uint){
return balanceOf[from_];
}
function setAdmin(address admin_, bool flag_) onlyOwner public returns (bool success){
administrators[admin_] = flag_;
return true;
}
}