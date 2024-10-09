pragma solidity ^0.4.15;
contract Token {
uint256 public totalSupply;
function balanceOf(address _owner) constant returns (uint256 balance);
function transfer(address _to, uint256 _value) returns (bool success);
function transferFrom(address _from, address _to, uint256 _value) returns (bool success);
function approve(address _spender, uint256 _value) returns (bool success);
function allowance(address _owner, address _spender) constant returns (uint256 remaining);
event Transfer(address indexed _from, address indexed _to, uint256 _value);
event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}
contract AbstractSingularDTVToken is Token {
}
contract SingularDTVFund {
string public version = "0.1.0";
AbstractSingularDTVToken public singularDTVToken;
address public owner;
uint public totalReward;
mapping (address => uint) public rewardAtTimeOfWithdraw;
mapping (address => uint) public owed;
modifier onlyOwner() {
if (msg.sender != owner) {
revert();
}
_;
}
function depositReward()
public
payable
returns (bool)
{
totalReward += msg.value;
return true;
}
function calcReward(address forAddress) private returns (uint) {
return singularDTVToken.balanceOf(forAddress) * (totalReward - rewardAtTimeOfWithdraw[forAddress]) / singularDTVToken.totalSupply();
}
function withdrawReward()
public
returns (uint)
{
uint value = calcReward(msg.sender) + owed[msg.sender];
rewardAtTimeOfWithdraw[msg.sender] = totalReward;
owed[msg.sender] = 0;
if (value > 0 && !msg.sender.send(value)) {
revert();
}
return value;
}
function softWithdrawRewardFor(address forAddress)
external
returns (uint)
{
uint value = calcReward(forAddress);
rewardAtTimeOfWithdraw[forAddress] = totalReward;
owed[forAddress] += value;
return value;
}
function setup(address singularDTVTokenAddress)
external
onlyOwner
returns (bool)
{
if (address(singularDTVToken) == 0) {
singularDTVToken = AbstractSingularDTVToken(singularDTVTokenAddress);
return true;
}
return false;
}
function SingularDTVFund() {
owner = msg.sender;
}
function ()
public
payable
{
if (msg.value == 0) {
withdrawReward();
} else {
depositReward();
}
}
}