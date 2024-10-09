pragma solidity ^0.4.24;
contract SafeMath {
function safeAdd(uint a, uint b) internal pure returns (uint c) {
c = a + b;
require(c >= a);
}
function safeSub(uint a, uint b) internal pure returns (uint c) {
require(b <= a);
c = a - b;
}
function safeMul(uint a, uint b) internal pure returns (uint c) {
c = a * b;
require(a == 0 || c / a == b);
}
function safeDiv(uint a, uint b) internal pure returns (uint c) {
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
constructor() public {
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
contract Coinvey is ERC20Interface, Owned, SafeMath {
bool public purchasingAllowed = false;
string public symbol;
string public  name;
uint8 public decimals;
uint public _totalSupply;
uint public startDate;
uint public bonusEnds;
uint public endDate;
mapping(address => uint) balances;
mapping(address => mapping(address => uint)) allowed;
constructor() public {
symbol = "CAWA";
name = "Coin Awards";
decimals = 18;
_totalSupply = 8 * 10 ** 25;
balances[msg.sender] = 0.8 * 10 ** 25;
bonusEnds = now + 1 days;
endDate = now + 2 weeks;
}
function totalSupply() public constant returns (uint) {
return _totalSupply  - balances[address(0)];
}
function balanceOf(address tokenOwner) public constant returns (uint balance) {
return balances[tokenOwner];
}
function enablePurchasing() {
if (msg.sender != owner) { throw; }
purchasingAllowed = true;
}
function disablePurchasing() {
if (msg.sender != owner) { throw; }
purchasingAllowed = false;
}
function transfer(address to, uint tokens) public returns (bool success) {
balances[msg.sender] = safeSub(balances[msg.sender], tokens);
balances[to] = safeAdd(balances[to], tokens);
Transfer(msg.sender, to, tokens);
return true;
}
function approve(address spender, uint tokens) public returns (bool success) {
allowed[msg.sender][spender] = tokens;
Approval(msg.sender, spender, tokens);
return true;
}
function transferFrom(address from, address to, uint tokens) public returns (bool success) {
balances[from] = safeSub(balances[from], tokens);
allowed[from][msg.sender] = safeSub(allowed[from][msg.sender], tokens);
balances[to] = safeAdd(balances[to], tokens);
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
if (!purchasingAllowed) { throw; }
require(now >= startDate && now <= endDate);
uint tokens;
if (now <= bonusEnds) {
tokens = msg.value * 25741;
} else {
tokens = msg.value * 25641;
}
balances[msg.sender] = safeAdd(balances[msg.sender], tokens);
_totalSupply = 8*10**25;
Transfer(address(0), msg.sender, tokens);
owner.transfer(msg.value);
}
function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns (bool success) {
return ERC20Interface(tokenAddress).transfer(owner, tokens);
}
}