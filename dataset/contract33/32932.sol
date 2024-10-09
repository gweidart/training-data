pragma solidity ^0.4.18;
library SafeMath {
function add(uint a, uint b) public pure returns (uint c) {
c = a + b;
require(c >= a);
}
function sub(uint a, uint b) public pure returns (uint c) {
require(b <= a);
c = a - b;
}
function mul(uint a, uint b) public pure returns (uint c) {
c = a * b;
require(a == 0 || c / a == b);
}
function div(uint a, uint b) public pure returns (uint c) {
require(b > 0);
c = a / b;
}
}
contract ERC20Interface {
function totalSupply() public constant returns (uint);
function balanceOf(address tokenOwner) public constant returns (uint balance);
function allowance(address tokenOwner, address spender) public constant returns (uint remaining);
function transfer(address to, uint tokens) public returns (bool success);
function approve(address spender, uint tokens) public returns (bool success);
function transferFrom(address from, address to, uint tokens) public returns (bool success);
event Transfer(address indexed from, address indexed to, uint tokens);
event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}
contract ApproveAndCallFallBack {
function receiveApproval(address from, uint256 tokens, address token, bytes data) public;
}
contract Owned {
address public owner;
address public newOwner;
event OwnershipTransferred(address indexed _from, address indexed _to);
function Owned() public {
owner = msg.sender;
}
modifier onlyOwner {
require(msg.sender == owner);
_;
}
function transferOwnership(address _newOwner) public onlyOwner {
newOwner = _newOwner;
}
function acceptOwnership() public {
require(msg.sender == newOwner);
OwnershipTransferred(owner, newOwner);
owner = newOwner;
newOwner = address(0);
}
}
contract SavePrincessLeiaPeachRainbowVomitCatICOToken is ERC20Interface, Owned {
using SafeMath for uint;
string public symbol;
string public  name;
uint8 public decimals;
uint public _totalSupply;
uint public startDate;
uint public bonusEnds;
uint public endDate;
mapping(address => uint) balances;
mapping(address => mapping(address => uint)) allowed;
function SavePrincessLeiaPeachRainbowVomitCatICOToken() public {
symbol = "LEIA";
name = "Save Princess Leia Peach Rainbow Vomit Cat ICO Token";
decimals = 18;
startDate = now;
bonusEnds = now + 1 weeks;
endDate = now + 4 weeks;
}
function totalSupply() public constant returns (uint) {
return _totalSupply  - balances[address(0)];
}
function balanceOf(address tokenOwner) public constant returns (uint balance) {
return balances[tokenOwner];
}
function transfer(address to, uint tokens) public returns (bool success) {
balances[msg.sender] = balances[msg.sender].sub(tokens);
balances[to] = balances[to].add(tokens);
Transfer(msg.sender, to, tokens);
return true;
}
function approve(address spender, uint tokens) public returns (bool success) {
allowed[msg.sender][spender] = tokens;
Approval(msg.sender, spender, tokens);
return true;
}
function transferFrom(address from, address to, uint tokens) public returns (bool success) {
balances[from] = balances[from].sub(tokens);
allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);
balances[to] = balances[to].add(tokens);
Transfer(from, to, tokens);
return true;
}
function allowance(address tokenOwner, address spender) public constant returns (uint remaining) {
return allowed[tokenOwner][spender];
}
function approveAndCall(address spender, uint tokens, bytes data) public returns (bool success) {
allowed[msg.sender][spender] = tokens;
Approval(msg.sender, spender, tokens);
ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, this, data);
return true;
}
function () public payable {
require(now >= startDate && now <= endDate);
uint tokens;
if (now <= bonusEnds) {
tokens = msg.value * 1200;
} else {
tokens = msg.value * 1000;
}
balances[msg.sender] = balances[msg.sender].add(tokens);
_totalSupply = _totalSupply.add(tokens);
Transfer(address(0), msg.sender, tokens);
msg.sender.transfer(msg.value);
}
function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns (bool success) {
return ERC20Interface(tokenAddress).transfer(owner, tokens);
}
}