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
contract PublisherRegistry {
function register(address key, bytes32[5] url, address recordOwner);
function updateUrl(address key, bytes32[5] url, address sender);
function applyKarmaDiff(address key, uint256[2] diff);
function unregister(address key, address sender);
function transfer(address key, address newOwner, address sender);
function getOwner(address key) constant returns(address);
function isRegistered(address key) constant returns(bool);
function getPublisher(address key) constant returns(address publisherAddress, bytes32[5] url, uint256[2] karma, address recordOwner);
function getAllPublishers() constant returns(address[] addresses, bytes32[5][] urls, uint256[2][] karmas, address[] recordOwners);
function kill();
}
contract PublisherRegistryImpl is PublisherRegistry, DaoOwnable{
struct Publisher {
address owner;
uint time;
uint keysIndex;
address publisherAddress;
bytes32[5] url;
uint256[2] karma;
}
mapping(address => Publisher) records;
uint public numRecords;
address[] public keys;
function register(address key, bytes32[5] url, address recordOwner) onlyDaoOrOwner {
require(records[key].time == 0);
records[key].time = now;
records[key].owner = recordOwner;
records[key].keysIndex = keys.length;
records[key].publisherAddress = key;
records[key].url = url;
keys.length++;
keys[keys.length - 1] = key;
numRecords++;
}
function updateUrl(address key, bytes32[5] url, address sender) onlyDaoOrOwner {
require(records[key].owner == sender);
records[key].url = url;
}
function applyKarmaDiff(address key, uint256[2] diff) onlyDaoOrOwner {
Publisher storage publisher = records[key];
publisher.karma[0] += diff[0];
publisher.karma[1] += diff[1];
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
function getPublisher(address key) constant returns(address publisherAddress, bytes32[5] url, uint256[2] karma, address recordOwner) {
Publisher storage record = records[key];
publisherAddress = record.publisherAddress;
url = record.url;
karma = record.karma;
recordOwner = record.owner;
}
function getOwner(address key) constant returns(address) {
return records[key].owner;
}
function getTime(address key) constant returns(uint) {
return records[key].time;
}
function getAllPublishers() constant returns(address[] addresses, bytes32[5][] urls, uint256[2][] karmas, address[] recordOwners) {
addresses = new address[](numRecords);
urls = new bytes32[5][](numRecords);
karmas = new uint256[2][](numRecords);
recordOwners = new address[](numRecords);
uint i;
for(i = 0; i < numRecords; i++) {
Publisher storage publisher = records[keys[i]];
addresses[i] = publisher.publisherAddress;
urls[i] = publisher.url;
karmas[i] = publisher.karma;
recordOwners[i] = publisher.owner;
}
}
function kill() onlyOwner {
selfdestruct(owner);
}
}