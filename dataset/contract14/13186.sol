pragma solidity 0.4.23;
contract ERC20Interface {
function totalSupply() public view returns (uint256);
function balanceOf(address account) public view returns (uint256);
function allowance(address owner, address spender) public view returns (uint256);
function transfer(address recipient, uint256 amount) public returns (bool);
function transferFrom(address from, address to, uint256 amount) public returns (bool);
function approve(address spender, uint256 amount) public returns (bool);
event Transfer(address indexed sender, address indexed recipient, uint256 amount);
event Approval(address indexed owner, address indexed spender, uint256 amount);
}
library SafeMath {
function add(uint256 a, uint256 b) internal pure returns (uint256) {
uint256 c = a + b;
assert(c >= a);
return c;
}
function sub(uint256 a, uint256 b) internal pure returns (uint256) {
require(b <= a);
return a - b;
}
function mul(uint256 a, uint256 b) internal pure returns (uint256) {
if (a == 0) {
return 0;
}
uint256 c = a * b;
assert(c / a == b);
return c;
}
function div(uint256 a, uint256 b) internal pure returns (uint256) {
return a / b;
}
}
contract ERC20Token is ERC20Interface {
using SafeMath for uint256;
uint256 _totalSupply;
mapping(address => uint256) balances;
mapping(address => mapping(address => uint256)) internal allowed;
function totalSupply() public view returns (uint256) {
return _totalSupply;
}
function balanceOf(address account) public view returns (uint256) {
return balances[account];
}
function allowance(address owner, address spender) public view returns (uint256) {
return allowed[owner][spender];
}
function transfer(address recipient, uint256 amount) public returns (bool) {
require(recipient != address(0) && recipient != address(this));
require(amount <= balances[msg.sender], "insufficient funds");
balances[msg.sender] = balances[msg.sender].sub(amount);
balances[recipient] = balances[recipient].add(amount);
emit Transfer(msg.sender, recipient, amount);
return true;
}
function transferFrom(address from, address to, uint256 amount) public returns (bool) {
require(to != address(0) && to != address(this));
require(amount <= balances[from] && amount <= allowed[from][msg.sender], "insufficient funds");
balances[from] = balances[from].sub(amount);
balances[to] = balances[to].add(amount);
allowed[from][msg.sender] = allowed[from][msg.sender].sub(amount);
emit Transfer(from, to, amount);
return true;
}
function approve(address spender, uint256 amount) public returns (bool) {
require(spender != address(0) && spender != address(this));
require(amount == 0 || allowed[msg.sender][spender] == 0);
allowed[msg.sender][spender] = amount;
emit Approval(msg.sender, spender, amount);
return true;
}
}
contract Ownable {
address public owner;
constructor() public {
owner = msg.sender;
}
modifier onlyOwner() {
require(msg.sender == owner);
_;
}
}
contract BurnableToken is Ownable, ERC20Token {
event Burn(address indexed burner, uint256 value);
function burn(uint256 amount) public onlyOwner returns (bool) {
require(amount <= balances[owner], "amount should be less than available balance");
balances[owner] = balances[owner].sub(amount);
_totalSupply = _totalSupply.sub(amount);
emit Burn(owner, amount);
emit Transfer(owner, address(0), amount);
return true;
}
}
contract PausableToken is Ownable, ERC20Token {
event Pause();
event Unpause();
bool public paused = false;
modifier whenNotPaused() {
require(!paused);
_;
}
modifier whenPaused() {
require(paused);
_;
}
function pause() onlyOwner whenNotPaused public {
paused = true;
emit Pause();
}
function unpause() onlyOwner whenPaused public {
paused = false;
emit Unpause();
}
function transfer(address recipient, uint256 amount) public whenNotPaused returns (bool) {
return super.transfer(recipient, amount);
}
function transferFrom(address from, address to, uint256 amount) public whenNotPaused returns (bool) {
return super.transferFrom(from, to, amount);
}
function approve(address spender, uint256 amount) public whenNotPaused returns (bool) {
return super.approve(spender, amount);
}
}
contract BloxiaToken is Ownable, ERC20Token, PausableToken, BurnableToken {
string public constant name = "Bloxia";
string public constant symbol = "BLOX";
uint8 public constant decimals = 18;
uint256 constant initial_supply = 500000000 * (10 ** uint256(decimals));
constructor() public {
_totalSupply = initial_supply;
balances[msg.sender] = initial_supply;
emit Transfer(0x0, msg.sender, initial_supply);
}
}