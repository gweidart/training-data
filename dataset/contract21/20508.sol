pragma solidity ^0.4.18;
library SafeMath {
function mul(uint256 a, uint256 b) internal pure returns (uint256) {
uint256 c = a * b;
assert(a == 0 || c / a == b);
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
contract Ownable {
address public owner;
function Ownable() public{
owner = msg.sender;
}
modifier onlyOwner() {
require(owner==msg.sender);
_;
}
function transferOwnership(address newOwner) public onlyOwner {
owner = newOwner;
}
}
contract ERC20 {
function totalSupply() public constant returns (uint256);
function balanceOf(address who) public constant returns (uint256);
function transfer(address to, uint256 value) public returns (bool success);
function transferFrom(address from, address to, uint256 value) public returns (bool success);
function approve(address spender, uint256 value) public returns (bool success);
function allowance(address owner, address spender) public constant returns (uint256);
event Transfer(address indexed from, address indexed to, uint256 value);
event Approval(address indexed owner, address indexed spender, uint256 value);
}
contract CBITToken is Ownable, ERC20 {
using SafeMath for uint256;
string public name = "CAMBITUS";
string public symbol = "CBIT";
uint256 public decimals = 18;
uint256 public _totalSupply = 250000000e18;
uint256 public _icoSupply = 156250000e18;
uint256 public _preSaleSupply = 43750000e18;
uint256 public _phase1Supply = 50000000e18;
uint256 public _phase2Supply = 50000000e18;
uint256 public _finalSupply = 12500000e18;
uint256 public _teamSupply = 43750000e18;
uint256 public _communitySupply = 12500000e18;
uint256 public _bountySupply = 12500000e18;
uint256 public _ecosysSupply = 25000000e18;
mapping (address => uint256) balances;
mapping (address => mapping(address => uint256)) allowed;
uint256 public startTime;
address public multisig;
uint256 public price;
uint256 public minContribAmount = 1 ether;
uint256 public maxCap = 81000 ether;
uint256 public minCap = 450 ether;
uint256 public totalNumberTokenSold=0;
bool public tradable = false;
event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);
modifier canTradable() {
require(tradable || (now > startTime + 180 days));
_;
}
function CBITToken() public{
multisig = 0xAfC252F597bd592276C6846cD44d1F82d87e63a2;
balances[multisig] = _totalSupply;
startTime = 1525150800;
owner = msg.sender;
}
function () external payable {
tokensale(msg.sender);
}
function tokensale(address recipient) public payable {
require(recipient != 0x0);
require(msg.value >= minContribAmount);
price = getPrice();
uint256 weiAmount = msg.value;
uint256 tokenToSend = weiAmount.mul(price);
require(tokenToSend > 0);
require(_icoSupply >= tokenToSend);
balances[multisig] = balances[multisig].sub(tokenToSend);
balances[recipient] = balances[recipient].add(tokenToSend);
totalNumberTokenSold=totalNumberTokenSold.add(tokenToSend);
_icoSupply = _icoSupply.sub(tokenToSend);
multisig.transfer(msg.value);
TokenPurchase(msg.sender, recipient, weiAmount, tokenToSend);
}
function sendICOSupplyToken(address to, uint256 value) public onlyOwner {
require (
to != 0x0 && value > 0 && _icoSupply >= value
);
balances[multisig] = balances[multisig].sub(value);
balances[to] = balances[to].add(value);
_icoSupply = _icoSupply.sub(value);
totalNumberTokenSold=totalNumberTokenSold.add(value);
Transfer(multisig, to, value);
}
function sendTeamSupplyToken(address to, uint256 value) public onlyOwner {
require (
to != 0x0 && value > 0 && _teamSupply >= value
);
balances[multisig] = balances[multisig].sub(value);
balances[to] = balances[to].add(value);
totalNumberTokenSold=totalNumberTokenSold.add(value);
_teamSupply = _teamSupply.sub(value);
Transfer(multisig, to, value);
}
function sendCommunitySupplyToken(address to, uint256 value) public onlyOwner {
require (
to != 0x0 && value > 0 && _communitySupply >= value
);
balances[multisig] = balances[multisig].sub(value);
balances[to] = balances[to].add(value);
totalNumberTokenSold=totalNumberTokenSold.add(value);
_communitySupply = _communitySupply.sub(value);
Transfer(multisig, to, value);
}
function sendBountySupplyToken(address to, uint256 value) public onlyOwner {
require (
to != 0x0 && value > 0 && _bountySupply >= value
);
balances[multisig] = balances[multisig].sub(value);
balances[to] = balances[to].add(value);
totalNumberTokenSold=totalNumberTokenSold.add(value);
_bountySupply = _bountySupply.sub(value);
Transfer(multisig, to, value);
}
function sendEcosysSupplyToken(address to, uint256 value) public onlyOwner {
require (
to != 0x0 && value > 0 && _ecosysSupply >= value
);
balances[multisig] = balances[multisig].sub(value);
balances[to] = balances[to].add(value);
totalNumberTokenSold=totalNumberTokenSold.add(value);
_ecosysSupply = _ecosysSupply.sub(value);
Transfer(multisig, to, value);
}
function startTradable(bool _tradable) public onlyOwner {
tradable = _tradable;
}
function totalSupply() public constant returns (uint256) {
return _totalSupply;
}
function totalNumberTokenSold() public view returns (uint256) {
return totalNumberTokenSold;
}
function balanceOf(address who) public constant returns (uint256) {
return balances[who];
}
function transfer(address to, uint256 value) public canTradable returns (bool success)  {
require (
balances[msg.sender] >= value && value > 0
);
balances[msg.sender] = balances[msg.sender].sub(value);
balances[to] = balances[to].add(value);
Transfer(msg.sender, to, value);
return true;
}
function transferFrom(address from, address to, uint256 value) public canTradable returns (bool success)  {
require (
allowed[from][msg.sender] >= value && balances[from] >= value && value > 0
);
balances[from] = balances[from].sub(value);
balances[to] = balances[to].add(value);
allowed[from][msg.sender] = allowed[from][msg.sender].sub(value);
Transfer(from, to, value);
return true;
}
function approve(address spender, uint256 value) public returns (bool success)  {
require (
balances[msg.sender] >= value && value > 0
);
allowed[msg.sender][spender] = value;
Approval(msg.sender, spender, value);
return true;
}
function allowance(address _owner, address spender) public constant returns (uint256) {
return allowed[_owner][spender];
}
function getPrice() public view returns (uint result) {
if ( (now < startTime + 30 days) && (totalNumberTokenSold < _preSaleSupply)) {
return 7500;
} else if ( (now < startTime + 60 days) && (totalNumberTokenSold < _preSaleSupply + _phase1Supply) ) {
return 5000;
} else if ( (now < startTime + 90 days) && (totalNumberTokenSold < _preSaleSupply + _phase1Supply + _phase2Supply) ) {
return 3125;
} else if ( (now < startTime + 99 days) && (totalNumberTokenSold < _preSaleSupply + _phase1Supply + _phase2Supply + _finalSupply) ) {
return 1500;
} else {
return 0;
}
}
function getTokenDetail() public view returns (string, string, uint256, uint256, uint256, uint256, uint256, uint256, uint256) {
return (name, symbol, _totalSupply, totalNumberTokenSold, _icoSupply, _teamSupply, _communitySupply, _bountySupply, _ecosysSupply);
}
}