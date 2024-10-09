pragma solidity ^0.4.11;
library SafeMath {
function mul(uint256 a, uint256 b) internal constant returns (uint256) {
uint256 c = a * b;
assert(a == 0 || c / a == b);
return c;
}
function div(uint256 a, uint256 b) internal constant returns (uint256) {
uint256 c = a / b;
return c;
}
function sub(uint256 a, uint256 b) internal constant returns (uint256) {
assert(b <= a);
return a - b;
}
function add(uint256 a, uint256 b) internal constant returns (uint256) {
uint256 c = a + b;
assert(c >= a);
return c;
}
}
contract owned {
address public owner;
function owned() public {
owner = msg.sender;
}
modifier onlyOwner {
require(msg.sender == owner);
_;
}
function transferOwnership(address newOwner) onlyOwner public {
owner = newOwner;
}
}
contract AuthenticationManager {
mapping (address => bool) adminAddresses;
mapping (address => bool) accountReaderAddresses;
address[] adminAudit;
address[] accountReaderAudit;
event AdminAdded(address addedBy, address admin);
event AdminRemoved(address removedBy, address admin);
event AccountReaderAdded(address addedBy, address account);
event AccountReaderRemoved(address removedBy, address account);
function AuthenticationManager() {
adminAddresses[msg.sender] = true;
AdminAdded(0, msg.sender);
adminAudit.length++;
adminAudit[adminAudit.length - 1] = msg.sender;
}
function isCurrentAdmin(address _address) constant returns (bool) {
return adminAddresses[_address];
}
function isCurrentOrPastAdmin(address _address) constant returns (bool) {
for (uint256 i = 0; i < adminAudit.length; i++)
if (adminAudit[i] == _address)
return true;
return false;
}
function isCurrentAccountReader(address _address) constant returns (bool) {
return accountReaderAddresses[_address];
}
function isCurrentOrPastAccountReader(address _address) constant returns (bool) {
for (uint256 i = 0; i < accountReaderAudit.length; i++)
if (accountReaderAudit[i] == _address)
return true;
return false;
}
function addAdmin(address _address) {
if (!isCurrentAdmin(msg.sender))
throw;
if (adminAddresses[_address])
throw;
adminAddresses[_address] = true;
AdminAdded(msg.sender, _address);
adminAudit.length++;
adminAudit[adminAudit.length - 1] = _address;
}
function removeAdmin(address _address) {
if (!isCurrentAdmin(msg.sender))
throw;
if (_address == msg.sender)
throw;
if (!adminAddresses[_address])
throw;
adminAddresses[_address] = false;
AdminRemoved(msg.sender, _address);
}
function addAccountReader(address _address) {
if (!isCurrentAdmin(msg.sender))
throw;
if (accountReaderAddresses[_address])
throw;
accountReaderAddresses[_address] = true;
AccountReaderAdded(msg.sender, _address);
accountReaderAudit.length++;
accountReaderAudit[adminAudit.length - 1] = _address;
}
function removeAccountReader(address _address) {
if (!isCurrentAdmin(msg.sender))
throw;
if (!accountReaderAddresses[_address])
throw;
accountReaderAddresses[_address] = false;
AccountReaderRemoved(msg.sender, _address);
}
}
contract XWinToken {
using SafeMath for uint256;
mapping (address => uint256) balances;
mapping(address => mapping (address => uint256)) allowed;
address[] allTokenHolders;
string public name;
string public symbol;
uint8 public decimals;
uint256 totalSupplyAmount = 0;
address public icoContractAddress;
bool public isClosed;
IcoPhaseManagement icoPhaseManagement;
AuthenticationManager authenticationManager;
event FundClosed();
event Transfer(address indexed from, address indexed to, uint256 value);
event Approval(address indexed _owner, address indexed _spender, uint256 _value);
function XWinToken(address _icoContractAddress, address _authenticationManagerAddress) {
name = "XWin CryptoBet";
symbol = "XWIN";
decimals = 8;
icoPhaseManagement = IcoPhaseManagement(_icoContractAddress);
authenticationManager = AuthenticationManager(_authenticationManagerAddress);
icoContractAddress = _icoContractAddress;
}
modifier onlyPayloadSize(uint numwords) {
assert(msg.data.length == numwords * 32 + 4);
_;
}
modifier accountReaderOnly {
if (!authenticationManager.isCurrentAccountReader(msg.sender)) throw;
_;
}
modifier fundSendablePhase {
if (icoPhaseManagement.icoAbandoned())
throw;
_;
}
function transferFrom(address _from, address _to, uint256 _amount) fundSendablePhase onlyPayloadSize(3) returns (bool) {
if (balances[_from] >= _amount && allowed[_from][msg.sender] >= _amount && _amount > 0 && balances[_to].add(_amount) > balances[_to]) {
bool isNew = balances[_to] == 0;
balances[_from] = balances[_from].sub(_amount);
allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_amount);
balances[_to] = balances[_to].add(_amount);
if (isNew)
tokenOwnerAdd(_to);
if (balances[_from] == 0)
tokenOwnerRemove(_from);
Transfer(_from, _to, _amount);
return true;
}
return false;
}
function tokenHolderCount()  constant returns (uint256) {
return allTokenHolders.length;
}
function tokenHolder(uint256 _index)  constant returns (address) {
return allTokenHolders[_index];
}
function approve(address _spender, uint256 _amount) fundSendablePhase onlyPayloadSize(2) returns (bool success) {
allowed[msg.sender][_spender] = _amount;
Approval(msg.sender, _spender, _amount);
return true;
}
function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
return allowed[_owner][_spender];
}
function totalSupply() constant returns (uint256) {
return totalSupplyAmount;
}
function balanceOf(address _owner) constant returns (uint256 balance) {
return balances[_owner];
}
function transfer(address _to, uint256 _amount) fundSendablePhase onlyPayloadSize(2) returns (bool) {
if (balances[msg.sender] < _amount || balances[_to].add(_amount) < balances[_to])
return false;
bool isRecipientNew = balances[_to] == 0;
balances[msg.sender] = balances[msg.sender].sub(_amount);
balances[_to] = balances[_to].add(_amount);
if (isRecipientNew)
tokenOwnerAdd(_to);
if (balances[msg.sender] == 0)
tokenOwnerRemove(msg.sender);
Transfer(msg.sender, _to, _amount);
return true;
}
function tokenOwnerAdd(address _addr) internal {
uint256 tokenHolderCount = allTokenHolders.length;
for (uint256 i = 0; i < tokenHolderCount; i++)
if (allTokenHolders[i] == _addr)
return;
allTokenHolders.length++;
allTokenHolders[allTokenHolders.length - 1] = _addr;
}
function tokenOwnerRemove(address _addr) internal {
uint256 tokenHolderCount = allTokenHolders.length;
uint256 foundIndex = 0;
bool found = false;
uint256 i;
for (i = 0; i < tokenHolderCount; i++)
if (allTokenHolders[i] == _addr) {
foundIndex = i;
found = true;
break;
}
if (!found)
return;
for (i = foundIndex; i < tokenHolderCount - 1; i++)
allTokenHolders[i] = allTokenHolders[i + 1];
allTokenHolders.length--;
}
function mintTokens(address _address, uint256 _amount) onlyPayloadSize(2) {
if (msg.sender != icoContractAddress || !icoPhaseManagement.icoPhase())
throw;
bool isNew = balances[_address] == 0;
totalSupplyAmount = totalSupplyAmount.add(_amount);
balances[_address] = balances[_address].add(_amount);
if (isNew)
tokenOwnerAdd(_address);
Transfer(0, _address, _amount);
}
}
contract IcoPhaseManagement {
using SafeMath for uint256;
bool public icoPhase = true;
bool public icoAbandoned = false;
bool xwinContractDefined = false;
uint256 public icoUnitPrice = 3 finney;
address mainWallet="0x20ce46Bce85BFf0CA13b02401164D96B3806f56e";
address manager = "0xE3ff0BA0C6E7673f46C7c94A5155b4CA84a5bE0C";
address reservedWallet1 = "0x43Ceb8b8f755518e325898d95F3912aF16b6110C";
address reservedWallet2 = "0x11F386d6c7950369E8Da56F401d1727cf131816D";
bool public reservedTokensDistributed;
mapping(address => uint256) public abandonedIcoBalances;
XWinToken xWinToken;
AuthenticationManager authenticationManager;
uint256 public icoStartTime;
uint256 public icoEndTime;
event IcoClosed();
event IcoAbandoned(string details);
modifier onlyDuringIco {
bool contractValid = xwinContractDefined && !xWinToken.isClosed();
if (!contractValid || (!icoPhase && !icoAbandoned)) throw;
_;
}
modifier onlyAfterIco {
if ( icoEndTime  > now) throw;
_;
}
modifier adminOnly {
if (!authenticationManager.isCurrentAdmin(msg.sender)) throw;
_;
}
modifier managerOnly {
require (msg.sender==manager);
_;
}
function IcoPhaseManagement(address _authenticationManagerAddress) {
icoStartTime = now;
icoEndTime = 1517270400;
authenticationManager = AuthenticationManager(_authenticationManagerAddress);
reservedTokensDistributed = false;
}
function setXWinContractAddress(address _xwinContractAddress) adminOnly {
if (xwinContractDefined)
throw;
xWinToken = XWinToken(_xwinContractAddress);
xwinContractDefined = true;
}
function setTokenPrice(uint newPriceInWei) managerOnly {
icoUnitPrice = newPriceInWei;
}
function close() managerOnly onlyDuringIco {
if (now <= icoEndTime)
throw;
icoPhase = false;
IcoClosed();
}
function distributeReservedTokens() managerOnly onlyAfterIco {
require (!reservedTokensDistributed);
uint extraTwentyPercents = xWinToken.totalSupply().div(4);
xWinToken.mintTokens(reservedWallet1,extraTwentyPercents.div(2));
xWinToken.mintTokens(reservedWallet2,extraTwentyPercents.div(2));
reservedTokensDistributed = true;
}
function () onlyDuringIco payable {
if (now < icoStartTime || now > icoEndTime)
throw;
xWinToken.mintTokens(msg.sender, msg.value.mul(100000000).div(icoUnitPrice));
mainWallet.send(msg.value);
}
}
contract DividendManager {
using SafeMath for uint256;
XWinToken xwinContract;
mapping (address => uint256) public dividends;
event PaymentAvailable(address addr, uint256 amount);
event DividendPayment(uint256 paymentPerShare, uint256 timestamp);
function DividendManager(address _xwinContractAddress) {
xwinContract = XWinToken(_xwinContractAddress);
}
function () payable {
if (xwinContract.isClosed())
throw;
uint256 validSupply = xwinContract.totalSupply();
uint256 paymentPerShare = msg.value.div(validSupply);
if (paymentPerShare == 0)
throw;
uint256 totalPaidOut = 0;
for (uint256 i = 0; i < xwinContract.tokenHolderCount(); i++) {
address addr = xwinContract.tokenHolder(i);
uint256 dividend = paymentPerShare * xwinContract.balanceOf(addr);
dividends[addr] = dividends[addr].add(dividend);
PaymentAvailable(addr, dividend);
totalPaidOut = totalPaidOut.add(dividend);
}
DividendPayment(paymentPerShare, now);
}
function withdrawDividend() {
if (dividends[msg.sender] == 0)
throw;
uint256 dividend = dividends[msg.sender];
dividends[msg.sender] = 0;
if (!msg.sender.send(dividend))
throw;
}
}
contract XWinAssociation {
address public manager = "0xE3ff0BA0C6E7673f46C7c94A5155b4CA84a5bE0C";
uint public changeManagerQuorum = 80;
uint public debatingPeriod = 3 days;
Proposal[] public proposals;
uint public numProposals;
XWinToken public sharesTokenAddress;
event ProposalAdded(uint proposalID, address newManager, string description);
event Voted(uint proposalID, bool position, address voter);
event ProposalTallied(uint proposalID, uint result,bool active);
event ChangeOfRules(uint newMinimumQuorum, uint newDebatingPeriodInMinutes, address newSharesTokenAddress);
struct Proposal {
address newManager;
string description;
uint votingDeadline;
bool executed;
bool proposalPassed;
uint numberOfVotes;
bytes32 proposalHash;
Vote[] votes;
mapping (address => bool) voted;
}
struct Vote {
bool inSupport;
address voter;
}
modifier onlyShareholders {
require(sharesTokenAddress.balanceOf(msg.sender) > 0);
_;
}
modifier onlyManager {
require(msg.sender == manager);
_;
}
function XWinAssociation(address _xwinContractAddress)  {
sharesTokenAddress = XWinToken(_xwinContractAddress);
}
function changeVoteRules (uint debatingPeriodInDays) onlyManager {
debatingPeriod = debatingPeriodInDays * 1 days;
}
function transferEthers(address receiver, uint valueInWei) onlyManager {
uint value = valueInWei;
require ( this.balance > value);
receiver.send(value);
}
function () payable {
}
function newProposal(
address newManager,
string managerDescription
)
onlyShareholders
returns (uint proposalID)
{
proposalID = proposals.length++;
Proposal storage p = proposals[proposalID];
p.newManager = newManager;
p.description = managerDescription;
p.proposalHash = sha3(newManager);
p.votingDeadline = now + debatingPeriod;
p.executed = false;
p.proposalPassed = false;
p.numberOfVotes = 0;
ProposalAdded(proposalID, newManager, managerDescription);
numProposals = proposalID+1;
return proposalID;
}
function checkProposalCode(
uint proposalNumber,
address newManager
)
constant
returns (bool codeChecksOut)
{
Proposal storage p = proposals[proposalNumber];
return p.proposalHash == sha3(newManager);
}
function vote(
uint proposalNumber,
bool supportsProposal
)
onlyShareholders
returns (uint voteID)
{
Proposal storage p = proposals[proposalNumber];
require(p.voted[msg.sender] != true);
voteID = p.votes.length++;
p.votes[voteID] = Vote({inSupport: supportsProposal, voter: msg.sender});
p.voted[msg.sender] = true;
p.numberOfVotes = voteID +1;
Voted(proposalNumber,  supportsProposal, msg.sender);
return voteID;
}
function executeProposal(uint proposalNumber, address newManager) {
Proposal storage p = proposals[proposalNumber];
require(now > p.votingDeadline
&& !p.executed
&& p.proposalHash == sha3(newManager));
uint yea = 0;
for (uint i = 0; i <  p.votes.length; ++i) {
Vote storage v = p.votes[i];
uint voteWeight = sharesTokenAddress.balanceOf(v.voter);
if (v.inSupport)
yea += voteWeight;
}
if ( yea > changeManagerQuorum * 10**sharesTokenAddress.decimals() ) {
manager = newManager;
p.executed = true;
p.proposalPassed = true;
}
ProposalTallied(proposalNumber, yea , p.proposalPassed);
}
}
contract XWinBet {
using SafeMath for uint256;
event BetAdded(uint betId, address bettor, uint value, uint rate, uint deadline);
event BetExecuted(uint betId, address bettor, uint winValue);
event FoundsTransferd(address dao, uint value);
XWinAssociation dao;
uint public numBets;
uint public reservedWeis;
struct Bet {
address bettor;
uint value;
uint rate;
uint deadline;
bytes32 betHash;
bool executed;
}
Bet[] public bets;
modifier onlyManager {
require(msg.sender == dao.manager());
_;
}
function XWinBet(address daoContract) {
dao = XWinAssociation(daoContract);
}
function () payable {
}
function transferEthersToDao(uint valueInEthers) onlyManager {
require(this.balance.sub(reservedWeis) >= valueInEthers * 1 ether);
dao.transfer(valueInEthers * 1 ether);
FoundsTransferd(dao, valueInEthers * 1 ether);
}
function bet (uint rate, uint timeLimitInMinutes) payable returns (uint betID)
{
uint reserved =  msg.value.mul(rate).div(1000);
require ( this.balance > reservedWeis.add(reserved));
reservedWeis = reservedWeis.add(reserved);
betID = bets.length++;
Bet storage b = bets[betID];
b.bettor = msg.sender;
b.value = msg.value;
b.rate = rate;
b.deadline = now + timeLimitInMinutes * 1 minutes;
b.betHash = sha3(betID,msg.sender,msg.value,rate,b.deadline);
b.executed = false;
BetAdded(betID, msg.sender,msg.value,rate,b.deadline);
numBets = betID+1;
return betID;
}
function executeBet (uint betId, bool win)
{
Bet b = bets[betId];
require (now > b.deadline);
require (!b.executed);
require (msg.sender == b.bettor);
require (sha3(betId,msg.sender,b.value,b.rate,b.deadline)==b.betHash);
uint winValue = b.value.mul(b.rate).div(1000);
reservedWeis = reservedWeis.sub(winValue);
if (win)
{
msg.sender.transfer(winValue);
BetExecuted(betId,msg.sender,winValue);
}
else
{
BetExecuted(betId, msg.sender,0);
}
b.executed = true;
}
}