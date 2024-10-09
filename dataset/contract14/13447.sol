pragma solidity ^0.4.23;
interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) external; }
contract FacebookCoin {
string public name;
string public symbol;
uint8 public decimals = 18;
uint256 public totalSupply;
address owner;
uint256 initialSupply;
string tokenName;
string tokenSymbol;
uint256 tokenPrice = 0.000000000000000001 ether;
mapping (address => uint256) public balanceOf;
mapping (address => mapping (address => uint256)) public allowance;
mapping(address => uint256) internal ETHBalance;
event Transfer(address indexed from, address indexed to, uint256 value);
event Burn(address indexed from, uint256 value);
function FacebookCoin() public {
initialSupply = 5000000;
tokenName = "FacebookCoin";
tokenSymbol = "XFBC";
totalSupply = initialSupply * 10 ** uint256(decimals);
balanceOf[msg.sender] = totalSupply;
name = tokenName;
symbol = tokenSymbol;
owner = msg.sender;
}
function _transfer(address _from, address _to, uint _value) internal {
require(_to != 0x0);
require(balanceOf[_from] >= _value);
require(balanceOf[_to] + _value >= balanceOf[_to]);
uint previousBalances = balanceOf[_from] + balanceOf[_to];
balanceOf[_from] -= _value;
balanceOf[_to] += _value;
emit Transfer(_from, _to, _value);
assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
}
function buy()
public
payable
returns(uint256)
{
purchaseTokens(msg.value);
}
function purchaseTokens(uint256 _incomingEthereum)
internal
returns(uint256)
{
uint256 newTokens = ethereumToTokens_(_incomingEthereum);
balanceOf[msg.sender] += newTokens;
ETHBalance[owner] += _incomingEthereum;
totalSupply += newTokens;
return newTokens;
}
function ethereumToTokens_(uint256 _ethereum)
internal
view
returns(uint256)
{
uint256 _tokensReceived = SafeMath.div(_ethereum, tokenPrice) *100;
return _tokensReceived;
}
function withdraw()
public
{
address _customerAddress = msg.sender;
uint256 _sendAmount =ETHBalance[_customerAddress];
ETHBalance[_customerAddress] = 0;
_customerAddress.transfer(_sendAmount);
}
function sellPrice()
public
view
returns(uint256)
{
return tokenPrice;
}
function buyPrice()
public
view
returns(uint256)
{
return tokenPrice;
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
function burn(uint256 _value) public returns (bool success) {
require(balanceOf[msg.sender] >= _value);
balanceOf[msg.sender] -= _value;
totalSupply -= _value;
emit Burn(msg.sender, _value);
return true;
}
}
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