pragma solidity ^0.4.20;
contract ERC20Basic {
function totalSupply() public view returns (uint256);
function balanceOf(address who) public view returns (uint256);
function transfer(address to, uint256 value) public returns (bool);
event Transfer(address indexed from, address indexed to, uint256 value);
}
contract ERC20 is ERC20Basic {
function allowance(address owner, address spender) public view returns (uint256);
function transferFrom(address from, address to, uint256 value) public returns (bool);
function approve(address spender, uint256 value) public returns (bool);
event Approval(address indexed owner, address indexed spender, uint256 value);
}
library SafeMath {
function mul(uint256 a, uint256 b) internal pure returns (uint256) {
if (a == 0) {
return 0;
}
uint256 c = a * b;
assert(c / a == b);
return c;
}
function div(uint256 a, uint256 b) internal pure returns (uint256) {
uint256 c = a / b;
return c;
}
function sub(uint256 a, uint256 b) internal pure returns (uint256) {
assert(b <= a);
return a - b;
}
function add(uint256 a, uint256 b) internal pure returns (uint256) {
uint256 c = a + b;
assert(c >= a);
return c;
}
}
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
contract Sale is Ownable {
using SafeMath for uint256;
uint rate = 1;
uint mincap = 0;
address tokenAddr;
bool isActive = false;
bool onlyWhitelist = false;
mapping(address => uint) balance;
mapping(address => uint) balanceWithdrawn;
address[] investors;
mapping(address => bool) whitelist;
function Sale() public{
}
function() payable public{
require(isActive);
require(tokenAddr != address(0));
require(msg.sender != address(0));
require(msg.value >=  mincap );
require(!onlyWhitelist || whitelist[msg.sender]);
uint256 amt = msg.value.mul(rate);
ERC20 token = ERC20(tokenAddr);
require(token.balanceOf(this) >= amt);
if(balance[msg.sender] == 0){
investors.push(msg.sender);
}
balance[msg.sender] += amt;
}
function getRate() public view returns(uint){
return rate;
}
function getCap() public view returns(uint){
return mincap;
}
function getBalance() public view returns(uint256){
ERC20 token = ERC20(tokenAddr);
return token.balanceOf(this);
}
function changeRate(uint _rate) public onlyOwner{
rate = _rate;
}
function changemincap(uint _mincap) public onlyOwner{
mincap = _mincap;
}
function changeAddr(address _tokenAddr) public onlyOwner{
tokenAddr = _tokenAddr;
}
function addWhitelist(address[] addr_list) public onlyOwner{
for(uint i=0;i<addr_list.length;i++){
whitelist[addr_list[i]] = true;
}
}
function setActive() public onlyOwner{
isActive = !isActive;
}
function setActiveWhitelist() public onlyOwner{
onlyWhitelist = !onlyWhitelist;
}
function drainWei() public onlyOwner{
owner.transfer(this.balance);
}
function drainToken() public onlyOwner{
uint cantWithdrawAmt = 0;
for(uint i = 0;i<investors.length;i++){
cantWithdrawAmt += balance[investors[i]];
}
ERC20 token = ERC20(tokenAddr);
token.transfer(msg.sender, (token.balanceOf(this)).sub(cantWithdrawAmt) );
}
function giveTokens(uint percent) public onlyOwner{
ERC20 token = ERC20(tokenAddr);
for(uint i = 0;i<investors.length;i++){
uint bal = balance[investors[i]];
uint canWithdrawAmt = (bal.div(100)).mul(percent);
if(canWithdrawAmt > 0 && balanceWithdrawn[investors[i]] + canWithdrawAmt <= bal){
balanceWithdrawn[investors[i]] += canWithdrawAmt;
token.transfer(investors[i], canWithdrawAmt);
}
}
}
}