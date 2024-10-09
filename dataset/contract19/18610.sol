pragma solidity^0.4.21;
contract ReceiverInterface {
function receiveEther() external payable {}
}
contract EthRelief {
bool    upgraded;
address etheraffle;
modifier onlyEtheraffle() {
require(msg.sender == etheraffle);
_;
}
event LogEtherReceived(address fromWhere, uint howMuch, uint atTime);
event LogUpgrade(address toWhere, uint amountTransferred, uint atTime);
function EthRelief(address _etheraffle) {
etheraffle = _etheraffle;
}
function upgrade(address _addr) onlyEtheraffle external {
upgraded = true;
emit LogUpgrade(_addr, this.balance, now);
ReceiverInterface(_addr).receiveEther.value(this.balance)();
}
function receiveEther() payable external {
emit LogEtherReceived(msg.sender, msg.value, now);
}
function setEtheraffle(address _newAddr) onlyEtheraffle external {
etheraffle = _newAddr;
}
function selfDestruct(address _addr) onlyEtheraffle {
require(upgraded);
selfdestruct(_addr);
}
function () payable external {
}
}