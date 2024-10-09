contract Kardashian {
struct Participant {
address etherAddress;
uint amount;
}
Participant[] public participants;
uint public payoutIdx = 0;
uint public collectedFees;
uint public balance = 0;
address public owner;
modifier onlyowner { if (msg.sender == owner) _ }
function Kardashian() {
owner = msg.sender;
}
function() {
enter();
}
function enter() {
if (msg.value < 10 finney) {
msg.sender.send(msg.value);
return;
}
uint amount;
if (msg.value > 100 ether) {
msg.sender.send(msg.value - 100 ether);
amount = 100 ether;
}
else {
amount = msg.value;
}
uint idx = participants.length;
participants.length += 1;
participants[idx].etherAddress = msg.sender;
participants[idx].amount = amount;
if (idx != 0) {
collectedFees += amount / 20;
balance += amount - amount / 20;
}
else {
collectedFees += amount;
}
while (balance > participants[payoutIdx].amount / 100 * 190) {
uint transactionAmount = participants[payoutIdx].amount / 100 * 190;
participants[payoutIdx].etherAddress.send(transactionAmount);
balance -= transactionAmount;
payoutIdx += 1;
}
}
function collectFees() onlyowner {
if (collectedFees == 0) return;
owner.send(collectedFees);
collectedFees = 0;
}
function setOwner(address _owner) onlyowner {
owner = _owner;
}
}