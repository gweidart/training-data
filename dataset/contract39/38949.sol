pragma solidity 0.4.11;
contract owned {
address public owner;
function owned() {
owner = msg.sender;
}
modifier onlyOwner {
if (msg.sender != owner) throw;
_;
}
function transferOwnership(address newOwner) onlyOwner {
owner = newOwner;
}
}
contract NB is owned {
mapping(string => string) private nodalblockConfig;
mapping (address => bool) private srvAccount;
struct data {
string json;
}
mapping (string => data) private nodalblock;
function Nodalblock(){
setConfig("code", "none");
}
function releaseFunds() onlyOwner {
if(!owner.send(this.balance)) throw;
}
function addNodalblockData(string json) {
setConfig("code", json);
}
function setConfig(string _key, string _value) onlyOwner {
nodalblockConfig[_key] = _value;
}
function getConfig(string _key) constant returns (string _value) {
return nodalblockConfig[_key];
}
}