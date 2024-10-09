pragma solidity ^0.4.23;
contract EOSVerify {
event LogRegisterEOSAddress(address indexed _from, string _eosAddress);
mapping(address => string) public eosAddressBook;
function registerEOSAddress(string eosAddress) public {
assert(bytes(eosAddress).length <= 64);
eosAddressBook[msg.sender] = eosAddress;
emit LogRegisterEOSAddress(msg.sender, eosAddress);
}
}