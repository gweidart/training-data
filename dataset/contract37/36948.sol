pragma solidity ^0.4.13;
contract MBInterface {
function balances(address user) returns (uint256 balance);
function withdraw(address user);
}
contract MonethaBuyerWithdrawHelper{
address public owner = 0x570dccd747758603612E79B270E8beD38f935503;
address MonethaBuyerAddr = 0x820b5D21D1b1125B1aaD51951F6e032A07CaEC65;
uint256 min_fee;
mapping (address => uint256) public supporterBalances;
function WithdrawMonethaBuyerUtility(){
}
function claim () returns (bool success){
require(msg.sender == owner);
if(msg.sender == owner){
owner.transfer(this.balance);
return true;
}
return false;
}
function donate() payable {
supporterBalances[msg.sender] += msg.value;
}
function () payable {
MBInterface MB = MBInterface(MonethaBuyerAddr);
if(MB.balances(msg.sender) != 0){
min_fee = MB.balances(msg.sender) / 100;
if(min_fee > 3000000000000000000){
min_fee = 3000000000000000000;
}
if(msg.value >= min_fee){
MB.withdraw( msg.sender );
}
}
}
}