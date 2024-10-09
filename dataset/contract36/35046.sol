contract SafeMath {
function safeMul(uint a, uint b) internal constant returns (uint) {
uint c = a * b;
assert(a == 0 || c / a == b);
return c;
}
function safeDiv(uint a, uint b) internal constant returns (uint) {
uint c = a / b;
return c;
}
function safeSub(uint a, uint b) internal constant returns (uint) {
require(b <= a);
return a - b;
}
function safeAdd(uint a, uint b) internal constant returns (uint) {
uint c = a + b;
assert(c>=a && c>=b);
return c;
}
}
contract EtherReceiverInterface {
function receiveEther() public payable;
}
contract Escrow is SafeMath, EtherReceiverInterface {
uint[3] threshold = [0 ether, 21008 ether, 1000000 ether];
uint[2] rate = [4, 1];
address public project;
address public icofunding;
uint public lockUntil;
uint public totalCollected;
modifier locked() {
require(block.number >= lockUntil);
_;
}
event e_Withdraw(uint block, uint fee, uint amount);
function Escrow(uint _lockUntil, address _icofunding, address _project) {
lockUntil = _lockUntil;
icofunding = _icofunding;
project = _project;
}
function withdraw() public locked {
uint fee = getFee(this.balance);
uint amount = safeSub(this.balance, fee);
icofunding.transfer(fee);
project.transfer(amount);
e_Withdraw(block.number, fee, amount);
}
function getFee(uint value) public constant returns (uint) {
uint fee;
uint slice;
uint aux;
for(uint i = 0; i < 2; i++) {
aux = value;
if(value > threshold[i+1])
aux = threshold[i+1];
if(threshold[i] < aux) {
slice = safeSub(aux, threshold[i]);
fee = safeAdd(fee, safeDiv(safeMul(slice, rate[i]), 100));
}
}
return fee;
}
function receiveEther() public payable {
totalCollected += msg.value;
}
function() payable {
totalCollected += msg.value;
}
}