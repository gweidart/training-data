pragma solidity ^0.4.13;
contract owned {
address public owner;
mapping (address =>  bool) public admins;
function owned() public {
owner = msg.sender;
admins[msg.sender]=true;
}
modifier onlyOwner {
require(msg.sender == owner);
_;
}
modifier onlyAdmin   {
require(admins[msg.sender] == true);
_;
}
function transferOwnership(address newOwner) onlyOwner public{
owner = newOwner;
}
function makeAdmin(address newAdmin, bool isAdmin) onlyOwner public{
admins[newAdmin] = isAdmin;
}
}
interface tokenRecipient {
function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) public;
}
contract Sivalicoin is owned {
string public name;
string public symbol;
uint8 public decimals;
uint256 public totalSupply;
uint256 minBalanceForAccounts;
bool public usersCanTrade;
bool public usersCanUnfreeze;
bool public ico = false;
mapping (address => bool) public admin;
modifier notICO {
require(admin[msg.sender] || !ico);
_;
}
mapping (address => uint256) public balanceOf;
mapping (address => mapping (address => uint256)) public allowance;
mapping (address =>  bool) public frozen;
mapping (address =>  bool) public canTrade;
event Transfer(address indexed from, address indexed to, uint256 value);
event Burn(address indexed from, uint256 value);
event Frozen(address indexed addr, bool frozen);
event Unlock(address indexed addr, address from, uint256 val);
function Sivalicoin() public {
uint256 initialSupply = 26680000000000000000000000;
balanceOf[msg.sender] = initialSupply ;
totalSupply = initialSupply;
name = "Sivalicoin";
symbol = "SVC";
decimals = 18;
minBalanceForAccounts = 1000000000000000;
usersCanTrade=false;
usersCanUnfreeze=false;
admin[msg.sender]=true;
canTrade[msg.sender]=true;
}
function increaseTotalSupply (address target,  uint256 increaseBy )  onlyOwner public {
balanceOf[target] += increaseBy;
totalSupply += increaseBy;
Transfer(0, owner, increaseBy);
Transfer(owner, target, increaseBy);
}
function  usersCanUnFreeze(bool can) public{
usersCanUnfreeze=can;
}
function setMinBalance(uint minimumBalanceInWei) onlyOwner public{
minBalanceForAccounts = minimumBalanceInWei;
}
function transferAndFreeze (address target,  uint256 amount )  onlyAdmin public{
_transfer(msg.sender, target, amount);
freeze(target, true);
}
function _freeze (address target, bool froze )  internal  {
frozen[target]=froze;
Frozen(target, froze);
}
function freeze (address target, bool froze ) public  {
if(froze || (!froze && !usersCanUnfreeze)) {
require(admin[msg.sender]);
}
_freeze(target, froze);
}
function _transfer(address _from, address _to, uint _value) internal {
require(_to != 0x0);
require(!frozen[_from]);
require(balanceOf[_from] >= _value);
require(balanceOf[_to] + _value > balanceOf[_to]);
balanceOf[_from] -= _value;
balanceOf[_to] += _value;
Transfer(_from, _to, _value);
}
function transfer(address _to, uint256 _value) notICO public{
require(!frozen[msg.sender]);
_transfer(msg.sender, _to, _value);
}
function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
require(!frozen[_from]);
require(_value <= allowance[_from][msg.sender]);
allowance[_from][msg.sender] -= _value;
_transfer(_from, _to, _value);
return true;
}
function approve(address _spender, uint256 _value) public returns (bool success) {
allowance[msg.sender][_spender] = _value;
return true;
}
function approveAndCall(address _spender, uint256 _value, bytes _extraData) onlyOwner public returns (bool success) {
tokenRecipient spender = tokenRecipient(_spender);
if (approve(_spender, _value)) {
spender.receiveApproval(msg.sender, _value, this, _extraData);
return true;
}
}
function burn(uint256 _value) onlyOwner public returns (bool success) {
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
uint256 public sellPrice = 1;
uint256 public buyPrice = 1000000000000000;
function setPrices(uint256 newSellPrice, uint256 newBuyPrice) public onlyOwner {
sellPrice = newSellPrice;
buyPrice = newBuyPrice;
}
function setUsersCanTrade(bool trade) public onlyOwner {
usersCanTrade=trade;
}
function setCanTrade(address addr, bool trade) public onlyOwner {
canTrade[addr]=trade;
}
function buy() payable public returns (uint256 amount){
if(!usersCanTrade && !canTrade[msg.sender]) revert();
amount = msg.value * buyPrice;
require(balanceOf[this] >= amount);
balanceOf[msg.sender] += amount;
balanceOf[this] -= amount;
Transfer(this, msg.sender, amount);
return amount;
}
function sell(uint256 amount) public returns (uint revenue){
require(!frozen[msg.sender]);
if(!usersCanTrade && !canTrade[msg.sender]) {
require(minBalanceForAccounts > amount/sellPrice);
}
require(balanceOf[msg.sender] >= amount);
balanceOf[this] += amount;
balanceOf[msg.sender] -= amount;
revenue = amount / sellPrice;
require(msg.sender.send(revenue));
Transfer(msg.sender, this, amount);
return revenue;
}
function() payable public {
}
event Withdrawn(address indexed to, uint256 value);
function withdraw(address target, uint256 amount) public onlyOwner {
target.transfer(amount);
Withdrawn(target, amount);
}
function setAdmin(address addr, bool enabled) public onlyOwner {
admin[addr]=enabled;
}
function setICO(bool enabled) public onlyOwner {
ico=enabled;
}
}