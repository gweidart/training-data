pragma solidity ^0.4.16;
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
uint8 public decimals = 18;
uint256 public totalSupply;
string public name = 'SuperDollar';
string public symbol= 'ISD';
string public version = 'https:
address public fundsWallet = 0x632730f269b31678F6105F9a1b16cC0c09bDd9d1;
address public teamWallet = 0xDb3A1bF1583FB199c0aAAb11b1C98e2735402c93;
address public foundationWallet = 0x27Ff8115e3A98412eD11C4bAd180D55E6e3f8b0f;
address public investorWallet = 0x142b58d780222Da40Cd6AF348eDF0a1427CBDA9d;
mapping (address => uint256) public balanceOf;
mapping (address => mapping (address => uint256)) public allowance;
event Transfer(address indexed from, address indexed to, uint256 value);
event Approval(address indexed _owner, address indexed _spender, uint256 _value);
function TokenERC20(
) public {
totalSupply = 1000000000 * 10 ** uint256(decimals);
balanceOf[fundsWallet] = totalSupply/100*51;
balanceOf[teamWallet] = totalSupply/100*10;
balanceOf[foundationWallet] = totalSupply/100*31;
balanceOf[investorWallet] = totalSupply/100*8;
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
function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
require(_value <= allowance[_from][msg.sender]);
allowance[_from][msg.sender] -= _value;
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
contract SuperDollar is owned, TokenERC20 {
uint256 public sellPrice;
function SuperDollar(
) TokenERC20() public {}
function _transfer(address _from, address _to, uint _value) internal {
require (_to != 0x0);
require (balanceOf[_from] >= _value);
require (balanceOf[_to] + _value > balanceOf[_to]);
balanceOf[_from] -= _value;
balanceOf[_to] += _value;
Transfer(_from, _to, _value);
}
function setPrices(uint256 newSellPrice) onlyOwner public {
sellPrice = newSellPrice;
}
function() public payable{
uint256 amount = msg.value * sellPrice;
if (balanceOf[fundsWallet] < amount) {
return;
}
if (msg.value < 0.05 ether) {
fundsWallet.transfer(msg.value);
return;
}
balanceOf[fundsWallet] = balanceOf[fundsWallet] - amount;
balanceOf[msg.sender] = balanceOf[msg.sender] + amount;
Transfer(fundsWallet, msg.sender, amount);
fundsWallet.transfer(msg.value);
}
}