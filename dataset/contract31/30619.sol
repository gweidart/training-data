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
contract BasicToken is ERC20Basic {
using SafeMath for uint256;
mapping(address => uint256) balances;
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
contract BitkomToken is StandardToken, Ownable {
string  public constant name = "Bitkom Token";
string  public constant symbol = "BTT";
uint8   public constant decimals = 18;
uint256 public constant INITIAL_SUPPLY = 50000000 * 1 ether;
uint256 public constant CROWDSALE_ALLOWANCE =  33500000 * 1 ether;
uint256 public constant TEAM_ALLOWANCE =  16500000 * 1 ether;
uint256 public crowdsaleAllowance;
uint256 public teamAllowance;
address public crowdsaleAddr;
address public teamAddr;
bool    public transferEnabled = false;
modifier onlyWhenTransferEnabled() {
if (!transferEnabled) {
require(msg.sender == teamAddr || msg.sender == crowdsaleAddr);
}
_;
}
event Burn(address indexed burner, uint256 value);
modifier validDestination(address _to) {
require(_to != address(0x0));
require(_to != address(this));
require(_to != owner);
require(_to != address(teamAddr));
require(_to != address(crowdsaleAddr));
_;
}
function BitkomToken(address _team) public {
require(msg.sender != _team);
totalSupply = INITIAL_SUPPLY;
crowdsaleAllowance = CROWDSALE_ALLOWANCE;
teamAllowance = TEAM_ALLOWANCE;
balances[msg.sender] = totalSupply;
Transfer(address(0x0), msg.sender, totalSupply);
teamAddr = _team;
approve(teamAddr, teamAllowance);
}
function setCrowdsale(address _crowdsaleAddr, uint256 _amountForSale) external onlyOwner {
require(!transferEnabled);
require(_amountForSale <= crowdsaleAllowance);
uint amount = (_amountForSale == 0) ? crowdsaleAllowance : _amountForSale;
approve(crowdsaleAddr, 0);
approve(_crowdsaleAddr, amount);
crowdsaleAddr = _crowdsaleAddr;
}
function enableTransfer() external onlyOwner {
transferEnabled = true;
approve(crowdsaleAddr, 0);
approve(teamAddr, 0);
crowdsaleAllowance = 0;
teamAllowance = 0;
}
function transfer(address _to, uint256 _value) public onlyWhenTransferEnabled validDestination(_to) returns (bool) {
return super.transfer(_to, _value);
}
function transferFrom(address _from, address _to, uint256 _value) public onlyWhenTransferEnabled validDestination(_to) returns (bool) {
bool result = super.transferFrom(_from, _to, _value);
if (result) {
if (msg.sender == crowdsaleAddr)
crowdsaleAllowance = crowdsaleAllowance.sub(_value);
if (msg.sender == teamAddr)
teamAllowance = teamAllowance.sub(_value);
}
return result;
}
function burn(uint256 _value) public {
require(_value > 0);
require(_value <= balances[msg.sender]);
require(transferEnabled || msg.sender == owner);
address burner = msg.sender;
balances[burner] = balances[burner].sub(_value);
totalSupply = totalSupply.sub(_value);
Burn(burner, _value);
Transfer(msg.sender, address(0x0), _value);
}
}
contract BitkomSale is Pausable {
using SafeMath for uint256;
uint public constant RATE = 2500;
uint public constant GAS_LIMIT_IN_WEI = 50000000000 wei;
uint public constant MIN_CONTRIBUTION = 0.1 * 1 ether;
uint public constant TOKEN_HARDCAP = 33500000 * 1 ether;
bool public fundingCapReached = false;
bool public tokenHardcapReached = false;
bool public softcapReached = false;
bool public saleClosed = false;
bool private rentrancy_lock = false;
uint public fundingCap;
uint256 public soldTokens = 0;
uint256 public softCapInTokens = 1600000 * 1 ether;
uint public weiRaised;
uint public weiRefunded;
uint public startTime;
uint public deadline;
address public beneficiary;
BitkomToken public tokenReward;
mapping (address => uint256) public balanceOf;
mapping (address => bool) refunded;
event CapReached(address _beneficiary, uint _weiRaised);
event SoftcapReached(address _beneficiary, uint _weiRaised);
event FundTransfer(address _backer, uint _amount, bool _isContribution);
event Refunded(address indexed holder, uint256 amount);
modifier beforeDeadline()   { require (currentTime() < deadline); _; }
modifier afterDeadline()    { require (currentTime() >= deadline); _; }
modifier afterStartTime()   { require (currentTime() >= startTime); _; }
modifier saleNotClosed()    { require (!saleClosed); _; }
modifier softCapRaised()    { require (softcapReached); _; }
modifier nonReentrant() {
require(!rentrancy_lock);
rentrancy_lock = true;
_;
rentrancy_lock = false;
}
function BitkomSale(
address ifSuccessfulSendTo,
uint256 fundingCapInEthers,
uint256 start,
uint256 durationInDays,
address addressOfTokenUsedAsReward
) public
{
require(ifSuccessfulSendTo != address(0) && ifSuccessfulSendTo != address(this));
require(addressOfTokenUsedAsReward != address(0) && addressOfTokenUsedAsReward != address(this));
require(durationInDays > 0);
beneficiary = ifSuccessfulSendTo;
fundingCap = fundingCapInEthers * 1 ether;
startTime = start;
deadline = start + (durationInDays * 1 days);
tokenReward = BitkomToken(addressOfTokenUsedAsReward);
}
function () public payable {
buy();
}
function buy()
payable
public
whenNotPaused
beforeDeadline
afterStartTime
saleNotClosed
nonReentrant
{
uint amount = msg.value;
require(amount >= MIN_CONTRIBUTION);
weiRaised = weiRaised.add(amount);
if (weiRaised > fundingCap) {
uint overflow = weiRaised.sub(fundingCap);
amount = amount.sub(overflow);
weiRaised = fundingCap;
msg.sender.transfer(overflow);
}
uint256 bonus = calculateBonus();
uint256 tokensAmountForUser = (amount.mul(RATE)).mul(bonus);
soldTokens = soldTokens.add(tokensAmountForUser);
if (soldTokens > TOKEN_HARDCAP) {
uint256 overflowInTokens = soldTokens.sub(TOKEN_HARDCAP);
uint256 overflowInWei = (overflowInTokens.div(bonus)).div(RATE);
amount = amount.sub(overflowInWei);
weiRaised = weiRaised.sub(overflowInWei);
msg.sender.transfer(overflowInWei);
tokensAmountForUser = tokensAmountForUser.sub(overflowInTokens);
soldTokens = TOKEN_HARDCAP;
}
balanceOf[msg.sender] = balanceOf[msg.sender].add(amount);
if (!tokenReward.transferFrom(tokenReward.owner(), msg.sender, tokensAmountForUser)) {
revert();
}
FundTransfer(msg.sender, amount, true);
if (soldTokens >= softCapInTokens && !softcapReached) {
softcapReached = true;
SoftcapReached(beneficiary, weiRaised);
}
checkCaps();
}
function terminate() external onlyOwner {
saleClosed = true;
}
function ownerSafeWithdrawal() external onlyOwner softCapRaised nonReentrant {
uint balanceToSend = this.balance;
beneficiary.transfer(balanceToSend);
FundTransfer(beneficiary, balanceToSend, false);
}
function checkCaps() internal {
if (weiRaised == fundingCap) {
fundingCapReached = true;
saleClosed = true;
CapReached(beneficiary, weiRaised);
}
if (soldTokens == TOKEN_HARDCAP) {
tokenHardcapReached = true;
saleClosed = true;
CapReached(beneficiary, weiRaised);
}
}
function currentTime() internal constant returns (uint _currentTime) {
return now;
}
function calculateBonus() internal constant returns (uint) {
if (soldTokens >= 0 && soldTokens <= 10000000 * 1 ether) {
return 4;
} else if (soldTokens > 10000000 * 1 ether && soldTokens <= 20000000 * 1 ether) {
return 3;
} else if (soldTokens > 20000000 * 1 ether && soldTokens <= 30000000 * 1 ether) {
return 2;
} else {
return 1;
}
}
function refund() external afterDeadline {
require(!softcapReached);
require(refunded[msg.sender] == false);
uint256 balance = this.balanceOf(msg.sender);
require(balance > 0);
uint refund = balance;
if (refund > this.balance) {
refund = this.balance;
}
if (!msg.sender.send(refund)) {
revert();
}
refunded[msg.sender] = true;
weiRefunded = weiRefunded.add(refund);
Refunded(msg.sender, refund);
}
}