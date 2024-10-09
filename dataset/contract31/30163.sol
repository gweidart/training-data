pragma solidity ^0.4.19;
contract PostManager {
enum State { Inactive, Created, Completed }
struct Post {
bytes32 jsonHash;
uint value;
}
modifier isOwner() {
require(msg.sender == owner);
_;
}
modifier isAdminGroupOrOwner() {
require(containsAdmin(msg.sender) || msg.sender == owner);
_;
}
uint constant version = 1;
address owner;
mapping(address => Post) posts;
mapping(address => address) administrators;
event AdminAdded(address _adminAddress);
event AdminDeleted(address _adminAddress);
event PostAdded(address _fromAddress);
event PostCompleted(address _fromAddress, address _toAddress);
function PostManager() public {
owner = msg.sender;
}
function getVersion() public constant returns (uint) {
return version;
}
function addAdmin(address _adminAddress) public isOwner {
administrators[_adminAddress] = _adminAddress;
AdminAdded(_adminAddress);
}
function deleteAdmin(address _adminAddress) public isOwner {
delete administrators[_adminAddress];
AdminDeleted(_adminAddress);
}
function containsAdmin(address _adminAddress) public constant returns (bool) {
return administrators[_adminAddress] != 0;
}
function addPost(bytes32 _jsonHash) public payable {
require(posts[msg.sender].value != 0);
var post = Post(_jsonHash, msg.value);
posts[msg.sender] = post;
PostAdded(msg.sender);
}
function completePost(address _fromAddress, address _toAddress) public isAdminGroupOrOwner() {
require(_toAddress != _fromAddress);
var post = posts[_fromAddress];
require(post.value != 0);
_toAddress.transfer(post.value);
delete posts[_fromAddress];
PostCompleted(_fromAddress, _toAddress);
}
function() public payable {
}
}