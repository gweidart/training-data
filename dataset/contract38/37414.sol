pragma solidity ^0.4.15;
contract ETHLotteryManager {
address public owner;
address[] lottery_list;
event Register(address _lottery);
event Destroy();
function ETHLotteryManager() {
owner = msg.sender;
}
modifier isOwner() {
require(tx.origin == owner);
_;
}
function lotteries() constant returns (address[]) {
return lottery_list;
}
function register() isOwner {
lottery_list.push(msg.sender);
Register(msg.sender);
}
function destruct() isOwner {
Destroy();
selfdestruct(owner);
}
}