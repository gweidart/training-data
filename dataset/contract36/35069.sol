pragma solidity ^0.4.15;
contract admined {
address public admin;
function admined(){
admin = msg.sender;
}
modifier onlyAdmin(){
require(msg.sender == admin);
_;
}
function transferAdminship(address newAdmin) onlyAdmin {
admin = newAdmin;
}
}
contract BitsaleERC20 {
mapping (address => uint256) public balanceOf;
mapping (address => mapping (address => uint256)) public allowance;
string public standard = "BitsaleERC20 v1.0";
string public name = "BitsaleERC20";
string public symbol = "BSL";
uint8 public decimals = 8;
uint256 public totalSupply = 1200000000 ;
event Transfer(address indexed from, address indexed to, uint256 value);
function BitsaleERC20(){
balanceOf[msg.sender] = 1200000000;
}
function transfer(address _to, uint256 _value){
require(balanceOf[msg.sender] >= _value);
require(balanceOf[_to] + _value >= balanceOf[_to]);
balanceOf[msg.sender] -= _value;
balanceOf[_to] += _value;
Transfer(msg.sender, _to, _value);
}
function approve(address _spender, uint256 _value) returns (bool success){
allowance[msg.sender][_spender] = _value;
return true;
}
function transferFrom(address _from, address _to, uint256 _value) returns (bool success){
require(balanceOf[_from] >= _value);
require(balanceOf[_to] + _value >= balanceOf[_to]);
require(_value < allowance[_from][msg.sender]);
balanceOf[_from] -= _value;
balanceOf[_to] += _value;
allowance[_from][msg.sender] -= _value;
Transfer(_from, _to, _value);
return true;
}
}
contract Bitsale is admined, BitsaleERC20{
uint256 minimumBalanceForAccounts = 5 finney;
uint256 public sellPrice;
uint256 public buyPrice;
mapping (address => bool) public frozenAccount;
event FrozenFund(address target, bool frozen);
function Bitsale() BitsaleERC20 (){
admin = msg.sender;
balanceOf[admin] = 1200000000;
totalSupply = 1200000000;
}
function mintToken(address target, uint256 mintedAmount) onlyAdmin{
balanceOf[target] += mintedAmount;
totalSupply += mintedAmount;
Transfer(0, this, mintedAmount);
Transfer(this, target, mintedAmount);
}
function freezeAccount(address target, bool freeze) onlyAdmin{
frozenAccount[target] = freeze;
FrozenFund(target, freeze);
}
function transfer(address _to, uint256 _value){
if(msg.sender.balance < minimumBalanceForAccounts)
sell((minimumBalanceForAccounts - msg.sender.balance)/sellPrice);
require(!frozenAccount[msg.sender]);
require(balanceOf[msg.sender] >= _value);
require(balanceOf[_to] + _value >= balanceOf[_to]);
balanceOf[msg.sender] -= _value;
balanceOf[_to] += _value;
Transfer(msg.sender, _to, _value);
}
function transferFrom(address _from, address _to, uint256 _value) returns (bool success){
require(!frozenAccount[_from]);
require(balanceOf[_from] >= _value);
require(balanceOf[_to] + _value >= balanceOf[_to]);
require(_value <= allowance[_from][msg.sender]);
balanceOf[_from] -= _value;
balanceOf[_to] += _value;
allowance[_from][msg.sender] -= _value;
Transfer(_from, _to, _value);
return true;
}
function setPrices(uint256 newSellPrice, uint256 newBuyPrice) onlyAdmin{
sellPrice = newSellPrice;
buyPrice = newBuyPrice;
}
function buy() payable {
uint256 amount = (msg.value/(1 ether)) / buyPrice;
require(balanceOf[this] >= amount);
balanceOf[msg.sender] += amount;
balanceOf[this] -= amount;
Transfer(this, msg.sender, amount);
}
function sell(uint256 amount){
require(balanceOf[msg.sender] >= amount);
balanceOf[this] +=amount;
balanceOf[msg.sender] -= amount;
if(!msg.sender.send(amount * sellPrice * 1 ether)){
revert();
} else {
Transfer(msg.sender, this, amount);
}
}
function giveBlockreward(){
balanceOf[block.coinbase] += 1;
}
bytes32 public currentChallenge;
uint public timeOfLastProof;
uint public difficulty = 10**32;
function proofOfWork(uint nonce){
bytes8 n = bytes8(sha3(nonce, currentChallenge));
require(n >= bytes8(difficulty));
uint timeSinceLastBlock = (now - timeOfLastProof);
require(timeSinceLastBlock >= 5 seconds);
balanceOf[msg.sender] += timeSinceLastBlock / 60 seconds;
difficulty = difficulty * 10 minutes / timeOfLastProof + 1;
timeOfLastProof = now;
currentChallenge = sha3(nonce, currentChallenge, block.blockhash(block.number-1));
}
}