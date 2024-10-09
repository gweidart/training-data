pragma solidity ^0.4.11;
contract EndpointRegistryContract {
event AddressRegistered(address indexed eth_address, string socket);
mapping (address => string) address_to_socket;
modifier noEmptyString(string str)
{
require(equals(str, "") != true);
_;
}
function registerEndpoint(string socket) noEmptyString(socket)
{
string storage old_socket = address_to_socket[msg.sender];
if (equals(old_socket, socket)) {
return;
}
address_to_socket[msg.sender] = socket;
AddressRegistered(msg.sender, socket);
}
function findEndpointByAddress(address eth_address) constant returns (string socket)
{
return address_to_socket[eth_address];
}
function equals(string a, string b) internal constant returns (bool result)
{
if (sha3(a) == sha3(b)) {
return true;
}
return false;
}
}