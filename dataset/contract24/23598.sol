pragma solidity ^ 0.4.17;
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
function transferOwnership(address newOwner) onlyOwner public {
require(newOwner != address(0));
OwnershipTransferred(owner, newOwner);
owner = newOwner;
}
}
contract WhiteList is Ownable {
mapping(address => bool) public whiteList;
mapping(address => address) public affiliates;
uint public totalWhiteListed;
event LogWhiteListed(address indexed user, address affiliate, uint whiteListedNum);
event LogWhiteListedMultiple(uint whiteListedNum);
event LogRemoveWhiteListed(address indexed user);
function isWhiteListedAndAffiliate(address _user) external view returns (bool, address) {
return (whiteList[_user], affiliates[_user]);
}
function returnReferral(address _user) external view returns (address) {
return  affiliates[_user];
}
function removeFromWhiteList(address _user) external onlyOwner() returns (bool) {
require(whiteList[_user] == true);
whiteList[_user] = false;
affiliates[_user] = address(0);
totalWhiteListed--;
LogRemoveWhiteListed(_user);
return true;
}
function addToWhiteList(address _user, address _affiliate) external onlyOwner() returns (bool) {
if (whiteList[_user] != true) {
whiteList[_user] = true;
affiliates[_user] = _affiliate;
totalWhiteListed++;
LogWhiteListed(_user, _affiliate, totalWhiteListed);
}
return true;
}
function addToWhiteListMultiple(address[] _users, address[] _affiliate) external onlyOwner() returns (bool) {
for (uint i = 0; i < _users.length; ++i) {
if (whiteList[_users[i]] != true) {
whiteList[_users[i]] = true;
affiliates[_users[i]] = _affiliate[i];
totalWhiteListed++;
}
}
LogWhiteListedMultiple(totalWhiteListed);
return true;
}
}