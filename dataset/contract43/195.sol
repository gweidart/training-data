pragma solidity ^0.4.18;
contract SafeMath {
function safeMul(uint256 a, uint256 b) internal pure returns (uint256) {
uint256 c = a * b;
assert(a == 0 || c / a == b);
return c;
}
function safeDiv(uint256 a, uint256 b) internal pure returns (uint256) {
assert(b > 0);
uint256 c = a / b;
assert(a == b * c + a % b);
return c;
}
function safeSub(uint256 a, uint256 b) internal pure returns (uint256) {
assert(b <= a);
return a - b;
}
function safeAdd(uint256 a, uint256 b) internal pure returns (uint256) {
uint256 c = a + b;
assert(c >= a && c >= b);
return c;
}
}
contract StandardToken is SafeMath {
uint256 public totalSupply;
mapping(address => uint) balances;
mapping (address => mapping (address => uint)) allowed;
event Transfer(address indexed from, address indexed to, uint256 value);
event Approval(address indexed owner, address indexed spender, uint256 value);
modifier onlyPayloadSize(uint256 size) {
require(msg.data.length == size + 4);
_;
}
function transfer(address _to, uint256 _value) onlyPayloadSize(2 * 32) public returns (bool success) {
require(_to != 0);
uint256 balanceFrom = balances[msg.sender];
require(_value <= balanceFrom);
balances[msg.sender] = safeSub(balanceFrom, _value);
balances[_to] = safeAdd(balances[_to], _value);
Transfer(msg.sender, _to, _value);
return true;
}
function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
require(_to != 0);
uint256 allowToTrans = allowed[_from][msg.sender];
uint256 balanceFrom = balances[_from];
require(_value <= balanceFrom);
require(_value <= allowToTrans);
balances[_to] = safeAdd(balances[_to], _value);
balances[_from] = safeSub(balanceFrom, _value);
allowed[_from][msg.sender] = safeSub(allowToTrans, _value);
Transfer(_from, _to, _value);
return true;
}
function balanceOf(address _owner) public view returns (uint256 balance) {
return balances[_owner];
}
function approve(address _spender, uint256 _value) public returns (bool success) {
allowed[msg.sender][_spender] = _value;
Approval(msg.sender, _spender, _value);
return true;
}
function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
return allowed[_owner][_spender];
}
function addApproval(address _spender, uint256 _addedValue)
onlyPayloadSize(2 * 32)
public returns (bool success) {
uint256 oldValue = allowed[msg.sender][_spender];
allowed[msg.sender][_spender] = safeAdd(oldValue, _addedValue);
Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
return true;
}
function subApproval(address _spender, uint256 _subtractedValue)
onlyPayloadSize(2 * 32)
public returns (bool success) {
uint256 oldVal = allowed[msg.sender][_spender];
if (_subtractedValue > oldVal) {
allowed[msg.sender][_spender] = 0;
} else {
allowed[msg.sender][_spender] = safeSub(oldVal, _subtractedValue);
}
Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
return true;
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
function transferOwnership(address newOwner) onlyOwner public {
require(newOwner != address(0));
OwnershipTransferred(owner, newOwner);
owner = newOwner;
}
}
contract MigrationAgent {
function migrateFrom(address _from, uint256 _value) public;
}
contract UpgradeableToken is Ownable, StandardToken {
address public migrationAgent;
event Upgrade(address indexed from, address indexed to, uint256 value);
event UpgradeAgentSet(address agent);
function migrate() public {
require(migrationAgent != 0);
uint value = balances[msg.sender];
balances[msg.sender] = safeSub(balances[msg.sender], value);
totalSupply = safeSub(totalSupply, value);
MigrationAgent(migrationAgent).migrateFrom(msg.sender, value);
Upgrade(msg.sender, migrationAgent, value);
}
function () public payable {
require(migrationAgent != 0);
require(balances[msg.sender] > 0);
migrate();
msg.sender.transfer(msg.value);
}
function setMigrationAgent(address _agent) onlyOwner external {
migrationAgent = _agent;
UpgradeAgentSet(_agent);
}
}
contract SixtyNine is UpgradeableToken {
event Mint(address indexed to, uint256 amount);
event MintFinished();
address public allTokenOwnerOnStart;
string public constant name = "SixtyNine";
string public constant symbol = "SXN";
uint256 public constant decimals = 6;
function SixtyNine() public {
allTokenOwnerOnStart = msg.sender;
totalSupply = 100000000000000;
balances[allTokenOwnerOnStart] = totalSupply;
Mint(allTokenOwnerOnStart, totalSupply);
Transfer(0x0, allTokenOwnerOnStart ,totalSupply);
MintFinished();
}
}
contract IcoSixtyNine is Ownable, SafeMath {
address public wallet;
address public allTokenAddress;
bool public emergencyFlagAndHiddenCap = false;
uint256 public startTime = 1514441340;
uint256 public endTime =   1516849740;
uint256 public USDto1ETH = 695;
uint256 public price;
uint256 public totalTokensSold = 0;
uint256 public constant maxTokensToSold = 40000000000000;
SixtyNine public token;
function IcoSixtyNine(address _wallet, SixtyNine _token) public {
wallet = _wallet;
token = _token;
allTokenAddress = token.allTokenOwnerOnStart();
price = 1 ether / USDto1ETH / 1000000;
}
function () public payable {
require(now <= endTime && now >= startTime);
require(!emergencyFlagAndHiddenCap);
require(totalTokensSold < maxTokensToSold);
uint256 value = msg.value;
uint256 tokensToSend = safeDiv(value, price);
require(tokensToSend >= 1000000 && tokensToSend <= 250000000000);
uint256 valueToReturn = safeSub(value, tokensToSend * price);
uint256 valueToWallet = safeSub(value, valueToReturn);
wallet.transfer(valueToWallet);
if (valueToReturn > 0) {
msg.sender.transfer(valueToReturn);
}
token.transferFrom(allTokenAddress, msg.sender, tokensToSend);
totalTokensSold += tokensToSend;
}
function ChangeUSDto1ETH(uint256 _USDto1ETH) onlyOwner public {
USDto1ETH = _USDto1ETH;
ChangePrice();
}
function ChangePrice() onlyOwner public {
uint256 priceWeiToUSD = 1 ether / USDto1ETH;
uint256 price1mToken = priceWeiToUSD / 1000000;
if ( now <= startTime + 69 hours) {
price = price1mToken * 1/4 ;
}
else {
if ( now <= startTime + 333 hours ) {
price = price1mToken * 55/100 ;
}else
if ( now <= startTime + 333 hours ) {
price = price1mToken * 155/100 ;
}
else {
price = price1mToken * 25 / 10;
}
}
}
function ChangeStart(uint _startTime) onlyOwner public {
startTime = _startTime;
}
function ChangeEnd(uint _endTime) onlyOwner public {
endTime = _endTime;
}
function emergencyAndHiddenCapToggle() onlyOwner public {
emergencyFlagAndHiddenCap = !emergencyFlagAndHiddenCap;
}
}