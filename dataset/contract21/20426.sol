pragma solidity 0.4.21;
library SafeMath {
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
contract Moneda {
using SafeMath for uint256;
string constant public standard = "ERC20";
string constant public name = "Moneda Token";
string constant public symbol = "MND";
uint8 constant public decimals = 18;
uint256 private _totalSupply = 400000000e18;
uint256 constant public preICOLimit = 20000000e18;
uint256 constant public icoLimit = 250000000e18;
uint256 constant public companyReserve = 80000000e18;
uint256 constant public teamReserve = 40000000e18;
uint256 constant public giveawayReserve = 10000000e18;
uint256 public preICOEnds = 1525132799;
uint256 public icoStarts = 1526342400;
uint256 public icoEnds = 1531699199;
uint256 constant public startTime = 1532822400;
uint256 constant public teamCompanyLock = 1563148800;
address public ownerAddr;
address public companyAddr;
address public giveawayAddr;
bool public burned;
mapping (address => uint256) public balances;
mapping (address => mapping (address => uint256)) internal allowed;
event Transfer(address indexed from, address indexed to, uint256 value);
event Approval(address indexed owner, address indexed spender, uint256 value);
event Burned(uint256 amount);
function Moneda(address _ownerAddr, address _companyAddr, address _giveawayAddr) public {
ownerAddr = _ownerAddr;
companyAddr = _companyAddr;
giveawayAddr = _giveawayAddr;
balances[ownerAddr] = _totalSupply;
}
function totalSupply() public view returns (uint256) {
return _totalSupply;
}
function balanceOf(address who) public view returns (uint256) {
return balances[who];
}
function allowance(address owner, address spender) public view returns (uint256) {
return allowed[owner][spender];
}
function transfer(address to, uint256 value) public returns (bool) {
require(now >= startTime);
require(value > 0);
if (msg.sender == ownerAddr || msg.sender == companyAddr)
require(now >= teamCompanyLock);
balances[msg.sender] = balances[msg.sender].sub(value);
balances[to] = balances[to].add(value);
emit Transfer(msg.sender, to, value);
return true;
}
function transferFrom(address from, address to, uint256 value) public returns (bool) {
require(value > 0);
require(to != address(0));
require(value <= balances[from]);
require(value <= allowed[from][msg.sender]);
if (now < icoEnds)
require(from == ownerAddr);
if (msg.sender == ownerAddr || msg.sender == companyAddr)
require(now >= teamCompanyLock);
balances[from] = balances[from].sub(value);
balances[to] = balances[to].add(value);
allowed[from][msg.sender] = allowed[from][msg.sender].sub(value);
emit Transfer(from, to, value);
return true;
}
function approve(address spender, uint256 value) public returns (bool) {
require((value == 0) || (allowed[msg.sender][spender] == 0));
allowed[msg.sender][spender] = value;
emit Approval(msg.sender, spender, value);
return true;
}
function burn() public {
require(!burned && now > icoEnds);
uint256 totalReserve = teamReserve.add(companyReserve);
uint256 difference = balances[ownerAddr].sub(totalReserve);
balances[ownerAddr] = teamReserve;
balances[companyAddr] = companyReserve;
balances[giveawayAddr] = giveawayReserve;
_totalSupply = _totalSupply.sub(difference);
burned = true;
emit Burned(difference);
}
}