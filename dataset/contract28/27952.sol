pragma solidity ^0.4.18;
interface ISTRegistrar {
function createSecurityToken (
string _name,
string _ticker,
uint256 _totalSupply,
uint8 _decimals,
address _owner,
uint256 _maxPoly,
address _host,
uint256 _fee,
uint8 _type,
uint256 _lockupPeriod,
uint8 _quorum
) external;
}
interface IERC20 {
function balanceOf(address _owner) public view returns (uint256 balance);
function transfer(address _to, uint256 _value) public returns (bool success);
function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
function approve(address _spender, uint256 _value) public returns (bool success);
function allowance(address _owner, address _spender) public view returns (uint256 remaining);
event Transfer(address indexed _from, address indexed _to, uint256 _value);
event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}
library SafeMath {
function mul(uint256 a, uint256 b) internal pure returns (uint256) {
uint256 c = a * b;
assert(a == 0 || c / a == b);
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
function max64(uint64 a, uint64 b) internal pure returns (uint64) {
return a >= b ? a : b;
}
function min64(uint64 a, uint64 b) internal pure returns (uint64) {
return a < b ? a : b;
}
function max256(uint256 a, uint256 b) internal pure returns (uint256) {
return a >= b ? a : b;
}
function min256(uint256 a, uint256 b) internal pure returns (uint256) {
return a < b ? a : b;
}
}
interface ICustomers {
function newProvider(address _providerAddress, string _name, bytes32 _details, uint256 _fee) public returns (bool success);
function changeFee(uint256 _newFee) public returns (bool success);
function verifyCustomer(
address _customer,
bytes32 _countryJurisdiction,
bytes32 _divisionJurisdiction,
uint8 _role,
bool _accredited,
uint256 _expires
) public returns (bool success);
function getCustomer(address _provider, address _customer) public constant returns (
bytes32,
bytes32,
bool,
uint8,
bool,
uint256
);
function getProvider(address _providerAddress) public constant returns (
string name,
uint256 joined,
bytes32 details,
uint256 fee
);
}
interface ICompliance {
function setRegsitrarAddress(address _STRegistrar) public returns (bool);
function createTemplate(
string _offeringType,
bytes32 _issuerJurisdiction,
bool _accredited,
address _KYC,
bytes32 _details,
uint256 _expires,
uint256 _fee,
uint8 _quorum,
uint256 _vestingPeriod
) public;
function proposeTemplate(
address _securityToken,
address _template
) public returns (bool success);
function proposeOfferingContract(
address _securityToken,
address _stoContract
) public returns (bool success);
function cancelTemplateProposal(
address _securityToken,
uint256 _templateProposalIndex
) public returns (bool success);
function setSTO (
address _STOAddress,
uint256 _fee,
uint256 _vestingPeriod,
uint8 _quorum
) public returns (bool success);
function cancelOfferingProposal(
address _securityToken,
uint256 _offeringProposalIndex
) public returns (bool success);
function updateTemplateReputation (address _template, uint8 _templateIndex) external returns (bool success);
function updateOfferingReputation (address _stoContract, uint8 _offeringProposalIndex) external returns (bool success);
function getTemplateByProposal(address _securityTokenAddress, uint8 _templateIndex) view public returns (
address _template
);
function getOfferingByProposal(address _securityTokenAddress, uint8 _offeringProposalIndex) view public returns (
address stoContract,
address auditor,
uint256 vestingPeriod,
uint8 quorum,
uint256 fee
);
}
interface ITemplate {
function addJurisdiction(bytes32[] _allowedJurisdictions, bool[] _allowed) public;
function addDivisionJurisdiction(bytes32[] _blockedDivisionJurisdictions, bool[] _blocked) public;
function addRoles(uint8[] _allowedRoles) public;
function updateDetails(bytes32 _details) public returns (bool allowed);
function finalizeTemplate() public returns (bool success);
function checkTemplateRequirements(
bytes32 _countryJurisdiction,
bytes32 _divisionJurisdiction,
bool _accredited,
uint8 _role
) public constant returns (bool allowed);
function getTemplateDetails() view public returns (bytes32, bool);
function getUsageDetails() view public returns (uint256, uint8, uint256, address, address);
}
contract STO20 {
uint256 public startTime;
uint256 public endTime;
function securityTokenOffering(
address _tokenAddress,
uint256 _startTime,
uint256 _endTime
) external ;
}
contract SecurityToken is IERC20 {
using SafeMath for uint256;
string public VERSION = "1";
IERC20 public POLY;
ICompliance public PolyCompliance;
ITemplate public Template;
ICustomers public PolyCustomers;
STO20 public STO;
string public name;
uint8 public decimals;
string public symbol;
address public owner;
uint256 public totalSupply;
mapping(address => mapping(address => uint256)) allowed;
mapping(address => uint256) balances;
address public delegate;
bytes32 public merkleRoot;
address public KYC;
struct Shareholder {
address verifier;
bool allowed;
uint8 role;
}
mapping(address => Shareholder) public shareholders;
bool public isSTOProposed = false;
bool public hasOfferingStarted = false;
uint256 public maxPoly;
uint256 public startSTO;
uint256 public endSTO;
struct Allocation {
uint256 amount;
uint256 vestingPeriod;
uint8 quorum;
uint256 yayVotes;
uint256 yayPercent;
bool frozen;
}
mapping(address => mapping(address => bool)) public voted;
mapping(address => Allocation) public allocations;
mapping(address => uint256) public contributedToSTO;
uint256 public tokensIssuedBySTO = 0;
event LogTemplateSet(address indexed _delegateAddress, address _template, address indexed _KYC);
event LogUpdatedComplianceProof(bytes32 _merkleRoot, bytes32 _complianceProofHash);
event LogSetSTOContract(address _STO, address indexed _STOtemplate, address indexed _auditor, uint256 _startTime, uint256 _endTime);
event LogNewWhitelistedAddress(address _KYC, address _shareholder, uint8 _role);
event LogNewBlacklistedAddress(address _KYC, address _shareholder);
event LogVoteToFreeze(address _recipient, uint256 _yayPercent, uint8 _quorum, bool _frozen);
event LogTokenIssued(address indexed _contributor, uint256 _stAmount, uint256 _polyContributed, uint256 _timestamp);
modifier onlyOwner() {
require (msg.sender == owner);
_;
}
modifier onlyDelegate() {
require (msg.sender == delegate);
_;
}
modifier onlyOwnerOrDelegate() {
require (msg.sender == delegate || msg.sender == owner);
_;
}
modifier onlySTO() {
require (msg.sender == address(STO));
_;
}
modifier onlyShareholder() {
require (shareholders[msg.sender].allowed);
_;
}
function SecurityToken(
string _name,
string _ticker,
uint256 _totalSupply,
uint8 _decimals,
address _owner,
uint256 _maxPoly,
uint256 _lockupPeriod,
uint8 _quorum,
address _polyTokenAddress,
address _polyCustomersAddress,
address _polyComplianceAddress
) public
{
decimals = _decimals;
name = _name;
symbol = _ticker;
owner = _owner;
maxPoly = _maxPoly;
totalSupply = _totalSupply;
balances[_owner] = _totalSupply;
POLY = IERC20(_polyTokenAddress);
PolyCustomers = ICustomers(_polyCustomersAddress);
PolyCompliance = ICompliance(_polyComplianceAddress);
allocations[owner] = Allocation(0, _lockupPeriod, _quorum, 0, 0, false);
Transfer(0x0, _owner, _totalSupply);
}
function selectTemplate(uint8 _templateIndex) public onlyOwner returns (bool success) {
require(!isSTOProposed);
address _template = PolyCompliance.getTemplateByProposal(this, _templateIndex);
require(_template != address(0));
Template = ITemplate(_template);
var (_fee, _quorum, _vestingPeriod, _delegate, _KYC) = Template.getUsageDetails();
require(POLY.balanceOf(this) >= _fee);
allocations[_delegate] = Allocation(_fee, _vestingPeriod, _quorum, 0, 0, false);
delegate = _delegate;
KYC = _KYC;
PolyCompliance.updateTemplateReputation(_template, _templateIndex);
LogTemplateSet(_delegate, _template, _KYC);
return true;
}
function updateComplianceProof(
bytes32 _newMerkleRoot,
bytes32 _merkleRoot
) public onlyOwnerOrDelegate returns (bool success)
{
merkleRoot = _newMerkleRoot;
LogUpdatedComplianceProof(merkleRoot, _merkleRoot);
return true;
}
function selectOfferingProposal (uint8 _offeringProposalIndex) public onlyDelegate returns (bool success) {
require(!isSTOProposed);
var (_stoContract, _auditor, _vestingPeriod, _quorum, _fee) = PolyCompliance.getOfferingByProposal(this, _offeringProposalIndex);
require(_stoContract != address(0));
require(merkleRoot != 0x0);
require(delegate != address(0));
require(POLY.balanceOf(this) >= allocations[delegate].amount.add(_fee));
STO = STO20(_stoContract);
require(STO.startTime() > now && STO.endTime() > STO.startTime());
allocations[_auditor] = Allocation(_fee, _vestingPeriod, _quorum, 0, 0, false);
shareholders[address(STO)] = Shareholder(this, true, 5);
startSTO = STO.startTime();
endSTO = STO.endTime();
isSTOProposed = !isSTOProposed;
PolyCompliance.updateOfferingReputation(_stoContract, _offeringProposalIndex);
LogSetSTOContract(STO, _stoContract, _auditor, startSTO, endSTO);
return true;
}
function startOffering() onlyOwner external returns (bool success) {
require(isSTOProposed);
require(!hasOfferingStarted);
uint256 tokenAmount = this.balanceOf(msg.sender);
require(tokenAmount == totalSupply);
balances[STO] = balances[STO].add(tokenAmount);
balances[msg.sender] = balances[msg.sender].sub(tokenAmount);
hasOfferingStarted = true;
Transfer(owner, STO, tokenAmount);
return true;
}
function addToWhitelist(address _whitelistAddress) onlyOwner public returns (bool success) {
var (countryJurisdiction, divisionJurisdiction, accredited, role, verified, expires) = PolyCustomers.getCustomer(KYC, _whitelistAddress);
require(verified && expires > now);
require(Template.checkTemplateRequirements(countryJurisdiction, divisionJurisdiction, accredited, role));
shareholders[_whitelistAddress] = Shareholder(msg.sender, true, role);
LogNewWhitelistedAddress(msg.sender, _whitelistAddress, role);
return true;
}
function addToBlacklist(address _blacklistAddress) onlyOwner public returns (bool success) {
require(shareholders[_blacklistAddress].allowed);
shareholders[_blacklistAddress].allowed = false;
LogNewBlacklistedAddress(msg.sender, _blacklistAddress);
return true;
}
function withdrawPoly() public returns (bool success) {
if (delegate == address(0)) {
return POLY.transfer(owner, POLY.balanceOf(this));
}
require(now > endSTO + allocations[msg.sender].vestingPeriod);
require(!allocations[msg.sender].frozen);
require(allocations[msg.sender].amount > 0);
require(POLY.transfer(msg.sender, allocations[msg.sender].amount));
allocations[msg.sender].amount = 0;
return true;
}
function voteToFreeze(address _recipient) public onlyShareholder returns (bool success) {
require(delegate != address(0));
require(now > endSTO);
require(now < endSTO.add(allocations[_recipient].vestingPeriod));
require(!voted[msg.sender][_recipient]);
voted[msg.sender][_recipient] = true;
allocations[_recipient].yayVotes = allocations[_recipient].yayVotes.add(contributedToSTO[msg.sender]);
allocations[_recipient].yayPercent = allocations[_recipient].yayVotes.mul(100).div(allocations[owner].amount);
if (allocations[_recipient].yayPercent >= allocations[_recipient].quorum) {
allocations[_recipient].frozen = true;
}
LogVoteToFreeze(_recipient, allocations[_recipient].yayPercent, allocations[_recipient].quorum, allocations[_recipient].frozen);
return true;
}
function issueSecurityTokens(address _contributor, uint256 _amountOfSecurityTokens, uint256 _polyContributed) public onlySTO returns (bool success) {
require(hasOfferingStarted);
require(shareholders[_contributor].allowed);
require(now >= startSTO && now <= endSTO);
require(POLY.transferFrom(_contributor, this, _polyContributed));
require(tokensIssuedBySTO.add(_amountOfSecurityTokens) <= totalSupply);
require(maxPoly >= allocations[owner].amount.add(_polyContributed));
balances[STO] = balances[STO].sub(_amountOfSecurityTokens);
balances[_contributor] = balances[_contributor].add(_amountOfSecurityTokens);
Transfer(STO, _contributor, _amountOfSecurityTokens);
tokensIssuedBySTO = tokensIssuedBySTO.add(_amountOfSecurityTokens);
contributedToSTO[_contributor] = contributedToSTO[_contributor].add(_polyContributed);
allocations[owner].amount = allocations[owner].amount.add(_polyContributed);
LogTokenIssued(_contributor, _amountOfSecurityTokens, _polyContributed, now);
return true;
}
function getTokenDetails() view public returns (address, address, bytes32, address, address) {
return (Template, delegate, merkleRoot, STO, KYC);
}
function transfer(address _to, uint256 _value) public returns (bool success) {
if (shareholders[_to].allowed && shareholders[msg.sender].allowed && balances[msg.sender] >= _value && _value > 0) {
balances[msg.sender] = balances[msg.sender].sub(_value);
balances[_to] = balances[_to].add(_value);
Transfer(msg.sender, _to, _value);
return true;
} else {
return false;
}
}
function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
if (shareholders[_to].allowed && shareholders[_from].allowed && balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0) {
uint256 _allowance = allowed[_from][msg.sender];
balances[_from] = balances[_from].sub(_value);
allowed[_from][msg.sender] = _allowance.sub(_value);
balances[_to] = balances[_to].add(_value);
Transfer(_from, _to, _value);
return true;
} else {
return false;
}
}
function balanceOf(address _owner) public constant returns (uint256 balance) {
return balances[_owner];
}
function approve(address _spender, uint256 _value) public returns (bool success) {
require(_value != 0);
allowed[msg.sender][_spender] = _value;
Approval(msg.sender, _spender, _value);
return true;
}
function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
return allowed[_owner][_spender];
}
}
contract Customers is ICustomers {
string public VERSION = "1";
IERC20 POLY;
struct Customer {
bytes32 countryJurisdiction;
bytes32 divisionJurisdiction;
uint256 joined;
uint8 role;
bool verified;
bool accredited;
bytes32 proof;
uint256 expires;
}
mapping(address => mapping(address => Customer)) public customers;
struct Provider {
string name;
uint256 joined;
bytes32 details;
uint256 fee;
}
mapping(address => Provider) public providers;
event LogNewProvider(address providerAddress, string name, bytes32 details);
event LogCustomerVerified(address customer, address provider, uint8 role);
modifier onlyProvider() {
require(providers[msg.sender].details != 0x0);
_;
}
function Customers(address _polyTokenAddress) public {
POLY = IERC20(_polyTokenAddress);
}
function newProvider(address _providerAddress, string _name, bytes32 _details, uint256 _fee) public returns (bool success) {
require(_providerAddress != address(0));
require(_details != 0x0);
require(providers[_providerAddress].details == 0x0);
providers[_providerAddress] = Provider(_name, now, _details, _fee);
LogNewProvider(_providerAddress, _name, _details);
return true;
}
function changeFee(uint256 _newFee) public returns (bool success) {
require(providers[msg.sender].details != 0x0);
providers[msg.sender].fee = _newFee;
return true;
}
function verifyCustomer(
address _customer,
bytes32 _countryJurisdiction,
bytes32 _divisionJurisdiction,
uint8 _role,
bool _accredited,
uint256 _expires
) public onlyProvider returns (bool success)
{
require(_expires > now);
require(POLY.transferFrom(_customer, msg.sender, providers[msg.sender].fee));
customers[msg.sender][_customer].countryJurisdiction = _countryJurisdiction;
customers[msg.sender][_customer].divisionJurisdiction = _divisionJurisdiction;
customers[msg.sender][_customer].role = _role;
customers[msg.sender][_customer].accredited = _accredited;
customers[msg.sender][_customer].expires = _expires;
customers[msg.sender][_customer].verified = true;
LogCustomerVerified(_customer, msg.sender, _role);
return true;
}
function getCustomer(address _provider, address _customer) public constant returns (
bytes32,
bytes32,
bool,
uint8,
bool,
uint256
) {
return (
customers[_provider][_customer].countryJurisdiction,
customers[_provider][_customer].divisionJurisdiction,
customers[_provider][_customer].accredited,
customers[_provider][_customer].role,
customers[_provider][_customer].verified,
customers[_provider][_customer].expires
);
}
function getProvider(address _providerAddress) public constant returns (
string name,
uint256 joined,
bytes32 details,
uint256 fee
) {
return (
providers[_providerAddress].name,
providers[_providerAddress].joined,
providers[_providerAddress].details,
providers[_providerAddress].fee
);
}
}
contract Template is ITemplate {
string public VERSION = "1";
address public owner;
string public offeringType;
bytes32 public issuerJurisdiction;
mapping(bytes32 => bool) public allowedJurisdictions;
mapping(bytes32 => bool) public blockedDivisionJurisdictions;
mapping(uint8 => bool) public allowedRoles;
bool public accredited;
address public KYC;
bytes32 details;
bool finalized;
uint256 public expires;
uint256 fee;
uint8 quorum;
uint256 vestingPeriod;
event DetailsUpdated(bytes32 _prevDetails, bytes32 _newDetails, uint _updateDate);
function Template (
address _owner,
string _offeringType,
bytes32 _issuerJurisdiction,
bool _accredited,
address _KYC,
bytes32 _details,
uint256 _expires,
uint256 _fee,
uint8 _quorum,
uint256 _vestingPeriod
) public
{
require(_KYC != address(0) && _owner != address(0));
require(_fee > 0);
require(_details.length > 0 && _expires > now && _issuerJurisdiction.length > 0);
require(_quorum > 0 && _quorum <= 100);
require(_vestingPeriod > 0);
owner = _owner;
offeringType = _offeringType;
issuerJurisdiction = _issuerJurisdiction;
accredited = _accredited;
KYC = _KYC;
details = _details;
finalized = false;
expires = _expires;
fee = _fee;
quorum = _quorum;
vestingPeriod = _vestingPeriod;
}
function addJurisdiction(bytes32[] _allowedJurisdictions, bool[] _allowed) public {
require(owner == msg.sender);
require(_allowedJurisdictions.length == _allowed.length);
require(!finalized);
for (uint i = 0; i < _allowedJurisdictions.length; ++i) {
allowedJurisdictions[_allowedJurisdictions[i]] = _allowed[i];
}
}
function addDivisionJurisdiction(bytes32[] _blockedDivisionJurisdictions, bool[] _blocked) public {
require(owner == msg.sender);
require(_blockedDivisionJurisdictions.length == _blocked.length);
require(!finalized);
for (uint i = 0; i < _blockedDivisionJurisdictions.length; ++i) {
blockedDivisionJurisdictions[_blockedDivisionJurisdictions[i]] = _blocked[i];
}
}
function addRoles(uint8[] _allowedRoles) public {
require(owner == msg.sender);
require(!finalized);
for (uint i = 0; i < _allowedRoles.length; ++i) {
allowedRoles[_allowedRoles[i]] = true;
}
}
function updateDetails(bytes32 _details) public returns (bool allowed) {
require(_details != 0x0);
require(owner == msg.sender);
bytes32 prevDetails = details;
details = _details;
DetailsUpdated(prevDetails, details, now);
return true;
}
function finalizeTemplate() public returns (bool success) {
require(owner == msg.sender);
finalized = true;
return true;
}
function checkTemplateRequirements(
bytes32 _countryJurisdiction,
bytes32 _divisionJurisdiction,
bool _accredited,
uint8 _role
) public constant returns (bool allowed)
{
require(_countryJurisdiction != 0x0);
require(allowedJurisdictions[_countryJurisdiction] || !blockedDivisionJurisdictions[_divisionJurisdiction]);
require(allowedRoles[_role]);
if (accredited) {
require(_accredited);
}
return true;
}
function getTemplateDetails() view public returns (bytes32, bool) {
require(expires > now);
return (details, finalized);
}
function getUsageDetails() view public returns (uint256, uint8, uint256, address, address) {
return (fee, quorum, vestingPeriod, owner, KYC);
}
}
interface ISecurityToken {
function SecurityToken(
string _name,
string _ticker,
uint256 _totalSupply,
uint8 _decimals,
address _owner,
uint256 _maxPoly,
uint256 _lockupPeriod,
uint8 _quorum,
address _polyTokenAddress,
address _polyCustomersAddress,
address _polyComplianceAddress
) public;
function selectTemplate(uint8 _templateIndex) public returns (bool success);
function updateComplianceProof(
bytes32 _newMerkleRoot,
bytes32 _complianceProof
) public returns (bool success);
function selectOfferingProposal (
uint8 _offeringProposalIndex
) public returns (bool success);
function startOffering() external returns (bool success);
function addToWhitelist(uint8 KYCProviderIndex, address _whitelistAddress) public returns (bool success);
function withdrawPoly() public returns (bool success);
function voteToFreeze(address _recipient) public returns (bool success);
function issueSecurityTokens(address _contributor, uint256 _amountOfSecurityTokens, uint256 _polyContributed) public returns (bool success);
function getTokenDetails() view public returns (address, address, bytes32, address, address);
function transfer(address _to, uint256 _value) public returns (bool success);
function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
function balanceOf(address _owner) public constant returns (uint256 balance);
function approve(address _spender, uint256 _value) public returns (bool success);
function allowance(address _owner, address _spender) public constant returns (uint256 remaining);
}
contract Compliance is ICompliance {
string public VERSION = "1";
ITemplate template;
SecurityTokenRegistrar public STRegistrar;
struct TemplateReputation {
address owner;
uint256 totalRaised;
uint256 timesUsed;
uint256 expires;
address[] usedBy;
}
mapping(address => TemplateReputation) public templates;
mapping(address => address[]) public templateProposals;
struct Offering {
address auditor;
uint256 fee;
uint256 vestingPeriod;
uint8 quorum;
address[] usedBy;
}
mapping(address => Offering) offerings;
mapping(address => address[]) public offeringProposals;
Customers public PolyCustomers;
uint256 public constant MINIMUM_VESTING_PERIOD = 60 * 60 * 24 * 100;
event LogTemplateCreated(address indexed _creator, address _template, string _offeringType);
event LogNewTemplateProposal(address indexed _securityToken, address _template, address _delegate, uint _templateProposalIndex);
event LogCancelTemplateProposal(address indexed _securityToken, address _template, uint _templateProposalIndex);
event LogNewContractProposal(address indexed _securityToken, address _offeringContract, address _delegate, uint _offeringProposalIndex);
event LogCancelContractProposal(address indexed _securityToken, address _offeringContract, uint _offeringProposalIndex);
function Compliance(address _polyCustomersAddress) public {
PolyCustomers = Customers(_polyCustomersAddress);
}
function setRegsitrarAddress(address _STRegistrar) public returns (bool) {
require(STRegistrar == address(0));
STRegistrar = SecurityTokenRegistrar(_STRegistrar);
return true;
}
function createTemplate(
string _offeringType,
bytes32 _issuerJurisdiction,
bool _accredited,
address _KYC,
bytes32 _details,
uint256 _expires,
uint256 _fee,
uint8 _quorum,
uint256 _vestingPeriod
) public
{
require(_KYC != address(0));
require(_vestingPeriod >= MINIMUM_VESTING_PERIOD);
address _template = new Template(
msg.sender,
_offeringType,
_issuerJurisdiction,
_accredited,
_KYC,
_details,
_expires,
_fee,
_quorum,
_vestingPeriod
);
templates[_template] = TemplateReputation({
owner: msg.sender,
totalRaised: 0,
timesUsed: 0,
expires: _expires,
usedBy: new address[](0)
});
LogTemplateCreated(msg.sender, _template, _offeringType);
}
function proposeTemplate(
address _securityToken,
address _template
) public returns (bool success)
{
var (totalSupply, owner,,) = STRegistrar.getSecurityTokenData(_securityToken);
require(totalSupply > 0 && owner != address(0));
require(templates[_template].expires > now);
require(templates[_template].owner == msg.sender);
template = Template(_template);
var (,finalized) = template.getTemplateDetails();
require(finalized);
templateProposals[_securityToken].push(_template);
LogNewTemplateProposal(_securityToken, _template, msg.sender,templateProposals[_securityToken].length -1);
return true;
}
function cancelTemplateProposal(
address _securityToken,
uint256 _templateProposalIndex
) public returns (bool success)
{
address proposedTemplate = templateProposals[_securityToken][_templateProposalIndex];
require(templates[proposedTemplate].owner == msg.sender);
var (chosenTemplate,,,,) = ISecurityToken(_securityToken).getTokenDetails();
require(chosenTemplate != proposedTemplate);
templateProposals[_securityToken][_templateProposalIndex] = address(0);
LogCancelTemplateProposal(_securityToken, proposedTemplate, _templateProposalIndex);
return true;
}
function setSTO (
address _STOAddress,
uint256 _fee,
uint256 _vestingPeriod,
uint8 _quorum
) public returns (bool success)
{
require(offerings[_STOAddress].auditor == address(0));
require(_STOAddress != address(0));
require(_quorum > 0 && _quorum <= 100);
require(_vestingPeriod >= MINIMUM_VESTING_PERIOD);
require(_fee > 0);
offerings[_STOAddress].auditor = msg.sender;
offerings[_STOAddress].fee = _fee;
offerings[_STOAddress].vestingPeriod = _vestingPeriod;
offerings[_STOAddress].quorum = _quorum;
return true;
}
function proposeOfferingContract(
address _securityToken,
address _stoContract
) public returns (bool success)
{
var (totalSupply, owner,,) = STRegistrar.getSecurityTokenData(_securityToken);
require(totalSupply > 0 && owner != address(0));
var (,,,,KYC) = ISecurityToken(_securityToken).getTokenDetails();
var (,,, verified, expires) = PolyCustomers.getCustomer(KYC, offerings[_stoContract].auditor);
require(offerings[_stoContract].auditor == msg.sender);
require(verified);
require(expires > now);
offeringProposals[_securityToken].push(_stoContract);
LogNewContractProposal(_securityToken, _stoContract, msg.sender,offeringProposals[_securityToken].length -1);
return true;
}
function cancelOfferingProposal(
address _securityToken,
uint256 _offeringProposalIndex
) public returns (bool success)
{
address proposedOffering = offeringProposals[_securityToken][_offeringProposalIndex];
require(offerings[proposedOffering].auditor == msg.sender);
var (,,,,chosenOffering) = ISecurityToken(_securityToken).getTokenDetails();
require(chosenOffering != proposedOffering);
offeringProposals[_securityToken][_offeringProposalIndex] = address(0);
LogCancelContractProposal(_securityToken, proposedOffering, _offeringProposalIndex);
return true;
}
function updateTemplateReputation (address _template, uint8 _templateIndex) external returns (bool success) {
require(templateProposals[msg.sender][_templateIndex] == _template);
templates[_template].usedBy.push(msg.sender);
return true;
}
function updateOfferingReputation (address _stoContract, uint8 _offeringProposalIndex) external returns (bool success) {
require(offeringProposals[msg.sender][_offeringProposalIndex] == _stoContract);
offerings[_stoContract].usedBy.push(msg.sender);
return true;
}
function getTemplateByProposal(address _securityTokenAddress, uint8 _templateIndex) view public returns (
address _template
){
return templateProposals[_securityTokenAddress][_templateIndex];
}
function getAllTemplateProposals(address _securityTokenAddress) view public returns (address[]){
return templateProposals[_securityTokenAddress];
}
function getOfferingByProposal(address _securityTokenAddress, uint8 _offeringProposalIndex) view public returns (
address stoContract,
address auditor,
uint256 vestingPeriod,
uint8 quorum,
uint256 fee
){
address _stoContract = offeringProposals[_securityTokenAddress][_offeringProposalIndex];
return (
_stoContract,
offerings[_stoContract].auditor,
offerings[_stoContract].vestingPeriod,
offerings[_stoContract].quorum,
offerings[_stoContract].fee
);
}
function getAllOfferingProposals(address _securityTokenAddress) view public returns (address[]){
return offeringProposals[_securityTokenAddress];
}
}
contract SecurityTokenRegistrar is ISTRegistrar {
string public VERSION = "1";
SecurityToken securityToken;
address public polyTokenAddress;
address public polyCustomersAddress;
address public polyComplianceAddress;
struct SecurityTokenData {
uint256 totalSupply;
address owner;
uint8 decimals;
string ticker;
uint8 securityType;
}
mapping(address => SecurityTokenData) securityTokens;
mapping(string => address) tickers;
event LogNewSecurityToken(string ticker, address securityTokenAddress, address owner, address host, uint256 fee, uint8 _type);
function SecurityTokenRegistrar(
address _polyTokenAddress,
address _polyCustomersAddress,
address _polyComplianceAddress
) public
{
polyTokenAddress = _polyTokenAddress;
polyCustomersAddress = _polyCustomersAddress;
polyComplianceAddress = _polyComplianceAddress;
Compliance PolyCompliance = Compliance(polyComplianceAddress);
require(PolyCompliance.setRegsitrarAddress(this));
}
function createSecurityToken (
string _name,
string _ticker,
uint256 _totalSupply,
uint8 _decimals,
address _owner,
uint256 _maxPoly,
address _host,
uint256 _fee,
uint8 _type,
uint256 _lockupPeriod,
uint8 _quorum
) external
{
require(_totalSupply > 0 && _maxPoly > 0 && _fee > 0);
require(tickers[_ticker] == 0x0);
require(_lockupPeriod >= now);
require(_owner != address(0) && _host != address(0));
require(bytes(_name).length > 0 && bytes(_ticker).length > 0);
IERC20 POLY = IERC20(polyTokenAddress);
POLY.transferFrom(msg.sender, _host, _fee);
address newSecurityTokenAddress = initialiseSecurityToken(_name, _ticker, _totalSupply, _decimals, _owner, _maxPoly, _type, _lockupPeriod, _quorum);
LogNewSecurityToken(_ticker, newSecurityTokenAddress, _owner, _host, _fee, _type);
}
function initialiseSecurityToken(
string _name,
string _ticker,
uint256 _totalSupply,
uint8 _decimals,
address _owner,
uint256 _maxPoly,
uint8 _type,
uint256 _lockupPeriod,
uint8 _quorum
) internal returns (address)
{
address newSecurityTokenAddress = new SecurityToken(
_name,
_ticker,
_totalSupply,
_decimals,
_owner,
_maxPoly,
_lockupPeriod,
_quorum,
polyTokenAddress,
polyCustomersAddress,
polyComplianceAddress
);
tickers[_ticker] = newSecurityTokenAddress;
securityTokens[newSecurityTokenAddress] = SecurityTokenData(
_totalSupply,
_owner,
_decimals,
_ticker,
_type
);
return newSecurityTokenAddress;
}
function getSecurityTokenAddress(string _ticker) public constant returns (address) {
return tickers[_ticker];
}
function getSecurityTokenData(address _STAddress) public constant returns (
uint256 totalSupply,
address owner,
uint8 decimals,
string ticker,
uint8 securityType
) {
return (
securityTokens[_STAddress].totalSupply,
securityTokens[_STAddress].owner,
securityTokens[_STAddress].decimals,
securityTokens[_STAddress].ticker,
securityTokens[_STAddress].securityType
);
}
}