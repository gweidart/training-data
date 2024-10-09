pragma solidity 0.4.19;
contract ERC20Interface {
function transfer(address to, uint256 value) public returns (bool);
function transferFrom(address from, address to, uint256 value) public returns (bool);
function balanceOf(address who) public view returns (uint256);
}
contract TokenSaleQueue {
using SafeMath for uint256;
address public owner;
modifier onlyOwner() {
require(msg.sender == owner);
_;
}
function getOwner() public view returns (address) {
return owner;
}
struct Record {
uint256 balance;
bool authorized;
}
mapping(address => Record) public deposits;
uint256 public weiRaised;
function() public payable {
deposit();
}
function balanceOf(address who) public view returns (uint256 balance) {
return deposits[who].balance;
}
function isAuthorized(address who) public view returns (bool authorized) {
return deposits[who].authorized;
}
function getDeadline() public view returns (uint) {
return deadline;
}
function getManager() public view returns (address) {
return manager;
}
event Whitelist(address who);
event Deposit(address who, uint256 amount);
event Withdrawal(address who);
event Authorized(address who);
event Process(address who);
event Refund(address who);
function TokenSaleQueue(address _owner, address _manager,  address _recipient, address _recipientContainer, uint _deadline, uint _extendedTime, uint _maxTime) public {
require(_owner != address(0));
require(_manager != address(0));
require(_recipient != address(0));
require(_recipientContainer != address(0));
owner = _owner;
manager = _manager;
recipient = _recipient;
recipientContainer = _recipientContainer;
deadline = _deadline;
extendedTime = _extendedTime;
maxTime = _maxTime;
finalTime = deadline + extendedTime;
}
modifier onlyManager() {
require(msg.sender == manager);
_;
}
mapping(address => bool) whitelist;
function addAddressInWhitelist(address who) public onlyManager {
require(who != address(0));
whitelist[who] = true;
Whitelist(who);
}
function isInWhiteList(address who) public view returns (bool result) {
return whitelist[who];
}
function deposit() public payable {
require(msg.value > 0);
require(whitelist[msg.sender]);
if (block.number <= finalTime) {
deposits[msg.sender].balance = deposits[msg.sender].balance.add(msg.value);
weiRaised = weiRaised.add(msg.value);
Deposit(msg.sender, msg.value);
} else {
msg.sender.transfer(msg.value);
if (weiRaised != 0) {
uint256 sendToRecepient = weiRaised;
weiRaised = 0;
recipient.transfer(sendToRecepient);
}
}
}
function withdraw() public {
Record storage record = deposits[msg.sender];
require(record.balance > 0);
uint256 balance = record.balance;
record.balance = 0;
weiRaised = weiRaised.sub(balance);
msg.sender.transfer(balance);
Withdrawal(msg.sender);
}
function authorize(address who) onlyManager public {
require(who != address(0));
Record storage record = deposits[who];
record.authorized = true;
Authorized(who);
}
function process() public {
Record storage record = deposits[msg.sender];
require(record.authorized);
require(record.balance > 0);
uint256 balance = record.balance;
record.balance = 0;
weiRaised = weiRaised.sub(balance);
owner.transfer(balance);
Process(msg.sender);
}
mapping(address => mapping(address => uint256)) public tokenDeposits;
mapping(address => bool) public tokenWalletsWhitelist;
address[] tokenWallets;
mapping(address => uint256) public tokenRaised;
bool reclaimTokenLaunch = false;
function addTokenWalletInWhitelist(address tokenWallet) public onlyManager {
require(tokenWallet != address(0));
require(!tokenWalletsWhitelist[tokenWallet]);
tokenWalletsWhitelist[tokenWallet] = true;
tokenWallets.push(tokenWallet);
TokenWhitelist(tokenWallet);
}
function tokenInWhiteList(address tokenWallet) public view returns (bool result) {
return tokenWalletsWhitelist[tokenWallet];
}
function tokenBalanceOf(address tokenWallet, address who) public view returns (uint256 balance) {
return tokenDeposits[tokenWallet][who];
}
event TokenWhitelist(address tokenWallet);
event TokenDeposit(address tokenWallet, address who, uint256 amount);
event TokenWithdrawal(address tokenWallet, address who);
event TokenProcess(address tokenWallet, address who);
event TokenRefund(address tokenWallet, address who);
function tokenDeposit(address tokenWallet, uint amount) public {
require(amount > 0);
require(tokenWalletsWhitelist[tokenWallet]);
require(whitelist[msg.sender]);
ERC20Interface ERC20Token = ERC20Interface(tokenWallet);
if (block.number <= finalTime) {
require(ERC20Token.transferFrom(msg.sender, this, amount));
tokenDeposits[tokenWallet][msg.sender] = tokenDeposits[tokenWallet][msg.sender].add(amount);
tokenRaised[tokenWallet] = tokenRaised[tokenWallet].add(amount);
TokenDeposit(tokenWallet, msg.sender, amount);
} else {
reclaimTokens(tokenWallets);
}
}
function tokenWithdraw(address tokenWallet) public {
require(tokenDeposits[tokenWallet][msg.sender] > 0);
uint256 balance = tokenDeposits[tokenWallet][msg.sender];
tokenDeposits[tokenWallet][msg.sender] = 0;
tokenRaised[tokenWallet] = tokenRaised[tokenWallet].sub(balance);
ERC20Interface ERC20Token = ERC20Interface(tokenWallet);
require(ERC20Token.transfer(msg.sender, balance));
TokenWithdrawal(tokenWallet, msg.sender);
}
function tokenProcess(address tokenWallet) public {
require(deposits[msg.sender].authorized);
require(tokenDeposits[tokenWallet][msg.sender] > 0);
uint256 balance = tokenDeposits[tokenWallet][msg.sender];
tokenDeposits[tokenWallet][msg.sender] = 0;
tokenRaised[tokenWallet] = tokenRaised[tokenWallet].sub(balance);
ERC20Interface ERC20Token = ERC20Interface(tokenWallet);
require(ERC20Token.transfer(owner, balance));
TokenProcess(tokenWallet, msg.sender);
}
function destroy(address[] tokens) public {
require(msg.sender == recipientContainer);
require(block.number > finalTime);
for (uint256 i = 0; i < tokens.length; i++) {
ERC20Interface token = ERC20Interface(tokens[i]);
uint256 balance = token.balanceOf(this);
token.transfer(recipientContainer, balance);
}
selfdestruct(recipientContainer);
}
function changeExtendedTime(uint _extendedTime) public onlyOwner {
require((deadline + _extendedTime) < maxTime);
require(_extendedTime > extendedTime);
extendedTime = _extendedTime;
finalTime = deadline + extendedTime;
}
function reclaimTokens(address[] tokens) internal {
require(!reclaimTokenLaunch);
for (uint256 i = 0; i < tokens.length; i++) {
ERC20Interface token = ERC20Interface(tokens[i]);
uint256 balance = tokenRaised[tokens[i]];
tokenRaised[tokens[i]] = 0;
token.transfer(recipient, balance);
}
reclaimTokenLaunch = true;
}
}
library SafeMath {
function add(uint256 a, uint256 b) internal pure returns (uint256) {
uint256 c = a + b;
assert(c >= a);
return c;
}
function sub(uint256 a, uint256 b) internal pure returns (uint256) {
assert(b <= a);
return a - b;
}
}