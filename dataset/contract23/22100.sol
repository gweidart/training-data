pragma solidity ^0.4.19;
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
contract ERC20Basic {
function totalSupply() public view returns (uint256);
function balanceOf(address who) public view returns (uint256);
function transfer(address to, uint256 value) public returns (bool);
event Transfer(address indexed from, address indexed to, uint256 value);
}
contract BasicToken is ERC20Basic {
using SafeMath for uint256;
mapping(address => uint256) balances;
uint256 totalSupply_;
function totalSupply() public view returns (uint256) {
return totalSupply_;
}
function transfer(address _to, uint256 _value) public returns (bool) {
require(_to != address(0));
require(_value <= balances[msg.sender]);
balances[msg.sender] = balances[msg.sender].sub(_value);
balances[_to] = balances[_to].add(_value);
emit Transfer(msg.sender, _to, _value);
return true;
}
function balanceOf(address _owner) public view returns (uint256 balance) {
return balances[_owner];
}
}
contract ERC20 is ERC20Basic {
function allowance(address owner, address spender) public view returns (uint256);
function transferFrom(address from, address to, uint256 value) public returns (bool);
function approve(address spender, uint256 value) public returns (bool);
event Approval(address indexed owner, address indexed spender, uint256 value);
}
contract StandardToken is ERC20, BasicToken {
mapping (address => mapping (address => uint256)) internal allowed;
function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
require(_to != address(0));
require(_value <= balances[_from]);
require(_value <= allowed[_from][msg.sender]);
balances[_from] = balances[_from].sub(_value);
balances[_to] = balances[_to].add(_value);
allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
emit Transfer(_from, _to, _value);
return true;
}
function approve(address _spender, uint256 _value) public returns (bool) {
allowed[msg.sender][_spender] = _value;
emit Approval(msg.sender, _spender, _value);
return true;
}
function allowance(address _owner, address _spender) public view returns (uint256) {
return allowed[_owner][_spender];
}
function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
return true;
}
function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
uint oldValue = allowed[msg.sender][_spender];
if (_subtractedValue > oldValue) {
allowed[msg.sender][_spender] = 0;
} else {
allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
}
emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
return true;
}
}
contract MintableToken is StandardToken, Ownable {
event Mint(address indexed to, uint256 amount);
event MintFinished();
bool public mintingFinished = false;
modifier canMint() {
require(!mintingFinished);
_;
}
function mint(address _to, uint256 _amount) onlyOwner canMint public returns (bool) {
totalSupply_ = totalSupply_.add(_amount);
balances[_to] = balances[_to].add(_amount);
emit Mint(_to, _amount);
emit Transfer(address(0), _to, _amount);
return true;
}
function finishMinting() onlyOwner canMint public returns (bool) {
mintingFinished = true;
emit MintFinished();
return true;
}
}
contract Pausable is Ownable {
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
}
contract PausableToken is StandardToken, Pausable {
function transfer(address _to, uint256 _value) public whenNotPaused returns (bool) {
return super.transfer(_to, _value);
}
function transferFrom(address _from, address _to, uint256 _value) public whenNotPaused returns (bool) {
return super.transferFrom(_from, _to, _value);
}
function approve(address _spender, uint256 _value) public whenNotPaused returns (bool) {
return super.approve(_spender, _value);
}
function increaseApproval(address _spender, uint _addedValue) public whenNotPaused returns (bool success) {
return super.increaseApproval(_spender, _addedValue);
}
function decreaseApproval(address _spender, uint _subtractedValue) public whenNotPaused returns (bool success) {
return super.decreaseApproval(_spender, _subtractedValue);
}
}
library SafeERC20 {
function safeTransfer(ERC20Basic token, address to, uint256 value) internal {
assert(token.transfer(to, value));
}
function safeTransferFrom(ERC20 token, address from, address to, uint256 value) internal {
assert(token.transferFrom(from, to, value));
}
function safeApprove(ERC20 token, address spender, uint256 value) internal {
assert(token.approve(spender, value));
}
}
contract CanReclaimToken is Ownable {
using SafeERC20 for ERC20Basic;
function reclaimToken(ERC20Basic token) external onlyOwner {
uint256 balance = token.balanceOf(this);
token.safeTransfer(owner, balance);
}
}
contract CanReclaimEther is Ownable {
function claim() public onlyOwner {
owner.transfer(this.balance);
}
}
contract ZNA is StandardToken, Ownable, PausableToken {
using SafeMath for uint256;
uint256 public MAX_TOTAL;
function ZNA (uint256 maxAmount) public {
MAX_TOTAL = maxAmount;
}
function mint(address _to, uint256 _amount)
public onlyOwner returns (bool) {
totalSupply_ = totalSupply_.add(_amount);
require(totalSupply_ <= MAX_TOTAL);
balances[_to] = balances[_to].add(_amount);
emit Transfer(address(0), _to, _amount);
return true;
}
string public name = "ZNA Token";
string public symbol = "ZNA";
uint8  public decimals = 18;
}
contract ZenomeCrowdsale is Ownable, CanReclaimToken, CanReclaimEther {
using SafeMath for uint256;
struct TokenPool {
address minter;
uint256 amount;
uint256 safecap;
uint256 total;
}
ZNA public token;
TokenPool public for_sale;
TokenPool public for_rewards;
TokenPool public for_longterm;
function ZenomeCrowdsale () public {
for_sale.total = 1575*10**22;
for_rewards.total = 1050*10**22;
for_longterm.total = 875*10**22;
uint256 MAX_TOTAL = for_sale.total
.add(for_rewards.total)
.add(for_longterm.total);
token = new ZNA(MAX_TOTAL);
}
function setSaleMinter (address minter, uint safecap) public onlyOwner { setMinter(for_sale, minter, safecap); }
function setRewardMinter (address minter, uint safecap) public onlyOwner {
require(safecap <= for_sale.amount);
setMinter(for_rewards, minter, safecap);
}
function setLongtermMinter (address minter, uint safecap) public onlyOwner {
require(for_sale.amount > 1400*10**22);
setMinter(for_longterm, minter, safecap);
}
function transferTokenOwnership (address newOwner) public onlyOwner {
require(newOwner != address(0));
token.transferOwnership(newOwner);
}
function pauseToken() public onlyOwner { token.pause(); }
function unpauseToken() public onlyOwner { token.unpause(); }
function mintSoldTokens (address to, uint256 amount) public {
mintTokens(for_sale, to, amount);
}
function mintRewardTokens (address to, uint256 amount) public {
mintTokens(for_rewards, to, amount);
}
function mintLongTermTokens (address to, uint256 amount) public {
mintTokens(for_longterm, to, amount);
}
function setMinter (TokenPool storage pool, address minter, uint256 safecap)
internal onlyOwner {
require(safecap <= pool.total);
pool.minter = minter;
pool.safecap = safecap;
}
function mintTokens (TokenPool storage pool, address to, uint256 amount )
internal {
require(msg.sender == pool.minter);
uint256 new_amount = pool.amount.add(amount);
require(new_amount <= pool.safecap);
pool.amount = new_amount;
token.mint(to, amount);
}
}