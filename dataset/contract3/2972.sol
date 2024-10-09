pragma solidity ^0.4.21;
library SafeMath {
function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
if (a == 0) {
return 0;
}
c = a * b;
assert(c / a == b);
return c;
}
function div(uint256 a, uint256 b) internal pure returns (uint256) {
return a / b;
}
function sub(uint256 a, uint256 b) internal pure returns (uint256) {
assert(b <= a);
return a - b;
}
function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
c = a + b;
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
contract ERC20 is ERC20Basic {
function allowance(address owner, address spender) public view returns (uint256);
function transferFrom(address from, address to, uint256 value) public returns (bool);
function approve(address spender, uint256 value) public returns (bool);
event Approval(address indexed owner, address indexed spender, uint256 value);
}
contract WETH9 {
string public name     = "Wrapped Ether";
string public symbol   = "WETH";
uint8  public decimals = 18;
event  Approval(address indexed src, address indexed guy, uint wad);
event  Transfer(address indexed src, address indexed dst, uint wad);
event  Deposit(address indexed dst, uint wad);
event  Withdrawal(address indexed src, uint wad);
mapping (address => uint)                       public  balanceOf;
mapping (address => mapping (address => uint))  public  allowance;
function() public payable {
deposit();
}
function deposit() public payable {
balanceOf[msg.sender] += msg.value;
Deposit(msg.sender, msg.value);
}
function withdraw(uint wad) public {
require(balanceOf[msg.sender] >= wad);
balanceOf[msg.sender] -= wad;
msg.sender.transfer(wad);
Withdrawal(msg.sender, wad);
}
function totalSupply() public view returns (uint) {
return this.balance;
}
function approve(address guy, uint wad) public returns (bool) {
allowance[msg.sender][guy] = wad;
Approval(msg.sender, guy, wad);
return true;
}
function transfer(address dst, uint wad) public returns (bool) {
return transferFrom(msg.sender, dst, wad);
}
function transferFrom(address src, address dst, uint wad)
public
returns (bool)
{
require(balanceOf[src] >= wad);
if (src != msg.sender && allowance[src][msg.sender] != uint(-1)) {
require(allowance[src][msg.sender] >= wad);
allowance[src][msg.sender] -= wad;
}
balanceOf[src] -= wad;
balanceOf[dst] += wad;
Transfer(src, dst, wad);
return true;
}
}
interface Registry {
function isAffiliated(address _affiliate) external returns (bool);
}
contract Affiliate {
struct Share {
address shareholder;
uint stake;
}
Share[] shares;
uint public totalShares;
string public relayerName;
address registry;
WETH9 weth;
event Payout(address indexed token, uint amount);
function init(address _registry, address[] shareholders, uint[] stakes, address _weth, string _name) public returns (bool) {
require(totalShares == 0);
require(shareholders.length == stakes.length);
weth = WETH9(_weth);
totalShares = 0;
for(uint i=0; i < shareholders.length; i++) {
shares.push(Share({shareholder: shareholders[i], stake: stakes[i]}));
totalShares += stakes[i];
}
relayerName = _name;
registry = _registry;
return true;
}
function payout(address[] tokens) public {
for(uint i=0; i < tokens.length; i++) {
ERC20 token = ERC20(tokens[i]);
uint balance = token.balanceOf(this);
for(uint j=0; j < shares.length; j++) {
token.transfer(shares[j].shareholder, SafeMath.mul(balance, shares[j].stake) / totalShares);
}
emit Payout(tokens[i], balance);
}
}
function isAffiliated(address _affiliate) public returns (bool)
{
return Registry(registry).isAffiliated(_affiliate);
}
function() public payable {
weth.deposit.value(msg.value)();
}
}