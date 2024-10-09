pragma solidity ^0.4.18;
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
uint256 public totalSupply;
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
contract StandardToken is ERC20 {
mapping(address => uint) balances;
mapping (address => mapping (address => uint)) allowed;
bool public constant isToken = true;
modifier onlyPayloadSize(uint size) {
if(msg.data.length < size + 4) {
revert();
}
_;
}
function transfer(address _to, uint _value) onlyPayloadSize(2 * 32) public returns (bool success) {
balances[msg.sender] = SafeMath.sub(balances[msg.sender], _value);
balances[_to] = SafeMath.add(balances[_to], _value);
Transfer(msg.sender, _to, _value);
return true;
}
function transferFrom(address _from, address _to, uint _value) public returns (bool success) {
var _allowance = allowed[_from][msg.sender];
balances[_to] = SafeMath.add(balances[_to], _value);
balances[_from] = SafeMath.sub(balances[_from], _value);
allowed[_from][msg.sender] = SafeMath.sub(_allowance, _value);
Transfer(_from, _to, _value);
return true;
}
function balanceOf(address _owner) public view returns (uint balance) {
return balances[_owner];
}
function approve(address _spender, uint _value) public returns (bool success) {
if ((_value != 0) && (allowed[msg.sender][_spender] != 0)) revert();
allowed[msg.sender][_spender] = _value;
Approval(msg.sender, _spender, _value);
return true;
}
function allowance(address _owner, address _spender) public view returns (uint remaining) {
return allowed[_owner][_spender];
}
}
contract BurnableToken is StandardToken {
address public constant BURN_ADDRESS = 0;
event Burned(address burner, uint burnedAmount);
function burn(uint burnAmount) public {
address burner = msg.sender;
balances[burner] = SafeMath.sub(balances[burner], burnAmount);
totalSupply = SafeMath.sub(totalSupply, burnAmount);
Burned(burner, burnAmount);
Transfer(burner, BURN_ADDRESS, burnAmount);
}
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
OwnershipTransferred(owner, newOwner);
owner = newOwner;
}
}
contract Haltable is Ownable {
bool public halted;
modifier stopInEmergency {
require (!halted);
_;
}
modifier onlyInEmergency {
require (halted);
_;
}
function halt() external onlyOwner {
halted = true;
}
function unhalt() external onlyOwner onlyInEmergency {
halted = false;
}
}
contract HaltableToken is StandardToken, Haltable {
function HaltableToken (address _owner) public {
owner = _owner;
}
function transfer(address _to, uint _value) stopInEmergency public returns (bool success) {
return super.transfer(_to, _value);
}
function transferFrom(address _from, address _to, uint _value) stopInEmergency public returns (bool success) {
return super.transferFrom(_from, _to, _value);
}
function approve(address _spender, uint _value) stopInEmergency public returns (bool success) {
return super.approve(_spender, _value);
}
}
contract UpgradeAgent {
uint public originalSupply;
function isUpgradeAgent() public pure returns (bool) {
return true;
}
function upgradeFrom(address _from, uint256 _value) public;
}
contract UpgradeableToken is StandardToken {
address public upgradeMaster;
UpgradeAgent public upgradeAgent;
uint256 public totalUpgraded;
enum UpgradeState {Unknown, NotAllowed, WaitingForAgent, ReadyToUpgrade, Upgrading}
event Upgrade(address indexed _from, address indexed _to, uint256 _value);
event UpgradeAgentSet(address agent);
function UpgradeableToken(address _upgradeMaster) public {
upgradeMaster = _upgradeMaster;
}
function upgrade(uint256 value) public {
UpgradeState state = getUpgradeState();
if (!(state == UpgradeState.ReadyToUpgrade || state == UpgradeState.Upgrading)) {
revert();
}
if (value == 0) revert();
balances[msg.sender] = SafeMath.sub(balances[msg.sender], value);
totalSupply = SafeMath.sub(totalSupply, value);
totalUpgraded = SafeMath.add(totalUpgraded, value);
upgradeAgent.upgradeFrom(msg.sender, value);
Upgrade(msg.sender, upgradeAgent, value);
}
function setUpgradeAgent(address agent) external {
if (!canUpgrade()) {
revert();
}
if (agent == 0x0) revert();
if (msg.sender != upgradeMaster) revert();
if (getUpgradeState() == UpgradeState.Upgrading) revert();
upgradeAgent = UpgradeAgent(agent);
if(!upgradeAgent.isUpgradeAgent()) revert();
if (upgradeAgent.originalSupply() != totalSupply) revert();
UpgradeAgentSet(upgradeAgent);
}
function getUpgradeState() public constant returns(UpgradeState) {
if(!canUpgrade()) return UpgradeState.NotAllowed;
else if(address(upgradeAgent) == 0x00) return UpgradeState.WaitingForAgent;
else if(totalUpgraded == 0) return UpgradeState.ReadyToUpgrade;
else return UpgradeState.Upgrading;
}
function setUpgradeMaster(address master) public {
require (master != 0x0);
require (msg.sender == upgradeMaster);
upgradeMaster = master;
}
function canUpgrade() public pure returns(bool) {
return true;
}
}
contract CentrallyIssuedToken is BurnableToken, UpgradeableToken, HaltableToken {
string public name;
string public symbol;
uint public decimals;
function CentrallyIssuedToken(address _owner, string _name, string _symbol, uint _totalSupply, uint _decimals) public HaltableToken(_owner) UpgradeableToken(_owner) {
name = _name;
symbol = _symbol;
totalSupply = _totalSupply;
decimals = _decimals;
balances[_owner] = _totalSupply;
}
}