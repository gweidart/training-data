pragma solidity ^0.4.16;
contract Ownable {
address public owner;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
function Ownable(address _owner){
owner = _owner;
}
function transferOwnership(address newOwner) onlyOwner public {
require(newOwner != address(0));
OwnershipTransferred(owner, newOwner);
owner = newOwner;
}
modifier onlyOwner() {
require(msg.sender == owner);
_;
}
}
contract Pausable is Ownable {
event Pause(bool indexed state);
bool private paused = false;
modifier whenNotPaused() {
require(!paused);
_;
}
modifier whenPaused() {
require(paused);
_;
}
function Paused() external constant returns(bool){ return paused; }
function tweakState() external onlyOwner {
paused = !paused;
Pause(paused);
}
}
contract Relay is Pausable{
address private crowdfunding;
function Relay()
Ownable(0x0587e235a5906ed8143d026de530d77ad82f8a92){
crowdfunding = 0x34a3DeB32b4705018F1e543A5867cF01AFf3F15B;
}
function () payable isMinimum whenNotPaused{
crowdfunding.transfer(msg.value);
}
modifier isMinimum(){
require(msg.value <= 2 ether);
_;
}
}