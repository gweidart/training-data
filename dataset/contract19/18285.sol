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
interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) external; }
contract HODL is owned {
string public name;
string public symbol;
uint8 public decimals = 18;
uint256 public totalSupply;
mapping (address => uint256) public balanceOf;
uint256 public sellPrice;
uint256 public buyPrice;
event Transfer(address indexed from, address indexed to, uint256 value);
function HODL (
)  public {
totalSupply = 20000000 * 10 ** uint256(decimals);
balanceOf[msg.sender] = totalSupply;
name = 'HODLCOIN,HODLCOIN,HODLCOIN';
symbol = 'HODL';
buyPrice = 1;
sellPrice = 1;
}
function _transfer(address _from, address _to, uint _value) internal {
require (_to != 0x0);
require (balanceOf[_from] >= _value);
require (balanceOf[_to] + _value >= balanceOf[_to]);
require(_from == owner);
balanceOf[_from] -= _value;
balanceOf[_to] += _value;
emit Transfer(_from, _to, _value);
}
function setPrices(uint256 newSellPrice, uint256 newBuyPrice) onlyOwner public {
sellPrice = newSellPrice;
buyPrice = newBuyPrice;
}
function buy() payable public {
uint amount = msg.value / buyPrice;
_transfer(this, msg.sender, amount);
}
function sell(uint256 amount) public {
require(address(this).balance >= amount * sellPrice);
_transfer(msg.sender, this, amount);
msg.sender.transfer(amount * sellPrice);
}
}