pragma solidity ^0.4.19;
library SafeMath {
function mul(uint256 a, uint256 b) internal pure returns (uint256) {
if (a == 0 || b == 0){
return 0;
}
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
contract Ownable {
address public owner;
address public newOwner;
address public techSupport;
address public newTechSupport;
modifier onlyOwner() {
require(msg.sender == owner);
_;
}
modifier onlyTechSupport() {
require(msg.sender == techSupport);
_;
}
function Ownable() public {
owner = msg.sender;
}
function transferOwnership(address _newOwner) public onlyOwner {
require(_newOwner != address(0));
newOwner = _newOwner;
}
function acceptOwnership() public {
if (msg.sender == newOwner) {
owner = newOwner;
}
}
function transferTechSupport (address _newSupport) public{
require (msg.sender == owner || msg.sender == techSupport);
newTechSupport = _newSupport;
}
function acceptSupport() public{
if(msg.sender == newTechSupport){
techSupport = newTechSupport;
}
}
}
contract CQTToken is Ownable {
using SafeMath for uint;
event Transfer(address indexed _from, address indexed _to, uint256 _value);
event Approval(address indexed _owner, address indexed _spender, uint256 _value);
string public constant symbol = "CQT";
string public constant name = "Checqit";
uint8 public constant decimals = 8;
uint256 _totalSupply = 1000000000*pow(10,decimals);
address public owner;
mapping(address => uint256) balances;
mapping(address => mapping (address => uint256)) allowed;
function pow(uint256 a, uint256 b) internal pure returns (uint256){
return (a**b);
}
function totalSupply() public constant returns (uint256) {
return _totalSupply;
}
function balanceOf(address _address) public constant returns (uint256 balance) {
return balances[_address];
}
function transfer(address _to, uint256 _amount) public returns (bool success) {
require(this != _to);
balances[msg.sender] = balances[msg.sender].sub(_amount);
balances[_to] = balances[_to].add(_amount);
Transfer(msg.sender,_to,_amount);
return true;
}
address public crowdsaleContract;
bool flag = false;
function setCrowdsaleContract (address _address) public{
require (!flag);
crowdsaleContract = _address;
flag = true;
}
function transferFrom(
address _from,
address _to,
uint256 _amount
)public returns (bool success) {
require(this != _to);
if (balances[_from] >= _amount
&& allowed[_from][msg.sender] >= _amount
&& _amount > 0
&& balances[_to] + _amount > balances[_to]) {
balances[_from] -= _amount;
allowed[_from][msg.sender] -= _amount;
balances[_to] += _amount;
Transfer(_from, _to, _amount);
return true;
} else {
return false;
}
}
function approve(address _spender, uint256 _amount)public returns (bool success) {
allowed[msg.sender][_spender] = _amount;
Approval(msg.sender, _spender, _amount);
return true;
}
function allowance(address _owner, address _spender)public constant returns (uint256 remaining) {
return allowed[_owner][_spender];
}
function CQTToken(address _owner) public {
techSupport = msg.sender;
owner = _owner;
balances[this] = _totalSupply;
teamBalanceMap[_owner] = true;
futureExpanstionMap[_owner] = true;
bountyProgramMap[_owner] = true;
}
function burnTokens(address _address) public{
require(msg.sender == crowdsaleContract);
Transfer(_address,0,balances[_address]);
balances[_address] = 0;
}
function burnSomeTokens(uint _value) public{
require (msg.sender == crowdsaleContract);
balances[this] = balances[this].sub(_value);
Transfer(this,0,_value);
}
uint private crowdsaleTokens = (uint)(610000000).mul(pow(10,decimals));
function getCrowdsaleTokens() public view returns(uint) {
return crowdsaleTokens;
}
uint public teamBalance = (uint)(250000000).mul(pow(10,decimals));
uint public futureExpanstion = (uint)(130000000).mul(pow(10,decimals));
uint public bountyProgram = (uint)(10000000).mul(pow(10,decimals));
mapping (address => bool) public teamBalanceMap;
mapping (address => bool) public futureExpanstionMap;
mapping (address => bool) public bountyProgramMap;
function addInTeamBalanceMap (address _address) public onlyOwner {
require(!teamBalanceMap[_address]);
teamBalanceMap[_address] = true;
}
function removeFromTeamBalanceMap (address _address) public onlyOwner {
require(teamBalanceMap[_address]);
teamBalanceMap[_address] = false;
}
function addInFutureExpanstionMap (address _address) public onlyOwner {
require(!futureExpanstionMap[_address]);
futureExpanstionMap[_address] = true;
}
function removeFromFutureExpanstionMap (address _address) public onlyOwner {
require(futureExpanstionMap[_address]);
futureExpanstionMap[_address] = false;
}
function addInBountyProgramMap (address _address) public onlyOwner {
require(!bountyProgramMap[_address]);
bountyProgramMap[_address] = true;
}
function removeFromBountyProgramMap (address _address) public onlyOwner {
require(bountyProgramMap[_address]);
bountyProgramMap[_address] = false;
}
function sendTeamBalance (address _address, uint _value) public {
require(teamBalanceMap[msg.sender]);
teamBalance = teamBalance.sub(_value);
balances[this] = balances[this].sub(_value);
balances[_address] = balances[_address].add(_value);
Transfer(this,_address,_value);
}
function sendFutureExpanstionBalance (address _address, uint _value) public {
require(futureExpanstionMap[msg.sender]);
futureExpanstion = futureExpanstion.sub(_value);
balances[this] = balances[this].sub(_value);
balances[_address] = balances[_address].add(_value);
Transfer(this,_address,_value);
}
function sendBountyProgramBalance (address _address, uint _value) public {
require(bountyProgramMap[msg.sender]);
bountyProgram = bountyProgram.sub(_value);
balances[this] = balances[this].sub(_value);
balances[_address] = balances[_address].add(_value);
Transfer(this,_address,_value);
}
function sendCrowdsaleTokens(address _address, uint256 _value)  public {
require (msg.sender == crowdsaleContract);
crowdsaleTokens = crowdsaleTokens.sub(_value);
balances[this] = balances[this].sub(_value);
balances[_address] = balances[_address].add(_value);
Transfer(this, _address, _value);
}
}