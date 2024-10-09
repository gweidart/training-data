pragma solidity ^0.4.18;
contract SafeMath {
function safeAdd(uint a, uint b) public pure returns (uint c) {
c = a + b;
require(c >= a);
}
function safeSub(uint a, uint b) public pure returns (uint c) {
require(b <= a);
c = a - b;
}
function safeMul(uint a, uint b) public pure returns (uint c) {
c = a * b;
require(a == 0 || c / a == b);
}
function safeDiv(uint a, uint b) public pure returns (uint c) {
require(b > 0);
c = a / b;
}
}
contract ERC20 {
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
contract HeliosToken is ERC20, Owned, SafeMath {
string public symbol;
string public  name;
uint8 public decimals;
uint public _totalSupply;
uint public _yearTwoSupply;
uint public _yearThreeSupply;
bool public _yearTwoClaimed;
bool public _yearThreeClaimed;
uint256 public startTime = 1519862400;
mapping(address => uint) balances;
mapping(address => mapping(address => uint)) allowed;
function HeliosToken() public {
symbol = "HLS";
name = "Helios Token";
decimals = 18;
_totalSupply = 350000000000000000000000000;
_yearTwoSupply = 30000000000000000000000000;
_yearThreeSupply = 20000000000000000000000000;
balances[0x6BFAf995ffce7Be6e3073dC8AAf45E445cf234e2] = (_totalSupply - _yearTwoSupply - _yearThreeSupply);
Transfer(address(0), 0x6BFAf995ffce7Be6e3073dC8AAf45E445cf234e2, (_totalSupply - _yearTwoSupply - _yearThreeSupply));
_yearTwoClaimed = false;
_yearThreeClaimed = false;
}
function teamClaim(uint year) public onlyOwner returns (bool success) {
if(year == 2)
{
require (now > (startTime + 31536000)  && _yearTwoClaimed == false);
balances[0x6BFAf995ffce7Be6e3073dC8AAf45E445cf234e2] = safeAdd(balances[0x6BFAf995ffce7Be6e3073dC8AAf45E445cf234e2], _yearTwoSupply);
Transfer(address(0), 0x6BFAf995ffce7Be6e3073dC8AAf45E445cf234e2, _yearTwoSupply);
_yearTwoClaimed = true;
}
if(year == 3)
{
require (now > (startTime + 63072000) && _yearThreeClaimed == false);
balances[0x6BFAf995ffce7Be6e3073dC8AAf45E445cf234e2] = safeAdd(balances[0x6BFAf995ffce7Be6e3073dC8AAf45E445cf234e2], _yearThreeSupply);
Transfer(address(0), 0x6BFAf995ffce7Be6e3073dC8AAf45E445cf234e2, _yearThreeSupply);
_yearThreeClaimed = true;
}
return true;
}
function totalSupply() public constant returns (uint) {
return _totalSupply  - balances[address(0)];
}
function balanceOf(address tokenOwner) public constant returns (uint balance) {
return balances[tokenOwner];
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
revert();
}
function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns (bool success) {
return ERC20(tokenAddress).transfer(owner, tokens);
}
}