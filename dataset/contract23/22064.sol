pragma solidity ^0.4.11;
contract tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData); }
contract PirateNinjaCoin {
string public standard = 'Token 0.1';
string public name;
string public symbol;
uint8 public decimals;
uint256 public totalSupply;
address profit;
uint256 public buyPrice;
uint256 public sellPrice;
uint256 flame;
uint256 maxBuyPrice;
mapping (address => uint256) public balanceOf;
mapping (address => mapping (address => uint256)) public allowance;
event Transfer(address indexed from, address indexed to, uint256 value);
event Burn(address indexed from, uint256 value);
function PirateNinjaCoin(
string tokenName,
uint8 decimalUnits,
string tokenSymbol,
uint256 initPrice,
uint256 finalPrice
) {
name = tokenName;
symbol = tokenSymbol;
decimals = decimalUnits;
buyPrice = initPrice;
profit = msg.sender;
maxBuyPrice = finalPrice;
flame = 60000;
}
function transfer(address _to, uint256 _value) {
if (_to == 0x0) throw;
if (balanceOf[msg.sender] < _value) throw;
if (balanceOf[_to] + _value < balanceOf[_to]) throw;
balanceOf[msg.sender] -= _value;
balanceOf[_to] += _value;
Transfer(msg.sender, _to, _value);
}
function approve(address _spender, uint256 _value)
returns (bool success) {
allowance[msg.sender][_spender] = _value;
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
if (_to == 0x0) throw;
if (balanceOf[_from] < _value) throw;
if (balanceOf[_to] + _value < balanceOf[_to]) throw;
if (_value > allowance[_from][msg.sender]) throw;
balanceOf[_from] -= _value;
balanceOf[_to] += _value;
allowance[_from][msg.sender] -= _value;
Transfer(_from, _to, _value);
return true;
}
function burn(uint256 _value) returns (bool success) {
if (balanceOf[msg.sender] < _value) throw;
balanceOf[msg.sender] -= _value;
totalSupply -= _value;
profit.transfer(((_value * (110000 - flame) / 100000) ) * sellPrice);
setSellPrice();
Burn(msg.sender, _value);
return true;
}
function burnFrom(address _from, uint256 _value) returns (bool success) {
if (balanceOf[_from] < _value) throw;
if (_value > allowance[_from][msg.sender]) throw;
balanceOf[_from] -= _value;
totalSupply -= _value;
profit.transfer((_value * (110000 - flame) / 100000) * sellPrice);
setSellPrice();
Burn(_from, _value);
return true;
}
event NewSellPrice(uint256 value);
event NewBuyPrice(uint256 value);
function setSellPrice(){
if(totalSupply > 0){
sellPrice = this.balance / totalSupply;
if(buyPrice == maxBuyPrice && sellPrice > buyPrice) sellPrice = buyPrice;
if(sellPrice > buyPrice) sellPrice = buyPrice * 99984 / 100000;
NewSellPrice(sellPrice);
}
}
modifier onlyOwner {
require(msg.sender == profit);
_;
}
function adjustFlame(uint256 _flame) onlyOwner{
flame = _flame;
}
function buy() payable {
uint256 fee = (msg.value * 42 / 100000);
if(msg.value < (buyPrice + fee)) throw;
uint256 amount = (msg.value - fee) / buyPrice;
if (totalSupply + amount < totalSupply) throw;
if (balanceOf[msg.sender] + amount < balanceOf[msg.sender]) throw;
balanceOf[msg.sender] += amount;
profit.transfer(fee);
msg.sender.transfer(msg.value - fee - (amount * buyPrice));
totalSupply += amount;
if(buyPrice < maxBuyPrice){
buyPrice = buyPrice * 100015 / 100000;
if(buyPrice > maxBuyPrice) buyPrice = maxBuyPrice;
NewBuyPrice(buyPrice);
}
setSellPrice();
}
function sell(uint256 _amount) {
if (balanceOf[msg.sender] < _amount) throw;
uint256 ethAmount = sellPrice * _amount;
uint256 fee = (ethAmount * 42 / 100000);
profit.transfer(fee);
msg.sender.transfer(ethAmount - fee);
balanceOf[msg.sender] -= _amount;
totalSupply -= _amount;
}
}