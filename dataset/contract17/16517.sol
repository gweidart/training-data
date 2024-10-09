pragma solidity ^0.4.18;
contract ERC20Basic {
function totalSupply() public view returns (uint256);
function balanceOf(address who) public view returns (uint256);
function transfer(address to, uint256 value) public returns (bool);
event Transfer(address indexed from, address indexed to, uint256 value);
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
contract Pausable is Ownable {
event Pause();
event Unpause();
bool public paused = false;
modifier whenNotPaused() {
require(!paused);
_;
}
modifier whenPaused() {
require(paused);
_;
}
function pause() onlyOwner whenNotPaused public {
paused = true;
Pause();
}
function unpause() onlyOwner whenPaused public {
paused = false;
Unpause();
}
}
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
mapping (address => mapping (address => uint256)) internal allowed;
function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
require(_to != address(0));
require(_value <= balances[_from]);
require(_value <= allowed[_from][msg.sender]);
balances[_from] = balances[_from].sub(_value);
balances[_to] = balances[_to].add(_value);
allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
Transfer(_from, _to, _value);
return true;
}
function approve(address _spender, uint256 _value) public returns (bool) {
allowed[msg.sender][_spender] = _value;
Approval(msg.sender, _spender, _value);
return true;
}
function allowance(address _owner, address _spender) public view returns (uint256) {
return allowed[_owner][_spender];
}
function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
return true;
}
function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
uint oldValue = allowed[msg.sender][_spender];
if (_subtractedValue > oldValue) {
allowed[msg.sender][_spender] = 0;
} else {
allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
}
Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
return true;
}
}
contract BurnableToken is BasicToken {
event Burn(address indexed burner, uint256 value);
function burn(uint256 _value) public {
require(_value <= balances[msg.sender]);
address burner = msg.sender;
balances[burner] = balances[burner].sub(_value);
totalSupply_ = totalSupply_.sub(_value);
Burn(burner, _value);
}
}
contract UIWish is StandardToken, BurnableToken, Ownable {
string  public constant name = "UIWish";
string  public constant symbol = "UI";
uint8   public constant decimals = 18;
string  public website = "www.ui-wish.com";
uint256 public constant INITIAL_SUPPLY      =  24680000 * (10 ** uint256(decimals));
uint256 public constant CROWDSALE_ALLOWANCE =  12340000 * (10 ** uint256(decimals));
uint256 public constant ADMIN_ALLOWANCE     =  12340000 * (10 ** uint256(decimals));
uint256 public totalSupply;
uint256 public crowdSaleAllowance;
uint256 public adminAllowance;
address public crowdSaleAddr;
address public adminAddr;
bool    public transferEnabled = true;
modifier validDestination(address _to) {
require(_to != address(0x0));
require(_to != address(this));
require(_to != owner);
require(_to != address(adminAddr));
require(_to != address(crowdSaleAddr));
_;
}
function UIWish(address _admin) public {
require(msg.sender != _admin);
totalSupply = INITIAL_SUPPLY;
crowdSaleAllowance = CROWDSALE_ALLOWANCE;
adminAllowance = ADMIN_ALLOWANCE;
balances[msg.sender] = totalSupply.sub(adminAllowance);
Transfer(address(0x0), msg.sender, totalSupply.sub(adminAllowance));
balances[_admin] = adminAllowance;
Transfer(address(0x0), _admin, adminAllowance);
adminAddr = _admin;
approve(adminAddr, adminAllowance);
}
function setCrowdsale(address _crowdSaleAddr, uint256 _amountForSale) external onlyOwner {
require(_amountForSale <= crowdSaleAllowance);
uint amount = (_amountForSale == 0) ? crowdSaleAllowance : _amountForSale;
approve(crowdSaleAddr, 0);
approve(_crowdSaleAddr, amount);
crowdSaleAddr = _crowdSaleAddr;
}
function transfer(address _to, uint256 _value) public validDestination(_to) returns (bool) {
return super.transfer(_to, _value);
}
function transferFrom(address _from, address _to, uint256 _value) public validDestination(_to) returns (bool) {
bool result = super.transferFrom(_from, _to, _value);
if (result) {
if (msg.sender == crowdSaleAddr)
crowdSaleAllowance = crowdSaleAllowance.sub(_value);
if (msg.sender == adminAddr)
adminAllowance = adminAllowance.sub(_value);
}
return result;
}
function burn(uint256 _value) public {
require(transferEnabled || msg.sender == owner);
super.burn(_value);
Transfer(msg.sender, address(0x0), _value);
}
function changeWebsite(string _website) external onlyOwner {website = _website;}
}
contract UIWishSale is Pausable {
using SafeMath for uint256;
address public beneficiary;
uint public fundingGoal;
uint public fundingCap;
uint public minContribution;
bool public fundingGoalReached = false;
bool public fundingCapReached = false;
bool public saleClosed = false;
uint public startTime;
uint public endTime;
uint public amountRaised;
uint public refundAmount;
uint public rate = 270;
uint public constant LOW_RANGE_RATE = 1;
uint public constant HIGH_RANGE_RATE = 30000;
bool private rentrancy_lock = false;
UIWish public tokenReward;
mapping(address => uint256) public balanceOf;
mapping(address => uint256) public contributions;
uint public maxUserContribution = 20 * 1 ether;
event GoalReached(address _beneficiary, uint _amountRaised);
event CapReached(address _beneficiary, uint _amountRaised);
event FundTransfer(address _backer, uint _amount, bool _isContribution);
modifier beforeDeadline()   { require (currentTime() < endTime); _; }
modifier afterDeadline()    { require (currentTime() >= endTime); _; }
modifier afterStartTime()    { require (currentTime() >= startTime); _; }
modifier saleNotClosed()    { require (!saleClosed); _; }
modifier nonReentrant() {
require(!rentrancy_lock);
rentrancy_lock = true;
_;
rentrancy_lock = false;
}
function UIWishSale(
address ifSuccessfulSendTo,
uint fundingGoalInEthers,
uint fundingCapInEthers,
uint minimumContributionInWei,
uint start,
uint end,
uint rateUIToEther,
address addressOfTokenUsedAsReward
) public {
require(ifSuccessfulSendTo != address(0) && ifSuccessfulSendTo != address(this));
require(addressOfTokenUsedAsReward != address(0) && addressOfTokenUsedAsReward != address(this));
require(fundingGoalInEthers <= fundingCapInEthers);
require(end > 0);
beneficiary = ifSuccessfulSendTo;
fundingGoal = fundingGoalInEthers * 1 ether;
fundingCap = fundingCapInEthers * 1 ether;
minContribution = minimumContributionInWei;
startTime = start;
endTime = end;
setRate(rateUIToEther);
tokenReward = UIWish(addressOfTokenUsedAsReward);
}
function () public payable whenNotPaused beforeDeadline afterStartTime saleNotClosed nonReentrant {
require(msg.value >= minContribution);
require(contributions[msg.sender].add(msg.value) <= maxUserContribution);
uint amount = msg.value;
uint currentBalance = balanceOf[msg.sender];
balanceOf[msg.sender] = currentBalance.add(amount);
amountRaised = amountRaised.add(amount);
uint numTokens = amount.mul(rate);
if (tokenReward.transferFrom(tokenReward.owner(), msg.sender, numTokens)) {
FundTransfer(msg.sender, amount, true);
contributions[msg.sender] = contributions[msg.sender].add(amount);
checkFundingGoal();
checkFundingCap();
}
else {
revert();
}
}
function terminate() external onlyOwner {
saleClosed = true;
}
function setRate(uint _rate) public onlyOwner {
require(_rate >= LOW_RANGE_RATE && _rate <= HIGH_RANGE_RATE);
rate = _rate;
}
function ownerAllocateTokens(address _to, uint amountWei, uint amountMiniUI) external
onlyOwner nonReentrant
{
if (!tokenReward.transferFrom(tokenReward.owner(), _to, amountMiniUI)) {
revert();
}
balanceOf[_to] = balanceOf[_to].add(amountWei);
amountRaised = amountRaised.add(amountWei);
FundTransfer(_to, amountWei, true);
checkFundingGoal();
checkFundingCap();
}
function ownerSafeWithdrawal() external onlyOwner nonReentrant {
require(fundingGoalReached);
uint balanceToSend = this.balance;
beneficiary.transfer(balanceToSend);
FundTransfer(beneficiary, balanceToSend, false);
}
function ownerUnlockFund() external afterDeadline onlyOwner {
fundingGoalReached = false;
}
function safeWithdrawal() external afterDeadline nonReentrant {
if (!fundingGoalReached) {
uint amount = balanceOf[msg.sender];
balanceOf[msg.sender] = 0;
if (amount > 0) {
msg.sender.transfer(amount);
FundTransfer(msg.sender, amount, false);
refundAmount = refundAmount.add(amount);
}
}
}
function checkFundingGoal() internal {
if (!fundingGoalReached) {
if (amountRaised >= fundingGoal) {
fundingGoalReached = true;
GoalReached(beneficiary, amountRaised);
}
}
}
function checkFundingCap() internal {
if (!fundingCapReached) {
if (amountRaised >= fundingCap) {
fundingCapReached = true;
saleClosed = true;
CapReached(beneficiary, amountRaised);
}
}
}
function currentTime() public constant returns (uint _currentTime) {
return now;
}
function convertToMiniUI(uint amount) internal constant returns (uint) {
return amount * (10 ** uint(tokenReward.decimals()));
}
function changeStartTime(uint256 _startTime) external onlyOwner {startTime = _startTime;}
function changeEndTime(uint256 _endTime) external onlyOwner {endTime = _endTime;}
}