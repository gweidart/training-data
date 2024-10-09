pragma solidity ^0.4.18;
library _SafeMath {
function add(uint a, uint b) internal pure returns (uint c) {
c = a + b;
require(c >= a);
}
function sub(uint a, uint b) internal pure returns (uint c) {
require(b <= a);
c = a - b;
}
function mul(uint a, uint b) internal pure returns (uint c) {
c = a * b;
require(a == 0 || c / a == b);
}
function div(uint a, uint b) internal pure returns (uint c) {
require(b > 0);
c = a / b;
}
}
contract WhiteListAccess {
function WhiteListAccess() public {
owner = msg.sender;
whitelist[owner] = true;
whitelist[address(this)] = true;
}
address public owner;
mapping (address => bool) whitelist;
modifier onlyOwner {require(msg.sender == owner); _;}
modifier onlyWhitelisted {require(whitelist[msg.sender]); _;}
function addToWhiteList(address trusted) public onlyOwner() {
whitelist[trusted] = true;
}
function removeFromWhiteList(address untrusted) public onlyOwner() {
whitelist[untrusted] = false;
}
}
contract _ERC20Interface {
function totalSupply() public constant returns (uint);
function balanceOf(address tokenOwner) public constant returns (uint balance);
function allowance(address tokenOwner, address spender) public constant returns (uint remaining);
function transfer(address to, uint tokens) public returns (bool success);
function approve(address spender, uint tokens) public returns (bool success);
function transferFrom(address from, address to, uint tokens) public returns (bool success);
event Transfer(address indexed from, address indexed to, uint tokens);
event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}
contract _Token is WhiteListAccess, _ERC20Interface {
using _SafeMath for uint;
uint8   public   decimals;
uint    public   totSupply;
string  public   symbol;
string  public   name;
mapping(address => uint) public balances;
mapping(address => mapping(address => uint)) public allowed;
function _Token(string _name, string _sym) public {
symbol = _sym;
name = _name;
decimals = 0;
totSupply = 0;
}
function totalSupply() public constant returns (uint) {
return totSupply;
}
function balanceOf(address _tokenOwner) public constant returns (uint balance) {
return balances[_tokenOwner];
}
function transfer(address to, uint tokens) public returns (bool success) {
require(!freezed);
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
function desapprove(address spender) public returns (bool success) {
allowed[msg.sender][spender] = 0;
return true;
}
function transferFrom(address from, address to, uint tokens) public returns (bool success) {
require(!freezed);
balances[from] = balances[from].sub(tokens);
allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);
balances[to] = balances[to].add(tokens);
Transfer(from, to, tokens);
return true;
}
function allowance(address tokenOwner, address spender) public constant returns (uint remaining) {
return allowed[tokenOwner][spender];
}
function () public payable {
revert();
}
bool freezed;
function create(uint units) public onlyWhitelisted() {
totSupply = totSupply + units;
balances[msg.sender] = balances[msg.sender] + units;
}
function freeze() public onlyWhitelisted() {
freezed = true;
}
function unfreeze() public onlyWhitelisted() {
freezed = false;
}
}
contract FourLeafClover is _Token("Four Leaf Clover", "FLC") {
function FourLeafClover() public {}
}