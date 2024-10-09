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
contract ERC20Basic {
uint256 public totalSupply;
function balanceOf(address who) public view returns (uint256);
function transfer(address to, uint256 value) public returns (bool);
event Transfer(address indexed from, address indexed to, uint256 value);
}
contract BasicToken is ERC20Basic {
using SafeMath for uint256;
mapping(address => uint256) balances;
function transfer(address _to, uint256 _value) public returns (bool) {
balances[msg.sender] = balances[msg.sender].sub(_value);
balances[_to] = balances[_to].add(_value);
Transfer(msg.sender, _to, _value);
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
mapping (address => mapping (address => uint256)) allowed;
function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
uint256 _allowance = allowed[_from][msg.sender];
balances[_to] = balances[_to].add(_value);
balances[_from] = balances[_from].sub(_value);
allowed[_from][msg.sender] = _allowance.sub(_value);
Transfer(_from, _to, _value);
return true;
}
function approve(address _spender, uint256 _value) public returns (bool) {
require((_value == 0) || (allowed[msg.sender][_spender] == 0));
allowed[msg.sender][_spender] = _value;
Approval(msg.sender, _spender, _value);
return true;
}
function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
return allowed[_owner][_spender];
}
}
contract StandardTokenExt is StandardToken {
function isToken() public pure returns (bool weAre) {
return true;
}
}
contract BurnableToken is StandardTokenExt {
address public constant BURN_ADDRESS = 0;
event Burned(address burner, uint burnedAmount);
function burn(uint burnAmount) public {
address burner = msg.sender;
balances[burner] = balances[burner].sub(burnAmount);
totalSupply = totalSupply.sub(burnAmount);
Burned(burner, burnAmount);
Transfer(burner, BURN_ADDRESS, burnAmount);
}
}
contract UpgradeAgent {
uint public originalSupply;
function isUpgradeAgent() public pure returns (bool) {
return true;
}
function upgradeFrom(address _from, uint256 _value) public;
}
contract Ownable {
address public owner;
function Ownable() public {
owner = msg.sender;
}
modifier onlyOwner() {
require(msg.sender == owner);
_;
}
function transferOwnership(address newOwner) public onlyOwner {
require(newOwner != address(0));
owner = newOwner;
}
}
contract UpgradeableToken is StandardTokenExt, Ownable {
UpgradeAgent public upgradeAgent;
uint256 public totalUpgraded;
enum UpgradeState {Unknown, NotAllowed, WaitingForAgent, ReadyToUpgrade, Upgrading}
event Upgrade(address indexed _from, address indexed _to, uint256 _value);
event UpgradeAgentSet(address agent);
function upgrade(uint256 value) public {
UpgradeState state = getUpgradeState();
require (state == UpgradeState.ReadyToUpgrade || state == UpgradeState.Upgrading);
require (value != 0);
balances[msg.sender] = balances[msg.sender].sub(value);
totalSupply = totalSupply.sub(value);
totalUpgraded = totalUpgraded.add(value);
upgradeAgent.upgradeFrom(msg.sender, value);
Upgrade(msg.sender, upgradeAgent, value);
}
function setUpgradeAgent(address agent) external onlyOwner {
require(canUpgrade());
require(agent != address(0));
require(getUpgradeState() != UpgradeState.Upgrading);
upgradeAgent = UpgradeAgent(agent);
require(upgradeAgent.isUpgradeAgent());
require(upgradeAgent.originalSupply() == totalSupply);
UpgradeAgentSet(upgradeAgent);
}
function getUpgradeState() public view returns(UpgradeState) {
if (!canUpgrade())
return UpgradeState.NotAllowed;
else if (address(upgradeAgent) == 0x00)
return UpgradeState.WaitingForAgent;
else if (totalUpgraded == 0)
return UpgradeState.ReadyToUpgrade;
else
return UpgradeState.Upgrading;
}
function canUpgrade() public pure returns(bool) {
return true;
}
}
contract RankToken is BurnableToken, UpgradeableToken {
string public name = "Rank Token";
string public symbol = "RANK";
uint public decimals = 18;
bool public released = false;
event UpdatedTokenInformation(string newName, string newSymbol);
function RankToken() public {
totalSupply = 1500000000000000000000000000;
balances[msg.sender] = totalSupply;
}
function setTokenInformation(string _name, string _symbol) public onlyOwner {
name = _name;
symbol = _symbol;
UpdatedTokenInformation(name, symbol);
}
function transfer(address _to, uint _value) public returns (bool success) {
require(released);
return super.transfer(_to, _value);
}
function releaseTokenTransfer() public onlyOwner {
released = true;
}
}