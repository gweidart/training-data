pragma solidity ^0.4.23;
interface ERC20 {
function totalSupply() external view returns (uint supply);
function balanceOf(address _owner) external view returns (uint balance);
function transfer(address _to, uint _value) external returns (bool success);
function transferFrom(address _from, address _to, uint _value) external returns (bool success);
function approve(address _spender, uint _value) external returns (bool success);
function allowance(address _owner, address _spender) external view returns (uint remaining);
function decimals() external view returns(uint digits);
event Approval(address indexed _owner, address indexed _spender, uint _value);
}
contract PermissionGroups {
address public admin;
address public pendingAdmin;
mapping(address=>bool) internal operators;
mapping(address=>bool) internal alerters;
address[] internal operatorsGroup;
address[] internal alertersGroup;
uint constant internal MAX_GROUP_SIZE = 50;
constructor(address _admin) public {
admin = _admin;
}
modifier onlyAdmin() {
require(msg.sender == admin);
_;
}
modifier onlyOperator() {
require(operators[msg.sender]);
_;
}
modifier onlyAlerter() {
require(alerters[msg.sender]);
_;
}
function getOperators () external view returns(address[]) {
return operatorsGroup;
}
function getAlerters () external view returns(address[]) {
return alertersGroup;
}
event TransferAdminPending(address pendingAdmin);
function transferAdmin(address newAdmin) public onlyAdmin {
require(newAdmin != address(0));
emit TransferAdminPending(pendingAdmin);
pendingAdmin = newAdmin;
}
function transferAdminQuickly(address newAdmin) public onlyAdmin {
require(newAdmin != address(0));
emit TransferAdminPending(newAdmin);
emit AdminClaimed(newAdmin, admin);
admin = newAdmin;
}
event AdminClaimed( address newAdmin, address previousAdmin);
function claimAdmin() public {
require(pendingAdmin == msg.sender);
emit AdminClaimed(pendingAdmin, admin);
admin = pendingAdmin;
pendingAdmin = address(0);
}
event AlerterAdded (address newAlerter, bool isAdd);
function addAlerter(address newAlerter) public onlyAdmin {
require(!alerters[newAlerter]);
require(alertersGroup.length < MAX_GROUP_SIZE);
emit AlerterAdded(newAlerter, true);
alerters[newAlerter] = true;
alertersGroup.push(newAlerter);
}
function removeAlerter (address alerter) public onlyAdmin {
require(alerters[alerter]);
alerters[alerter] = false;
for (uint i = 0; i < alertersGroup.length; ++i) {
if (alertersGroup[i] == alerter) {
alertersGroup[i] = alertersGroup[alertersGroup.length - 1];
alertersGroup.length--;
emit AlerterAdded(alerter, false);
break;
}
}
}
event OperatorAdded(address newOperator, bool isAdd);
function addOperator(address newOperator) public onlyAdmin {
require(!operators[newOperator]);
require(operatorsGroup.length < MAX_GROUP_SIZE);
emit OperatorAdded(newOperator, true);
operators[newOperator] = true;
operatorsGroup.push(newOperator);
}
function removeOperator (address operator) public onlyAdmin {
require(operators[operator]);
operators[operator] = false;
for (uint i = 0; i < operatorsGroup.length; ++i) {
if (operatorsGroup[i] == operator) {
operatorsGroup[i] = operatorsGroup[operatorsGroup.length - 1];
operatorsGroup.length -= 1;
emit OperatorAdded(operator, false);
break;
}
}
}
}
contract Withdrawable is PermissionGroups {
constructor(address _admin) PermissionGroups (_admin) public {}
event TokenWithdraw(ERC20 token, uint amount, address sendTo);
function withdrawToken(ERC20 token, uint amount, address sendTo) external onlyAdmin {
require(token.transfer(sendTo, amount));
emit TokenWithdraw(token, amount, sendTo);
}
event EtherWithdraw(uint amount, address sendTo);
function withdrawEther(uint amount, address sendTo) external onlyAdmin {
sendTo.transfer(amount);
emit EtherWithdraw(amount, sendTo);
}
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
contract IEORate is Withdrawable {
uint public ethToTokenNumerator;
uint public ethToTokenDenominator;
constructor(address admin) Withdrawable(admin) public
{}
event RateSet (uint rateNumerator, uint rateDenominator, address sender);
function setRateEthToToken(uint rateNumerator, uint rateDenominator) public onlyOperator {
require(rateNumerator > 0);
require(rateDenominator > 0);
ethToTokenNumerator = rateNumerator;
ethToTokenDenominator = rateDenominator;
emit RateSet(rateNumerator, rateDenominator, msg.sender);
}
function getRate () public view returns(uint rateNumerator, uint rateDenominator) {
rateNumerator = ethToTokenNumerator;
rateDenominator = ethToTokenDenominator;
}
}
contract CapManager is Withdrawable {
mapping(uint=>uint) public participatedWei;
uint public contributorCapWei;
uint internal IEOId;
uint constant public MAX_PURCHASE_WEI = uint(-1);
uint public cappedIEOStartTime;
uint public openIEOStartTime;
uint public endIEOTime;
using SafeMath for uint;
constructor(uint _cappedIEOTime,
uint _openIEOTime,
uint _endIEOTime,
uint _contributorCapWei,
uint _IEOId,
address _admin)
Withdrawable(_admin)
public
{
require(_cappedIEOTime >= now);
require(_cappedIEOTime <= _openIEOTime);
require(_openIEOTime <= _endIEOTime);
require(_IEOId != 0);
contributorCapWei = _contributorCapWei;
IEOId = _IEOId;
cappedIEOStartTime = _cappedIEOTime;
openIEOStartTime = _openIEOTime;
endIEOTime = _endIEOTime;
}
function getContributorRemainingCap(uint userId) public view returns(uint capWei) {
if (!IEOStarted()) return 0;
if (IEOEnded()) return 0;
if (openIEOStarted()) {
capWei = MAX_PURCHASE_WEI;
} else {
if (participatedWei[userId] >= contributorCapWei) capWei = 0;
else capWei = contributorCapWei.sub(participatedWei[userId]);
}
}
function eligible(uint userID, uint amountWei) public view returns(uint) {
uint remainingCap = getContributorRemainingCap(userID);
if (amountWei > remainingCap) return remainingCap;
return amountWei;
}
event ContributorCapSet(uint capWei, address sender);
function setContributorCap(uint capWei) public onlyAdmin {
contributorCapWei = capWei;
emit ContributorCapSet(capWei, msg.sender);
}
function IEOStarted() public view returns(bool) {
return (now >= cappedIEOStartTime);
}
function openIEOStarted() public view returns(bool) {
return (now >= openIEOStartTime);
}
function IEOEnded() public view returns(bool) {
return (now >= endIEOTime);
}
function validateContributor(address contributor, uint userId, uint8 v, bytes32 r, bytes32 s) public view returns(bool) {
require(verifySignature(keccak256(contributor, userId, IEOId), v, r, s));
return true;
}
function getIEOId() external view returns(uint) {
return IEOId;
}
function eligibleCheckAndIncrement(uint userId, uint amountInWei) internal returns(uint)
{
uint result = eligible(userId, amountInWei);
participatedWei[userId] = participatedWei[userId].add(result);
return result;
}
function verifySignature(bytes32 hash, uint8 v, bytes32 r, bytes32 s) internal view returns(bool) {
address signer = ecrecover(hash, v, r, s);
return operators[signer];
}
}
interface KyberIEOInterface {
function contribute(address contributor, uint userId, uint8 v, bytes32 r, bytes32 s) external payable returns(bool);
function getContributorRemainingCap(uint userId) external view returns(uint capWei);
function getIEOId() external view returns(uint);
}
contract KyberIEO is KyberIEOInterface, CapManager {
mapping(address=>bool) public whiteListedAddresses;
ERC20 public token;
uint  public raisedWei;
uint  public distributedTokensTwei;
bool  public haltedIEO = false;
IEORate public IEORateContract;
address public contributionWallet;
constructor (
address _admin,
address _contributionWallet,
ERC20 _token,
uint _contributorCapWei,
uint _IEOId,
uint _cappedIEOStart,
uint _openIEOStart,
uint _publicIEOEnd)
CapManager(_cappedIEOStart, _openIEOStart, _publicIEOEnd, _contributorCapWei, _IEOId, _admin)
public
{
require(_token != address(0));
require(_contributionWallet != address(0));
IEORateContract = new IEORate(_admin);
contributionWallet = _contributionWallet;
token = _token;
}
event IEOHalted(address sender);
function haltIEO() public onlyAlerter {
haltedIEO = true;
emit IEOHalted(msg.sender);
}
event IEOResumed(address sender);
function resumeIEO() public onlyAdmin {
haltedIEO = false;
emit IEOResumed(msg.sender);
}
event Contribution(address msgSender, address contributor, uint userId, uint distributedTokensTwei, uint payedWei);
function contribute(address contributor, uint userId, uint8 v, bytes32 r, bytes32 s) external payable returns(bool) {
require(!haltedIEO);
require(IEOStarted());
require(!IEOEnded());
require((contributor == msg.sender) || whiteListedAddresses[msg.sender]);
uint rateNumerator;
uint rateDenominator;
(rateNumerator, rateDenominator) = IEORateContract.getRate();
require(rateNumerator > 0);
require(rateDenominator > 0);
require(validateContributor(contributor, userId, v, r, s));
uint weiPayment = eligibleCheckAndIncrement(userId, msg.value);
require(weiPayment > 0);
uint tokenQty = weiPayment.mul(rateNumerator).div(rateDenominator);
require(tokenQty > 0);
if(msg.value > weiPayment) {
msg.sender.transfer(msg.value.sub(weiPayment));
}
sendETHToContributionWallet(weiPayment);
raisedWei = raisedWei.add(weiPayment);
require(token.transfer(contributor, tokenQty));
distributedTokensTwei = distributedTokensTwei.add(tokenQty);
emit Contribution(msg.sender, contributor, userId, tokenQty, weiPayment);
return true;
}
event addressWhiteListed(address _address, bool whiteListed);
function whiteListAddress(address addr, bool whiteListed) public onlyAdmin {
whiteListedAddresses[addr] = whiteListed;
emit addressWhiteListed(addr, whiteListed);
}
function getRate () public view returns(uint rateNumerator, uint rateDenominator) {
(rateNumerator, rateDenominator) = IEORateContract.getRate();
}
function debugBuy() public payable {
require(msg.value == 123);
sendETHToContributionWallet(msg.value);
}
function sendETHToContributionWallet(uint valueWei) internal {
contributionWallet.transfer(valueWei);
}
}
contract ERC20Plus is ERC20 {
function symbol() external view returns(string);
function totalSupply() external view returns(uint);
}
contract KyberIEOGetter {
function getIEOInfo(KyberIEO IEO) public view returns (
uint[3] IEOTimes,
bool[4] IEOStates,
uint[2] rate,
uint[5] amounts,
uint tokenDecimals,
address tokenAddress,
string symbol
)
{
IEOTimes = [IEO.cappedIEOStartTime(), IEO.openIEOStartTime(), IEO.endIEOTime()];
IEOStates = [IEO.IEOStarted(), IEO.openIEOStarted(), IEO.IEOEnded(), IEO.haltedIEO()];
rate = [IEORate(IEO.IEORateContract()).ethToTokenNumerator(), IEORate(IEO.IEORateContract()).ethToTokenDenominator()];
amounts = [IEO.distributedTokensTwei(), IEO.raisedWei(), IEO.contributorCapWei(), 0, IEO.token().totalSupply()];
amounts[3] = IEO.token().balanceOf(address(IEO));
return(IEOTimes, IEOStates, rate, amounts, IEO.token().decimals(), IEO.token(), ERC20Plus(IEO.token()).symbol());
}
function getIEOsInfo(KyberIEO[] IEOs) public view returns(
uint[] distributedTweiPerIEO,
uint[] tokenBalancePerIEO,
address[] tokenAddressPerIEO,
bytes32[] tokenSymbolPerIEO,
uint[] tokenDecimalsPerIEO,
uint[] totalSupplyPerIEO
)
{
distributedTweiPerIEO = new uint[](IEOs.length);
tokenBalancePerIEO = new uint[](IEOs.length);
tokenAddressPerIEO = new address[](IEOs.length);
tokenSymbolPerIEO = new bytes32[](IEOs.length);
tokenDecimalsPerIEO = new uint[](IEOs.length);
totalSupplyPerIEO = new uint[](IEOs.length);
for(uint i = 0; i < IEOs.length; i++) {
distributedTweiPerIEO[i] = IEOs[i].distributedTokensTwei();
tokenBalancePerIEO[i] = IEOs[i].token().balanceOf(address(IEOs[i]));
tokenAddressPerIEO[i] = IEOs[i].token();
tokenSymbolPerIEO[i] = stringToBytes32(ERC20Plus(IEOs[i].token()).symbol());
tokenDecimalsPerIEO[i] = IEOs[i].token().decimals();
totalSupplyPerIEO[i] = IEOs[i].token().totalSupply();
}
}
function stringToBytes32(string memory source) public pure returns (bytes32 result) {
bytes memory tempEmptyStringTest = bytes(source);
if (tempEmptyStringTest.length == 0) {
return 0x0;
}
assembly {
result := mload(add(source, 32))
}
}
}