pragma solidity ^0.4.16;
library SafeMath {
function mul(uint256 a, uint256 b) internal constant returns (uint256) {
uint256 c = a * b;
assert(a == 0 || c / a == b);
return c;
}
function div(uint256 a, uint256 b) internal constant returns (uint256) {
uint256 c = a / b;
return c;
}
function sub(uint256 a, uint256 b) internal constant returns (uint256) {
assert(b <= a);
return a - b;
}
function add(uint256 a, uint256 b) internal constant returns (uint256) {
uint256 c = a + b;
assert(c >= a);
return c;
}
}
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
contract TokenERC20 {
string public name;
string public symbol;
uint8 public decimals = 0;
uint256 public totalSupply;
using SafeMath for uint;
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
function _transfer(address _from, address _to, uint _value) internal {
require(_to != 0x0);
require(balanceOf[_from] >= _value);
require(balanceOf[_to] + _value > balanceOf[_to]);
uint previousBalances = balanceOf[_from].add(balanceOf[_to]);
balanceOf[_from] = balanceOf[_from].sub(_value);
balanceOf[_to] = balanceOf[_to].add(_value);
Transfer(_from, _to, _value);
assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
}
function transfer(address _to, uint256 _value) public {
_transfer(msg.sender, _to, _value);
}
function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
require(_value <= allowance[_from][msg.sender]);
allowance[_from][msg.sender] = allowance[_from][msg.sender].sub(_value);
_transfer(_from, _to, _value);
return true;
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
}
contract MyAdvancedToken is owned, TokenERC20 {
uint256 public sellPrice;
uint256 public buyPrice;
using SafeMath for uint;
mapping (address => bool) public frozenAccount;
event FrozenFunds(address target, bool frozen);
function MyAdvancedToken(
uint256 initialSupply,
string tokenName,
string tokenSymbol
) TokenERC20(initialSupply, tokenName, tokenSymbol) public {}
function _transfer(address _from, address _to, uint _value) internal {
require (_to != 0x0);
require (balanceOf[_from] >= _value);
require (balanceOf[_to] + _value > balanceOf[_to]);
require(!frozenAccount[_from]);
require(!frozenAccount[_to]);
balanceOf[_from] = balanceOf[_from].sub(_value);
balanceOf[_to] = balanceOf[_to].add(_value);
Transfer(_from, _to, _value);
}
function mintToken(address target, uint256 mintedAmount) onlyOwner public {
balanceOf[target] = balanceOf[target].add(mintedAmount);
totalSupply = totalSupply.add(mintedAmount);
Transfer(0, this, mintedAmount);
Transfer(this, target, mintedAmount);
}
function freezeAccount(address target, bool freeze) onlyOwner public {
frozenAccount[target] = freeze;
FrozenFunds(target, freeze);
}
}