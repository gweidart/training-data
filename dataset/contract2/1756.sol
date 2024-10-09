pragma solidity ^0.4.23;
contract ZTHInterface {
function buyAndSetDivPercentage(address _referredBy, uint8 _divChoice, string providedUnhashedPass) public payable returns (uint);
function balanceOf(address who) public view returns (uint);
function transfer(address _to, uint _value)     public returns (bool);
function transferFrom(address _from, address _toAddress, uint _amountOfTokens) public returns (bool);
function exit() public;
function sell(uint amountOfTokens) public;
function withdraw(address _recipient) public;
function getUserAverageDividendRate(address user) public view returns (uint);
}
contract ZethrGameInterface{
function execute(address from, uint value, uint userDivRate, bytes data) public;
}
contract ERC223Receiving {
function tokenFallback(address _from, uint _amountOfTokens, bytes _data) public returns (bool);
}
contract ZethrBankroll {
address public stakeAddress;
mapping (address => bool) public isOwner;
function changeAllocation(address what, int delta) public;
}
library ZethrTierLibrary{
uint constant internal magnitude = 2**64;
function getTier(uint divRate) internal pure returns (uint){
uint actualDiv = divRate / magnitude;
if (actualDiv >= 30){
return 7;
}
else if (actualDiv >= 25){
return 6;
}
else if (actualDiv >= 20){
return 5;
}
else if (actualDiv >= 15){
return 4;
}
else if (actualDiv >= 10){
return 3;
}
else if (actualDiv >= 5){
return 2;
}
else if (actualDiv >= 2){
return 1;
}
else{
revert();
}
}
}
contract ZethrTokenBankroll is ERC223Receiving {
mapping(address => bool) public whitelistedContract;
mapping (address => uint) public tokenVolumeInput;
mapping (address => uint) public tokenVolumeOutput;
mapping (address => uint) public gameTokenAmount;
mapping (address => uint) public gameTokenAllocation;
uint public freeTokens;
address[] public games;
address Zethr;
ZTHInterface ZethrContract;
address ZethrMainBankroll;
uint public divRate;
uint public tier;
uint constant internal magnitude = 2**64;
modifier contractIsWhiteListed(address ctr){
require(whitelistedContract[ctr]);
_;
}
modifier onlyDevOrBankroll(){
require(msg.sender == ZethrMainBankroll || ZethrBankroll(ZethrMainBankroll).isOwner(msg.sender));
_;
}
modifier onlyDev(){
require(ZethrBankroll(ZethrMainBankroll).isOwner(msg.sender));
_;
}
constructor (uint ctrDivRate) public {
Zethr = address(0xD48B633045af65fF636F3c6edd744748351E020D);
ZethrContract = ZTHInterface(Zethr);
ZethrMainBankroll = address(0x1866abdba62468c33c32eb9cc366923af4b760f9);
divRate = ctrDivRate;
tier = ZethrTierLibrary.getTier(divRate * magnitude);
}
function setBankroll(address bankrollAddress) public onlyDevOrBankroll() {
ZethrMainBankroll =  bankrollAddress;
}
function getData(bytes data) public pure returns (address, bytes rem) {
require(data.length == (data.length/32) * 32);
if (data.length == 0) {
revert();
}
address out_a;
bytes memory out_b;
if (data.length == 32){
assembly {
out_a := mload(add(data, 0x20))
}
}
else{
uint len = data.length - 32;
assembly {
out_a := mload(add(data, 0x20))
mstore(out_b, len)
for { let i := 0 } lt(i, div(len, 0x20)) { i := add(i, 0x1) } {
let mem_slot := add(out_b, mul(0x20, add(i,1)))
let load_slot := add(mem_slot,0x20)
mstore(mem_slot, mload(load_slot))
}
}
}
return (out_a, out_b);
}
function isContract(address ctr) internal view returns (bool){
uint codelen;
assembly{
codelen := extcodesize(ctr)
}
return (codelen > 0);
}
function tokenFallback(address _from, uint _amountOfTokens, bytes _data) public returns (bool) {
require(msg.sender == Zethr);
uint userDivRate = ZethrContract.getUserAverageDividendRate(_from);
require(ZethrTierLibrary.getTier(userDivRate) == tier);
address target;
bytes memory remaining_data;
(target, remaining_data) = getData(_data);
require(isContract(target));
require(whitelistedContract[target]);
gameTokenAmount[target] = SafeMath.add(gameTokenAmount[target], _amountOfTokens);
tokenVolumeInput[target] = SafeMath.add(tokenVolumeInput[target], _amountOfTokens);
ZethrGameInterface(target).execute(_from, _amountOfTokens, userDivRate, remaining_data);
}
function gameRequestTokens(address target, uint tokens)
public
contractIsWhiteListed(msg.sender)
{
require(gameTokenAmount[msg.sender] >= tokens);
gameTokenAmount[msg.sender] = gameTokenAmount[msg.sender] - tokens;
tokenVolumeOutput[msg.sender] = tokenVolumeOutput[msg.sender] + tokens;
ZethrContract.transfer(target, tokens);
}
function addGame(address game, uint allocated)
onlyDevOrBankroll
public
{
games.push(game);
gameTokenAllocation[game] = allocated;
if (freeTokens >= allocated){
freeTokens = SafeMath.sub(freeTokens, allocated);
gameTokenAmount[game] = allocated;
}
ZethrBankroll(ZethrMainBankroll).changeAllocation(address(this), int(allocated));
whitelistedContract[game] = true;
}
function removeGame(address game)
public
onlyDevOrBankroll
contractIsWhiteListed(game)
{
for (uint i=0; i < games.length; i++){
if (games[i] == game){
games[i] = address(0x0);
if (i != games.length){
games[i] = games[games.length];
}
games.length = games.length - 1;
break;
}
}
freeTokens = SafeMath.add(freeTokens, gameTokenAmount[game]);
gameTokenAmount[game] = 0;
whitelistedContract[game] = false;
ZethrBankroll(ZethrMainBankroll).changeAllocation(address(this), int(-gameTokenAllocation[game]));
gameTokenAllocation[game] = 0;
}
function changeAllocation(int delta)
public
contractIsWhiteListed(msg.sender)
{
uint newAlloc;
if (delta > 0){
newAlloc = SafeMath.add(gameTokenAllocation[msg.sender], uint(delta));
require(gameTokenAmount[msg.sender] >= newAlloc);
gameTokenAllocation[msg.sender] = newAlloc;
ZethrBankroll(ZethrMainBankroll).changeAllocation(address(this), delta);
} else {
newAlloc = SafeMath.sub(gameTokenAllocation[msg.sender], uint(-delta));
gameTokenAllocation[msg.sender] = newAlloc;
ZethrBankroll(ZethrMainBankroll).changeAllocation(address(this), delta);
}
}
function allocateTokens()
onlyDevOrBankroll
public
{
ZethrContract.withdraw(address(this));
if (address(this).balance >= (0.1 ether)){
zethrBuyIn();
}
address gameAddress;
uint gameBalance;
uint gameAllotment;
int difference;
for (uint i=0; i < games.length; i++) {
gameAddress = games[i];
gameBalance = gameTokenAmount[gameAddress];
gameAllotment = gameTokenAllocation[gameAddress];
difference = int(gameBalance) - int(gameAllotment);
if (difference > 0) {
gameTokenAmount[gameAddress] = gameAllotment;
freeTokens = freeTokens + uint(difference);
} else {
}
}
for (uint j=0; j < games.length; j++) {
gameAddress = games[i];
gameBalance = gameTokenAmount[gameAddress];
gameAllotment = gameTokenAllocation[gameAddress];
difference = int(gameBalance) - int(gameAllotment);
if (difference < 0) {
require(freeTokens >= uint(-difference));
freeTokens = freeTokens - uint(-difference);
gameTokenAmount[gameAddress] = gameAllotment;
}
}
}
function dumpFreeTokens(address stakeAddress) onlyDevOrBankroll public returns (uint) {
allocateTokens();
if (freeTokens < 1e18) { return 0; }
ZethrContract.transfer(stakeAddress, freeTokens);
uint sent = freeTokens;
freeTokens = 0;
return sent;
}
function contractTokenWithdrawToFreeTokens(address ctr, uint amount)
onlyDevOrBankroll
contractIsWhiteListed(ctr)
public
{
uint currentBalance = gameTokenAmount[ctr];
uint allocated = gameTokenAllocation[ctr];
if ( SafeMath.sub(currentBalance, amount) > allocated){
gameTokenAmount[ctr] = gameTokenAmount[ctr] - amount;
freeTokens = SafeMath.add(freeTokens, amount);
}
else{
revert();
}
}
function zethrBuyIn()
onlyDevOrBankroll
public
{
if (address(this).balance < 0.1 ether) { return; }
uint cBal = ZethrContract.balanceOf(address(this));
ZethrContract.buyAndSetDivPercentage.value(address(this).balance)(ZethrMainBankroll, uint8(divRate), "");
freeTokens = freeTokens + (ZethrContract.balanceOf(address(this)) - cBal);
}
function WithdrawTokensToBankroll(uint amount)
onlyDevOrBankroll
public
{
ZethrContract.transfer(ZethrMainBankroll, amount);
}
function WithdrawToBankroll() public {
ZethrMainBankroll.transfer(address(this).balance);
}
function WithdrawAndTransferToBankroll() public {
ZethrContract.withdraw(ZethrMainBankroll);
WithdrawToBankroll();
}
}
library SafeMath {
function mul(uint a, uint b) internal pure returns (uint) {
if (a == 0) {
return 0;
}
uint c = a * b;
assert(c / a == b);
return c;
}
function div(uint a, uint b) internal pure returns (uint) {
uint c = a / b;
return c;
}
function sub(uint a, uint b) internal pure returns (uint) {
assert(b <= a);
return a - b;
}
function add(uint a, uint b) internal pure returns (uint) {
uint c = a + b;
assert(c >= a);
return c;
}
}