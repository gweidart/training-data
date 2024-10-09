pragma solidity 0.4.24;
contract Ownable {
address public owner;
event OwnershipTransferred(
address indexed previousOwner,
address indexed newOwner
);
constructor() public {
owner = msg.sender;
}
modifier onlyOwner() {
require(msg.sender == owner);
_;
}
function transferOwnership(address _newOwner) public onlyOwner {
_transferOwnership(_newOwner);
}
function _transferOwnership(address _newOwner) internal {
require(_newOwner != address(0));
emit OwnershipTransferred(owner, _newOwner);
owner = _newOwner;
}
}
contract DZariusz is Ownable {
string public name;
string public contact;
event LogSetName(address indexed executor, string newName);
event LogSetContact(address indexed executor, string newContact);
constructor(string _name, string _contact) public {
setName(_name);
setContact(_contact);
}
function setName(string _name) public onlyOwner returns (bool) {
name = _name;
emit LogSetName(msg.sender, _name);
return true;
}
function setContact(string _contact) public onlyOwner returns (bool) {
contact = _contact;
emit LogSetContact(msg.sender, _contact);
return true;
}
}