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
contract DSPTypeAware {
enum DSPType { Gate, Direct }
}
contract DSPRegistry is DSPTypeAware{
function register(address key, DSPType dspType, bytes32[5] url, address recordOwner);
function updateUrl(address key, bytes32[5] url, address sender);
function applyKarmaDiff(address key, uint256[2] diff);
function unregister(address key, address sender);
function transfer(address key, address newOwner, address sender);
function getOwner(address key) constant returns(address);
function isRegistered(address key) constant returns(bool);
function getDSP(address key) constant returns(address dspAddress, DSPType dspType, bytes32[5] url, uint256[2] karma, address recordOwner);
function getAllDSP() constant returns(address[] addresses, DSPType[] dspTypes, bytes32[5][] urls, uint256[2][] karmas, address[] recordOwners) ;
function kill();
}
contract DSPRegistryImpl is DSPRegistry, DaoOwnable {
uint public creationTime = now;
struct DSP {
address owner;
uint time;
uint keysIndex;
address dspAddress;
DSPType dspType;
bytes32[5] url;
uint256[2] karma;
}
mapping(address => DSP) records;
uint public numRecords;
address[] public keys;
function register(address key, DSPType dspType, bytes32[5] url, address recordOwner) onlyDaoOrOwner {
require(records[key].time == 0);
records[key].time = now;
records[key].owner = recordOwner;
records[key].keysIndex = keys.length;
records[key].dspAddress = key;
records[key].dspType = dspType;
records[key].url = url;
keys.length++;
keys[keys.length - 1] = key;
numRecords++;
}
function updateUrl(address key, bytes32[5] url, address sender) onlyDaoOrOwner {
require(records[key].owner == sender);
records[key].url = url;
}
function applyKarmaDiff(address key, uint256[2] diff) onlyDaoOrOwner{
DSP storage dsp = records[key];
dsp.karma[0] += diff[0];
dsp.karma[1] += diff[1];
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
function getDSP(address key) constant returns(address dspAddress, DSPType dspType, bytes32[5] url, uint256[2] karma, address recordOwner) {
DSP storage record = records[key];
dspAddress = record.dspAddress;
url = record.url;
dspType = record.dspType;
karma = record.karma;
recordOwner = record.owner;
}
function getOwner(address key) constant returns(address) {
return records[key].owner;
}
function getTime(address key) constant returns(uint) {
return records[key].time;
}
function getAllDSP() constant returns(address[] addresses, DSPType[] dspTypes, bytes32[5][] urls, uint256[2][] karmas, address[] recordOwners) {
addresses = new address[](numRecords);
dspTypes = new DSPType[](numRecords);
urls = new bytes32[5][](numRecords);
karmas = new uint256[2][](numRecords);
recordOwners = new address[](numRecords);
uint i;
for(i = 0; i < numRecords; i++) {
DSP storage dsp = records[keys[i]];
addresses[i] = dsp.dspAddress;
dspTypes[i] = dsp.dspType;
urls[i] = dsp.url;
karmas[i] = dsp.karma;
recordOwners[i] = dsp.owner;
}
}
function kill() onlyOwner {
selfdestruct(owner);
}
}