pragma solidity 0.4.15;
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
contract Ownable {
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
function Ownable() {
owner = msg.sender;
}
function transferOwnership(address newOwner) onlyOwner public {
require(newOwner != address(0));
OwnershipTransferred(owner, newOwner);
owner = newOwner;
}
modifier onlyOwner() {
require(msg.sender == owner);
_;
}
address public owner;
}
contract DaoOwnable is Ownable{
address public dao = address(0);
event DaoOwnershipTransferred(address indexed previousOwner, address indexed newOwner);
modifier onlyDao() {
require(msg.sender == dao);
_;
}
modifier onlyDaoOrOwner() {
require(msg.sender == dao || msg.sender == owner);
_;
}
function transferDao(address newDao) onlyOwner {
require(newDao != address(0));
dao = newDao;
DaoOwnershipTransferred(owner, newDao);
}
}
contract DepositRegistry {
function register(address key, uint256 amount, address depositOwner);
function unregister(address key);
function transfer(address key, address newOwner, address sender);
function spend(address key, uint256 amount);
function refill(address key, uint256 amount);
function isRegistered(address key) constant returns(bool);
function getDepositOwner(address key) constant returns(address);
function getDeposit(address key) constant returns(uint256 amount);
function getDepositRecord(address key) constant returns(address owner, uint time, uint256 amount, address depositOwner);
function hasEnough(address key, uint256 amount) constant returns(bool);
function kill();
}
contract DepositRegistryImpl is DepositRegistry, DaoOwnable {
using SafeMath for uint256;
uint public creationTime = now;
struct Deposit {
address owner;
uint time;
uint keysIndex;
uint256 amount;
}
mapping(address => Deposit) records;
uint public numDeposits;
address[] public keys;
function register(address key, uint256 amount, address depositOwner) onlyDaoOrOwner {
require(records[key].time == 0);
records[key].time = now;
records[key].owner = depositOwner;
records[key].keysIndex = keys.length;
keys.length++;
keys[keys.length - 1] = key;
records[key].amount = amount;
numDeposits++;
}
function unregister(address key) onlyDaoOrOwner {
uint keysIndex = records[key].keysIndex;
delete records[key];
numDeposits--;
keys[keysIndex] = keys[keys.length - 1];
records[keys[keysIndex]].keysIndex = keysIndex;
keys.length--;
}
function transfer(address key, address newOwner, address sender) onlyDaoOrOwner {
require(records[key].owner == sender);
records[key].owner = newOwner;
}
function isRegistered(address key) constant returns(bool) {
return records[key].time != 0;
}
function getDepositOwner(address key) constant returns (address) {
return records[key].owner;
}
function getDeposit(address key) constant returns(uint256 amount) {
Deposit storage record = records[key];
amount = record.amount;
}
function getDepositRecord(address key) constant returns(address owner, uint time, uint256 amount, address depositOwner) {
Deposit storage record = records[key];
owner = record.owner;
time = record.time;
amount = record.amount;
depositOwner = record.owner;
}
function hasEnough(address key, uint256 amount) constant returns(bool) {
Deposit storage deposit = records[key];
return deposit.amount >= amount;
}
function spend(address key, uint256 amount) onlyDaoOrOwner {
require(isRegistered(key));
records[key].amount = records[key].amount.sub(amount);
}
function refill(address key, uint256 amount) onlyDaoOrOwner {
require(isRegistered(key));
records[key].amount = records[key].amount.add(amount);
}
function kill() onlyOwner {
selfdestruct(owner);
}
}
contract SecurityDepositRegistry is DepositRegistryImpl{
}