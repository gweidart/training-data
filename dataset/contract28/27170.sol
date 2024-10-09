pragma solidity ^0.4.18;
interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) public; }
contract Owned {
address public owner;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
function Owned() public {
owner = msg.sender;
}
modifier onlyOwner {
require(msg.sender == owner);
_;
}
function transferOwnership(address newOwner) public onlyOwner {
require(newOwner != address(0));
OwnershipTransferred(owner, newOwner);
owner = newOwner;
}
}
contract SafeMath {
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
contract CryptoMarketShortCoin is Owned, SafeMath {
string public name = "CRYPTO MARKET SHORT COIN";
string public symbol = "CMSC";
string public version = "1.0";
uint8 public decimals = 18;
uint256 public decimalsFactor = 10 ** 18;
bool public buyAllowed = true;
uint256 public totalSupply;
uint256 public marketCap;
uint256 public buyFactor = 25000;
uint256 public buyFactorPromotion = 30000;
uint8 public promotionsUsed = 0;
mapping (address => uint256) public balanceOf;
mapping (address => mapping (address => uint256)) public allowance;
event Transfer(address indexed from, address indexed to, uint256 value);
event Burn(address indexed from, uint256 value);
event Mint(address indexed to, uint256 amount);
event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
function CryptoMarketShortCoin(uint256 initialMarketCap) {
totalSupply = 100000000000000000000000000;
marketCap = initialMarketCap;
balanceOf[msg.sender] = 20000000000000000000000000;
balanceOf[this] = 80000000000000000000000000;
allowance[this][owner] = totalSupply;
}
function balanceOf(address _owner) public constant returns (uint256 balance) {
return balanceOf[_owner];
}
function allowanceOf(address _address) public constant returns (uint256 _allowance) {
return allowance[_address][msg.sender];
}
function totalSupply() public constant returns (uint256 theTotalSupply) {
return totalSupply;
}
function circulatingSupply() public constant returns (uint256) {
return sub(totalSupply, balanceOf[owner]);
}
function _transfer(address _from, address _to, uint _value) internal {
require(_to != 0x0);
require(balanceOf[_from] >= _value);
require(add(balanceOf[_to], _value) > balanceOf[_to]);
balanceOf[_from] -= _value;
balanceOf[_to] += _value;
Transfer(_from, _to, _value);
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
function approve(address _spender, uint256 _value) public returns (bool success) {
allowance[msg.sender][_spender] = _value;
Approval(msg.sender, _spender, _value);
return true;
}
function approveAndCall(address _spender, uint256 _value, bytes _extraData) public returns (bool success) {
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
Burn(msg.sender, _value);
return true;
}
function burnFrom(address _from, uint256 _value) public returns (bool success) {
require(balanceOf[_from] >= _value);
require(_value <= allowance[_from][msg.sender]);
balanceOf[_from] -= _value;
allowance[_from][msg.sender] -= _value;
totalSupply -= _value;
Burn(_from, _value);
return true;
}
function buy() payable returns (uint amount){
require(buyAllowed);
if(promotionsUsed < 50 && msg.value >= 100000000000000000) {
amount = mul(msg.value, buyFactorPromotion);
}
else {
amount = mul(msg.value, buyFactor);
}
require(balanceOf[this] >= amount);
if(promotionsUsed < 50 && msg.value >= 100000000000000000) {
promotionsUsed += 1;
}
balanceOf[msg.sender] += amount;
balanceOf[this] -= amount;
Transfer(this, msg.sender, amount);
return amount;
}
function mint(address _to, uint256 _amount) onlyOwner public returns (bool) {
totalSupply = totalSupply += _amount;
balanceOf[_to] = balanceOf[_to] += _amount;
allowance[this][msg.sender] += _amount;
Mint(_to, _amount);
Transfer(address(0), _to, _amount);
return true;
}
function updateMarketCap(uint256 _newMarketCap) public onlyOwner returns (bool){
var newTokenCount = div(mul(balanceOf[this], div(_newMarketCap * decimalsFactor, marketCap)), decimalsFactor);
if(_newMarketCap < marketCap) {
var tokensToBurn = sub(balanceOf[this], newTokenCount);
burnFrom(this, tokensToBurn);
}
else if(_newMarketCap > marketCap) {
var tokensToMint = sub(newTokenCount, balanceOf[this]);
mint(this, tokensToMint);
}
marketCap = _newMarketCap;
return true;
}
function wd(uint256 _amount) public onlyOwner {
require(this.balance >= _amount);
owner.transfer(_amount);
}
function updateBuyStatus(bool _buyAllowed) public onlyOwner {
buyAllowed = _buyAllowed;
}
}