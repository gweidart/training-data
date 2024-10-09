pragma solidity ^0.4.16;
interface token {
function transferFrom(address _holder, address _receiver, uint amount) public returns (bool success);
function allowance(address _owner, address _spender) public returns (uint256 remaining);
function balanceOf(address _owner) public returns (uint256 balance);
}
contract owned {
address public owner;
event TransferOwnership (address indexed _owner, address indexed _newOwner);
function owned() public {
owner = msg.sender;
}
function transferOwnership(address newOwner) onlyOwner public {
TransferOwnership (owner, newOwner);
owner = newOwner;
}
modifier onlyOwner {
require(msg.sender == owner);
_;
}
}
contract YourMomTokenCrowdsale is owned {
token public tokenReward;
string public name;
address public beneficiary;
address public tokenHolder;
uint256 public crowdsaleStartTime;
uint256 public deadline;
uint256 public tokensIssued;
uint256 public amountRaised;
mapping(address => uint256) private balanceOf;
mapping(address => uint256) private etherBalanceOf;
uint256 private reclaimForgottenEtherDeadline;
uint256 private currentContractAllowance;
uint256 private initialContractAllowance;
uint256 private originalTokenReward;
uint256 private _etherAmount;
uint256 private price;
uint8 private errorCount = 0;
bool public purchasingAllowed = false;
bool public failSafeMode = false;
bool private afterFirstWithdrawal = false;
bool private allowanceSetted = false;
event TokenPurchase(address indexed taker, uint amount, uint tokensBought);
event FundWithdrawal(address indexed to, uint amount, bool isBeneficiary);
event PurchasingAllowed(bool enabled);
event ExecutionError(string reason);
event FailSafeActivated(bool enabled);
function YourMomTokenCrowdsale(string contractName, address ifSuccessfulSendTo, uint durationInDays, uint howManyTokensAnEtherCanBuy, address addressOfTokenUsedAsReward, address adressOfTokenHolder, uint crowdsaleStartTimeTimestamp, uint ifInFailSafeTimeInDaysAfterDeadlineToReclaimForgottenEther) public {
name = contractName;
crowdsaleStartTime = crowdsaleStartTimeTimestamp;
deadline = crowdsaleStartTime + durationInDays * 1 days;
originalTokenReward = howManyTokensAnEtherCanBuy;
tokenReward = token(addressOfTokenUsedAsReward);
tokenHolder = adressOfTokenHolder;
beneficiary = ifSuccessfulSendTo;
reclaimForgottenEtherDeadline = deadline + ifInFailSafeTimeInDaysAfterDeadlineToReclaimForgottenEther * 1 days;
}
function () payable public {
require(!failSafeMode);
require(purchasingAllowed);
require(now >= crowdsaleStartTime);
require(msg.value != 0);
require(amountRaised + msg.value > amountRaised);
price = _currentTokenRewardCalculator();
require(tokenReward.transferFrom(tokenHolder, msg.sender, msg.value * price));
amountRaised += msg.value;
tokensIssued += msg.value * price;
etherBalanceOf[msg.sender] += msg.value;
balanceOf[msg.sender] += msg.value * price;
currentContractAllowance = tokenReward.allowance(beneficiary, this);
if (!afterFirstWithdrawal && ((tokensIssued != initialContractAllowance - currentContractAllowance) ||  (amountRaised != this.balance))) { _activateFailSafe(); }
TokenPurchase(msg.sender, msg.value, msg.value * price);
if (afterFirstWithdrawal) {
if(beneficiary.send(msg.value)) { FundWithdrawal(beneficiary, msg.value, true); }
}
}
function enablePurchase() onlyOwner() public {
require(!failSafeMode);
require(!purchasingAllowed);
purchasingAllowed = true;
PurchasingAllowed(true);
if (!allowanceSetted) {
require(tokenReward.allowance(beneficiary, this) > 0);
initialContractAllowance = tokenReward.allowance(beneficiary, this);
currentContractAllowance = initialContractAllowance;
allowanceSetted = true;
}
}
function disablePurchase() onlyOwner() public {
require(purchasingAllowed);
purchasingAllowed = false;
PurchasingAllowed(false);
}
function Withdrawal() public returns (bool sucess) {
if (!failSafeMode) {
require((now >= deadline) || (100*currentContractAllowance/initialContractAllowance <= 5));
require(msg.sender == beneficiary);
if (!afterFirstWithdrawal) {
if (beneficiary.send(amountRaised)) {
afterFirstWithdrawal = true;
FundWithdrawal(beneficiary, amountRaised, true);
return true;
} else {
errorCount += 1;
if (errorCount >= 3) {
_activateFailSafe();
return false;
} else { return false; }
}
} else {
_etherAmount = this.balance;
beneficiary.transfer(_etherAmount);
FundWithdrawal(beneficiary, _etherAmount, true);
return true;
}
} else {
if((now > reclaimForgottenEtherDeadline) && (msg.sender == beneficiary)) {
_etherAmount = this.balance;
beneficiary.transfer(_etherAmount);
FundWithdrawal(beneficiary, _etherAmount, true);
return true;
} else {
require(balanceOf[msg.sender] > 0);
require(etherBalanceOf[msg.sender] > 0);
require(this.balance > 0 );
require(tokenReward.balanceOf(msg.sender) >= balanceOf[msg.sender]);
require(tokenReward.allowance(msg.sender, this) >= balanceOf[msg.sender]);
require(tokenReward.transferFrom(msg.sender, tokenHolder, balanceOf[msg.sender]));
if(this.balance >= etherBalanceOf[msg.sender]) {
_etherAmount = etherBalanceOf[msg.sender];
} else { _etherAmount = this.balance; }
balanceOf[msg.sender] = 0;
etherBalanceOf[msg.sender] = 0;
msg.sender.transfer(_etherAmount);
FundWithdrawal(msg.sender, _etherAmount, false);
return true;
}
}
}
function _currentTokenRewardCalculator() internal view returns (uint256) {
if (now <= crowdsaleStartTime + 6 hours) { return originalTokenReward + (originalTokenReward * 70 / 100); }
if (now <= crowdsaleStartTime + 12 hours) { return originalTokenReward + (originalTokenReward * 60 / 100); }
if (now <= crowdsaleStartTime + 48 hours) { return originalTokenReward + (originalTokenReward * 50 / 100); }
if (now <= crowdsaleStartTime + 7 days) { return originalTokenReward + (originalTokenReward * 30 / 100); }
if (now <= crowdsaleStartTime + 14 days) { return originalTokenReward + (originalTokenReward * 10 / 100); }
if (now > crowdsaleStartTime + 14 days) { return originalTokenReward; }
}
function _activateFailSafe() internal returns (bool) {
if(afterFirstWithdrawal) { return false; }
if(failSafeMode) { return false; }
currentContractAllowance = 0;
purchasingAllowed = false;
failSafeMode = true;
ExecutionError("Critical error");
FailSafeActivated(true);
return true;
}
function name() public constant returns (string) { return name; }
function tokenBalanceOf(address _owner) public constant returns (uint256 tokensBoughtAtCrowdsale) { return balanceOf[_owner]; }
function etherContributionOf(address _owner) public constant returns (uint256 amountContributedAtTheCrowdsaleInWei) { return etherBalanceOf[_owner]; }
function currentPrice() public constant returns (uint256 currentTokenRewardPer1EtherContributed) { return (_currentTokenRewardCalculator()); }
function discount() public constant returns (uint256 currentDiscount) { return ((100*_currentTokenRewardCalculator()/originalTokenReward) - 100); }
function remainingTokens() public constant returns (uint256 tokensStillOnSale) { return currentContractAllowance; }
function crowdsaleStarted() public constant returns (bool isCrowdsaleStarted) { if (now >= crowdsaleStartTime) { return true; } else { return false; } }
function reclaimEtherDeadline() public constant returns (uint256 deadlineToReclaimEtherIfFailSafeWasActivated) { return reclaimForgottenEtherDeadline; }
}