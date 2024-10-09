pragma solidity ^0.4.20;
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
contract Pausable is Ownable {
event Pause();
event Unpause();
bool public paused = false;
modifier whenNotPaused() {
require(!paused);
_;
}
modifier whenPaused() {
require(paused);
_;
}
function pause() onlyOwner whenNotPaused public {
paused = true;
emit Pause();
}
function unpause() onlyOwner whenPaused public {
paused = false;
emit Unpause();
}
}
contract BlockchainCutiesPresale is Pausable
{
mapping (uint256 => address) public ownerOf;
mapping (uint256 => uint256) public prices;
event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
function addCutie(uint40 id, uint256 price) public onlyOwner
{
require(ownerOf[id] == address(0));
prices[id] = price;
}
function isAvailable(uint40 id) public view returns (bool)
{
return ownerOf[id] == address(0) && prices[id] > 0;
}
function getPrice(uint40 id) public view returns (uint256 price, bool available)
{
price = prices[id];
available = isAvailable(id);
}
function bid(uint40 id) public payable
{
require(isAvailable(id));
require(prices[id] <= msg.value);
ownerOf[id] = msg.sender;
emit Transfer(0, msg.sender, id);
}
function destroyContract() public onlyOwner {
selfdestruct(msg.sender);
}
function withdraw() public onlyOwner {
address(msg.sender).transfer(address(this).balance);
}
}