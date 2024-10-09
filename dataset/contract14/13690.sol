pragma solidity ^0.4.21;
contract ERC20Interface {
function transfer(address to, uint256 tokens) public returns (bool success);
}
contract Halo3D {
function buy(address) public payable returns(uint256);
function transfer(address, uint256) public returns(bool);
function withdraw() public;
function myTokens() public view returns(uint256);
function myDividends(bool) public view returns(uint256);
function reinvest() public;
}
contract AcceptsHalo3D {
Halo3D public tokenContract;
function AcceptsHalo3D(address _tokenContract) public {
tokenContract = Halo3D(_tokenContract);
}
modifier onlyTokenContract {
require(msg.sender == address(tokenContract));
_;
}
function tokenFallback(address _from, uint256 _value, bytes _data) external returns (bool);
}
contract Owned {
address public owner;
address public ownerCandidate;
function Owned() public {
owner = msg.sender;
}
modifier onlyOwner() {
require(msg.sender == owner);
_;
}
function changeOwner(address _newOwner) public onlyOwner {
ownerCandidate = _newOwner;
}
function acceptOwnership() public {
require(msg.sender == ownerCandidate);
owner = ownerCandidate;
}
}
contract Halo3DDoublr is Owned, AcceptsHalo3D {
event Deposit(uint256 amount, address depositer);
event Payout(uint256 amount, address creditor);
struct Participant {
address etherAddress;
uint256 payout;
}
uint256 throughput;
uint256 dividends;
uint256 public multiplier;
uint256 public payoutOrder = 0;
uint256 public backlog = 0;
Participant[] public participants;
mapping(address => uint256) public creditRemaining;
function Halo3DDoublr(uint multiplierPercent, address _baseContract)
AcceptsHalo3D(_baseContract)
public {
multiplier = multiplierPercent;
}
function() payable public {
}
function tokenFallback(address _from, uint256 _value, bytes _data)
external
onlyTokenContract
returns (bool) {
require(!_isContract(_from));
require(_value <= 100 ether);
require(_value >= 1 ether);
uint256 amountCredited = (_value * multiplier) / 100;
participants.push(Participant(_from, amountCredited));
backlog += amountCredited;
creditRemaining[_from] += amountCredited;
emit Deposit(_value, _from);
throughput += _value;
uint balance = _value;
reinvest();
while (balance > 0) {
uint payoutToSend = balance < participants[payoutOrder].payout ? balance : participants[payoutOrder].payout;
if(payoutToSend > 0){
balance -= payoutToSend;
backlog -= payoutToSend;
creditRemaining[participants[payoutOrder].etherAddress] -= payoutToSend;
participants[payoutOrder].payout -= payoutToSend;
if(tokenContract.transfer(participants[payoutOrder].etherAddress, payoutToSend)) {
emit Payout(payoutToSend, participants[payoutOrder].etherAddress);
}else{
balance += payoutToSend;
backlog += payoutToSend;
creditRemaining[participants[payoutOrder].etherAddress] += payoutToSend;
participants[payoutOrder].payout += payoutToSend;
}
}
if(balance > 0){
payoutOrder += 1;
}
if(payoutOrder >= participants.length){
return true;
}
}
return true;
}
function _isContract(address _user) internal view returns (bool) {
uint size;
assembly { size := extcodesize(_user) }
return size > 0;
}
function reinvest() public {
if(tokenContract.myDividends(true) > 1) {
tokenContract.reinvest();
}
}
function backlogLength() public view returns (uint256){
return participants.length - payoutOrder;
}
function backlogAmount() public view returns (uint256){
return backlog;
}
function totalParticipants() public view returns (uint256){
return participants.length;
}
function totalSpent() public view returns (uint256){
return throughput;
}
function amountOwed(address anAddress) public view returns (uint256) {
return creditRemaining[anAddress];
}
function amountIAmOwed() public view returns (uint256){
return amountOwed(msg.sender);
}
}