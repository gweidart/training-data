pragma solidity ^0.4 .24;
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
function balanceOf(
address tokenOwner
) public constant returns (uint balance);
function allowance(
address tokenOwner,
address spender
) public constant returns (uint remaining);
function transfer(address to, uint tokens) public returns (bool success);
function approve(
address spender,
uint tokens
) public returns (bool success);
function transferFrom(
address from,
address to,
uint tokens
) public returns (bool success);
event Transfer(address indexed from, address indexed to, uint tokens);
event Approval(
address indexed tokenOwner,
address indexed spender,
uint tokens
);
}
contract ApproveAndCallFallBack {
function receiveApproval(
address from,
uint256 tokens,
address token,
bytes data
) public;
}
contract Owned {
address public owner;
address public newOwner;
event OwnershipTransferred(address indexed _from, address indexed _to);
constructor() public {
owner = msg.sender;
}
modifier onlyOwner() {
require(msg.sender == owner);
_;
}
function transferOwnership(address _newOwner) public onlyOwner {
newOwner = _newOwner;
}
function acceptOwnership() public {
require(msg.sender == newOwner);
emit OwnershipTransferred(owner, newOwner);
owner = newOwner;
newOwner = address(0);
}
}
contract BTYCToken is ERC20Interface, Owned {
using SafeMath for uint;
string public symbol;
string public name;
uint8 public decimals;
uint _totalSupply;
uint256 public sellPrice;
uint256 public buyPrice;
uint256 public sysPrice;
uint256 public sysPer;
uint256 public onceOuttime;
uint256 public onceAddTime;
mapping(address => uint) balances;
mapping(address => mapping(address => uint)) allowed;
mapping(address => bool) public frozenAccount;
struct roundsOwn {
uint256 addtime;
uint256 addmoney;
}
mapping(address => roundsOwn[]) public mycan;
mapping(address => uint256) public tradenum;
mapping(address => uint) public cronaddOf;
event FrozenFunds(address target, bool frozen);
constructor() public {
symbol = "BTYC";
name = "BTYC Coin";
decimals = 18;
_totalSupply = 84000000 * 10 ** uint(decimals);
sellPrice = 510;
buyPrice = 526;
sysPrice = 766;
sysPer = 225;
onceOuttime = 86400;
onceAddTime = 864000;
balances[owner] = _totalSupply;
emit Transfer(address(0), owner, _totalSupply);
}
function balanceOf(address tokenOwner) public view returns (uint balance) {
return balances[tokenOwner];
}
function addmoney(address _addr, uint256 _money) private {
roundsOwn stateVar;
uint256 _now = now;
stateVar.addtime = _now;
stateVar.addmoney = _money;
mycan[_addr].push(stateVar);
tradenum[_addr] = tradenum[_addr] + 1;
}
function getcanuse(address tokenOwner) public view returns (uint balance) {
uint256 _now = now;
uint256 _left = 0;
for (uint256 i = 0; i < tradenum[tokenOwner]; i++) {
roundsOwn mydata = mycan[tokenOwner][i];
uint256 stime = mydata.addtime;
uint256 smoney = mydata.addmoney;
uint256 lefttimes = _now - stime;
if (lefttimes >= onceOuttime) {
uint256 leftpers = lefttimes / onceOuttime;
if (leftpers > 100) {
leftpers = 100;
}
_left = (smoney * leftpers) / 100 + _left;
}
}
return (_left);
}
function transfer(address to, uint tokens) public returns (bool success) {
require(!frozenAccount[msg.sender]);
require(!frozenAccount[to]);
uint256 canuse = getcanuse(msg.sender);
require(canuse >= tokens);
balances[msg.sender] = balances[msg.sender].sub(tokens);
balances[to] = balances[to].add(tokens);
addmoney(to, tokens);
emit Transfer(msg.sender, to, tokens);
return true;
}
function approve(
address spender,
uint tokens
) public returns (bool success) {
allowed[msg.sender][spender] = tokens;
emit Approval(msg.sender, spender, tokens);
return true;
}
function transferFrom(
address from,
address to,
uint tokens
) public returns (bool success) {
balances[from] = balances[from].sub(tokens);
allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);
balances[to] = balances[to].add(tokens);
emit Transfer(from, to, tokens);
return true;
}
function allowance(
address tokenOwner,
address spender
) public view returns (uint remaining) {
return allowed[tokenOwner][spender];
}
function approveAndCall(
address spender,
uint tokens,
bytes data
) public returns (bool success) {
allowed[msg.sender][spender] = tokens;
emit Approval(msg.sender, spender, tokens);
ApproveAndCallFallBack(spender).receiveApproval(
msg.sender,
tokens,
this,
data
);
return true;
}
function freezeAccount(address target, bool freeze) public onlyOwner {
frozenAccount[target] = freeze;
emit FrozenFunds(target, freeze);
}
function setPrices(
uint256 newBuyPrice,
uint256 newSellPrice,
uint256 systyPrice,
uint256 sysPermit
) public onlyOwner {
buyPrice = newBuyPrice;
sellPrice = newSellPrice;
sysPrice = systyPrice;
sysPer = sysPermit;
}
function getprice()
public
view
returns (uint256 bprice, uint256 spice, uint256 sprice, uint256 sper)
{
bprice = buyPrice;
spice = sellPrice;
sprice = sysPrice;
sper = sysPer;
}
function totalSupply() public view returns (uint) {
return _totalSupply.sub(balances[address(0)]);
}
function mintToken(address target, uint256 mintedAmount) public onlyOwner {
require(!frozenAccount[target]);
if (cronaddOf[msg.sender] < 1) {
cronaddOf[msg.sender] = now + onceAddTime;
}
balances[target] += mintedAmount;
addmoney(target, mintedAmount);
emit Transfer(this, target, mintedAmount);
}
function mintme() public {
require(!frozenAccount[msg.sender]);
require(now > cronaddOf[msg.sender]);
uint256 mintAmount = (balances[msg.sender] * sysPer) / 10000;
balances[msg.sender] += mintAmount;
cronaddOf[msg.sender] = now + onceAddTime;
addmoney(msg.sender, mintAmount);
emit Transfer(this, msg.sender, mintAmount);
}
function buy(uint256 money) public payable returns (uint256 amount) {
require(!frozenAccount[msg.sender]);
amount = money * buyPrice;
balances[msg.sender] += amount;
balances[this] -= amount;
addmoney(msg.sender, amount);
emit Transfer(this, msg.sender, amount);
return (amount);
}
function() public payable {
buy(msg.value);
}
function sell(uint256 amount) public returns (bool success) {
uint256 canuse = getcanuse(msg.sender);
require(canuse >= amount);
uint moneys = amount / sellPrice;
require(msg.sender.send(moneys));
balances[msg.sender] -= amount;
balances[this] += amount;
emit Transfer(this, msg.sender, moneys);
return (true);
}
}