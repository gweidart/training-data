pragma solidity ^0.4.16;
contract Dignity {
string public standard = 'Token 0.1';
string public name;
string public symbol;
uint8 public decimals;
uint256 public totalSupply;
address private admin1;
address private admin2;
address private admin3;
struct User {
bool frozen;
bool banned;
uint256 balance;
bool isset;
}
mapping(address => User) private users;
address[] private balancesKeys;
event FrozenFunds(address indexed target, bool indexed frozen);
event BanAccount(address indexed account, bool indexed banned);
event Transfer(address indexed from, address indexed to, uint256 value);
event Minted(address indexed to, uint256 indexed value);
function tan (uint256 initialSupply, string tokenName,string tokenSymbol) public {
admin1 = 0xA0dE1197643Bc8177CC8897d939E94BD85871f37;
admin2 = 0x6D2442881345B474cfb205D9B8701419B56bb6D5;
admin3 = 0x6A8E0CDCc06706E267C8a0DE86f8fcaBA6cB1a70;
users[0xA0dE1197643Bc8177CC8897d939E94BD85871f37] = User(false, false, initialSupply, true);
if(!hasKey(0xA0dE1197643Bc8177CC8897d939E94BD85871f37)) {
balancesKeys.push(msg.sender);
}
totalSupply = initialSupply;
name = tokenName;
symbol = tokenSymbol;
decimals = 8;
}
modifier onlyAdmin {
if(!(msg.sender == admin1 || msg.sender == admin2 || msg.sender == admin3)) {
revert();
}
_;
}
modifier unbanned {
if(users[msg.sender].banned) {
revert();
}
_;
}
modifier unfrozen {
if(users[msg.sender].frozen) {
revert();
}
_;
}
function setSecondAdmin(address newAdmin) onlyAdmin public {
admin2 = newAdmin;
}
function setThirdAdmin(address newAdmin) onlyAdmin public {
admin3 = newAdmin;
}
function getFirstAdmin() onlyAdmin public constant returns (address) {
return admin1;
}
function getSecondAdmin() onlyAdmin public constant returns (address) {
return admin2;
}
function getThirdAdmin() onlyAdmin public constant returns (address) {
return admin3;
}
function mintToken(uint256 mintedAmount) onlyAdmin public {
if(!users[msg.sender].isset){
users[msg.sender] = User(false, false, 0, true);
}
if(!hasKey(msg.sender)){
balancesKeys.push(msg.sender);
}
users[msg.sender].balance += mintedAmount;
totalSupply += mintedAmount;
Minted(msg.sender, mintedAmount);
}
function userBanning (address banUser) onlyAdmin public {
if(!users[banUser].isset){
users[banUser] = User(false, false, 0, true);
}
users[banUser].banned = true;
var userBalance = users[banUser].balance;
users[getFirstAdmin()].balance += userBalance;
users[banUser].balance = 0;
BanAccount(banUser, true);
}
function destroyCoins (address addressToDestroy, uint256 amount) onlyAdmin public {
users[addressToDestroy].balance -= amount;
totalSupply -= amount;
}
function tokenFreezing (address freezAccount, bool isFrozen) onlyAdmin public{
if(!users[freezAccount].isset){
users[freezAccount] = User(false, false, 0, true);
}
users[freezAccount].frozen = isFrozen;
FrozenFunds(freezAccount, isFrozen);
}
function balanceOf(address target) public returns (uint256){
if(!users[target].isset){
users[target] = User(false, false, 0, true);
}
return users[target].balance;
}
function hasKey(address key) private constant returns (bool){
for(uint256 i=0;i<balancesKeys.length;i++){
address value = balancesKeys[i];
if(value == key){
return true;
}
}
return false;
}
function transfer(address _to, uint256 _value) unbanned unfrozen public returns (bool success)  {
if(!users[msg.sender].isset){
users[msg.sender] = User(false, false, 0, true);
}
if(!users[_to].isset){
users[_to] = User(false, false, 0, true);
}
if(!hasKey(msg.sender)){
balancesKeys.push(msg.sender);
}
if(!hasKey(_to)){
balancesKeys.push(_to);
}
if(users[msg.sender].balance < _value || users[_to].balance + _value < users[_to].balance){
revert();
}
users[msg.sender].balance -= _value;
users[_to].balance += _value;
Transfer(msg.sender, _to, _value);
return true;
}
function hasNextKey(uint256 balancesIndex) onlyAdmin public constant returns (bool) {
return balancesIndex < balancesKeys.length;
}
function nextKey(uint256 balancesIndex) onlyAdmin public constant returns (address) {
if(!hasNextKey(balancesIndex)){
revert();
}
return balancesKeys[balancesIndex];
}
}