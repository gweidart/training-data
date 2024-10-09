pragma solidity ^0.4.10;
contract IOwned {
function owner() public constant returns (address) {}
function transferOwnership(address _newOwner) public;
contract Owned is IOwned {
address public owner;
function Owned() public {
owner = msg.sender;
}
modifier ownerOnly {
require(msg.sender == owner);
_;
}
function transferOwnership(address _newOwner) public ownerOnly {
require(_newOwner != owner);
owner = _newOwner;
}
}
contract TrancheWallet is Owned {
address public beneficiary;
uint256 public tranchePeriodInDays;
uint256 public trancheAmountPct;
uint256 public lockStart;
uint256 public completeUnlockTime;
uint256 public initialFunds;
uint256 public tranchesSent;
event Withdraw(uint256 amount, uint256 tranches);
function TrancheWallet(
address _beneficiary,
uint256 _tranchePeriodInDays,
uint256 _trancheAmountPct
)
{
beneficiary = _beneficiary;
tranchePeriodInDays = _tranchePeriodInDays;
trancheAmountPct = _trancheAmountPct;
tranchesSent = 0;
completeUnlockTime = 0;
}
function setBeneficiary(address newBeneficiary) public ownerOnly {
beneficiary = newBeneficiary;
}
function lock(uint256 lockPeriodInDays) public ownerOnly {
require(lockStart == 0);
initialFunds = currentBalance();
lockStart = now;
completeUnlockTime = lockPeriodInDays * 1 days + lockStart;
}
function sendToBeneficiary() {
uint256 amountToWithdraw;
uint256 tranchesToSend;
(amountToWithdraw, tranchesToSend) = amountAvailableToWithdraw();
require(amountToWithdraw > 0);
tranchesSent += tranchesToSend;
doTransfer(amountToWithdraw);
Withdraw(amountToWithdraw, tranchesSent);
}
function amountAvailableToWithdraw() constant returns (uint256 amount, uint256 tranches) {
if (currentBalance() > 0) {
if(now > completeUnlockTime) {
amount = currentBalance();
tranches = 0;
} else {
uint256 periodsSinceLock = (now - lockStart) / (tranchePeriodInDays * 1 days);
tranches = periodsSinceLock - tranchesSent + 1;
amount = tranches * oneTrancheAmount();
if(amount > currentBalance()) {
amount = currentBalance();
tranches = amount / oneTrancheAmount();
}
}
} else {
amount = 0;
tranches = 0;
}
}
function oneTrancheAmount() constant returns(uint256) {
return trancheAmountPct * initialFunds / 100;
}
function currentBalance() internal constant returns(uint256);
function doTransfer(uint256 amount) internal;
}
contract IERC20Token {
function name() public constant returns (string _name) { _name; }
function symbol() public constant returns (string _symbol) { _symbol; }
function decimals() public constant returns (uint8 _decimals) { _decimals; }
function totalSupply() public constant returns (uint total) {total;}
function balanceOf(address _owner) public constant returns (uint balance) {_owner; balance;}
function allowance(address _owner, address _spender) public constant returns (uint remaining) {_owner; _spender; remaining;}
function transfer(address _to, uint _value) public returns (bool success);
function transferFrom(address _from, address _to, uint _value) public returns (bool success);
function approve(address _spender, uint _value) public returns (bool success);
event Transfer(address indexed _from, address indexed _to, uint _value);
event Approval(address indexed _owner, address indexed _spender, uint _value);
}
contract TokenTrancheWallet is TrancheWallet {
IERC20Token public token;
function TokenTrancheWallet(
IERC20Token _token,
address _beneficiary,
uint256 _tranchePeriodInDays,
uint256 _trancheAmountPct
) TrancheWallet(_beneficiary, _tranchePeriodInDays, _trancheAmountPct)
{
token = _token;
}
function currentBalance() internal constant returns(uint256) {
return token.balanceOf(this);
}
function doTransfer(uint256 amount) internal {
require(token.transfer(beneficiary, amount));
}
}