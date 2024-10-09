pragma solidity ^0.4.24;
contract ERC20Basic {
function totalSupply() public view returns (uint256);
function balanceOf(address who) public view returns (uint256);
function transfer(address to, uint256 value) public returns (bool);
event Transfer(address indexed from, address indexed to, uint256 value);
}
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
function balanceOf(address _owner) public view returns (uint256) {
return balances[_owner];
}
}
contract ERC20 is ERC20Basic {
function allowance(address owner, address spender)
public view returns (uint256);
function transferFrom(address from, address to, uint256 value)
public returns (bool);
function approve(address spender, uint256 value) public returns (bool);
event Approval(
address indexed owner,
address indexed spender,
uint256 value
);
}
contract StandardToken is ERC20, BasicToken {
mapping (address => mapping (address => uint256)) internal allowed;
function transferFrom(
address _from,
address _to,
uint256 _value
)
public
returns (bool)
{
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
function allowance(
address _owner,
address _spender
)
public
view
returns (uint256)
{
return allowed[_owner][_spender];
}
function increaseApproval(
address _spender,
uint _addedValue
)
public
returns (bool)
{
allowed[msg.sender][_spender] = (
allowed[msg.sender][_spender].add(_addedValue));
emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
return true;
}
function decreaseApproval(
address _spender,
uint _subtractedValue
)
public
returns (bool)
{
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
contract DetailedERC20 is ERC20 {
string public name;
string public symbol;
uint8 public decimals;
constructor(string _name, string _symbol, uint8 _decimals) public {
name = _name;
symbol = _symbol;
decimals = _decimals;
}
}
contract IST20 is StandardToken, DetailedERC20 {
string public tokenDetails;
function verifyTransfer(address _from, address _to, uint256 _amount) public returns (bool success);
function mint(address _investor, uint256 _amount) public returns (bool success);
function burn(uint256 _value) public;
event Minted(address indexed to, uint256 amount);
event Burnt(address indexed _burner, uint256 _value);
}
contract Ownable {
address public owner;
event OwnershipRenounced(address indexed previousOwner);
event OwnershipTransferred(
address indexed previousOwner,
address indexed newOwner
);
constructor() public {
owner = msg.sender;
}
modifier onlyOwner() {
require(msg.sender == owner);
_;
}
function renounceOwnership() public onlyOwner {
emit OwnershipRenounced(owner);
owner = address(0);
}
function transferOwnership(address _newOwner) public onlyOwner {
_transferOwnership(_newOwner);
}
function _transferOwnership(address _newOwner) internal {
require(_newOwner != address(0));
emit OwnershipTransferred(owner, _newOwner);
owner = _newOwner;
}
}
contract ISecurityToken is IST20, Ownable {
uint8 public constant PERMISSIONMANAGER_KEY = 1;
uint8 public constant TRANSFERMANAGER_KEY = 2;
uint8 public constant STO_KEY = 3;
uint8 public constant CHECKPOINT_KEY = 4;
uint256 public granularity;
uint256 public currentCheckpointId;
uint256 public investorCount;
address[] public investors;
function checkPermission(address _delegate, address _module, bytes32 _perm) public view returns(bool);
function getModule(uint8 _moduleType, uint _moduleIndex) public view returns (bytes32, address);
function getModuleByName(uint8 _moduleType, bytes32 _name) public view returns (bytes32, address);
function totalSupplyAt(uint256 _checkpointId) public view returns(uint256);
function balanceOfAt(address _investor, uint256 _checkpointId) public view returns(uint256);
function createCheckpoint() public returns(uint256);
function getInvestorsLength() public view returns(uint256);
}
contract IModuleFactory is Ownable {
ERC20 public polyToken;
uint256 public setupCost;
uint256 public usageCost;
uint256 public monthlySubscriptionCost;
event LogChangeFactorySetupFee(uint256 _oldSetupcost, uint256 _newSetupCost, address _moduleFactory);
event LogChangeFactoryUsageFee(uint256 _oldUsageCost, uint256 _newUsageCost, address _moduleFactory);
event LogChangeFactorySubscriptionFee(uint256 _oldSubscriptionCost, uint256 _newMonthlySubscriptionCost, address _moduleFactory);
event LogGenerateModuleFromFactory(address _module, bytes32 indexed _moduleName, address indexed _moduleFactory, address _creator, uint256 _timestamp);
constructor (address _polyAddress, uint256 _setupCost, uint256 _usageCost, uint256 _subscriptionCost) public {
polyToken = ERC20(_polyAddress);
setupCost = _setupCost;
usageCost = _usageCost;
monthlySubscriptionCost = _subscriptionCost;
}
function deploy(bytes _data) external returns(address);
function getType() public view returns(uint8);
function getName() public view returns(bytes32);
function getDescription() public view returns(string);
function getTitle() public view returns(string);
function getInstructions() public view returns (string);
function getTags() public view returns (bytes32[]);
function getSig(bytes _data) internal pure returns (bytes4 sig) {
uint len = _data.length < 4 ? _data.length : 4;
for (uint i = 0; i < len; i++) {
sig = bytes4(uint(sig) + uint(_data[i]) * (2 ** (8 * (len - 1 - i))));
}
}
function changeFactorySetupFee(uint256 _newSetupCost) public onlyOwner {
emit LogChangeFactorySetupFee(setupCost, _newSetupCost, address(this));
setupCost = _newSetupCost;
}
function changeFactoryUsageFee(uint256 _newUsageCost) public onlyOwner {
emit LogChangeFactoryUsageFee(usageCost, _newUsageCost, address(this));
usageCost = _newUsageCost;
}
function changeFactorySubscriptionFee(uint256 _newSubscriptionCost) public onlyOwner {
emit LogChangeFactorySubscriptionFee(monthlySubscriptionCost, _newSubscriptionCost, address(this));
monthlySubscriptionCost = _newSubscriptionCost;
}
}
contract IModule {
address public factory;
address public securityToken;
bytes32 public constant FEE_ADMIN = "FEE_ADMIN";
ERC20 public polyToken;
constructor (address _securityToken, address _polyAddress) public {
securityToken = _securityToken;
factory = msg.sender;
polyToken = ERC20(_polyAddress);
}
function getInitFunction() public pure returns (bytes4);
modifier withPerm(bytes32 _perm) {
bool isOwner = msg.sender == ISecurityToken(securityToken).owner();
bool isFactory = msg.sender == factory;
require(isOwner||isFactory||ISecurityToken(securityToken).checkPermission(msg.sender, address(this), _perm), "Permission check failed");
_;
}
modifier onlyOwner {
require(msg.sender == ISecurityToken(securityToken).owner(), "Sender is not owner");
_;
}
modifier onlyFactory {
require(msg.sender == factory, "Sender is not factory");
_;
}
modifier onlyFactoryOwner {
require(msg.sender == IModuleFactory(factory).owner(), "Sender is not factory owner");
_;
}
function getPermissions() public view returns(bytes32[]);
function takeFee(uint256 _amount) public withPerm(FEE_ADMIN) returns(bool) {
require(polyToken.transferFrom(address(this), IModuleFactory(factory).owner(), _amount), "Unable to take fee");
return true;
}
}
contract ICheckpoint is IModule {
}
library Math {
function max64(uint64 a, uint64 b) internal pure returns (uint64) {
return a >= b ? a : b;
}
function min64(uint64 a, uint64 b) internal pure returns (uint64) {
return a < b ? a : b;
}
function max256(uint256 a, uint256 b) internal pure returns (uint256) {
return a >= b ? a : b;
}
function min256(uint256 a, uint256 b) internal pure returns (uint256) {
return a < b ? a : b;
}
}
contract EtherDividendCheckpoint is ICheckpoint {
using SafeMath for uint256;
bytes32 public constant DISTRIBUTE = "DISTRIBUTE";
struct Dividend {
uint256 checkpointId;
uint256 created;
uint256 maturity;
uint256 expiry;
uint256 amount;
uint256 claimedAmount;
uint256 totalSupply;
bool reclaimed;
mapping (address => bool) claimed;
}
Dividend[] public dividends;
event EtherDividendDeposited(address indexed _depositor, uint256 _checkpointId, uint256 _created, uint256 _maturity, uint256 _expiry, uint256 _amount, uint256 _totalSupply, uint256 _dividendIndex);
event EtherDividendClaimed(address indexed _payee, uint256 _dividendIndex, uint256 _amount);
event EtherDividendReclaimed(address indexed _claimer, uint256 _dividendIndex, uint256 _claimedAmount);
event EtherDividendClaimFailed(address indexed _payee, uint256 _dividendIndex, uint256 _amount);
modifier validDividendIndex(uint256 _dividendIndex) {
require(_dividendIndex < dividends.length, "Incorrect dividend index");
require(now >= dividends[_dividendIndex].maturity, "Dividend maturity is in the future");
require(now < dividends[_dividendIndex].expiry, "Dividend expiry is in the past");
require(!dividends[_dividendIndex].reclaimed, "Dividend has been reclaimed by issuer");
_;
}
constructor (address _securityToken, address _polyAddress) public
IModule(_securityToken, _polyAddress)
{
}
function getInitFunction() public pure returns (bytes4) {
return bytes4(0);
}
function createDividend(uint256 _maturity, uint256 _expiry) payable public onlyOwner {
require(_expiry > _maturity);
require(_expiry > now);
require(msg.value > 0);
uint256 dividendIndex = dividends.length;
uint256 checkpointId = ISecurityToken(securityToken).createCheckpoint();
uint256 currentSupply = ISecurityToken(securityToken).totalSupply();
dividends.push(
Dividend(
checkpointId,
now,
_maturity,
_expiry,
msg.value,
0,
currentSupply,
false
)
);
emit EtherDividendDeposited(msg.sender, checkpointId, now, _maturity, _expiry, msg.value, currentSupply, dividendIndex);
}
function createDividendWithCheckpoint(uint256 _maturity, uint256 _expiry, uint256 _checkpointId) payable public onlyOwner {
require(_expiry > _maturity);
require(_expiry > now);
require(msg.value > 0);
require(_checkpointId <= ISecurityToken(securityToken).currentCheckpointId());
uint256 dividendIndex = dividends.length;
uint256 currentSupply = ISecurityToken(securityToken).totalSupplyAt(_checkpointId);
dividends.push(
Dividend(
_checkpointId,
now,
_maturity,
_expiry,
msg.value,
0,
currentSupply,
false
)
);
emit EtherDividendDeposited(msg.sender, _checkpointId, now, _maturity, _expiry, msg.value, currentSupply, dividendIndex);
}
function pushDividendPaymentToAddresses(uint256 _dividendIndex, address[] _payees) public withPerm(DISTRIBUTE) validDividendIndex(_dividendIndex) {
Dividend storage dividend = dividends[_dividendIndex];
for (uint256 i = 0; i < _payees.length; i++) {
if (!dividend.claimed[_payees[i]]) {
_payDividend(_payees[i], dividend, _dividendIndex);
}
}
}
function pushDividendPayment(uint256 _dividendIndex, uint256 _start, uint256 _iterations) public withPerm(DISTRIBUTE) validDividendIndex(_dividendIndex) {
Dividend storage dividend = dividends[_dividendIndex];
uint256 numberInvestors = ISecurityToken(securityToken).getInvestorsLength();
for (uint256 i = _start; i < Math.min256(numberInvestors, _start.add(_iterations)); i++) {
address payee = ISecurityToken(securityToken).investors(i);
if (!dividend.claimed[payee]) {
_payDividend(payee, dividend, _dividendIndex);
}
}
}
function pullDividendPayment(uint256 _dividendIndex) public validDividendIndex(_dividendIndex)
{
Dividend storage dividend = dividends[_dividendIndex];
require(!dividend.claimed[msg.sender], "Dividend already reclaimed");
_payDividend(msg.sender, dividend, _dividendIndex);
}
function _payDividend(address _payee, Dividend storage _dividend, uint256 _dividendIndex) internal {
uint256 claim = calculateDividend(_dividendIndex, _payee);
_dividend.claimed[_payee] = true;
_dividend.claimedAmount = claim.add(_dividend.claimedAmount);
if (claim > 0) {
if (_payee.send(claim)) {
emit EtherDividendClaimed(_payee, _dividendIndex, claim);
} else {
_dividend.claimed[_payee] = false;
emit EtherDividendClaimFailed(_payee, _dividendIndex, claim);
}
}
}
function reclaimDividend(uint256 _dividendIndex) public onlyOwner {
require(_dividendIndex < dividends.length, "Incorrect dividend index");
require(now >= dividends[_dividendIndex].expiry, "Dividend expiry is in the future");
require(!dividends[_dividendIndex].reclaimed, "Dividend already claimed");
Dividend storage dividend = dividends[_dividendIndex];
dividend.reclaimed = true;
uint256 remainingAmount = dividend.amount.sub(dividend.claimedAmount);
msg.sender.transfer(remainingAmount);
emit EtherDividendReclaimed(msg.sender, _dividendIndex, remainingAmount);
}
function calculateDividend(uint256 _dividendIndex, address _payee) public view returns(uint256) {
Dividend storage dividend = dividends[_dividendIndex];
if (dividend.claimed[_payee]) {
return 0;
}
uint256 balance = ISecurityToken(securityToken).balanceOfAt(_payee, dividend.checkpointId);
return balance.mul(dividend.amount).div(dividend.totalSupply);
}
function getDividendIndex(uint256 _checkpointId) public view returns(uint256[]) {
uint256 counter = 0;
for(uint256 i = 0; i < dividends.length; i++) {
if (dividends[i].checkpointId == _checkpointId) {
counter++;
}
}
uint256[] memory index = new uint256[](counter);
counter = 0;
for(uint256 j = 0; j < dividends.length; j++) {
if (dividends[j].checkpointId == _checkpointId) {
index[counter] = j;
counter++;
}
}
return index;
}
function getPermissions() public view returns(bytes32[]) {
bytes32[] memory allPermissions = new bytes32[](1);
allPermissions[0] = DISTRIBUTE;
return allPermissions;
}
}
contract EtherDividendCheckpointFactory is IModuleFactory {
constructor (address _polyAddress, uint256 _setupCost, uint256 _usageCost, uint256 _subscriptionCost) public
IModuleFactory(_polyAddress, _setupCost, _usageCost, _subscriptionCost)
{
}
if(setupCost > 0)
require(polyToken.transferFrom(msg.sender, owner, setupCost), "Failed transferFrom because of sufficent Allowance is not provided");
return address(new EtherDividendCheckpoint(msg.sender, address(polyToken)));
}
function getType() public view returns(uint8) {
return 4;
}
function getName() public view returns(bytes32) {
return "EtherDividendCheckpoint";
}
function getDescription() public view returns(string) {
return "Create ETH dividends for token holders at a specific checkpoint";
}
function getTitle() public  view returns(string) {
return "Ether Dividend Checkpoint";
}
function getInstructions() public view returns(string) {
return "Create a dividend which will be paid out to token holders proportional to their balances at the point the dividend is created";
}
function getTags() public view returns(bytes32[]) {
bytes32[] memory availableTags = new bytes32[](3);
availableTags[0] = "ETH";
availableTags[1] = "Checkpoint";
availableTags[2] = "Dividend";
return availableTags;
}
}