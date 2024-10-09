pragma solidity ^0.4.11;
contract Lottery {
mapping(uint => address) public gamblers;
uint8 public player_count;
uint public ante;
uint8 public required_number_players;
uint8 public next_round_players;
uint random;
uint public winner_percentage;
address owner;
uint bet_blocknumber;
function Lottery(){
owner = msg.sender;
player_count = 0;
ante = 1 ether;
required_number_players = 100;
winner_percentage = 90;
}
function refund() {
if (msg.sender == owner) {
while (this.balance > ante) {
gamblers[player_count].transfer(ante);
player_count -=1;
}
gamblers[1].transfer(this.balance);
}
}
event Announce_winner(
address indexed _from,
address indexed _to,
uint _value
);
function () payable {
if(msg.value != ante) throw;
player_count +=1;
gamblers[player_count] = msg.sender;
if (player_count == required_number_players) {
bet_blocknumber=block.number;
}
if (player_count > required_number_players) {
if (block.number>bet_blocknumber){
random = uint(block.blockhash(block.number-1))%required_number_players + 1;
gamblers[random].transfer(ante*required_number_players*winner_percentage/100);
0x4b0044E50E074A86aFAbA6eac1872c4Ce5af7712.transfer(ante*required_number_players - ante*required_number_players*winner_percentage/100);
next_round_players = player_count-required_number_players;
while (player_count > required_number_players) {
gamblers[player_count-required_number_players] = gamblers[player_count];
player_count -=1;
}
player_count = next_round_players;
}
else throw;
}
}
}