pragma solidity ^0.4.21;
contract Ownable {
address public owner;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
function Ownable() public {
owner = msg.sender;
}
modifier onlyOwner() {
require(msg.sender == owner);
_;
}
function transferOwnership(address newOwner) public onlyOwner {
require(newOwner != address(0));
emit OwnershipTransferred(owner, newOwner);
owner = newOwner;
}
}
contract KnowYourCustomer is Ownable
{
struct Contributor {
bool cleared;
uint16 contributor_get;
address ref;
uint16 affiliate_get;
}
mapping (address => Contributor) public whitelist;
function setContributor(address _address, bool cleared, uint16 contributor_get, uint16 affiliate_get, address ref) onlyOwner public{
require(contributor_get<10000);
require(affiliate_get<10000);
Contributor storage contributor = whitelist[_address];
contributor.cleared = cleared;
contributor.contributor_get = contributor_get;
contributor.ref = ref;
contributor.affiliate_get = affiliate_get;
}
function getContributor(address _address) view public returns (bool, uint16, address, uint16 ) {
return (whitelist[_address].cleared, whitelist[_address].contributor_get, whitelist[_address].ref, whitelist[_address].affiliate_get);
}
function getClearance(address _address) view public returns (bool) {
return whitelist[_address].cleared;
}
}