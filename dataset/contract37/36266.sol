pragma solidity ^0.4.16;
contract Owned {
address public owner;
address public newOwner;
function Owned() public {
owner = msg.sender;
}
modifier onlyOwner {
require(msg.sender == owner);
_;
}
function transferOwnership(address _newOwner) public onlyOwner {
newOwner = _newOwner;
}
function acceptOwnership() public {
require(msg.sender == newOwner);
OwnershipTransferred(owner, newOwner);
owner = newOwner;
newOwner = 0x0;
}
event OwnershipTransferred(address indexed _from, address indexed _to);
}
contract Administered is Owned {
mapping (address => bool) public administrators;
event AdminstratorAdded(address adminAddress);
event AdminstratorRemoved(address adminAddress);
modifier onlyAdministrator() {
require(administrators[msg.sender] || owner == msg.sender);
_;
}
function addAdministrators(address _adminAddress) public onlyOwner {
administrators[_adminAddress] = true;
AdminstratorAdded(_adminAddress);
}
function removeAdministrators(address _adminAddress) public onlyOwner {
delete administrators[_adminAddress];
AdminstratorRemoved(_adminAddress);
}
}
contract GazeCoinCrowdsaleWhitelist is Administered {
bool public sealed;
mapping(address => bool) public whitelist;
event Whitelisted(address indexed whitelistedAddress, bool enabled);
function GazeCoinCrowdsaleWhitelist() public {
}
function enable(address[] _addresses) public onlyAdministrator {
require(!sealed);
require(_addresses.length != 0);
for (uint i = 0; i < _addresses.length; i++) {
require(_addresses[i] != 0x0);
if (!whitelist[_addresses[i]]) {
whitelist[_addresses[i]] = true;
Whitelisted(_addresses[i], true);
}
}
}
function disable(address[] _addresses) public onlyAdministrator {
require(!sealed);
require(_addresses.length != 0);
for (uint i = 0; i < _addresses.length; i++) {
require(_addresses[i] != 0x0);
if (whitelist[_addresses[i]]) {
whitelist[_addresses[i]] = false;
Whitelisted(_addresses[i], false);
}
}
}
function seal() public onlyOwner {
require(!sealed);
sealed = true;
}
function () public {
}
}