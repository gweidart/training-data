pragma solidity ^0.4.2;
contract PassTokenManagerInterface {
struct fundingData {
bool publicCreation;
address mainPartner;
uint maxAmountToFund;
uint fundedAmount;
uint startTime;
uint closingTime;
uint initialPriceMultiplier;
uint inflationRate;
uint proposalID;
}
address public creator;
address public client;
address public recipient;
string public name;
string public symbol;
uint8 public decimals;
uint256 totalSupply;
mapping (address => uint256) balances;
mapping (address => mapping (address => uint256)) allowed;
mapping (uint => uint) fundedAmount;
bool public transferable;
mapping (address => uint) public blockedDeadLine;
fundingData[2] public FundingRules;
function TotalSupply() constant external returns (uint256);
function balanceOf(address _owner) constant external returns (uint256 balance);
function allowance(address _owner, address _spender) constant external returns (uint256 remaining);
function FundedAmount(uint _proposalID) constant external returns (uint);
function priceDivisor(uint _saleDate) constant internal returns (uint);
function actualPriceDivisor() constant external returns (uint);
function fundingMaxAmount(address _mainPartner) constant external returns (uint);
modifier onlyClient {if (msg.sender != client) throw; _;}
modifier onlyMainPartner {if (msg.sender !=  FundingRules[0].mainPartner) throw; _;}
modifier onlyContractor {if (recipient == 0 || (msg.sender != recipient && msg.sender != creator)) throw; _;}
modifier onlyDao {if (recipient != 0) throw; _;}
function initToken(
string _tokenName,
string _tokenSymbol,
uint8 _tokenDecimals,
address _initialSupplyRecipient,
uint256 _initialSupply,
bool _transferable
);
function setTokenPriceProposal(
uint _initialPriceMultiplier,
uint _inflationRate,
uint _closingTime
);
function setFundingRules(
address _mainPartner,
bool _publicCreation,
uint _initialPriceMultiplier,
uint _maxAmountToFund,
uint _minutesFundingPeriod,
uint _inflationRate,
uint _proposalID
) external;
function createToken(
address _recipient,
uint _amount,
uint _saleDate
) internal returns (bool success);
function setFundingStartTime(uint _startTime) external;
function rewardToken(
address _recipient,
uint _amount,
uint _date
) external;
function closeFunding() internal;
function setFundingFueled() external;
function ableTransfer();
function disableTransfer();
function blockTransfer(address _shareHolder, uint _deadLine) external;
function transferFromTo(
address _from,
address _to,
uint256 _value
) internal returns (bool);
function transfer(address _to, uint256 _value);
function transferFrom(
address _from,
address _to,
uint256 _value
) returns (bool success);
function approve(address _spender, uint256 _value) returns (bool success);
event TokensCreated(address indexed Sender, address indexed TokenHolder, uint Quantity);
event FundingRulesSet(address indexed MainPartner, uint indexed FundingProposalId, uint indexed StartTime, uint ClosingTime);
event FundingFueled(uint indexed FundingProposalID, uint FundedAmount);
event TransferAble();
event TransferDisable();
}
contract PassTokenManager is PassTokenManagerInterface {
function TotalSupply() constant external returns (uint256) {
return totalSupply;
}
function balanceOf(address _owner) constant external returns (uint256 balance) {
return balances[_owner];
}
function allowance(address _owner, address _spender) constant external returns (uint256 remaining) {
return allowed[_owner][_spender];
}
function FundedAmount(uint _proposalID) constant external returns (uint) {
return fundedAmount[_proposalID];
}
function priceDivisor(uint _saleDate) constant internal returns (uint) {
uint _date = _saleDate;
if (_saleDate > FundingRules[0].closingTime) _date = FundingRules[0].closingTime;
if (_saleDate < FundingRules[0].startTime) _date = FundingRules[0].startTime;
return 100 + 100*FundingRules[0].inflationRate*(_date - FundingRules[0].startTime)/(100*365 days);
}
function actualPriceDivisor() constant external returns (uint) {
return priceDivisor(now);
}
function fundingMaxAmount(address _mainPartner) constant external returns (uint) {
if (now > FundingRules[0].closingTime
|| now < FundingRules[0].startTime
|| _mainPartner != FundingRules[0].mainPartner) {
return 0;
} else {
return FundingRules[0].maxAmountToFund;
}
}
function PassTokenManager(
address _creator,
address _client,
address _recipient
) {
if (_creator == 0
|| _client == 0
|| _client == _recipient
|| _client == address(this)
|| _recipient == address(this)) throw;
creator = _creator;
client = _client;
recipient = _recipient;
}
function initToken(
string _tokenName,
string _tokenSymbol,
uint8 _tokenDecimals,
address _initialSupplyRecipient,
uint256 _initialSupply,
bool _transferable) {
if (_initialSupplyRecipient == address(this)
|| decimals != 0
|| msg.sender != creator
|| totalSupply != 0) throw;
name = _tokenName;
symbol = _tokenSymbol;
decimals = _tokenDecimals;
if (_transferable) {
transferable = true;
TransferAble();
} else {
transferable = false;
TransferDisable();
}
balances[_initialSupplyRecipient] = _initialSupply;
totalSupply = _initialSupply;
TokensCreated(msg.sender, _initialSupplyRecipient, _initialSupply);
}
function setTokenPriceProposal(
uint _initialPriceMultiplier,
uint _inflationRate,
uint _closingTime
) onlyContractor {
if (_closingTime < now
|| now < FundingRules[1].closingTime) throw;
FundingRules[1].initialPriceMultiplier = _initialPriceMultiplier;
FundingRules[1].inflationRate = _inflationRate;
FundingRules[1].startTime = now;
FundingRules[1].closingTime = _closingTime;
}
function setFundingRules(
address _mainPartner,
bool _publicCreation,
uint _initialPriceMultiplier,
uint _maxAmountToFund,
uint _minutesFundingPeriod,
uint _inflationRate,
uint _proposalID
) external onlyClient {
if (now < FundingRules[0].closingTime
|| _mainPartner == address(this)
|| _mainPartner == client
|| (!_publicCreation && _mainPartner == 0)
|| (_publicCreation && _mainPartner != 0)
|| (recipient == 0 && _initialPriceMultiplier == 0)
|| (recipient != 0
&& (FundingRules[1].initialPriceMultiplier == 0
|| _inflationRate < FundingRules[1].inflationRate
|| now < FundingRules[1].startTime
|| FundingRules[1].closingTime < now + (_minutesFundingPeriod * 1 minutes)))
|| _maxAmountToFund == 0
|| _minutesFundingPeriod == 0
) throw;
FundingRules[0].startTime = now;
FundingRules[0].closingTime = now + _minutesFundingPeriod * 1 minutes;
FundingRules[0].mainPartner = _mainPartner;
FundingRules[0].publicCreation = _publicCreation;
if (recipient == 0) FundingRules[0].initialPriceMultiplier = _initialPriceMultiplier;
else FundingRules[0].initialPriceMultiplier = FundingRules[1].initialPriceMultiplier;
if (recipient == 0) FundingRules[0].inflationRate = _inflationRate;
else FundingRules[0].inflationRate = FundingRules[1].inflationRate;
FundingRules[0].fundedAmount = 0;
FundingRules[0].maxAmountToFund = _maxAmountToFund;
FundingRules[0].proposalID = _proposalID;
FundingRulesSet(_mainPartner, _proposalID, FundingRules[0].startTime, FundingRules[0].closingTime);
}
function createToken(
address _recipient,
uint _amount,
uint _saleDate
) internal returns (bool success) {
if (now > FundingRules[0].closingTime
|| now < FundingRules[0].startTime
||_saleDate > FundingRules[0].closingTime
|| _saleDate < FundingRules[0].startTime
|| FundingRules[0].fundedAmount + _amount > FundingRules[0].maxAmountToFund) return;
uint _a = _amount*FundingRules[0].initialPriceMultiplier;
uint _multiplier = 100*_a;
uint _quantity = _multiplier/priceDivisor(_saleDate);
if (_a/_amount != FundingRules[0].initialPriceMultiplier
|| _multiplier/100 != _a
|| totalSupply + _quantity <= totalSupply
|| totalSupply + _quantity <= _quantity) return;
balances[_recipient] += _quantity;
totalSupply += _quantity;
FundingRules[0].fundedAmount += _amount;
TokensCreated(msg.sender, _recipient, _quantity);
if (FundingRules[0].fundedAmount == FundingRules[0].maxAmountToFund) closeFunding();
return true;
}
function setFundingStartTime(uint _startTime) external onlyMainPartner {
if (now > FundingRules[0].closingTime) throw;
FundingRules[0].startTime = _startTime;
}
function rewardToken(
address _recipient,
uint _amount,
uint _date
) external onlyMainPartner {
uint _saleDate;
if (_date == 0) _saleDate = now; else _saleDate = _date;
if (!createToken(_recipient, _amount, _saleDate)) throw;
}
function closeFunding() internal {
if (recipient == 0) fundedAmount[FundingRules[0].proposalID] = FundingRules[0].fundedAmount;
FundingRules[0].closingTime = now;
}
function setFundingFueled() external onlyMainPartner {
if (now > FundingRules[0].closingTime) throw;
closeFunding();
if (recipient == 0) FundingFueled(FundingRules[0].proposalID, FundingRules[0].fundedAmount);
}
function ableTransfer() onlyClient {
if (!transferable) {
transferable = true;
TransferAble();
}
}
function disableTransfer() onlyClient {
if (transferable) {
transferable = false;
TransferDisable();
}
}
function blockTransfer(address _shareHolder, uint _deadLine) external onlyClient onlyDao {
if (_deadLine > blockedDeadLine[_shareHolder]) {
blockedDeadLine[_shareHolder] = _deadLine;
}
}
function transferFromTo(
address _from,
address _to,
uint256 _value
) internal returns (bool) {
if (transferable
&& now > blockedDeadLine[_from]
&& now > blockedDeadLine[_to]
&& _to != address(this)
&& balances[_from] >= _value
&& balances[_to] + _value > balances[_to]
&& balances[_to] + _value >= _value
) {
balances[_from] -= _value;
balances[_to] += _value;
return true;
} else {
return false;
}
}
function transfer(address _to, uint256 _value) {
if (!transferFromTo(msg.sender, _to, _value)) throw;
}
function transferFrom(
address _from,
address _to,
uint256 _value
) returns (bool success) {
if (allowed[_from][msg.sender] < _value
|| !transferFromTo(_from, _to, _value)) throw;
allowed[_from][msg.sender] -= _value;
}
function approve(address _spender, uint256 _value) returns (bool success) {
allowed[msg.sender][_spender] = _value;
return true;
}
}
pragma solidity ^0.4.2;
contract PassManagerInterface is PassTokenManagerInterface {
struct proposal {
uint amount;
string description;
bytes32 hashOfTheDocument;
uint dateOfProposal;
uint orderAmount;
uint dateOfOrder;
}
proposal[] public proposals;
function () payable;
function updateRecipient(address _newRecipient);
function buyShares() payable;
function buySharesFor(address _recipient) payable;
function newProposal(
uint _amount,
string _description,
bytes32 _hashOfTheDocument
) returns (uint);
function order(
uint _proposalID,
uint _amount
) external returns (bool) ;
function sendTo(
address _recipient,
uint _amount
) external returns (bool);
function withdraw(uint _amount);
event ProposalAdded(uint indexed ProposalID, uint Amount, string Description);
event Order(uint indexed ProposalID, uint Amount);
event Withdawal(address indexed Recipient, uint Amount);
}
contract PassManager is PassManagerInterface, PassTokenManager {
function PassManager(
address _creator,
address _client,
address _recipient
) PassTokenManager(
_creator,
_client,
_recipient
) {
proposals.length = 1;
}
function () payable {}
function updateRecipient(address _newRecipient) onlyContractor {
if (_newRecipient == 0
|| _newRecipient == client) throw;
recipient = _newRecipient;
}
function buyShares() payable {
buySharesFor(msg.sender);
}
function buySharesFor(address _recipient) payable onlyDao {
if (!FundingRules[0].publicCreation
|| !createToken(_recipient, msg.value, now)) throw;
}
function newProposal(
uint _amount,
string _description,
bytes32 _hashOfTheDocument
) onlyContractor returns (uint) {
uint _proposalID = proposals.length++;
proposal c = proposals[_proposalID];
c.amount = _amount;
c.description = _description;
c.hashOfTheDocument = _hashOfTheDocument;
c.dateOfProposal = now;
ProposalAdded(_proposalID, c.amount, c.description);
return _proposalID;
}
function order(
uint _proposalID,
uint _orderAmount
) external onlyClient returns (bool) {
proposal c = proposals[_proposalID];
uint _sum = c.orderAmount + _orderAmount;
if (_sum > c.amount
|| _sum < c.orderAmount
|| _sum < _orderAmount) return;
c.orderAmount = _sum;
c.dateOfOrder = now;
Order(_proposalID, _orderAmount);
return true;
}
function sendTo(
address _recipient,
uint _amount
) external onlyClient onlyDao returns (bool) {
if (_recipient.send(_amount)) return true;
else return false;
}
function withdraw(uint _amount) onlyContractor {
if (!recipient.send(_amount)) throw;
Withdawal(recipient, _amount);
}
}
contract PassManagerCreator {
event NewPassManager(address Creator, address Client, address Recipient, address PassManager);
function createManager(
address _client,
address _recipient
) returns (PassManager) {
PassManager _passManager = new PassManager(
msg.sender,
_client,
_recipient
);
NewPassManager(msg.sender, _client, _recipient, _passManager);
return _passManager;
}
}
pragma solidity ^0.4.2;
contract PassFundingInterface {
struct Partner {
address partnerAddress;
uint presaleAmount;
uint presaleDate;
uint fundingAmountLimit;
uint fundedAmount;
bool valid;
}
address public creator;
PassManager public DaoManager;
bool tokenCreation;
PassManager public contractorManager;
uint public minFundingAmount;
uint public minPresaleAmount;
uint public maxPresaleAmount;
uint public startTime;
uint public closingTime;
uint minAmountLimit;
uint maxAmountLimit;
uint divisorBalanceLimit;
uint multiplierSharesLimit;
uint divisorSharesLimit;
bool public limitSet;
bool public allSet;
Partner[] public partners;
mapping (address => uint) public partnerID;
uint public totalFunded;
uint sumOfFundingAmountLimits;
uint public pauseClosingTime;
bool IsfundingAborted;
uint setFromPartner;
uint refundFromPartner;
modifier onlyCreator {if (msg.sender != creator) throw; _ ;}
function SetContractorManager(address _contractorManager);
function SetPresaleAmountLimits(
uint _minPresaleAmount,
uint _maxPresaleAmount
);
function () payable;
function presale() payable returns (bool);
function setPartners(
bool _valid,
uint _from,
uint _to
);
function setShareHolders(
bool _valid,
uint _from,
uint _to
);
function abortFunding();
function pause(uint _pauseClosingTime) {
pauseClosingTime = _pauseClosingTime;
}
function setLimits(
uint _minAmountLimit,
uint _maxAmountLimit,
uint _divisorBalanceLimit,
uint _multiplierSharesLimit,
uint _divisorSharesLimit
);
function setFunding(uint _to) returns (bool _success);
function fundDaoFor(
uint _from,
uint _to
) returns (bool);
function fundDao() returns (bool);
function refundFor(uint _partnerID) internal returns (bool);
function refundForValidPartners(uint _to);
function refundForAll(
uint _from,
uint _to);
function refund();
function estimatedFundingAmount(
uint _minAmountLimit,
uint _maxAmountLimit,
uint _divisorBalanceLimit,
uint _multiplierSharesLimit,
uint _divisorSharesLimit,
uint _from,
uint _to
) constant external returns (uint);
function partnerFundingLimit(
uint _index,
uint _minAmountLimit,
uint _maxAmountLimit,
uint _divisorBalanceLimit,
uint _multiplierSharesLimit,
uint _divisorSharesLimit
) internal returns (uint);
function numberOfPartners() constant external returns (uint);
function numberOfValidPartners(
uint _from,
uint _to
) constant external returns (uint);
event ContractorManagerSet(address ContractorManagerAddress);
event IntentionToFund(address indexed partner, uint amount);
event Fund(address indexed partner, uint amount);
event Refund(address indexed partner, uint amount);
event LimitSet(uint minAmountLimit, uint maxAmountLimit, uint divisorBalanceLimit,
uint _multiplierSharesLimit, uint divisorSharesLimit);
event PartnersNotSet(uint sumOfFundingAmountLimits);
event AllPartnersSet(uint fundingAmount);
event Fueled();
event FundingClosed();
}
contract PassFunding is PassFundingInterface {
function PassFunding (
address _creator,
address _DaoManager,
uint _minFundingAmount,
uint _startTime,
uint _closingTime
) {
if (_creator == _DaoManager
|| _creator == 0
|| _DaoManager == 0
|| (_startTime < now && _startTime != 0)) throw;
creator = _creator;
DaoManager = PassManager(_DaoManager);
minFundingAmount = _minFundingAmount;
if (_startTime == 0) {startTime = now;} else {startTime = _startTime;}
if (_closingTime <= startTime) throw;
closingTime = _closingTime;
setFromPartner = 1;
refundFromPartner = 1;
partners.length = 1;
}
function SetContractorManager(address _contractorManager) onlyCreator {
if (_contractorManager == 0
|| limitSet
|| address(contractorManager) != 0
|| creator == _contractorManager
|| _contractorManager == address(DaoManager)) throw;
tokenCreation = true;
contractorManager = PassManager(_contractorManager);
ContractorManagerSet(_contractorManager);
}
function SetPresaleAmountLimits(
uint _minPresaleAmount,
uint _maxPresaleAmount
) onlyCreator {
if (limitSet) throw;
minPresaleAmount = _minPresaleAmount;
maxPresaleAmount = _maxPresaleAmount;
}
function () payable {
if (!presale()) throw;
}
function presale() payable returns (bool) {
if (msg.value <= 0
|| now < startTime
|| now > closingTime
|| now < pauseClosingTime
|| limitSet
|| msg.value < minPresaleAmount
|| msg.value > maxPresaleAmount
|| msg.sender == creator
) throw;
if (partnerID[msg.sender] == 0) {
uint _partnerID = partners.length++;
Partner t = partners[_partnerID];
partnerID[msg.sender] = _partnerID;
t.partnerAddress = msg.sender;
t.presaleAmount += msg.value;
t.presaleDate = now;
} else {
Partner p = partners[partnerID[msg.sender]];
if (p.presaleAmount + msg.value > maxPresaleAmount) throw;
p.presaleDate = (p.presaleDate*p.presaleAmount + now*msg.value)/(p.presaleAmount + msg.value);
p.presaleAmount += msg.value;
}
IntentionToFund(msg.sender, msg.value);
return true;
}
function setPartners(
bool _valid,
uint _from,
uint _to
) onlyCreator {
if (limitSet
||_from < 1
|| _to > partners.length - 1) throw;
for (uint i = _from; i <= _to; i++) {
Partner t = partners[i];
t.valid = _valid;
}
}
function setShareHolders(
bool _valid,
uint _from,
uint _to
) onlyCreator {
if (limitSet
||_from < 1
|| _to > partners.length - 1) throw;
for (uint i = _from; i <= _to; i++) {
Partner t = partners[i];
if (DaoManager.balanceOf(t.partnerAddress) != 0) t.valid = _valid;
}
}
function abortFunding() onlyCreator {
limitSet = true;
maxPresaleAmount = 0;
IsfundingAborted = true;
}
function pause(uint _pauseClosingTime) onlyCreator {
pauseClosingTime = _pauseClosingTime;
}
function setLimits(
uint _minAmountLimit,
uint _maxAmountLimit,
uint _divisorBalanceLimit,
uint _multiplierSharesLimit,
uint _divisorSharesLimit
) onlyCreator {
if (limitSet) throw;
minAmountLimit = _minAmountLimit;
maxAmountLimit = _maxAmountLimit;
divisorBalanceLimit = _divisorBalanceLimit;
multiplierSharesLimit = _multiplierSharesLimit;
divisorSharesLimit = _divisorSharesLimit;
limitSet = true;
LimitSet(_minAmountLimit, _maxAmountLimit, _divisorBalanceLimit, _multiplierSharesLimit, _divisorSharesLimit);
}
function setFunding(uint _to) onlyCreator returns (bool _success) {
uint _fundingMaxAmount = DaoManager.fundingMaxAmount(address(this));
if (!limitSet
|| _fundingMaxAmount < minFundingAmount
|| setFromPartner > _to
|| _to > partners.length - 1) throw;
DaoManager.setFundingStartTime(startTime);
if (tokenCreation) contractorManager.setFundingStartTime(startTime);
if (setFromPartner == 1) sumOfFundingAmountLimits = 0;
for (uint i = setFromPartner; i <= _to; i++) {
partners[i].fundingAmountLimit = partnerFundingLimit(i, minAmountLimit, maxAmountLimit,
divisorBalanceLimit, multiplierSharesLimit, divisorSharesLimit);
sumOfFundingAmountLimits += partners[i].fundingAmountLimit;
}
setFromPartner = _to + 1;
if (setFromPartner >= partners.length) {
setFromPartner = 1;
if (sumOfFundingAmountLimits < minFundingAmount
|| sumOfFundingAmountLimits > _fundingMaxAmount) {
maxPresaleAmount = 0;
IsfundingAborted = true;
PartnersNotSet(sumOfFundingAmountLimits);
return;
}
else {
allSet = true;
AllPartnersSet(sumOfFundingAmountLimits);
return true;
}
}
}
function fundDaoFor(
uint _from,
uint _to
) returns (bool) {
if (!allSet) throw;
if (_from < 1 || _to > partners.length - 1) throw;
address _partner;
uint _amountToFund;
uint _sumAmountToFund = 0;
for (uint i = _from; i <= _to; i++) {
_partner = partners[i].partnerAddress;
_amountToFund = partners[i].fundingAmountLimit - partners[i].fundedAmount;
if (_amountToFund > 0) {
partners[i].fundedAmount += _amountToFund;
_sumAmountToFund += _amountToFund;
DaoManager.rewardToken(_partner, _amountToFund, partners[i].presaleDate);
if (tokenCreation) {
contractorManager.rewardToken(_partner, _amountToFund, partners[i].presaleDate);
}
}
}
if (_sumAmountToFund == 0) return;
if (!DaoManager.send(_sumAmountToFund)) throw;
totalFunded += _sumAmountToFund;
if (totalFunded == sumOfFundingAmountLimits) {
DaoManager.setFundingFueled();
if (tokenCreation) contractorManager.setFundingFueled();
Fueled();
}
return true;
}
function fundDao() returns (bool) {
return fundDaoFor(partnerID[msg.sender], partnerID[msg.sender]);
}
function refundFor(uint _partnerID) internal returns (bool) {
Partner t = partners[_partnerID];
uint _amountnotToRefund = t.presaleAmount;
uint _amountToRefund;
if (t.presaleAmount > maxPresaleAmount && t.valid) {
_amountnotToRefund = maxPresaleAmount;
}
if (t.fundedAmount > 0 || now > closingTime) {
_amountnotToRefund = t.fundedAmount;
}
_amountToRefund = t.presaleAmount - _amountnotToRefund;
if (_amountToRefund <= 0) return true;
t.presaleAmount = _amountnotToRefund;
if (t.partnerAddress.send(_amountToRefund)) {
Refund(t.partnerAddress, _amountToRefund);
return true;
} else {
t.presaleAmount = _amountnotToRefund + _amountToRefund;
return false;
}
}
function refundForValidPartners(uint _to) {
if (refundFromPartner > _to || _to > partners.length - 1) throw;
for (uint i = refundFromPartner; i <= _to; i++) {
if (partners[i].valid) {
if (!refundFor(i)) throw;
}
}
refundFromPartner = _to + 1;
if (refundFromPartner >= partners.length) {
refundFromPartner = 1;
if ((totalFunded >= sumOfFundingAmountLimits && allSet && closingTime > now)
|| IsfundingAborted) {
closingTime = now;
FundingClosed();
}
}
}
function refundForAll(
uint _from,
uint _to) {
if (_from < 1 || _to > partners.length - 1) throw;
for (uint i = _from; i <= _to; i++) {
if (!refundFor(i)) throw;
}
}
function refund() {
refundForAll(partnerID[msg.sender], partnerID[msg.sender]);
}
function estimatedFundingAmount(
uint _minAmountLimit,
uint _maxAmountLimit,
uint _divisorBalanceLimit,
uint _multiplierSharesLimit,
uint _divisorSharesLimit,
uint _from,
uint _to
) constant external returns (uint) {
if (_from < 1 || _to > partners.length - 1) throw;
uint _total = 0;
for (uint i = _from; i <= _to; i++) {
_total += partnerFundingLimit(i, _minAmountLimit, _maxAmountLimit,
_divisorBalanceLimit, _multiplierSharesLimit, _divisorSharesLimit);
}
return _total;
}
function partnerFundingLimit(
uint _index,
uint _minAmountLimit,
uint _maxAmountLimit,
uint _divisorBalanceLimit,
uint _multiplierSharesLimit,
uint _divisorSharesLimit
) internal returns (uint) {
uint _amount;
uint _amount1;
Partner t = partners[_index];
if (t.valid) {
_amount = t.presaleAmount;
if (_divisorBalanceLimit > 0) {
_amount1 = uint(t.partnerAddress.balance)/uint(_divisorBalanceLimit);
if (_amount > _amount1) _amount = _amount1;
}
if (_multiplierSharesLimit > 0 && _divisorSharesLimit > 0) {
uint _balance = uint(DaoManager.balanceOf(t.partnerAddress));
uint _multiplier = _balance*_multiplierSharesLimit;
if (_multiplier/_balance != _multiplierSharesLimit) throw;
_amount1 = _multiplier/_divisorSharesLimit;
if (_amount > _amount1) _amount = _amount1;
}
if (_amount > _maxAmountLimit) _amount = _maxAmountLimit;
if (_amount < _minAmountLimit) _amount = _minAmountLimit;
if (_amount > t.presaleAmount) _amount = t.presaleAmount;
}
return _amount;
}
function numberOfPartners() constant external returns (uint) {
return partners.length - 1;
}
function numberOfValidPartners(
uint _from,
uint _to
) constant external returns (uint) {
if (_from < 1 || _to > partners.length-1) throw;
uint _total = 0;
for (uint i = _from; i <= _to; i++) {
if (partners[i].valid) _total += 1;
}
return _total;
}
}
contract PassFundingCreator {
event NewFunding(address creator, address DaoManager,
uint MinFundingAmount, uint StartTime, uint ClosingTime, address FundingContractAddress);
function createFunding(
address _DaoManager,
uint _minFundingAmount,
uint _startTime,
uint _closingTime
) returns (PassFunding) {
PassFunding _newFunding = new PassFunding(
msg.sender,
_DaoManager,
_minFundingAmount,
_startTime,
_closingTime
);
NewFunding(msg.sender, _DaoManager,
_minFundingAmount, _startTime, _closingTime, address(_newFunding));
return _newFunding;
}
}