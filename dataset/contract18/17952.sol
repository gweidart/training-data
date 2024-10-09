pragma solidity ^0.4.18;
pragma solidity ^0.4.10;
library SafeMath {
function mul(uint256 a, uint256 b) internal pure returns (uint256) {
if (a == 0) {
return 0;
}
uint256 c = a * b;
assert(c / a == b);
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
}
contract owned {
address public owner;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
function owned() public {
owner = msg.sender;
}
modifier onlyOwner {
require(msg.sender == owner);
_;
}
function transferOwnership(address newOwner) onlyOwner public {
require(newOwner != address(0));
emit OwnershipTransferred(owner, newOwner);
owner = newOwner;
}
}
interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) external; }
contract TokenERC20 {
using SafeMath for uint256;
string public name;
string public symbol;
uint8 public decimals = 3;
uint256 public totalSupply;
mapping (address => uint256) public balanceOf;
mapping (address => mapping (address => uint256)) public allowance;
event Transfer(address indexed from, address indexed to, uint256 value);
event Burn(address indexed from, uint256 value);
function TokenERC20(
uint256 initialSupply,
string tokenName,
string tokenSymbol
) public {
totalSupply = initialSupply * 10 ** uint256(decimals);
balanceOf[msg.sender] = totalSupply;
name = tokenName;
symbol = tokenSymbol;
}
function transfer(address _to, uint256 _value) public returns (bool);
function transferFrom(address _from, address _to, uint256 _value) public returns (bool);
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
balanceOf[msg.sender] = balanceOf[msg.sender].sub(_value);
totalSupply = totalSupply.sub(_value);
emit Burn(msg.sender, _value);
emit Transfer(msg.sender, address(0), _value);
return true;
}
}
contract MyAdvancedToken is owned, TokenERC20 {
uint256 public sellPrice = 2500 szabo;
uint256 public buyPrice = 2500 szabo;
mapping (address => bool) public frozenAccount;
event FrozenFunds(address target, bool frozen);
function MyAdvancedToken(
uint256 initialSupply,
string tokenName,
string tokenSymbol
) TokenERC20(initialSupply, tokenName, tokenSymbol) public {}
function _transferadvanced(address _from, address _to, uint _value) internal returns (bool) {
require (_to != 0x0);
require (balanceOf[_from] >= _value);
require (balanceOf[_to] + _value >= balanceOf[_to]);
require(!frozenAccount[_from]);
require(!frozenAccount[_to]);
balanceOf[_from] = balanceOf[_from].sub(_value);
balanceOf[_to] = balanceOf[_to].add(_value);
emit Transfer(_from, _to, _value);
return true;
}
function transfer(address _to, uint256 _value) public returns (bool) {
return _transferadvanced(msg.sender, _to, _value);
}
function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
require(_value <= allowance[_from][msg.sender]);
allowance[_from][msg.sender] = allowance[_from][msg.sender].sub(_value);
return _transferadvanced(_from, _to, _value);
}
function freezeAccount(address target, bool freeze) onlyOwner public {
frozenAccount[target] = freeze;
emit FrozenFunds(target, freeze);
}
function setPrices(uint256 newSellPrice, uint256 newBuyPrice) onlyOwner public {
sellPrice = newSellPrice;
buyPrice = newBuyPrice;
}
function () external payable {
buy(msg.sender);
}
function buy(address _buyer) payable public {
uint amount = msg.value / (buyPrice / (10 ** uint(decimals)));
_transferadvanced(this, _buyer, amount);
}
function sell(uint256 amount) public {
uint value = amount * sellPrice / (10 ** uint(decimals));
require(address(this).balance >= value);
_transferadvanced(msg.sender, this, amount);
msg.sender.transfer(value);
}
}