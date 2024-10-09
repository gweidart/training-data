pragma solidity ^0.4.18;
contract Owned {
address public owner;
address receiver;
function Owned() public {
owner = msg.sender;
receiver = owner;
}
modifier onlyOwner {
require(msg.sender == owner);
_;
}
function transferOwnership(address newOwner) onlyOwner public {
require(newOwner != address(0));
owner = newOwner;
}
function changeReceiver(address newReceiver) onlyOwner public {
require(newReceiver != address(0));
receiver =  newReceiver;
}
}
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
contract ERC20Basic {
uint256 public totalSupply;
function balanceOf(address who) public constant returns (uint256);
function transfer(address to, uint256 value) public returns (bool);
event Transfer(address indexed from, address indexed to, uint256 value);
}
contract ERC20 is ERC20Basic {
function allowance(address owner, address spender) public constant returns (uint256);
function transferFrom(address from, address to, uint256 value) public returns (bool);
function approve(address spender, uint256 value) public returns (bool);
event Approval(address indexed owner, address indexed spender, uint256 value);
}
contract AdminToken is Owned{
bool onSale = true;
uint stageNumber = 1;
uint256 tokenPrice = 1000;
function sell() public onlyOwner {
require (!onSale && stageNumber < 5);
stageNumber += 1;
if (stageNumber != 5) {
tokenPrice -= 100;
}
else{
tokenPrice -= 200;
}
onSale = true;
}
function _stopSale() internal {
onSale = false;
}
}
contract AdminBasicToken is ERC20Basic, AdminToken {
using SafeMath for uint256;
mapping (address => uint256) balances;
function _transfer(address _from, address _to, uint _value) internal {
require (_to != 0x0 &&
balances[_from] >= _value &&
balances[_to] + _value > balances[_to]);
balances[_from] = balances[_from].sub(_value);
balances[_to] = balances[_to].add(_value);
Transfer(_from, _to, _value);
}
function transfer(address _to, uint256 _value) public returns (bool) {
_transfer(msg.sender, _to, _value);
return true;
}
function balanceOf(address _owner) public constant returns (uint256 balance) {
return balances[_owner];
}
}
contract StandardToken is ERC20, AdminBasicToken {
mapping (address => mapping (address => uint256)) allowed;
function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
require(_value <= allowed[_from][msg.sender]);
allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
_transfer(_from, _to, _value);
return true;
}
function approve(address _spender, uint256 _value) public returns (bool success) {
require((_value == 0) || (allowed[msg.sender][_spender] == 0));
allowed[msg.sender][_spender] = _value;
Approval(msg.sender, _spender, _value);
return true;
}
function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
require(_addedValue !=0 && allowed[msg.sender][_spender] > 0);
allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
return true;
}
function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
require(_subtractedValue !=0 && allowed[msg.sender][_spender] > 0);
uint oldValue = allowed[msg.sender][_spender];
if (_subtractedValue > oldValue) {
allowed[msg.sender][_spender] = 0;
} else {
allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
}
Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
return true;
}
function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
return allowed[_owner][_spender];
}
}
contract SackWengerCoin is StandardToken {
string public name =  "Sack Wenger Coin";
string public symbol = "AXW";
uint8 public decimals = 18;
uint256 ETHreceived = 0;
uint256 eachStageSupply = 20000000 * 10 ** uint256(decimals);
uint256 stageTokenIssued = 0;
function SackWengerCoin() public {
totalSupply = 0;
}
function getStats() public constant returns (uint, uint256, uint256, uint256, uint256, bool) {
return (stageNumber, stageTokenIssued, tokenPrice, ETHreceived, totalSupply, onSale);
}
function _createTokenAndSend(uint256 price) internal {
uint newTokenIssued = msg.value * price;
totalSupply += newTokenIssued;
stageTokenIssued += newTokenIssued;
balances[msg.sender] += newTokenIssued;
if (stageTokenIssued >= eachStageSupply) {
_stopSale();
stageTokenIssued = 0;
}
}
function () payable public {
require (onSale && msg.value != 0);
receiver.transfer(msg.value);
ETHreceived += msg.value;
_createTokenAndSend(tokenPrice);
}
}