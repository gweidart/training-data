pragma solidity ^0.4.0;
contract Genesis {
event registrationEvent(address addr, address parent);
event dieEvent(address whoDied, address whoReplaced);
event getFundsEvent(address addr, uint256 amount);
mapping (address => address[]) public children;
mapping (address => address) public parents;
mapping (address => uint256) public funds;
mapping (address => string) public nicknames;
mapping (address => uint256) public lastActivity;
uint256 public capital;
uint256 public customers;
uint256 public constant deadLine = 50 days;
address public genesis;
modifier onlyGenesis() {
require(msg.sender == genesis);
_;
}
modifier withFunds() {
require(funds[msg.sender] > 0);
_;
}
function Genesis(address firstChild) {
require(msg.sender != firstChild);
genesis = msg.sender;
nicknames[genesis] = 'Genesis';
parents[genesis] = 0x0;
customers++;
registerAdmin(firstChild, 'First');
}
function isNotRegistered(address addr) constant  public returns (bool){
if (parents[addr] == 0x0 && children[addr].length == 0) return true;
return false;
}
function currentPayment() public constant returns (uint payment){
if (capital > 1000 ether) {
return 2 ether;
}
else
if (capital > 200 ether) {
return 1.33 ether;
}
else
if (capital > 30 ether) {
return 0.66 ether;
}
else
if (capital > 4 ether) {
return 0.33 ether;
}
else
if (capital > 0.5 ether) {
return 0.17 ether;
}
else
if (capital > 0.1 ether) {
return 0.05 ether;
}
return 0.01 ether;
}
function registerAdmin(address admin, string name) onlyGenesis public {
require(isNotRegistered(admin));
nicknames[admin] = name;
parents[admin] = msg.sender;
lastActivity[genesis] = now;
children[genesis].push(admin);
customers++;
lastActivity[admin] = now;
}
function registerUser(address child, address parent, string nickname, uint value) private {
require(isNotRegistered(child));
nicknames[child] = nickname;
parents[child] = parent;
children[parent].push(child);
funds[parent] += value;
capital += value;
customers++;
registrationEvent(child, parent);
lastActivity[child] = now;
}
function registration(address parent, string nickname) payable public {
require(msg.value == currentPayment());
registerUser(msg.sender, parent, nickname, msg.value);
}
function getMine() public withFunds {
require(!isNotRegistered(msg.sender));
require(msg.sender != genesis);
uint256 mine = funds[msg.sender] / 2;
funds[parents[msg.sender]] += (funds[msg.sender] - mine);
funds[msg.sender] = 0;
msg.sender.transfer(mine);
getFundsEvent(msg.sender, mine);
lastActivity[msg.sender] = now;
}
function myAvailableFunds() public constant returns (uint256 myFunds) {
return funds[msg.sender] / 2;
}
function getMineGenesis() public onlyGenesis withFunds {
uint256 mine = funds[msg.sender];
funds[msg.sender] = 0;
msg.sender.transfer(mine);
getFundsEvent(msg.sender, mine);
lastActivity[msg.sender] = now;
}
function transferGenesis(address newGen) public onlyGenesis {
require(isNotRegistered(newGen));
for (uint i = 0; i < children[genesis].length; i++) {
children[newGen].push(children[genesis][i]);
parents[children[genesis][i]] = newGen;
children[genesis][i] = 0x0;
}
children[genesis].length = 0;
funds[newGen] = funds[genesis];
funds[genesis] = 0;
nicknames[newGen] = nicknames[genesis];
nicknames[genesis] = '';
lastActivity[newGen] = now;
lastActivity[genesis] = 0;
genesis = newGen;
}
function transferChildren(address child) public {
require(parents[child] == msg.sender);
require(now - lastActivity[child] > deadLine);
require(children[child].length > 0);
for (uint256 i = 0; i < children[child].length; i++) {
children[msg.sender].push(children[child][i]);
parents[children[child][i]] = msg.sender;
children[child][i] = 0x0;
}
children[child].length = 0;
parents[child] = 0x0;
funds[msg.sender] += funds[child];
funds[child] = 0;
dieEvent(child, msg.sender);
lastActivity[msg.sender] = now;
}
}