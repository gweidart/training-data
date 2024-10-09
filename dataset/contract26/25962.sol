pragma solidity ^0.4.18;
interface IERC20 {
function totalSupply() public constant returns (uint);
function balanceOf(address tokenOwner) public constant returns (uint balance);
function transfer(address to, uint tokens) public returns (bool success);
function transferFrom(address from, address to, uint tokens) public returns (bool success);
function approve(address spender, uint tokens) public returns (bool success);
function allowance(address tokenOwner, address spender) public constant returns (uint remaining);
event Transfer(address indexed from, address indexed to, uint tokens);
event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
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
contract TheDevilsToken is IERC20 {
using SafeMath for uint;
uint public _totalSupply = 0;
uint public constant maxSupply = 666666000000000000000000;
string public constant name = 'The Devil\'s Token';
string public constant symbol = 'DVL';
uint8 public constant decimals = 18;
uint public constant RATE = 666;
address public owner;
mapping(address => uint) balances;
mapping(address => mapping(address => uint)) allowed;
function () public payable {
createTokens();
}
function TheDevilsToken() public {
owner = msg.sender;
}
function createTokens() public payable {
require(msg.value > 0 && _totalSupply < maxSupply);
uint requestedTokens = msg.value.mul(RATE);
uint tokens = requestedTokens;
uint newTokensCount = _totalSupply.add(requestedTokens);
if (newTokensCount > maxSupply) {
tokens = maxSupply - _totalSupply;
}
balances[msg.sender] = balances[msg.sender].add(tokens);
_totalSupply = _totalSupply.add(tokens);
owner.transfer(msg.value);
}
function totalSupply() public constant returns(uint) {
return _totalSupply;
}
function balanceOf(address tokenOwner) public constant returns (uint balance) {
return balances[tokenOwner];
}
function transfer(address to, uint tokens) public returns (bool success) {
require(
msg.data.length >= (2 * 32) + 4 &&
tokens > 0 &&
balances[msg.sender] >= tokens
);
balances[msg.sender] = balances[msg.sender].sub(tokens);
balances[to] = balances[to].add(tokens);
Transfer(msg.sender, to, tokens);
return true;
}
function transferFrom(address from, address to, uint tokens) public returns (bool success) {
require(
msg.data.length >= (3 * 32) + 4 &&
tokens > 0 &&
balances[from] >= tokens &&
allowed[from][msg.sender] >= tokens
);
balances[from] = balances[from].sub(tokens);
balances[to] = balances[to].add(tokens);
allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);
Transfer(from, to, tokens);
return true;
}
function approve(address spender, uint tokens) public returns (bool success) {
allowed[msg.sender][spender] = tokens;
Approval(msg.sender, spender, tokens);
return true;
}
function allowance(address tokenOwner, address spender) public constant returns (uint remaining) {
return allowed[tokenOwner][spender];
}
event Transfer(address indexed from, address indexed to, uint tokens);
event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}