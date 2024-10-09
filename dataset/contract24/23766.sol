pragma solidity ^0.4.18;
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
OwnershipTransferred(owner, newOwner);
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
Pause();
}
function unpause() onlyOwner whenPaused public {
paused = false;
Unpause();
}
}
contract SkinPresale is Pausable {
mapping (address => uint256) public accountToBoughtNum;
uint256 public totalSupplyForPresale = 10000;
uint256 public accountBuyLimit = 100;
uint256 public remainPackage = 10000;
event BuyPresale(address account);
function buyPresale() payable external whenNotPaused {
address account = msg.sender;
require(accountToBoughtNum[account] + 1 < accountBuyLimit);
require(remainPackage > 0);
uint256 price = 20 finney + (10000 - remainPackage) / 500 * 10 finney;
require(msg.value >= price);
accountToBoughtNum[account] += 1;
remainPackage -= 1;
BuyPresale(account);
}
function withdrawETH() external onlyOwner {
owner.transfer(this.balance);
}
}