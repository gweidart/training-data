pragma solidity ^0.4.21;
contract ERC20_Interface {
function totalSupply() public constant returns (uint256);
function balanceOf(address tokenOwner) public constant returns (uint256 balance);
function allowance(address tokenOwner, address spender) public constant returns (uint256 remaining);
function transfer(address to, uint256 tokens) public returns (bool success);
function approve(address spender, uint256 tokens) public returns (bool success);
function transferFrom(address from, address to, uint256 tokens) public returns (bool success);
event Transfer(address indexed from, address indexed to, uint256 tokens);
event Approval(address indexed tokenOwner, address indexed spender, uint256 tokens);
}
contract ERC20_ReceivingInterface {
function receiveApproval(address from, uint256 tokens, address token, bytes data) public;
}
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
emit OwnershipTransferred(owner, newOwner);
owner = newOwner;
}
}
contract SafeMath {
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
contract SoraToken is ERC20_Interface, Ownable, SafeMath {
string  public constant symbol         = "XOR";
string  public constant name           = "Sora";
uint8   public constant decimals       = 18;
uint256 internal constant _totalSupply = 161803398874989484820458683437;
mapping(address => uint256) public balances;
mapping(address => mapping(address => uint256)) public allowed;
function totalSupply() public constant returns (uint256) {
return _totalSupply - balances[address(0)];
}
function SoraToken() public {
balances[owner] = _totalSupply;
emit Transfer(address(0), owner, _totalSupply);
}
function() public payable {
revert();
}
function approve(address spender, uint256 tokens) public returns (bool success) {
allowed[msg.sender][spender] = tokens;
emit Approval(msg.sender, spender, tokens);
return true;
}
function transferFrom(address from, address to, uint256 tokens) public returns (bool success) {
balances[from] = sub(balances[from], tokens);
allowed[from][msg.sender] = sub(allowed[from][msg.sender], tokens);
balances[to] = add(balances[to], tokens);
emit Transfer(from, to, tokens);
return true;
}
function allowance(address tokenOwner, address spender) public constant returns (uint256 remaining) {
return allowed[tokenOwner][spender];
}
function approveAndCall(address spender, uint256 tokens, bytes data) public returns (bool success) {
allowed[msg.sender][spender] = tokens;
emit Approval(msg.sender, spender, tokens);
ERC20_ReceivingInterface(spender).receiveApproval(msg.sender, tokens, this, data);
return true;
}
function transferAnyERC20Token(address tokenAddress, uint256 tokens) public onlyOwner returns (bool success) {
return ERC20_Interface(tokenAddress).transfer(owner, tokens);
}
function balanceOf(address tokenOwner) public constant returns (uint256 balance) {
return balances[tokenOwner];
}
function transfer(address to, uint tokens) public returns (bool success) {
balances[msg.sender] = sub(balances[msg.sender], tokens);
balances[to] = add(balances[to], tokens);
emit Transfer(msg.sender, to, tokens);
return true;
}
}