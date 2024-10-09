pragma solidity ^0.4.24;
contract BasicTokenInterface{
string public name;
uint8 public decimals;
string public symbol;
uint public totalSupply;
mapping (address => uint256) internal balances;
modifier checkpayloadsize(uint size) {
assert(msg.data.length >= size + 4);
_;
}
function balanceOf(address tokenOwner) public view returns (uint balance);
function transfer(address to, uint tokens) public returns (bool success);
event Transfer(address indexed from, address indexed to, uint tokens);
}
contract ApproveAndCallFallBack {
event ApprovalReceived(address indexed from, uint256 indexed amount, address indexed tokenAddr, bytes data);
function receiveApproval(address from, uint256 amount, address tokenAddr, bytes data) public{
emit ApprovalReceived(from, amount, tokenAddr, data);
}
}
contract ERC20TokenInterface is BasicTokenInterface, ApproveAndCallFallBack{
string public name;
string public symbol;
uint8 public decimals;
uint256 public totalSupply;
function allowance(address tokenOwner, address spender) public view returns (uint remaining);
function approve(address spender, uint tokens) public returns (bool success);
function transferFrom(address from, address to, uint tokens) public returns (bool success);
function transferTokens(address token, uint amount) public returns (bool success);
function approveAndCall(address spender, uint tokens, bytes data) public returns (bool success);
event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}
contract ManagedInterface{
address manager;
event ManagerChanged(address indexed oldManager, address indexed newManager);
modifier restricted(){
require(msg.sender == manager,"Function can only be used by manager");
_;
}
function sweepTokens(address token, address destination) public restricted {
uint balance = ERC20TokenInterface(token).balanceOf(address(this));
ERC20TokenInterface(token).transfer(destination,balance);
}
function sweepFunds(address destination, uint amount) public restricted{
amount = amount > address(this).balance ? address(this).balance : amount;
address(destination).transfer(amount);
}
function setManager(address newManager) public;
}
contract ManagedContract is ManagedInterface{
constructor(address creator) public{
manager = creator;
}
function setManager(address newManager) public restricted{
address oldManager = manager;
manager = newManager;
emit ManagerChanged(oldManager,manager);
}
}
library SafeMath {
function add(uint a, uint b) internal pure returns (uint c) {
c = a + b;
return (c >= a && c >= b) ? c : 0;
}
function sub(uint a, uint b) internal pure returns (uint) {
return (a >=b) ? (a - b): 0;
}
function mul(uint a, uint b) internal pure returns (uint c) {
c = a * b;
require(a == 0 || b == 0 || c / a == b);
return c;
}
function div(uint a, uint b) internal pure returns (uint c) {
require(a > 0 && b > 0);
c = a / b;
return c;
}
}
contract AVIVAccountInterface is ManagedInterface{
using SafeMath for uint;
uint verified_users;
uint public alias_price = 100000000000000000;
struct Account{
string name;
string country;
mapping(string => byte[]) pubkeys;
mapping(address => bool) communities;
bool verified;
uint donations;
}
mapping(string => address) internal names;
mapping(address => Account) internal accounts;
event AccountVerified(address user, string name, string country);
event KeyChanged(address user, string label, byte[] key);
event JoinedCommunity(string name, address community);
event LeftCommunity(string name, address community);
event DonationReceived(address sender, uint value);
event NewAlias(address user, string name);
function() public payable{
accounts[msg.sender].donations = accounts[msg.sender].donations.add(msg.value);
emit DonationReceived(msg.sender,msg.value);
}
function setAliasPrice(uint price) public;
function addAlias(address user, string alias) public payable;
function verifyAccount(address holder, string name, string country) public restricted;
function changeKeys(string label, byte[] key) public;
function joinCommunity(address community) public;
function leaveCommunity(address community) public;
function inCommunity(address user, address community) public view returns (bool);
function getName(address user) public view returns (string);
function getByAlias(string name) public view returns (address);
function isVerified(address user) public view returns (bool);
function donationsFrom(address user) public view returns (uint);
}
contract AVIVAccount is ManagedContract(msg.sender), AVIVAccountInterface{
function verifyAccount(address holder, string name, string country) public restricted{
require((names[name] == address(0) || names[name] == holder),"NAMEINUSE");
names[name] = holder;
Account storage account = accounts[holder];
account.name = name;
account.verified = true;
verified_users++;
emit AccountVerified(holder, name, country);
emit NewAlias(holder, name);
}
function setAliasPrice(uint price) public restricted{
alias_price = price;
}
function addAlias(address user, string alias) public payable{
if(msg.sender != manager){
require(msg.value >= alias_price,"MINIMUMDONATIONREQUIRED");
emit DonationReceived(msg.sender, msg.value);
}
require(names[alias] == address(0),"NAMEINUSE");
names[alias] = user;
emit NewAlias(user, alias);
}
function changeKeys(string label, byte[] key) public{
accounts[msg.sender].pubkeys[label] = key;
emit KeyChanged(msg.sender,label,key);
}
function joinCommunity(address community) public{
accounts[msg.sender].communities[community] = true;
emit JoinedCommunity(accounts[msg.sender].name, community);
}
function leaveCommunity(address community) public{
accounts[msg.sender].communities[community] = true;
emit LeftCommunity(accounts[msg.sender].name, community);
}
function inCommunity(address user, address community) public view returns (bool){
return accounts[user].communities[community];
}
function getKey(address user, string label) public view returns (byte[]){
return accounts[user].pubkeys[label];
}
function getName(address user) public view returns (string){
return accounts[user].name;
}
function getByAlias(string name) public view returns (address){
return names[name];
}
function isVerified(address user) public view returns (bool){
return accounts[user].verified;
}
function donationsFrom(address user) public view returns (uint){
return accounts[user].donations;
}
}