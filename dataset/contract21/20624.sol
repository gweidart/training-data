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
contract AbstractCon {
function allowance(address _owner, address _spender)  public pure returns (uint256 remaining);
function transferFrom(address _from, address _to, uint256 _value) public  returns (bool success);
function decimals() public returns (uint8);
}
contract EXOTokenSale is Ownable {
using SafeMath for uint256;
string public constant name = "EXO_TOKEN_SALE";
enum StageName {Pause, PreSale, Sale, Ended, Refund}
struct StageProperties {
uint256 planEndDate;
address tokenKeeper;
}
StageName public currentStage;
mapping(uint8   => StageProperties) public campaignStages;
mapping(address => uint256)         public deposited;
uint256 public weiRaised=0;
uint256 public token_rate=1600;
uint256 public minimum_token_sell=1000;
uint256 public softCap=1042*10**18;
uint256 public hardCap=52083*10**18;
address public wallet ;
address public ERC20address;
event Income(address from, uint256 amount, uint64 timestamp);
event NewTokenRate(uint256 rate);
event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 weivalue, uint256 tokens);
event FundsWithdraw(address indexed who, uint256 amount , uint64 timestamp);
event Refunded(address investor, uint256 depositedValue);
function EXOTokenSale(address _wallet, address _preSaleTokenKeeper , address _SaleTokenKeeper) public {
require(_wallet != address(0));
wallet = _wallet;
campaignStages[uint8(StageName.PreSale)] = StageProperties(1525132800, _preSaleTokenKeeper);
campaignStages[uint8(StageName.Sale)]    = StageProperties(1535760000, _SaleTokenKeeper);
currentStage = StageName.Pause;
}
function() public payable {
exchangeEtherOnTokens(msg.sender);
}
function exchangeEtherOnTokens(address beneficiary) public payable  {
emit Income(msg.sender, msg.value, uint64(now));
require(currentStage == StageName.PreSale || currentStage == StageName.Sale);
uint256 weiAmount = msg.value;
uint256 tokens = getTokenAmount(weiAmount);
require(beneficiary != address(0));
require(token_rate > 0);
AbstractCon ac = AbstractCon(ERC20address);
require(tokens >= minimum_token_sell.mul(10 ** uint256(ac.decimals())));
require(ac.transferFrom(campaignStages[uint8(currentStage)].tokenKeeper, beneficiary, tokens));
checkCurrentStage();
weiRaised = weiRaised.add(weiAmount);
deposited[beneficiary] = deposited[beneficiary].add(weiAmount);
emit TokenPurchase(msg.sender, beneficiary, msg.value, tokens);
if (weiRaised >= softCap)
withdrawETH();
}
function checkCurrentStage() internal {
if  (campaignStages[uint8(currentStage)].planEndDate <= now) {
if  (currentStage == StageName.PreSale
&& (weiRaised + msg.value) < softCap
) {
currentStage = StageName.Refund;
return;
}
currentStage = StageName.Pause;
}
if (currentStage == StageName.Sale
&& (weiRaised + msg.value) >= hardCap
) {
currentStage = StageName.Ended;
}
}
function getTokenAmount(uint256 weiAmount) internal view returns(uint256) {
return weiAmount.mul(token_rate);
}
function withdrawETH() internal {
emit FundsWithdraw(wallet, this.balance, uint64(now));
wallet.transfer(this.balance);
}
function setCurrentStage(StageName _name) external onlyOwner  {
currentStage = _name;
}
function setStageProperties(
StageName _name,
uint256 _planEndDate,
address _tokenKeeper
) external onlyOwner {
campaignStages[uint8(_name)] = StageProperties(_planEndDate, _tokenKeeper);
}
function setERC20address(address newERC20contract)  external onlyOwner {
require(address(newERC20contract) != 0);
AbstractCon ac = AbstractCon(newERC20contract);
require(ac.allowance(campaignStages[uint8(currentStage)].tokenKeeper, address(this))>0);
ERC20address = newERC20contract;
}
function refund(address investor) external {
require(currentStage == StageName.Refund);
require(investor != address(0));
assert(msg.data.length >= 32 + 4);
uint256 depositedValue = deposited[investor];
deposited[investor] = 0;
investor.transfer(depositedValue);
emit Refunded(investor, depositedValue);
}
function setTokenRate(uint256 newRate) external onlyOwner {
token_rate = newRate;
emit NewTokenRate(newRate);
}
function setSoftCap(uint256 _val) external onlyOwner {
softCap = _val;
}
function setHardCap(uint256 _val) external onlyOwner {
hardCap = _val;
}
function setMinimumTokenSell(uint256 newNumber) external onlyOwner {
minimum_token_sell = newNumber;
}
function setWallet(address _wallet) external onlyOwner {
wallet = _wallet;
}
function destroy()  external onlyOwner {
if  (weiRaised >= softCap)
selfdestruct(owner);
}
}