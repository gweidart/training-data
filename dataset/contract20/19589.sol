pragma solidity ^0.4.21;
contract Ownable {
modifier onlyOwner() {
checkOwner();
_;
}
function checkOwner() internal;
}
contract OwnableImpl is Ownable {
address public owner;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
function OwnableImpl() public {
owner = msg.sender;
}
function checkOwner() internal {
require(msg.sender == owner);
}
function transferOwnership(address newOwner) onlyOwner public {
require(newOwner != address(0));
emit OwnershipTransferred(owner, newOwner);
owner = newOwner;
}
}
contract Secured {
modifier only(string role) {
require(msg.sender == getRole(role));
_;
}
function getRole(string role) constant public returns (address);
}
contract SecuredImpl is Ownable, Secured {
mapping(string => address) users;
event RoleTransferred(address indexed previousUser, address indexed newUser, string role);
function getRole(string role) constant public returns (address) {
return users[role];
}
function transferRole(string role, address to) onlyOwner public {
require(to != address(0));
emit RoleTransferred(users[role], to, role);
users[role] = to;
}
}
contract Factory {
event TokenCreated(address addr);
event SaleCreated(address addr);
function createICO(bytes token, bytes sale) public {
address tokenAddress = create(token);
emit TokenCreated(tokenAddress);
address saleAddress = create(sale);
emit SaleCreated(saleAddress);
SecuredImpl(tokenAddress).transferRole("minter", saleAddress);
OwnableImpl(tokenAddress).transferOwnership(msg.sender);
OwnableImpl(saleAddress).transferOwnership(msg.sender);
}
function create(bytes code) internal returns (address addr) {
assembly {
addr := create(0, add(code,0x20), mload(code))
switch extcodesize(addr) case 0 {revert(0, 0)} default {}
}
}
}