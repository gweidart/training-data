pragma solidity ^0.4.18;
contract CrowdsaleParameters {
uint256 public constant generalSaleStartDate = 1524182400;
uint256 public constant generalSaleEndDate = 1529452800;
struct AddressTokenAllocation {
address addr;
uint256 amount;
}
AddressTokenAllocation internal generalSaleWallet = AddressTokenAllocation(0x5aCdaeF4fa410F38bC26003d0F441d99BB19265A, 22800000);
AddressTokenAllocation internal bounty = AddressTokenAllocation(0xc1C77Ff863bdE913DD53fD6cfE2c68Dfd5AE4f7F, 2000000);
AddressTokenAllocation internal partners = AddressTokenAllocation(0x307744026f34015111B04ea4D3A8dB9FdA2650bb, 3200000);
AddressTokenAllocation internal team = AddressTokenAllocation(0xCC4271d219a2c33a92aAcB4C8D010e9FBf664D1c, 12000000);
AddressTokenAllocation internal featureDevelopment = AddressTokenAllocation(0x06281A31e1FfaC1d3877b29150bdBE93073E043B, 0);
}
contract Owned {
address public owner;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
function Owned() public {
owner = msg.sender;
}
modifier onlyOwner() {
require(msg.sender == owner);
_;
}
function changeOwner(address newOwner) onlyOwner public {
require(newOwner != address(0));
require(newOwner != owner);
OwnershipTransferred(owner, newOwner);
owner = newOwner;
}
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
contract SBIToken is Owned, CrowdsaleParameters {
using SafeMath for uint256;
string public standard = 'ERC20/SBI';
string public name = 'Subsoil Blockchain Investitions';
string public symbol = 'SBI';
uint8 public decimals = 18;
mapping (address => uint256) private balances;
mapping (address => mapping (address => uint256)) private allowed;
mapping (address => mapping (address => bool)) private allowanceUsed;
event Transfer(address indexed from, address indexed to, uint tokens);
event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
event Issuance(uint256 _amount);
event Destruction(uint256 _amount);
event NewSBIToken(address _token);
uint256 public totalSupply = 0;
bool public transfersEnabled = true;
function SBIToken() public {
owner = msg.sender;
mintToken(generalSaleWallet);
mintToken(bounty);
mintToken(partners);
mintToken(team);
NewSBIToken(address(this));
}
modifier transfersAllowed {
require(transfersEnabled);
_;
}
modifier onlyPayloadSize(uint size) {
assert(msg.data.length >= size + 4);
_;
}
function approveCrowdsale(address _crowdsaleAddress) external onlyOwner {
approveAllocation(generalSaleWallet, _crowdsaleAddress);
}
function approveAllocation(AddressTokenAllocation tokenAllocation, address _crowdsaleAddress) internal {
uint uintDecimals = decimals;
uint exponent = 10**uintDecimals;
uint amount = tokenAllocation.amount * exponent;
allowed[tokenAllocation.addr][_crowdsaleAddress] = amount;
Approval(tokenAllocation.addr, _crowdsaleAddress, amount);
}
function balanceOf(address _address) public constant returns (uint256 balance) {
return balances[_address];
}
function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
return allowed[_owner][_spender];
}
function transfer(address _to, uint256 _value) public transfersAllowed onlyPayloadSize(2*32) returns (bool success) {
require(_to != address(0));
require(_value <= balances[msg.sender]);
balances[msg.sender] = balances[msg.sender].sub(_value);
balances[_to] = balances[_to].add(_value);
Transfer(msg.sender, _to, _value);
return true;
}
function mintToken(AddressTokenAllocation tokenAllocation) internal {
uint uintDecimals = decimals;
uint exponent = 10**uintDecimals;
uint mintedAmount = tokenAllocation.amount * exponent;
balances[tokenAllocation.addr] += mintedAmount;
totalSupply += mintedAmount;
Issuance(mintedAmount);
Transfer(address(this), tokenAllocation.addr, mintedAmount);
}
function approve(address _spender, uint256 _value) public onlyPayloadSize(2*32) returns (bool success) {
require(_value == 0 || allowanceUsed[msg.sender][_spender] == false);
allowed[msg.sender][_spender] = _value;
allowanceUsed[msg.sender][_spender] = false;
Approval(msg.sender, _spender, _value);
return true;
}
function transferFrom(address _from, address _to, uint256 _value) public transfersAllowed onlyPayloadSize(3*32) returns (bool success) {
require(_to != address(0));
require(_value <= balances[_from]);
require(_value <= allowed[_from][msg.sender]);
balances[_from] = balances[_from].sub(_value);
balances[_to] = balances[_to].add(_value);
allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
Transfer(_from, _to, _value);
return true;
}
function() public {}
function toggleTransfers(bool _enable) external onlyOwner {
transfersEnabled = _enable;
}
}
contract SBIBank is Owned, CrowdsaleParameters {
using SafeMath for uint256;
string public name = 'Subsoil Blockchain Investitions Bank';
SBIToken private token;
uint256 public currentVotingDate = 0;
uint public currentVotingAmount = 0;
uint public allowedWithdraw = 0;
uint public allowedRefund = 0;
uint256 public toAllow = 0;
uint256 public toCancel = 0;
uint256 public toRefund = 0;
uint8 result = 0;
address sbiBank = this;
mapping(address => uint8) public votes;
mapping(address => uint256) public voteDates;
mapping(address => uint256) public alreadyRefunded;
event NewIncomingFunds(uint indexed amount, address indexed sender);
event NewVoting(uint256 indexed date, uint indexed amount);
event NewVote(address indexed voter, uint256 indexed date, uint8 indexed proposal);
event CancelVote(uint256 indexed date, uint indexed amount);
event AllowVote(uint256 indexed date, uint indexed amount);
event RefundVote(uint256 indexed date, uint indexed amount);
event Refund(uint256 indexed date, uint256 indexed amount, address indexed investor);
event Withdraw(uint256 indexed date, uint indexed amount);
function SBIBank(address _tokenAddress) public payable {
token = SBIToken(_tokenAddress);
}
function addVoting(uint _amount) public onlyOwner {
require(sbiBank.balance >= _amount);
require(currentVotingDate == 0 && currentVotingAmount == 0);
currentVotingDate = now;
currentVotingAmount = _amount;
NewVoting(now, _amount);
}
function voteOf(address voter) public constant returns (uint8 vote) {
return votes[voter];
}
function vote(uint8 proposal) public returns(uint8 prop) {
require(token.balanceOf(msg.sender) > 0);
require(now >= currentVotingDate && now <= currentVotingDate + 3 days);
require(proposal == 1 || proposal == 2 || proposal == 3);
require(voteDates[msg.sender] != currentVotingDate);
alreadyRefunded[msg.sender] = 0;
votes[msg.sender] = proposal;
voteDates[msg.sender] = currentVotingDate;
if(proposal == 1) {
toAllow = toAllow + token.balanceOf(msg.sender);
}
if(proposal == 2) {
toCancel = toCancel + token.balanceOf(msg.sender);
}
if(proposal == 3) {
toRefund = toRefund + token.balanceOf(msg.sender);
}
NewVote(msg.sender, now, proposal);
return proposal;
}
function endVoting() public onlyOwner {
require(currentVotingDate > 0 && now >= currentVotingDate + 3 days);
if (toAllow > toCancel && toAllow > toRefund) {
AllowVote(currentVotingDate, toAllow);
allowedWithdraw = currentVotingAmount;
allowedRefund = 0;
}
if (toCancel > toAllow && toCancel > toRefund) {
CancelVote(currentVotingDate, toCancel);
allowedWithdraw = 0;
allowedRefund = 0;
}
if (toRefund > toAllow && toRefund > toCancel) {
RefundVote(currentVotingDate, toRefund);
allowedRefund = currentVotingAmount;
allowedWithdraw = 0;
}
currentVotingDate = 0;
currentVotingAmount = 0;
toAllow = 0;
toCancel = 0;
toRefund = 0;
}
function withdraw() public onlyOwner {
require(currentVotingDate == 0);
require(allowedWithdraw > 0);
owner.transfer(allowedWithdraw);
Withdraw(now, allowedWithdraw);
allowedWithdraw = 0;
}
function refund() public {
require(allowedRefund > 0);
require(alreadyRefunded[msg.sender] == 0);
require(token.balanceOf(msg.sender) > 0);
uint256 tokensPercent = token.balanceOf(msg.sender).div(40000000).div(1000000000000000);
uint256 refundedAmount = tokensPercent.mul(sbiBank.balance).div(1000);
address sender = msg.sender;
alreadyRefunded[msg.sender] = refundedAmount;
token.transferFrom(msg.sender, featureDevelopment.addr, token.balanceOf(msg.sender));
sender.transfer(refundedAmount);
Refund(now, refundedAmount, msg.sender);
}
function () external payable {
NewIncomingFunds(msg.value, msg.sender);
}
}