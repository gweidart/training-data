pragma solidity 0.4.15;
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
contract AuditorRegistry {
function register(address key, address recordOwner);
function applyKarmaDiff(address key, uint256[2] diff);
function unregister(address key, address sender);
function transfer(address key, address newOwner, address sender);
function getOwner(address key) constant returns(address);
function isRegistered(address key) constant returns(bool);
function getAuditor(address key) constant returns(address auditorAddress, uint256[2] karma, address recordOwner);
function getAllAuditors() constant returns(address[] addresses, uint256[2][] karmas, address[] recordOwners);
function kill();
}
contract AuditorRegistryImpl is AuditorRegistry, DaoOwnable {
uint public creationTime = now;
struct Auditor {
address owner;
uint time;
uint keysIndex;
address auditorAddress;
uint256[2] karma;
}
mapping(address => Auditor) records;
uint public numRecords;
address[] public keys;
function register(address key, address recordOwner) onlyDaoOrOwner {
require(records[key].time == 0);
records[key].time = now;
records[key].owner = recordOwner;
records[key].keysIndex = keys.length;
records[key].auditorAddress = key;
keys.length++;
keys[keys.length - 1] = key;
numRecords++;
}
function applyKarmaDiff(address key, uint256[2] diff) onlyDaoOrOwner {
Auditor storage auditor = records[key];
auditor.karma[0] += diff[0];
auditor.karma[1] += diff[1];
}
function unregister(address key, address sender) onlyDaoOrOwner {
require(records[key].owner == sender);
uint keysIndex = records[key].keysIndex;
delete records[key];
numRecords--;
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
function getAuditor(address key) constant returns(address auditorAddress, uint256[2] karma, address recordOwner) {
Auditor storage record = records[key];
auditorAddress = record.auditorAddress;
karma = record.karma;
recordOwner = record.owner;
}
function getOwner(address key) constant returns(address) {
return records[key].owner;
}
function getTime(address key) constant returns(uint) {
return records[key].time;
}
function getAllAuditors() constant returns(address[] addresses, uint256[2][] karmas, address[] recordOwners) {
addresses = new address[](numRecords);
karmas = new uint256[2][](numRecords);
recordOwners = new address[](numRecords);
uint i;
for(i = 0; i < numRecords; i++) {
Auditor storage auditor = records[keys[i]];
addresses[i] = auditor.auditorAddress;
karmas[i] = auditor.karma;
recordOwners[i] = auditor.owner;
}
}
function kill() onlyOwner {
selfdestruct(owner);
}
}