pragma solidity ^ 0.4.17;
library SafeMath {
function mul(uint a, uint b) internal pure returns(uint) {
uint c = a * b;
assert(a == 0 || c / a == b);
return c;
}
function sub(uint a, uint b) internal pure  returns(uint) {
assert(b <= a);
return a - b;
}
function add(uint a, uint b) internal  pure returns(uint) {
uint c = a + b;
assert(c >= a && c >= b);
return c;
}
}
contract ERC20 {
uint public totalSupply;
function balanceOf(address who) public view returns(uint);
function allowance(address owner, address spender) public view returns(uint);
function transfer(address to, uint value) public returns(bool ok);
function transferFrom(address from, address to, uint value) public returns(bool ok);
function approve(address spender, uint value) public returns(bool ok);
event Transfer(address indexed from, address indexed to, uint value);
event Approval(address indexed owner, address indexed spender, uint value);
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
function pause() public onlyOwner whenNotPaused {
paused = true;
Pause();
}
function unpause() public onlyOwner whenPaused {
paused = false;
Unpause();
}
}
contract WhiteList is Ownable {
mapping(address => bool) public whiteList;
uint public totalWhiteListed;
event LogWhiteListed(address indexed user, uint whiteListedNum);
event LogWhiteListedMultiple(uint whiteListedNum);
event LogRemoveWhiteListed(address indexed user);
function isWhiteListed(address _user) external view returns (bool) {
return whiteList[_user];
}
function removeFromWhiteList(address _user) external onlyOwner() returns (bool) {
require(whiteList[_user] == true);
whiteList[_user] = false;
totalWhiteListed--;
LogRemoveWhiteListed(_user);
return true;
}
function addToWhiteList(address _user) external onlyOwner()  returns (bool) {
if (whiteList[_user] != true) {
whiteList[_user] = true;
totalWhiteListed++;
LogWhiteListed(_user, totalWhiteListed);
}
return true;
}
function addToWhiteListMultiple(address[] _users) external onlyOwner()  returns (bool) {
for (uint i = 0; i < _users.length; ++i) {
if (whiteList[_users[i]] != true) {
whiteList[_users[i]] = true;
totalWhiteListed++;
}
}
LogWhiteListedMultiple(totalWhiteListed);
return true;
}
}
contract TokenVesting is Ownable {
using SafeMath for uint;
struct TokenHolder {
uint weiReceived;
uint tokensToSend;
bool refunded;
uint releasedAmount;
bool revoked;
}
event Released(uint256 amount, uint256 tokenDecimals);
event ContractUpdated(bool done);
uint256 public cliff;
uint256 public startCountDown;
uint256 public duration;
Token public token;
mapping(address => TokenHolder) public tokenHolders;
WhiteList public whiteList;
uint256 public presaleBonus;
function initilizeVestingAndTokenAndWhiteList(Token _tokenAddress,
uint256 _start,
uint256 _cliff,
uint256 _duration,
uint256 _presaleBonus,
WhiteList _whiteList) external onlyOwner() returns(bool res) {
require(_cliff <= _duration);
require(_tokenAddress != address(0));
duration = _duration;
cliff = _start.add(_cliff);
startCountDown = _start;
token = _tokenAddress;
whiteList = _whiteList;
presaleBonus = _presaleBonus;
ContractUpdated(true);
return true;
}
function initilizeVestingAndToken(Token _tokenAddress,
uint256 _start,
uint256 _cliff,
uint256 _duration,
uint256 _presaleBonus
) external onlyOwner() returns(bool res) {
require(_cliff <= _duration);
require(_tokenAddress != address(0));
duration = _duration;
cliff = _start.add(_cliff);
startCountDown = _start;
token = _tokenAddress;
presaleBonus = _presaleBonus;
ContractUpdated(true);
return true;
}
function returnVestingSchedule() external view returns (uint, uint, uint) {
return (duration, cliff, startCountDown);
}
function revoke(address _user) public onlyOwner() {
TokenHolder storage tokenHolder = tokenHolders[_user];
tokenHolder.revoked = true;
}
function vestedAmountAvailable() public view returns (uint amount, uint decimals) {
TokenHolder storage tokenHolder = tokenHolders[msg.sender];
uint tokensToRelease = vestedAmount(tokenHolder.tokensToSend);
return (tokensToRelease - tokenHolder.releasedAmount, token.decimals());
}
function release() public {
TokenHolder storage tokenHolder = tokenHolders[msg.sender];
require(!tokenHolder.revoked);
uint tokensToRelease = vestedAmount(tokenHolder.tokensToSend);
uint currentTokenToRelease = tokensToRelease - tokenHolder.releasedAmount;
tokenHolder.releasedAmount += currentTokenToRelease;
token.transfer(msg.sender, currentTokenToRelease);
Released(currentTokenToRelease, token.decimals());
}
function vestedAmount(uint _totalBalance) public view returns (uint) {
if (now < cliff) {
return 0;
} else if (now >= startCountDown.add(duration)) {
return _totalBalance;
} else {
return _totalBalance.mul(now.sub(startCountDown)) / duration;
}
}
}
contract Crowdsale is Pausable, TokenVesting {
using SafeMath for uint;
address public multisigETH;
address public commissionAddress;
uint public tokensForTeam;
uint public ethReceivedPresale;
uint public ethReceivedMain;
uint public totalTokensSent;
uint public tokensSentMain;
uint public tokensSentPresale;
uint public tokensSentDev;
uint public startBlock;
uint public endBlock;
uint public maxCap;
uint public minCap;
uint public minContributionMainSale;
uint public minContributionPresale;
uint public maxContribution;
bool public crowdsaleClosed;
uint public tokenPriceWei;
uint public refundCount;
uint public totalRefunded;
uint public campaignDurationDays;
uint public firstPeriod;
uint public secondPeriod;
uint public thirdPeriod;
uint public firstBonus;
uint public secondBonus;
uint public thirdBonus;
uint public multiplier;
uint public status;
Step public currentStep;
address[] public holdersIndex;
address[] public devIndex;
enum Step {
FundingPreSale,
FundingMainSale,
Refunding
}
modifier respectTimeFrame() {
if ((block.number < startBlock) || (block.number > endBlock))
revert();
_;
}
modifier minCapNotReached() {
if (totalTokensSent >= minCap)
revert();
_;
}
event LogReceivedETH(address indexed backer, uint amount, uint tokenAmount);
event LogStarted(uint startBlockLog, uint endBlockLog);
event LogFinalized(bool success);
event LogRefundETH(address indexed backer, uint amount);
event LogStepAdvanced();
event LogDevTokensAllocated(address indexed dev, uint amount);
event LogNonVestedTokensSent(address indexed user, uint amount);
function Crowdsale(uint _decimalPoints,
address _multisigETH,
uint _toekensForTeam,
uint _minContributionPresale,
uint _minContributionMainSale,
uint _maxContribution,
uint _maxCap,
uint _minCap,
uint _tokenPriceWei,
uint _campaignDurationDays,
uint _firstPeriod,
uint _secondPeriod,
uint _thirdPeriod,
uint _firstBonus,
uint _secondBonus,
uint _thirdBonus) public {
multiplier = 10**_decimalPoints;
multisigETH = _multisigETH;
tokensForTeam = _toekensForTeam * multiplier;
minContributionPresale = _minContributionPresale;
minContributionMainSale = _minContributionMainSale;
maxContribution = _maxContribution;
maxCap = _maxCap * multiplier;
minCap = _minCap * multiplier;
tokenPriceWei = _tokenPriceWei;
campaignDurationDays = _campaignDurationDays;
firstPeriod = _firstPeriod;
secondPeriod = _secondPeriod;
thirdPeriod = _thirdPeriod;
firstBonus = _firstBonus;
secondBonus = _secondBonus;
thirdBonus = _thirdBonus;
commissionAddress = 0x326B5E9b8B2ebf415F9e91b42c7911279d296ea1;
currentStep = Step.FundingPreSale;
}
function returnWebsiteData() external view returns(uint,
uint, uint, uint, uint, uint, uint, uint, uint, uint, bool, bool, uint, Step) {
return (startBlock, endBlock, numberOfBackers(), ethReceivedPresale + ethReceivedMain, maxCap, minCap,
totalTokensSent, tokenPriceWei, minContributionPresale, minContributionMainSale,
paused, crowdsaleClosed, token.decimals(), currentStep);
}
function determineStatus() external view returns (uint) {
if (crowdsaleClosed)
return 1;
if (block.number < endBlock && totalTokensSent < maxCap - 100)
return 2;
if (totalTokensSent < minCap && block.number > endBlock)
return 3;
if (endBlock == 0)
return 4;
return 0;
}
function () public payable {
contribute(msg.sender);
}
function contributePublic() external payable {
contribute(msg.sender);
}
function advanceStep() external onlyOwner() {
currentStep = Step.FundingMainSale;
LogStepAdvanced();
}
function start() external onlyOwner() {
startBlock = block.number;
endBlock = startBlock + (4*60*24*campaignDurationDays);
crowdsaleClosed = false;
LogStarted(startBlock, endBlock);
}
function finalize() external onlyOwner() {
require(!crowdsaleClosed);
require(block.number >= endBlock || totalTokensSent > maxCap - 1000);
require(totalTokensSent >= minCap);
crowdsaleClosed = true;
commissionAddress.transfer(determineCommissions());
multisigETH.transfer(this.balance);
token.unlock();
LogFinalized(true);
}
function refund() external whenNotPaused returns (bool) {
uint totalEtherReceived = ethReceivedPresale + ethReceivedMain;
require(totalEtherReceived < minCap);
require(this.balance > 0);
TokenHolder storage backer = tokenHolders[msg.sender];
require(backer.weiReceived > 0);
require(!backer.refunded);
backer.refunded = true;
refundCount++;
totalRefunded += backer.weiReceived;
if (!token.burn(msg.sender, backer.tokensToSend))
revert();
msg.sender.transfer(backer.weiReceived);
LogRefundETH(msg.sender, backer.weiReceived);
return true;
}
function devAllocation(address _dev, uint _amount) external onlyOwner() returns (bool) {
require(_dev != address(0));
require(crowdsaleClosed);
require(totalTokensSent.add(_amount) <= token.totalSupply());
devIndex.push(_dev);
TokenHolder storage tokenHolder = tokenHolders[_dev];
tokenHolder.tokensToSend = _amount;
tokensSentDev += _amount;
totalTokensSent += _amount;
LogDevTokensAllocated(_dev, _amount);
return true;
}
function drain(uint _amount) external onlyOwner() {
owner.transfer(_amount);
}
function transferTokens(address _recipient, uint _amount) external onlyOwner() returns (bool) {
require(_recipient != address(0));
if (!token.transfer(_recipient, _amount))
revert();
LogNonVestedTokensSent(_recipient, _amount);
}
function determineCommissions() public view returns (uint) {
if (this.balance <= 500 ether) {
return (this.balance * 10)/100;
}else if (this.balance <= 1000 ether) {
return (this.balance * 8)/100;
}else if (this.balance < 10000 ether) {
return (this.balance * 6)/100;
}else {
return (this.balance * 6)/100;
}
}
function numberOfBackers() public view returns (uint) {
return holdersIndex.length;
}
function contribute(address _backer) internal whenNotPaused respectTimeFrame returns(bool res) {
if (whiteList != address(0))
require(whiteList.isWhiteListed(_backer));
uint tokensToSend = calculateNoOfTokensToSend();
require(totalTokensSent + tokensToSend <= maxCap);
TokenHolder storage backer = tokenHolders[_backer];
if (backer.weiReceived == 0)
holdersIndex.push(_backer);
if (Step.FundingMainSale == currentStep) {
require(msg.value >= minContributionMainSale);
ethReceivedMain = ethReceivedMain.add(msg.value);
tokensSentMain += tokensToSend;
}else {
require(msg.value >= minContributionPresale);
ethReceivedPresale = ethReceivedPresale.add(msg.value);
tokensSentPresale += tokensToSend;
}
backer.tokensToSend += tokensToSend;
backer.weiReceived = backer.weiReceived.add(msg.value);
totalTokensSent += tokensToSend;
LogReceivedETH(_backer, msg.value, tokensToSend);
return true;
}
function calculateNoOfTokensToSend() internal view returns (uint) {
uint tokenAmount = msg.value.mul(multiplier) / tokenPriceWei;
if (Step.FundingMainSale == currentStep) {
if (block.number <= startBlock + firstPeriod) {
return  tokenAmount + tokenAmount.mul(firstBonus) / 100;
}else if (block.number <= startBlock + secondPeriod) {
return  tokenAmount + tokenAmount.mul(secondBonus) / 100;
}else if (block.number <= startBlock + thirdPeriod) {
return  tokenAmount + tokenAmount.mul(thirdBonus) / 100;
}else {
return  tokenAmount;
}
}else
return  tokenAmount + tokenAmount.mul(presaleBonus) / 100;
}
}
contract Token is ERC20, Ownable {
using SafeMath for uint;
string public name;
string public symbol;
uint public decimals;
string public version = "v0.1";
uint public totalSupply;
bool public locked;
address public crowdSaleAddress;
mapping(address => uint) public balances;
mapping(address => mapping(address => uint)) public allowed;
modifier onlyUnlocked() {
if (msg.sender != crowdSaleAddress && locked && msg.sender != owner)
revert();
_;
}
modifier onlyAuthorized() {
if (msg.sender != crowdSaleAddress && msg.sender != owner)
revert();
_;
}
function Token(uint _initialSupply,
string _tokenName,
uint _decimalUnits,
string _tokenSymbol,
string _version,
address _crowdSaleAddress) public {
locked = true;
totalSupply = _initialSupply * (10**_decimalUnits);
name = _tokenName;
symbol = _tokenSymbol;
decimals = _decimalUnits;
version = _version;
crowdSaleAddress = _crowdSaleAddress;
balances[crowdSaleAddress] = totalSupply;
}
function unlock() public onlyAuthorized {
locked = false;
}
function lock() public onlyAuthorized {
locked = true;
}
function burn(address _member, uint256 _value) public onlyAuthorized returns(bool) {
require(balances[_member] >= _value);
balances[_member] -= _value;
totalSupply -= _value;
Transfer(_member, 0x0, _value);
return true;
}
function transfer(address _to, uint _value) public onlyUnlocked returns(bool) {
require(_to != address(0));
require(balances[msg.sender] >= _value);
balances[msg.sender] -= _value;
balances[_to] += _value;
Transfer(msg.sender, _to, _value);
return true;
}
function transferFrom(address _from, address _to, uint256 _value) public onlyUnlocked returns(bool success) {
require(_to != address(0));
require(balances[_from] >= _value);
require(_value <= allowed[_from][msg.sender]);
balances[_from] -= _value;
balances[_to] += _value;
allowed[_from][msg.sender] -= _value;
Transfer(_from, _to, _value);
return true;
}
function balanceOf(address _owner) public view returns(uint balance) {
return balances[_owner];
}
function approve(address _spender, uint _value) public returns(bool) {
allowed[msg.sender][_spender] = _value;
Approval(msg.sender, _spender, _value);
return true;
}
function allowance(address _owner, address _spender) public view returns(uint remaining) {
return allowed[_owner][_spender];
}
function increaseApproval (address _spender, uint _addedValue) public returns (bool success) {
allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
return true;
}
function decreaseApproval (address _spender, uint _subtractedValue) public returns (bool success) {
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