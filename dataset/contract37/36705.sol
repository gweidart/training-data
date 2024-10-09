pragma solidity ^0.4.4;
contract TgeProxy {
address[] public managers;
mapping (address => address) votesAddr;
bool locked = false;
function TgeProxy() {
managers.push(0xCE05A8Aa56E1054FAFC214788246707F5258c0Ae);
managers.push(0xBb62A710BDbEAF1d3AD417A222d1ab6eD08C37f5);
managers.push(0x009A55A3c16953A359484afD299ebdC444200EdB);
}
function() payable isLocked {
votesAddr[managers[0]].transfer(msg.value);
}
function setTgeAddr(address addr) isManager isUnlocked {
votesAddr[msg.sender] = addr;
lockAttemp();
}
function lockAttemp() private {
address addr = votesAddr[managers[0]];
bool lock = true;
for (uint8 i = 0; i < managers.length; ++i) {
if (votesAddr[managers[i]] == 0x0) {
lock = false;
break;
}
if (votesAddr[managers[i]] != addr) {
lock = false;
break;
}
}
if (lock) {
locked = true;
}
}
modifier isManager() {
for (uint8 i = 0; i < managers.length; ++i) {
if (managers[i] == msg.sender) {
_;
}
}
}
modifier isUnlocked() {
assert(!locked);
_;
}
modifier isLocked() {
assert(locked);
_;
}
}