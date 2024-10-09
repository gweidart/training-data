pragma solidity ^0.4.18;
contract Quicketh {
address public owner;
uint public players;
address[] public playedWallets;
address[] public winners;
uint playPrice = 0.001 * 1000000000000000000;
uint public rounds;
event WinnerWinnerChickenDinner(address winner, uint amount);
event AnotherPlayer(address player);
function Quicketh() public payable{
owner = msg.sender;
players = 0;
rounds = 0;
}
function play()  payable public{
require (msg.value == playPrice);
playedWallets.push(msg.sender);
players += 1;
AnotherPlayer(msg.sender);
if (players > 9){
uint random_number = uint(block.blockhash(block.number-1))%10 + 1;
winners.push(playedWallets[random_number]);
playedWallets[random_number].transfer(8*playPrice);
WinnerWinnerChickenDinner(playedWallets[random_number], 8*playPrice);
owner.transfer(this.balance);
rounds += 1;
players = 0;
delete playedWallets;
}
}
}