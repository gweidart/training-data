pragma solidity ^0.4.11;
contract owned {
address public owner;
function owned() {
owner = msg.sender;
}
modifier onlyOwner {
if (msg.sender != owner) throw;
_;
}
function transferOwnership(address newOwner) onlyOwner {
owner = newOwner;
}
}
contract tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData); }
contract token {
string public standard = 'Token 0.1';
string public name;
string public symbol;
uint8 public decimals;
uint256 public totalSupply;
mapping (address => uint256) public balanceOf;
mapping (address => mapping (address => uint256)) public allowance;
event Transfer(address indexed from, address indexed to, uint256 value);
function token(
uint256 initialSupply,
string tokenName,
uint8 decimalUnits,
string tokenSymbol
) {
balanceOf[msg.sender] = initialSupply;
totalSupply = initialSupply;
name = tokenName;
symbol = tokenSymbol;
decimals = decimalUnits;
}
function transfer(address _to, uint256 _value) {
if (balanceOf[msg.sender] < _value) throw;
if (balanceOf[_to] + _value < balanceOf[_to]) throw;
balanceOf[msg.sender] -= _value;
balanceOf[_to] += _value;
Transfer(msg.sender, _to, _value);
}
function approve(address _spender, uint256 _value)
returns (bool success) {
allowance[msg.sender][_spender] = _value;
tokenRecipient spender = tokenRecipient(_spender);
return true;
}
function approveAndCall(address _spender, uint256 _value, bytes _extraData)
returns (bool success) {
tokenRecipient spender = tokenRecipient(_spender);
if (approve(_spender, _value)) {
spender.receiveApproval(msg.sender, _value, this, _extraData);
return true;
}
}
function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
if (balanceOf[_from] < _value) throw;
if (balanceOf[_to] + _value < balanceOf[_to]) throw;
if (_value > allowance[_from][msg.sender]) throw;
balanceOf[_from] -= _value;
balanceOf[_to] += _value;
allowance[_from][msg.sender] -= _value;
Transfer(_from, _to, _value);
return true;
}
function () payable {
throw;
}
}
contract MyAdvancedToken is owned, token {
uint256 public sellPrice;
uint256 public buyPrice;
uint256 public totalSupply;
mapping (address => bool) public frozenAccount;
event FrozenFunds(address target, bool frozen);
function MyAdvancedToken(
uint256 initialSupply,
string tokenName,
uint8 decimalUnits,
string tokenSymbol,
address centralMinter
) token (initialSupply, tokenName, decimalUnits, tokenSymbol) {
if(centralMinter != 0 ) owner = centralMinter;
balanceOf[owner] = initialSupply;
}
function transfer(address _to, uint256 _value) {
if (balanceOf[msg.sender] < _value) throw;
if (balanceOf[_to] + _value < balanceOf[_to]) throw;
if (frozenAccount[msg.sender]) throw;
balanceOf[msg.sender] -= _value;
balanceOf[_to] += _value;
Transfer(msg.sender, _to, _value);
}
function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
if (frozenAccount[_from]) throw;
if (balanceOf[_from] < _value) throw;
if (balanceOf[_to] + _value < balanceOf[_to]) throw;
if (_value > allowance[_from][msg.sender]) throw;
balanceOf[_from] -= _value;
balanceOf[_to] += _value;
allowance[_from][msg.sender] -= _value;
Transfer(_from, _to, _value);
return true;
}
function mintToken(address target, uint256 mintedAmount) onlyOwner {
balanceOf[target] += mintedAmount;
totalSupply += mintedAmount;
Transfer(0, this, mintedAmount);
Transfer(this, target, mintedAmount);
}
function freezeAccount(address target, bool freeze) onlyOwner {
frozenAccount[target] = freeze;
FrozenFunds(target, freeze);
}
function setPrices(uint256 newSellPrice, uint256 newBuyPrice) onlyOwner {
sellPrice = newSellPrice;
buyPrice = newBuyPrice;
}
function buy() payable {
uint amount = msg.value / buyPrice;
if (balanceOf[this] < amount) throw;
balanceOf[msg.sender] += amount;
balanceOf[this] -= amount;
Transfer(this, msg.sender, amount);
}
function sell(uint256 amount) {
if (balanceOf[msg.sender] < amount ) throw;
balanceOf[this] += amount;
balanceOf[msg.sender] -= amount;
if (!msg.sender.send(amount * sellPrice)) {
throw;
} else {
Transfer(msg.sender, this, amount);
}
}
}
contract cashBackMintable is token {
uint256 tokensForWei;
function cashBackMintable(
string tokenName,
uint8 decimalUnits,
string tokenSymbol,
uint256 _tokensForWei
)
token(0, tokenName, decimalUnits, tokenSymbol)
{
tokensForWei = _tokensForWei;
}
function () public payable {
msg.sender.transfer(msg.value);
uint amount = msg.value * tokensForWei;
if (amount > 0) {
balanceOf[msg.sender] += amount;
totalSupply += amount;
Transfer(0, msg.sender, amount);
}
}
}