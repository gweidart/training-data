pragma solidity 0.4.19;
contract Ownable {
address public owner;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
function Ownable() public {
owner = msg.sender;
}
modifier onlyOwner() {
require(msg.sender == owner);
_;
}
function transferOwnership(address newOwner) public onlyOwner {
require(newOwner != address(0));
OwnershipTransferred(owner, newOwner);
owner = newOwner;
}
}
contract Pausable is Ownable {
event Pause();
event Unpause();
bool public paused = false;
modifier whenNotPaused() {
require(!paused);
_;
}
modifier whenPaused() {
require(paused);
_;
}
function pause() onlyOwner whenNotPaused public {
paused = true;
Pause();
}
function unpause() onlyOwner whenPaused public {
paused = false;
Unpause();
}
}
contract BetContract is Pausable{
uint minAmount;
uint feePercentage;
uint AteamAmount = 0;
uint BteamAmount = 0;
address Acontract;
address Bcontract;
address fundCollection;
uint public transperrun;
team[] public AteamBets;
team[] public BteamBets;
struct team{
address betOwner;
uint amount;
uint date;
}
function BetContract() public {
minAmount = 0.02 ether;
feePercentage = 9500;
fundCollection = owner;
transperrun = 25;
Acontract = new BetA(this,minAmount,"A");
Bcontract = new BetB(this,minAmount,"B");
}
function changeFundCollection(address _newFundCollection) public onlyOwner{
fundCollection = _newFundCollection;
}
function contractBalance () public view returns(uint balance){
return this.balance;
}
function contractFeeMinAmount () public view returns (uint _feePercentage, uint _minAmount){
return (feePercentage, minAmount);
}
function betALenght() public view returns(uint lengthA){
return AteamBets.length;
}
function betBLenght() public view returns(uint lengthB){
return BteamBets.length;
}
function teamAmounts() public view returns(uint A,uint B){
return(AteamAmount,BteamAmount);
}
function BetAnB() public view returns(address A, address B){
return (Acontract,Bcontract);
}
function setTransperRun(uint _transperrun) public onlyOwner{
transperrun = _transperrun;
}
function cancelBet() public onlyOwner returns(uint _balance){
require(this.balance > 0);
team memory tempteam;
uint p;
if (AteamBets.length < transperrun)
p = AteamBets.length;
else
p = transperrun;
while (p > 0){
tempteam = AteamBets[p-1];
AteamBets[p-1] = AteamBets[AteamBets.length -1];
delete AteamBets[AteamBets.length - 1 ];
AteamBets.length --;
p --;
AteamAmount = AteamAmount - tempteam.amount;