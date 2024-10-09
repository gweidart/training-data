pragma solidity ^0.4.24;
library SafeMath {
function mul(uint256 a, uint256 b) internal pure returns (uint256) {
uint256 c = a * b;
assert(a == 0 || c / a == b);
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
contract ApproveAndCallReceiver {
function receiveApproval(
address _from,
uint256 _amount,
address _token,
bytes _data
) public;
}
contract Controlled {
modifier onlyController {
require(msg.sender == controller);
_;
}
address public controller;
constructor() public {
controller = msg.sender;
}
function changeController(address _newController) onlyController public {
controller = _newController;
}
}
contract TokenController {
function proxyPayment(address _owner) payable public returns(bool);
function onTransfer(address _from, address _to, uint _amount) public returns(bool);
function onApprove(address _owner, address _spender, uint _amount) public returns(bool);
}
contract ERC20Token {
uint256 public totalSupply;
mapping (address => uint256) public balanceOf;
function transfer(address _to, uint256 _value) public returns (bool success);
function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
function approve(address _spender, uint256 _value) public returns (bool success);
mapping (address => mapping (address => uint256)) public allowance;
event Transfer(address indexed _from, address indexed _to, uint256 _value);
event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}
contract TokenI is ERC20Token, Controlled {
string public name;
uint8 public decimals = 18;
string public symbol;
function approveAndCall(
address _spender,
uint256 _amount,
bytes _extraData
) public returns (bool success);
function generateTokens(address _owner, uint _amount) public returns (bool);
function destroyTokens(address _owner, uint _amount) public returns (bool);
function enableTransfers(bool _transfersEnabled) public;
function claimTokens(address[] _tokens, address _to) public;
event ClaimedTokens(address indexed _token, address indexed _controller, uint _amount);
}
contract Token is TokenI {
using SafeMath for uint256;
string public techProvider = "WeYii Tech";
string public officialSite = "http:
address public owner;
struct FreezeInfo {
address user;
uint256 amount;
}
mapping (uint8 => mapping (uint32 => FreezeInfo)) public freezeOf;
mapping (uint8 => uint32) public lastFreezeSeq;
bool public transfersEnabled = true;
event Burn(address indexed from, uint256 value);
event Freeze(address indexed from, uint256 value);
event Unfreeze(address indexed from, uint256 value);
event TransferMulti(uint256 userLen, uint256 valueAmount);
constructor(
uint256 initialSupply,
string tokenName,
string tokenSymbol,
address initialOwner
) public {
owner = initialOwner;
totalSupply = initialSupply * uint256(10) ** decimals;
balanceOf[owner] = totalSupply;
name = tokenName;
symbol = tokenSymbol;
}
modifier onlyOwner() {
require(msg.sender == owner);
_;
}
modifier ownerOrController() {
require(msg.sender == owner || msg.sender == controller);
_;
}
modifier transable(){
require(transfersEnabled == true);
_;
}
modifier realUser(address user){
require(user != 0x0);
_;
}
function isContract(address _addr) constant internal returns(bool) {
uint size;
if (_addr == 0) {
return false;
}
assembly {
size := extcodesize(_addr)
}
return size>0;
}
function transfer(address _to, uint256 _value) realUser(_to) transable public returns (bool) {
require(balanceOf[msg.sender] >= _value);
balanceOf[msg.sender] = balanceOf[msg.sender].sub(_value);
balanceOf[_to] = balanceOf[_to].add(_value);
emit Transfer(msg.sender, _to, _value);
return true;
}
function approve(address _spender, uint256 _value) transable public returns (bool success) {
require(_value == 0 || (allowance[msg.sender][_spender] == 0));
allowance[msg.sender][_spender] = _value;
emit Approval(msg.sender, _spender, _value);
return true;
}
function approveAndCall(address _spender, uint256 _amount, bytes _extraData) transable public returns (bool success) {
require(approve(_spender, _amount));
ApproveAndCallReceiver(_spender).receiveApproval(
msg.sender,
_amount,
this,
_extraData
);
return true;
}
function transferFrom(address _from, address _to, uint256 _value) realUser(_from) realUser(_to) transable public returns (bool success) {
require(balanceOf[_from] >= _value);
require(balanceOf[_to] + _value > balanceOf[_to]);
require(_value <= allowance[_from][msg.sender]);
balanceOf[_from] = balanceOf[_from].sub(_value);
balanceOf[_to] = balanceOf[_to].add(_value);
allowance[_from][msg.sender] = allowance[_from][msg.sender].sub(_value);
emit Transfer(_from, _to, _value);
return true;
}
function transferMulti(address[] _to, uint256[] _value) transable public returns (uint256 amount){
require(_to.length == _value.length && _to.length <= 1024);
uint256 balanceOfSender = balanceOf[msg.sender];
uint256 len = _to.length;
for(uint256 j; j<len; j++){
amount = amount.add(_value[j]);
}
balanceOf[msg.sender] = balanceOfSender.sub(amount);
address _toI;
uint256 _valueI;
for(uint256 i; i<len; i++){
_toI = _to[i];
_valueI = _value[i];
balanceOf[_toI] = balanceOf[_toI].add(_valueI);
emit Transfer(msg.sender, _toI, _valueI);
}
emit TransferMulti(len, amount);
}
function transferMultiSameVaule(address[] _to, uint256 _value) transable public returns (bool success){
uint256 len = _to.length;
uint256 amount = _value.mul(len);
balanceOf[msg.sender] = balanceOf[msg.sender].sub(amount);
address _toI;
for(uint256 i; i<len; i++){
_toI = _to[i];
balanceOf[_toI] = balanceOf[_toI].add(_value);
emit Transfer(msg.sender, _toI, _value);
}
emit TransferMulti(len, amount);
return true;
}
function freeze(address _user, uint256 _value, uint8 _step) ownerOrController public returns (bool success) {
require(balanceOf[_user] >= _value);
balanceOf[_user] = balanceOf[_user] - _value;
freezeOf[_step][lastFreezeSeq[_step]] = FreezeInfo({user:_user, amount:_value});
lastFreezeSeq[_step]++;
emit Freeze(_user, _value);
return true;
}
function unFreeze(uint8 _step) ownerOrController public returns (bool unlockOver) {
uint32 _end = lastFreezeSeq[_step];
require(_end > 0);
unlockOver = (_end <= 99);
uint32 _start = (_end > 99) ? _end-100 : 0;
for(; _end>_start; _end--){
FreezeInfo storage fInfo = freezeOf[_step][_end-1];
uint256 _amount = fInfo.amount;
balanceOf[fInfo.user] += _amount;
delete freezeOf[_step][_end-1];
lastFreezeSeq[_step]--;
emit Unfreeze(fInfo.user, _amount);
}
}
function() payable public {
require(isContract(controller));
bool proxyPayment = TokenController(controller).proxyPayment.value(msg.value)(msg.sender);
require(proxyPayment);
}
function generateTokens(address _user, uint _amount) onlyController public returns (bool) {
require(balanceOf[owner] >= _amount);
balanceOf[_user] += _amount;
balanceOf[owner] -= _amount;
emit Transfer(0, _user, _amount);
return true;
}
function destroyTokens(address _user, uint _amount) onlyController public returns (bool) {
require(balanceOf[_user] >= _amount);
balanceOf[owner] += _amount;
balanceOf[_user] -= _amount;
emit Transfer(_user, 0, _amount);
emit Burn(_user, _amount);
return true;
}
function enableTransfers(bool _transfersEnabled) ownerOrController public {
transfersEnabled = _transfersEnabled;
}
function claimTokens(address[] tokens, address to) onlyOwner public {
if(to == 0x0){
to = owner;
}
address _token;
uint256 balance;
uint256 len = tokens.length;
for(uint256 i; i<len; i++){
_token = tokens[i];
if (_token == 0x0) {
balance = address(this).balance;
if(balance > 0){
to.transfer(balance);
}
}else{
ERC20Token token = ERC20Token(_token);
balance = token.balanceOf(address(this));
token.transfer(to, balance);
emit ClaimedTokens(_token, to, balance);
}
}
}
function changeOwner(address newOwner) onlyOwner public returns (bool) {
balanceOf[newOwner] = balanceOf[owner].add(balanceOf[newOwner]);
balanceOf[owner] = 0;
owner = newOwner;
return true;
}
}