pragma solidity ^0.4.18;
library SafeMath {
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
contract FINXToken is ERC20Interface {
using SafeMath for uint;
string constant public symbol = "FINX";
string constant public name = "FINX";
uint8 constant public decimals = 18;
uint public _totalSupply = 100000000000e18;
uint constant endTime = 1543622400;
uint constant unlockTime = 1622505600;
address founder1 = 0x0e85a9faB7D61b6cbbf1ccafA8144E23009a60AF;
address founder2 = 0xFcEa27D04354aD5f20B5dbaf5C314e4f143eAe48;
address founder3 = 0xa0eC2A32bd678DFbD3d359Be8075093f36B2c0aa;
address founder4 = 0xC93324C26ce4221d187FEeeaf54bC047Bbddd26a;
address mgmtTeam = 0xb3495892fB336D81dBAb4650c2291Bfd7A52c1C1;
address advsTeam = 0x72C1A4670a97a6A2BD106cA3341f059123a4F381;
address crowdSale = 0x9940bd75d32a0544750eed5EfC208453F4ae31ab;
uint constant founderTokens = 250000000e18;
uint constant mgmtTokens = 20000000e18;
uint constant advsTokens = 40000000e18;
uint constant crowdSaleTokens = 98940000000e18;
mapping(address => uint) balances;
mapping(address => mapping(address => uint)) allowed;
function FINXToken() public {
preSale(founder1, founderTokens);
preSale(founder2, founderTokens);
preSale(founder3, founderTokens);
preSale(founder4, founderTokens);
preSale(mgmtTeam, mgmtTokens);
preSale(advsTeam, advsTokens);
preSale(crowdSale, crowdSaleTokens);
}
function preSale(address _address, uint _amount) internal returns (bool) {
balances[_address] = _amount;
emit Transfer(address(0x0), _address, _amount);
}
function transferPermissions(address spender) internal constant returns (bool) {
if (spender == crowdSale) {
return true;
}
if (now < endTime) {
return false;
}
if (now < unlockTime) {
if (spender == founder1 || spender == founder2 || spender == founder3 || spender == founder4) {
return false;
}
}
return true;
}
function totalSupply() public constant returns (uint) {
return _totalSupply;
}
function balanceOf(address tokenOwner) public constant returns (uint balance) {
return balances[tokenOwner];
}
function transfer(address to, uint tokens) public returns (bool success) {
require(transferPermissions(msg.sender));
balances[msg.sender] = balances[msg.sender].sub(tokens);
balances[to] = balances[to].add(tokens);
emit Transfer(msg.sender, to, tokens);
return true;
}
function approve(address spender, uint tokens) public returns (bool success) {
allowed[msg.sender][spender] = tokens;
emit Approval(msg.sender, spender, tokens);
return true;
}
function transferFrom(address from, address to, uint tokens) public returns (bool success) {
require(transferPermissions(from));
balances[from] = balances[from].sub(tokens);
allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);
balances[to] = balances[to].add(tokens);
emit Transfer(from, to, tokens);
return true;
}
function allowance(address tokenOwner, address spender) public constant returns (uint remaining) {
return allowed[tokenOwner][spender];
}
function () public payable {
revert();
}
}