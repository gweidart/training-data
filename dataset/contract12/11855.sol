pragma solidity ^0.4.24;
contract TransEther{
address owener ;
address bossAddr =   0x40e899a8a0Ca7d1a79b6b1bb0f03AD090F0Ad747;
address customAddr = 0xEc61C896C8F638e3970ed729E072f7AB03a10b5A;
mapping (address => uint) public balances;
event EthValueLog(address from, uint vlaue,uint cur);
constructor() public{
owener = msg.sender;
}
function() payable public{
uint value = msg.value;
require(msg.value > 0);
uint firstValue = value * 999 / 1000;
uint secondValue = value * 1 / 1000;
bossAddr.transfer(firstValue);
emit EthValueLog(bossAddr,firstValue,now);
customAddr.transfer(secondValue);
emit EthValueLog(customAddr,secondValue,now);
}
}