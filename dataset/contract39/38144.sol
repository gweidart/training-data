pragma solidity ^0.4.13;
contract owned {
address public owner;
function owned() {
owner = msg.sender;
}
modifier onlyOwner {
if (msg.sender != owner) revert();
_;
}
function ownerTransferOwnership(address newOwner)
onlyOwner
{
owner = newOwner;
}
}
contract DSSafeAddSub {
function safeToAdd(uint a, uint b) internal returns (bool) {
return (a + b >= a);
}
function safeAdd(uint a, uint b) internal returns (uint) {
if (!safeToAdd(a, b)) revert();
return a + b;
}
function safeToSubtract(uint a, uint b) internal returns (bool) {
return (b <= a);
}
function safeSub(uint a, uint b) internal returns (uint) {
if (!safeToSubtract(a, b)) revert();
return a - b;
}
}
contract DoneToken is owned, DSSafeAddSub {
modifier onlyBy(address _account) {
if (msg.sender != _account) revert();
_;
}
string public standard = 'Token 1.0';
string public name = "DONE";
string public symbol = "DET";
uint8 public decimals = 16;
uint public totalSupply = 150000000000000000000000;
address public priviledgedAddress;
bool public tokensFrozen;
uint public crowdfundDeadline = now + 1 hours;
uint public nextFreeze = now + 2 hours;
uint public nextThaw = now + 3 hours;
mapping (address => uint) public balanceOf;
mapping (address => mapping (address => uint)) public allowance;
event Transfer(address indexed _from, address indexed _to, uint256 _value);
event Approval(address indexed _owner, address indexed _spender, uint256 _value);
event LogTokensFrozen(bool indexed Frozen);
function DoneToken(){
balanceOf[msg.sender] = 150000000000000000000000;
tokensFrozen = false;
}
function transfer(address _to, uint _value) public
returns (bool success)
{
return true;
}
function transferFrom(address _from, address _to, uint _value) public
returns (bool success)
{
return true;
}
function approve(address _spender, uint _value) public
returns (bool success)
{
allowance[msg.sender][_spender] = _value;
Approval(msg.sender, _spender, _value);
return true;
}
function priviledgedAddressBurnUnsoldCoins() public
onlyBy(priviledgedAddress)
{
totalSupply = safeSub(totalSupply, balanceOf[priviledgedAddress]);
balanceOf[priviledgedAddress] = 0;
}
function updateTokenStatus() public
{
if(now < crowdfundDeadline){
tokensFrozen = true;
LogTokensFrozen(tokensFrozen);
}
if(now >= nextFreeze){
tokensFrozen = true;
LogTokensFrozen(tokensFrozen);
}
if(now >= nextThaw){
tokensFrozen = false;
nextFreeze = now + 2 hours;
nextThaw = now + 3 hours;
LogTokensFrozen(tokensFrozen);
}
}
function ownerSetPriviledgedAddress(address _newPriviledgedAddress) public
onlyOwner
{
priviledgedAddress = _newPriviledgedAddress;
}
}