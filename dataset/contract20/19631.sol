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
}pragma solidity ^0.4.18;
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
contract GemsToken is Ownable{
using SafeMath for uint256;
mapping(address => uint256) public balances;
mapping (address => mapping (address => uint256)) internal allowed;
event Approval(address indexed owner, address indexed spender, uint256 value);
event Transfer(address indexed from, address indexed to, uint256 value);
string public name = "Gems Of Power";
string public symbol = "GOP";
uint8 public decimals = 0;
uint256 public totalSupply = 200000000 * 10 ** uint(decimals);
address crowdsaleContract = address(0x0);
bool flag = false;
function GemsToken () public {
balances[this] = totalSupply;
}
function totalSupply() public view returns (uint256) {
return totalSupply;
}
function getdecimals() public view returns (uint8) {
return decimals;
}
function balanceOf(address _owner) public view returns (uint256 balance) {
return balances[_owner];
}
function transfer(address _to, uint256 _value) public returns (bool) {
require(_to != address(0));
require(_value <= balances[msg.sender]);
balances[_to] = balances[_to].add(_value);
balances[msg.sender] = balances[msg.sender].sub(_value);
Transfer(msg.sender, _to, _value);
return true;
}
function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
require(_to != address(0));
require(_value <= balances[_from]);
require(_value <= allowed[_from][msg.sender]);
balances[_from] = balances[_from].sub(_value);
balances[_to] = balances[_to].add(_value);
allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
Transfer(_from, _to, _value);
return true;
}
function _transfer(address _from, address _to, uint256 _value) internal returns (bool) {
require(_to != 0x0);
require(balances[_from] >= _value);
require(balances[_to] + _value > balances[_to]);
uint previousBalances = balances[_from].add(balances[_to]);
balances[_from] = balances[_from].sub(_value);
balances[_to] = balances[_to].add(_value);
Transfer(_from, _to, _value);
assert(balances[_from] + balances[_to] == previousBalances);
return true;
}
function approve(address _spender, uint256 _value) public returns (bool) {
allowed[msg.sender][_spender] = _value;
Approval(msg.sender, _spender, _value);
return true;
}
function allowance(address _owner, address _spender) public view returns (uint256) {
return allowed[_owner][_spender];
}
function sendCrowdsaleBalance (address _address, uint256 _value) public {
require (msg.sender == crowdsaleContract);
require (_value <= balances[this]);
totalSupply = totalSupply.sub(_value);
balances[this] = balances[this].sub(_value);
balances[_address] = balances[_address].add(_value);
Transfer(this, _address, _value);
}
function sendOwnerBalance(address _address, uint _value) public onlyOwner {
uint256 value = _value * 10 ** uint(decimals);
require (value <= balances[this]);
balances[this] = balances[this].sub(value);
balances[_address] = balances[_address].add(value);
Transfer(this, _address, value);
}
function setCrowdsaleContract(address _address) public onlyOwner {
require(!flag);
crowdsaleContract = _address;
flag = true;
}
function removeCrowdsaleContract(address _address) public onlyOwner {
require(flag);
if(crowdsaleContract == _address) {
crowdsaleContract = address(0x0);
flag = false;
}
}
function GetcrowdsaleContract() public view returns(address) {
return crowdsaleContract;
}
}