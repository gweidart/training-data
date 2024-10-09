pragma solidity 0.4.20;
contract IAugur {
function createChildUniverse(bytes32 _parentPayoutDistributionHash, uint256[] _parentPayoutNumerators, bool _parentInvalid) public returns (IUniverse);
function isKnownUniverse(IUniverse _universe) public view returns (bool);
function trustedTransfer(ERC20 _token, address _from, address _to, uint256 _amount) public returns (bool);
function logMarketCreated(bytes32 _topic, string _description, string _extraInfo, IUniverse _universe, address _market, address _marketCreator, bytes32[] _outcomes, int256 _minPrice, int256 _maxPrice, IMarket.MarketType _marketType) public returns (bool);
function logMarketCreated(bytes32 _topic, string _description, string _extraInfo, IUniverse _universe, address _market, address _marketCreator, int256 _minPrice, int256 _maxPrice, IMarket.MarketType _marketType) public returns (bool);
function logInitialReportSubmitted(IUniverse _universe, address _reporter, address _market, uint256 _amountStaked, bool _isDesignatedReporter, uint256[] _payoutNumerators, bool _invalid) public returns (bool);
function disputeCrowdsourcerCreated(IUniverse _universe, address _market, address _disputeCrowdsourcer, uint256[] _payoutNumerators, uint256 _size, bool _invalid) public returns (bool);
function logDisputeCrowdsourcerContribution(IUniverse _universe, address _reporter, address _market, address _disputeCrowdsourcer, uint256 _amountStaked) public returns (bool);
function logDisputeCrowdsourcerCompleted(IUniverse _universe, address _market, address _disputeCrowdsourcer) public returns (bool);
function logInitialReporterRedeemed(IUniverse _universe, address _reporter, address _market, uint256 _amountRedeemed, uint256 _repReceived, uint256 _reportingFeesReceived, uint256[] _payoutNumerators) public returns (bool);
function logDisputeCrowdsourcerRedeemed(IUniverse _universe, address _reporter, address _market, uint256 _amountRedeemed, uint256 _repReceived, uint256 _reportingFeesReceived, uint256[] _payoutNumerators) public returns (bool);
function logFeeWindowRedeemed(IUniverse _universe, address _reporter, uint256 _amountRedeemed, uint256 _reportingFeesReceived) public returns (bool);
function logMarketFinalized(IUniverse _universe) public returns (bool);
function logMarketMigrated(IMarket _market, IUniverse _originalUniverse) public returns (bool);
function logReportingParticipantDisavowed(IUniverse _universe, IMarket _market) public returns (bool);
function logMarketParticipantsDisavowed(IUniverse _universe) public returns (bool);
function logOrderCanceled(IUniverse _universe, address _shareToken, address _sender, bytes32 _orderId, Order.Types _orderType, uint256 _tokenRefund, uint256 _sharesRefund) public returns (bool);
function logOrderCreated(Order.Types _orderType, uint256 _amount, uint256 _price, address _creator, uint256 _moneyEscrowed, uint256 _sharesEscrowed, bytes32 _tradeGroupId, bytes32 _orderId, IUniverse _universe, address _shareToken) public returns (bool);
function logOrderFilled(IUniverse _universe, address _shareToken, address _filler, bytes32 _orderId, uint256 _numCreatorShares, uint256 _numCreatorTokens, uint256 _numFillerShares, uint256 _numFillerTokens, uint256 _marketCreatorFees, uint256 _reporterFees, uint256 _amountFilled, bytes32 _tradeGroupId) public returns (bool);
function logCompleteSetsPurchased(IUniverse _universe, IMarket _market, address _account, uint256 _numCompleteSets) public returns (bool);
function logCompleteSetsSold(IUniverse _universe, IMarket _market, address _account, uint256 _numCompleteSets) public returns (bool);
function logTradingProceedsClaimed(IUniverse _universe, address _shareToken, address _sender, address _market, uint256 _numShares, uint256 _numPayoutTokens, uint256 _finalTokenBalance) public returns (bool);
function logUniverseForked() public returns (bool);
function logFeeWindowTransferred(IUniverse _universe, address _from, address _to, uint256 _value) public returns (bool);
function logReputationTokensTransferred(IUniverse _universe, address _from, address _to, uint256 _value) public returns (bool);
function logDisputeCrowdsourcerTokensTransferred(IUniverse _universe, address _from, address _to, uint256 _value) public returns (bool);
function logShareTokensTransferred(IUniverse _universe, address _from, address _to, uint256 _value) public returns (bool);
function logReputationTokenBurned(IUniverse _universe, address _target, uint256 _amount) public returns (bool);
function logReputationTokenMinted(IUniverse _universe, address _target, uint256 _amount) public returns (bool);
function logShareTokenBurned(IUniverse _universe, address _target, uint256 _amount) public returns (bool);
function logShareTokenMinted(IUniverse _universe, address _target, uint256 _amount) public returns (bool);
function logFeeWindowBurned(IUniverse _universe, address _target, uint256 _amount) public returns (bool);
function logFeeWindowMinted(IUniverse _universe, address _target, uint256 _amount) public returns (bool);
function logDisputeCrowdsourcerTokensBurned(IUniverse _universe, address _target, uint256 _amount) public returns (bool);
function logDisputeCrowdsourcerTokensMinted(IUniverse _universe, address _target, uint256 _amount) public returns (bool);
function logFeeWindowCreated(IFeeWindow _feeWindow, uint256 _id) public returns (bool);
function logFeeTokenTransferred(IUniverse _universe, address _from, address _to, uint256 _value) public returns (bool);
function logFeeTokenBurned(IUniverse _universe, address _target, uint256 _amount) public returns (bool);
function logFeeTokenMinted(IUniverse _universe, address _target, uint256 _amount) public returns (bool);
function logTimestampSet(uint256 _newTimestamp) public returns (bool);
function logInitialReporterTransferred(IUniverse _universe, IMarket _market, address _from, address _to) public returns (bool);
function logMarketTransferred(IUniverse _universe, address _from, address _to) public returns (bool);
function logMarketMailboxTransferred(IUniverse _universe, IMarket _market, address _from, address _to) public returns (bool);
function logEscapeHatchChanged(bool _isOn) public returns (bool);
}
contract IControlled {
function getController() public view returns (IController);
function setController(IController _controller) public returns(bool);
}
contract Controlled is IControlled {
IController internal controller;
modifier onlyWhitelistedCallers {
require(controller.assertIsWhitelisted(msg.sender));
_;
}
modifier onlyCaller(bytes32 _key) {
require(msg.sender == controller.lookup(_key));
_;
}
modifier onlyControllerCaller {
require(IController(msg.sender) == controller);
_;
}
modifier onlyInGoodTimes {
require(controller.stopInEmergency());
_;
}
modifier onlyInBadTimes {
require(controller.onlyInEmergency());
_;
}
function Controlled() public {
controller = IController(msg.sender);
}
function getController() public view returns(IController) {
return controller;
}
function setController(IController _controller) public onlyControllerCaller returns(bool) {
controller = _controller;
return true;
}
}
contract IController {
function assertIsWhitelisted(address _target) public view returns(bool);
function lookup(bytes32 _key) public view returns(address);
function stopInEmergency() public view returns(bool);
function onlyInEmergency() public view returns(bool);
function getAugur() public view returns (IAugur);
function getTimestamp() public view returns (uint256);
}
contract DelegationTarget is Controlled {
bytes32 public controllerLookupName;
}
contract IOwnable {
function getOwner() public view returns (address);
function transferOwnership(address newOwner) public returns (bool);
}
contract ITyped {
function getTypeName() public view returns (bytes32);
}
contract Initializable {
bool private initialized = false;
modifier afterInitialized {
require(initialized);
_;
}
modifier beforeInitialized {
require(!initialized);
_;
}
function endInitialization() internal beforeInitialized returns (bool) {
initialized = true;
return true;
}
function getInitialized() public view returns (bool) {
return initialized;
}
}
library SafeMathUint256 {
function mul(uint256 a, uint256 b) internal pure returns (uint256) {
uint256 c = a * b;
require(a == 0 || c / a == b);
return c;
}
function div(uint256 a, uint256 b) internal pure returns (uint256) {
uint256 c = a / b;
return c;
}
function sub(uint256 a, uint256 b) internal pure returns (uint256) {
require(b <= a);
return a - b;
}
function add(uint256 a, uint256 b) internal pure returns (uint256) {
uint256 c = a + b;
require(c >= a);
return c;
}
function min(uint256 a, uint256 b) internal pure returns (uint256) {
if (a <= b) {
return a;
} else {
return b;
}
}
function max(uint256 a, uint256 b) internal pure returns (uint256) {
if (a >= b) {
return a;
} else {
return b;
}
}
function getUint256Min() internal pure returns (uint256) {
return 0;
}
function getUint256Max() internal pure returns (uint256) {
return 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;
}
function isMultipleOf(uint256 a, uint256 b) internal pure returns (bool) {
return a % b == 0;
}
function fxpMul(uint256 a, uint256 b, uint256 base) internal pure returns (uint256) {
return div(mul(a, b), base);
}
function fxpDiv(uint256 a, uint256 b, uint256 base) internal pure returns (uint256) {
return div(mul(a, base), b);
}
}
contract ERC20Basic {
event Transfer(address indexed from, address indexed to, uint256 value);
function balanceOf(address _who) public view returns (uint256);
function transfer(address _to, uint256 _value) public returns (bool);
function totalSupply() public view returns (uint256);
}
contract BasicToken is ERC20Basic {
using SafeMathUint256 for uint256;
uint256 internal supply;
mapping(address => uint256) internal balances;
function transfer(address _to, uint256 _value) public returns(bool) {
return internalTransfer(msg.sender, _to, _value);
}
function internalTransfer(address _from, address _to, uint256 _value) internal returns (bool) {
balances[_from] = balances[_from].sub(_value);
balances[_to] = balances[_to].add(_value);
Transfer(_from, _to, _value);
onTokenTransfer(_from, _to, _value);
return true;
}
function balanceOf(address _owner) public view returns (uint256) {
return balances[_owner];
}
function totalSupply() public view returns (uint256) {
return supply;
}
function onTokenTransfer(address _from, address _to, uint256 _value) internal returns (bool);
}
contract ERC20 is ERC20Basic {
event Approval(address indexed owner, address indexed spender, uint256 value);
function allowance(address _owner, address _spender) public view returns (uint256);
function transferFrom(address _from, address _to, uint256 _value) public returns (bool);
function approve(address _spender, uint256 _value) public returns (bool);
}
contract StandardToken is ERC20, BasicToken {
using SafeMathUint256 for uint256;
uint256 public constant ETERNAL_APPROVAL_VALUE = 2 ** 256 - 1;
mapping (address => mapping (address => uint256)) internal allowed;
function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
uint256 _allowance = allowed[_from][msg.sender];
if (_allowance != ETERNAL_APPROVAL_VALUE) {
allowed[_from][msg.sender] = _allowance.sub(_value);
}
internalTransfer(_from, _to, _value);
return true;
}
function approve(address _spender, uint256 _value) public returns (bool) {
approveInternal(msg.sender, _spender, _value);
return true;
}
function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
return allowed[_owner][_spender];
}
function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
approveInternal(msg.sender, _spender, allowed[msg.sender][_spender].add(_addedValue));
return true;
}
function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
uint oldValue = allowed[msg.sender][_spender];
if (_subtractedValue > oldValue) {
approveInternal(msg.sender, _spender, 0);
} else {
approveInternal(msg.sender, _spender, oldValue.sub(_subtractedValue));
}
return true;
}
function approveInternal(address _owner, address _spender, uint256 _value) internal returns (bool) {
allowed[_owner][_spender] = _value;
Approval(_owner, _spender, _value);
return true;
}
}
contract VariableSupplyToken is StandardToken {
using SafeMathUint256 for uint256;
event Mint(address indexed target, uint256 value);
event Burn(address indexed target, uint256 value);
function mint(address _target, uint256 _amount) internal returns (bool) {
balances[_target] = balances[_target].add(_amount);
supply = supply.add(_amount);
Mint(_target, _amount);
onMint(_target, _amount);
return true;
}
function burn(address _target, uint256 _amount) internal returns (bool) {
balances[_target] = balances[_target].sub(_amount);
supply = supply.sub(_amount);
Burn(_target, _amount);
onBurn(_target, _amount);
return true;
}
function onMint(address, uint256) internal returns (bool);
function onBurn(address, uint256) internal returns (bool);
}
contract IFeeToken is ERC20, Initializable {
function initialize(IFeeWindow _feeWindow) public returns (bool);
function getFeeWindow() public view returns (IFeeWindow);
function feeWindowBurn(address _target, uint256 _amount) public returns (bool);
function mintForReportingParticipant(address _target, uint256 _amount) public returns (bool);
}
contract IFeeWindow is ITyped, ERC20 {
function initialize(IUniverse _universe, uint256 _feeWindowId) public returns (bool);
function getUniverse() public view returns (IUniverse);
function getReputationToken() public view returns (IReputationToken);
function getStartTime() public view returns (uint256);
function getEndTime() public view returns (uint256);
function getNumMarkets() public view returns (uint256);
function getNumInvalidMarkets() public view returns (uint256);
function getNumIncorrectDesignatedReportMarkets() public view returns (uint256);
function getNumDesignatedReportNoShows() public view returns (uint256);
function getFeeToken() public view returns (IFeeToken);
function isActive() public view returns (bool);
function isOver() public view returns (bool);
function onMarketFinalized() public returns (bool);
function buy(uint256 _attotokens) public returns (bool);
function redeem(address _sender) public returns (bool);
function redeemForReportingParticipant() public returns (bool);
function mintFeeTokens(uint256 _amount) public returns (bool);
function trustedUniverseBuy(address _buyer, uint256 _attotokens) public returns (bool);
}
contract IMailbox {
function initialize(address _owner, IMarket _market) public returns (bool);
function depositEther() public payable returns (bool);
}
contract IMarket is ITyped, IOwnable {
enum MarketType {
YES_NO,
CATEGORICAL,
SCALAR
}
function initialize(IUniverse _universe, uint256 _endTime, uint256 _feePerEthInAttoeth, ICash _cash, address _designatedReporterAddress, address _creator, uint256 _numOutcomes, uint256 _numTicks) public payable returns (bool _success);
function derivePayoutDistributionHash(uint256[] _payoutNumerators, bool _invalid) public view returns (bytes32);
function getUniverse() public view returns (IUniverse);
function getFeeWindow() public view returns (IFeeWindow);
function getNumberOfOutcomes() public view returns (uint256);
function getNumTicks() public view returns (uint256);
function getDenominationToken() public view returns (ICash);
function getShareToken(uint256 _outcome)  public view returns (IShareToken);
function getMarketCreatorSettlementFeeDivisor() public view returns (uint256);
function getForkingMarket() public view returns (IMarket _market);
function getEndTime() public view returns (uint256);
function getMarketCreatorMailbox() public view returns (IMailbox);
function getWinningPayoutDistributionHash() public view returns (bytes32);
function getWinningPayoutNumerator(uint256 _outcome) public view returns (uint256);
function getReputationToken() public view returns (IReputationToken);
function getFinalizationTime() public view returns (uint256);
function getInitialReporterAddress() public view returns (address);
function deriveMarketCreatorFeeAmount(uint256 _amount) public view returns (uint256);
function isContainerForShareToken(IShareToken _shadyTarget) public view returns (bool);
function isContainerForReportingParticipant(IReportingParticipant _reportingParticipant) public view returns (bool);
function isInvalid() public view returns (bool);
function finalize() public returns (bool);
function designatedReporterWasCorrect() public view returns (bool);
function designatedReporterShowed() public view returns (bool);
function isFinalized() public view returns (bool);
function finalizeFork() public returns (bool);
function assertBalances() public view returns (bool);
}
contract IReportingParticipant {
function getStake() public view returns (uint256);
function getPayoutDistributionHash() public view returns (bytes32);
function liquidateLosing() public returns (bool);
function redeem(address _redeemer) public returns (bool);
function isInvalid() public view returns (bool);
function isDisavowed() public view returns (bool);
function migrate() public returns (bool);
function getPayoutNumerator(uint256 _outcome) public view returns (uint256);
function getMarket() public view returns (IMarket);
function getSize() public view returns (uint256);
}
contract IDisputeCrowdsourcer is IReportingParticipant, ERC20 {
function initialize(IMarket market, uint256 _size, bytes32 _payoutDistributionHash, uint256[] _payoutNumerators, bool _invalid) public returns (bool);
function contribute(address _participant, uint256 _amount) public returns (uint256);
}
contract IReputationToken is ITyped, ERC20 {
function initialize(IUniverse _universe) public returns (bool);
function migrateOut(IReputationToken _destination, uint256 _attotokens) public returns (bool);
function migrateIn(address _reporter, uint256 _attotokens) public returns (bool);
function trustedReportingParticipantTransfer(address _source, address _destination, uint256 _attotokens) public returns (bool);
function trustedMarketTransfer(address _source, address _destination, uint256 _attotokens) public returns (bool);
function trustedFeeWindowTransfer(address _source, address _destination, uint256 _attotokens) public returns (bool);
function trustedUniverseTransfer(address _source, address _destination, uint256 _attotokens) public returns (bool);
function getUniverse() public view returns (IUniverse);
function getTotalMigrated() public view returns (uint256);
function getTotalTheoreticalSupply() public view returns (uint256);
function mintForReportingParticipant(uint256 _amountMigrated) public returns (bool);
}
contract IUniverse is ITyped {
function initialize(IUniverse _parentUniverse, bytes32 _parentPayoutDistributionHash) external returns (bool);
function fork() public returns (bool);
function getParentUniverse() public view returns (IUniverse);
function createChildUniverse(uint256[] _parentPayoutNumerators, bool _invalid) public returns (IUniverse);
function getChildUniverse(bytes32 _parentPayoutDistributionHash) public view returns (IUniverse);
function getReputationToken() public view returns (IReputationToken);
function getForkingMarket() public view returns (IMarket);
function getForkEndTime() public view returns (uint256);
function getForkReputationGoal() public view returns (uint256);
function getParentPayoutDistributionHash() public view returns (bytes32);
function getDisputeRoundDurationInSeconds() public view returns (uint256);
function getOrCreateFeeWindowByTimestamp(uint256 _timestamp) public returns (IFeeWindow);
function getOrCreateCurrentFeeWindow() public returns (IFeeWindow);
function getOrCreateNextFeeWindow() public returns (IFeeWindow);
function getOpenInterestInAttoEth() public view returns (uint256);
function getRepMarketCapInAttoeth() public view returns (uint256);
function getTargetRepMarketCapInAttoeth() public view returns (uint256);
function getOrCacheValidityBond() public returns (uint256);
function getOrCacheDesignatedReportStake() public returns (uint256);
function getOrCacheDesignatedReportNoShowBond() public returns (uint256);
function getOrCacheReportingFeeDivisor() public returns (uint256);
function getDisputeThresholdForFork() public view returns (uint256);
function getInitialReportMinValue() public view returns (uint256);
function calculateFloatingValue(uint256 _badMarkets, uint256 _totalMarkets, uint256 _targetDivisor, uint256 _previousValue, uint256 _defaultValue, uint256 _floor) public pure returns (uint256 _newValue);
function getOrCacheMarketCreationCost() public returns (uint256);
function getCurrentFeeWindow() public view returns (IFeeWindow);
function getOrCreateFeeWindowBefore(IFeeWindow _feeWindow) public returns (IFeeWindow);
function isParentOf(IUniverse _shadyChild) public view returns (bool);
function updateTentativeWinningChildUniverse(bytes32 _parentPayoutDistributionHash) public returns (bool);
function isContainerForFeeWindow(IFeeWindow _shadyTarget) public view returns (bool);
function isContainerForMarket(IMarket _shadyTarget) public view returns (bool);
function isContainerForReportingParticipant(IReportingParticipant _reportingParticipant) public view returns (bool);
function isContainerForShareToken(IShareToken _shadyTarget) public view returns (bool);
function isContainerForFeeToken(IFeeToken _shadyTarget) public view returns (bool);
function addMarketTo() public returns (bool);
function removeMarketFrom() public returns (bool);
function decrementOpenInterest(uint256 _amount) public returns (bool);
function decrementOpenInterestFromMarket(uint256 _amount) public returns (bool);
function incrementOpenInterest(uint256 _amount) public returns (bool);
function incrementOpenInterestFromMarket(uint256 _amount) public returns (bool);
function getWinningChildUniverse() public view returns (IUniverse);
function isForking() public view returns (bool);
}
library Reporting {
uint256 private constant DESIGNATED_REPORTING_DURATION_SECONDS = 3 days;
uint256 private constant DISPUTE_ROUND_DURATION_SECONDS = 7 days;
uint256 private constant CLAIM_PROCEEDS_WAIT_TIME = 3 days;
uint256 private constant FORK_DURATION_SECONDS = 60 days;
uint256 private constant INITIAL_REP_SUPPLY = 11 * 10 ** 6 * 10 ** 18;
uint256 private constant DEFAULT_VALIDITY_BOND = 1 ether / 100;
uint256 private constant VALIDITY_BOND_FLOOR = 1 ether / 100;
uint256 private constant DEFAULT_REPORTING_FEE_DIVISOR = 100;
uint256 private constant MAXIMUM_REPORTING_FEE_DIVISOR = 10000;
uint256 private constant MINIMUM_REPORTING_FEE_DIVISOR = 3;
uint256 private constant TARGET_INVALID_MARKETS_DIVISOR = 100;
uint256 private constant TARGET_INCORRECT_DESIGNATED_REPORT_MARKETS_DIVISOR = 100;
uint256 private constant TARGET_DESIGNATED_REPORT_NO_SHOWS_DIVISOR = 100;
uint256 private constant TARGET_REP_MARKET_CAP_MULTIPLIER = 15;
uint256 private constant TARGET_REP_MARKET_CAP_DIVISOR = 2;
uint256 private constant FORK_MIGRATION_PERCENTAGE_BONUS_DIVISOR = 20;
function getDesignatedReportingDurationSeconds() internal pure returns (uint256) { return DESIGNATED_REPORTING_DURATION_SECONDS; }
function getDisputeRoundDurationSeconds() internal pure returns (uint256) { return DISPUTE_ROUND_DURATION_SECONDS; }
function getClaimTradingProceedsWaitTime() internal pure returns (uint256) { return CLAIM_PROCEEDS_WAIT_TIME; }
function getForkDurationSeconds() internal pure returns (uint256) { return FORK_DURATION_SECONDS; }
function getDefaultValidityBond() internal pure returns (uint256) { return DEFAULT_VALIDITY_BOND; }
function getValidityBondFloor() internal pure returns (uint256) { return VALIDITY_BOND_FLOOR; }
function getTargetInvalidMarketsDivisor() internal pure returns (uint256) { return TARGET_INVALID_MARKETS_DIVISOR; }
function getTargetIncorrectDesignatedReportMarketsDivisor() internal pure returns (uint256) { return TARGET_INCORRECT_DESIGNATED_REPORT_MARKETS_DIVISOR; }
function getTargetDesignatedReportNoShowsDivisor() internal pure returns (uint256) { return TARGET_DESIGNATED_REPORT_NO_SHOWS_DIVISOR; }
function getTargetRepMarketCapMultiplier() internal pure returns (uint256) { return TARGET_REP_MARKET_CAP_MULTIPLIER; }
function getTargetRepMarketCapDivisor() internal pure returns (uint256) { return TARGET_REP_MARKET_CAP_DIVISOR; }
function getForkMigrationPercentageBonusDivisor() internal pure returns (uint256) { return FORK_MIGRATION_PERCENTAGE_BONUS_DIVISOR; }
function getMaximumReportingFeeDivisor() internal pure returns (uint256) { return MAXIMUM_REPORTING_FEE_DIVISOR; }
function getMinimumReportingFeeDivisor() internal pure returns (uint256) { return MINIMUM_REPORTING_FEE_DIVISOR; }
function getDefaultReportingFeeDivisor() internal pure returns (uint256) { return DEFAULT_REPORTING_FEE_DIVISOR; }
function getInitialREPSupply() internal pure returns (uint256) { return INITIAL_REP_SUPPLY; }
}
contract ReputationToken is DelegationTarget, ITyped, Initializable, VariableSupplyToken, IReputationToken {
using SafeMathUint256 for uint256;
string constant public name = "Reputation";
string constant public symbol = "REP";
uint8 constant public decimals = 18;
IUniverse private universe;
uint256 private totalMigrated;
mapping(address => uint256) migratedToSibling;
uint256 private parentTotalTheoreticalSupply;
uint256 private totalTheoreticalSupply;
bool private isMigratingFromLegacy;
uint256 private targetSupply;
modifier whenMigratingFromLegacy() {
require(isMigratingFromLegacy);
_;
}
modifier whenNotMigratingFromLegacy() {
require(!isMigratingFromLegacy);
_;
}
function initialize(IUniverse _universe) public onlyInGoodTimes beforeInitialized returns (bool) {
endInitialization();
require(_universe != address(0));
universe = _universe;
updateParentTotalTheoreticalSupply();
ERC20 _legacyRepToken = getLegacyRepToken();
isMigratingFromLegacy = _universe.getParentUniverse() == IUniverse(0);
targetSupply = _legacyRepToken.totalSupply();
return true;
}
function migrateOutByPayout(uint256[] _payoutNumerators, bool _invalid, uint256 _attotokens) public onlyInGoodTimes whenNotMigratingFromLegacy afterInitialized returns (bool) {
require(_attotokens > 0);
IUniverse _destinationUniverse = universe.createChildUniverse(_payoutNumerators, _invalid);
IReputationToken _destination = _destinationUniverse.getReputationToken();
burn(msg.sender, _attotokens);
_destination.migrateIn(msg.sender, _attotokens);
return true;
}
function migrateOut(IReputationToken _destination, uint256 _attotokens) public onlyInGoodTimes whenNotMigratingFromLegacy afterInitialized returns (bool) {
require(_attotokens > 0);
assertReputationTokenIsLegitSibling(_destination);
burn(msg.sender, _attotokens);
_destination.migrateIn(msg.sender, _attotokens);
return true;
}
function migrateIn(address _reporter, uint256 _attotokens) public onlyInGoodTimes whenNotMigratingFromLegacy afterInitialized returns (bool) {
IUniverse _parentUniverse = universe.getParentUniverse();
require(ReputationToken(msg.sender) == _parentUniverse.getReputationToken());
mint(_reporter, _attotokens);
totalMigrated += _attotokens;
if (controller.getTimestamp() < _parentUniverse.getForkEndTime()) {
uint256 _bonus = _attotokens.div(Reporting.getForkMigrationPercentageBonusDivisor());
mint(_reporter, _bonus);
totalTheoreticalSupply += _bonus;
}
if (!_parentUniverse.getForkingMarket().isFinalized()) {
_parentUniverse.updateTentativeWinningChildUniverse(universe.getParentPayoutDistributionHash());
}
return true;
}
function mintForReportingParticipant(uint256 _amountMigrated) public onlyInGoodTimes whenNotMigratingFromLegacy afterInitialized returns (bool) {
IUniverse _parentUniverse = universe.getParentUniverse();
IReportingParticipant _reportingParticipant = IReportingParticipant(msg.sender);
require(_parentUniverse.isContainerForReportingParticipant(_reportingParticipant));
uint256 _bonus = _amountMigrated.div(2);
mint(_reportingParticipant, _bonus);
totalTheoreticalSupply += _bonus;
return true;
}
function transfer(address _to, uint _value) public whenNotMigratingFromLegacy returns (bool) {
return super.transfer(_to, _value);
}
function transferFrom(address _from, address _to, uint _value) public whenNotMigratingFromLegacy returns (bool) {
return super.transferFrom(_from, _to, _value);
}
function trustedUniverseTransfer(address _source, address _destination, uint256 _attotokens) public onlyInGoodTimes whenNotMigratingFromLegacy afterInitialized returns (bool) {
require(IUniverse(msg.sender) == universe);
return internalTransfer(_source, _destination, _attotokens);
}
function trustedMarketTransfer(address _source, address _destination, uint256 _attotokens) public onlyInGoodTimes whenNotMigratingFromLegacy afterInitialized returns (bool) {
require(universe.isContainerForMarket(IMarket(msg.sender)));
return internalTransfer(_source, _destination, _attotokens);
}
function trustedReportingParticipantTransfer(address _source, address _destination, uint256 _attotokens) public onlyInGoodTimes whenNotMigratingFromLegacy afterInitialized returns (bool) {
require(universe.isContainerForReportingParticipant(IReportingParticipant(msg.sender)));
return internalTransfer(_source, _destination, _attotokens);
}
function trustedFeeWindowTransfer(address _source, address _destination, uint256 _attotokens) public onlyInGoodTimes whenNotMigratingFromLegacy afterInitialized returns (bool) {
require(universe.isContainerForFeeWindow(IFeeWindow(msg.sender)));
return internalTransfer(_source, _destination, _attotokens);
}
function assertReputationTokenIsLegitSibling(IReputationToken _shadyReputationToken) private view returns (bool) {
IUniverse _shadyUniverse = _shadyReputationToken.getUniverse();
require(universe.isParentOf(_shadyUniverse));
IUniverse _legitUniverse = _shadyUniverse;
require(_legitUniverse.getReputationToken() == _shadyReputationToken);
return true;
}
function getTypeName() public view returns (bytes32) {
return "ReputationToken";
}
function getUniverse() public view returns (IUniverse) {
return universe;
}
function getTotalMigrated() public view returns (uint256) {
return totalMigrated;
}
function getLegacyRepToken() public view returns (ERC20) {
return ERC20(controller.lookup("LegacyReputationToken"));
}
function updateSiblingMigrationTotal(IReputationToken _token) public whenNotMigratingFromLegacy returns (bool) {
require(_token != this);
IUniverse _shadyUniverse = _token.getUniverse();
require(_token == universe.getParentUniverse().getChildUniverse(_shadyUniverse.getParentPayoutDistributionHash()).getReputationToken());
totalTheoreticalSupply += migratedToSibling[_token];
migratedToSibling[_token] = _token.getTotalMigrated();
totalTheoreticalSupply -= migratedToSibling[_token];
return true;
}
function updateParentTotalTheoreticalSupply() public whenNotMigratingFromLegacy returns (bool) {
IUniverse _parentUniverse = universe.getParentUniverse();
totalTheoreticalSupply -= parentTotalTheoreticalSupply;
if (_parentUniverse == IUniverse(0)) {
parentTotalTheoreticalSupply = Reporting.getInitialREPSupply();
} else {
parentTotalTheoreticalSupply = _parentUniverse.getReputationToken().getTotalTheoreticalSupply();
}
totalTheoreticalSupply += parentTotalTheoreticalSupply;
return true;
}
function getTotalTheoreticalSupply() public view returns (uint256) {
return totalTheoreticalSupply;
}
function onTokenTransfer(address _from, address _to, uint256 _value) internal returns (bool) {
controller.getAugur().logReputationTokensTransferred(universe, _from, _to, _value);
return true;
}
function onMint(address _target, uint256 _amount) internal returns (bool) {
controller.getAugur().logReputationTokenMinted(universe, _target, _amount);
return true;
}
function onBurn(address _target, uint256 _amount) internal returns (bool) {
controller.getAugur().logReputationTokenBurned(universe, _target, _amount);
return true;
}
function migrateBalancesFromLegacyRep(address[] _holders) public onlyInGoodTimes whenMigratingFromLegacy afterInitialized returns (bool) {
ERC20 _legacyRepToken = getLegacyRepToken();
for (uint256 i = 0; i < _holders.length; i++) {
migrateBalanceFromLegacyRep(_holders[i], _legacyRepToken);
}
return true;
}
function migrateBalanceFromLegacyRep(address _holder, ERC20 _legacyRepToken) private onlyInGoodTimes whenMigratingFromLegacy afterInitialized returns (bool) {
if (balances[_holder] > 0) {
return false;
}
uint256 amount = _legacyRepToken.balanceOf(_holder);
if (amount == 0) {
return false;
}
mint(_holder, amount);
if (targetSupply == supply) {
isMigratingFromLegacy = false;
}
return true;
}
function migrateAllowancesFromLegacyRep(address[] _owners, address[] _spenders) public onlyInGoodTimes whenMigratingFromLegacy afterInitialized returns (bool) {
ERC20 _legacyRepToken = getLegacyRepToken();
for (uint256 i = 0; i < _owners.length; i++) {
address _owner = _owners[i];
address _spender = _spenders[i];
uint256 _allowance = _legacyRepToken.allowance(_owner, _spender);
approveInternal(_owner, _spender, _allowance);
}
return true;
}
function getIsMigratingFromLegacy() public view returns (bool) {
return isMigratingFromLegacy;
}
function getTargetSupply() public view returns (uint256) {
return targetSupply;
}
}
contract ICash is ERC20 {
function depositEther() external payable returns(bool);
function depositEtherFor(address _to) external payable returns(bool);
function withdrawEther(uint256 _amount) external returns(bool);
function withdrawEtherTo(address _to, uint256 _amount) external returns(bool);
function withdrawEtherToIfPossible(address _to, uint256 _amount) external returns (bool);
}
contract IOrders {
function saveOrder(Order.Types _type, IMarket _market, uint256 _fxpAmount, uint256 _price, address _sender, uint256 _outcome, uint256 _moneyEscrowed, uint256 _sharesEscrowed, bytes32 _betterOrderId, bytes32 _worseOrderId, bytes32 _tradeGroupId) public returns (bytes32 _orderId);
function removeOrder(bytes32 _orderId) public returns (bool);
function getMarket(bytes32 _orderId) public view returns (IMarket);
function getOrderType(bytes32 _orderId) public view returns (Order.Types);
function getOutcome(bytes32 _orderId) public view returns (uint256);
function getAmount(bytes32 _orderId) public view returns (uint256);
function getPrice(bytes32 _orderId) public view returns (uint256);
function getOrderCreator(bytes32 _orderId) public view returns (address);
function getOrderSharesEscrowed(bytes32 _orderId) public view returns (uint256);
function getOrderMoneyEscrowed(bytes32 _orderId) public view returns (uint256);
function getBetterOrderId(bytes32 _orderId) public view returns (bytes32);
function getWorseOrderId(bytes32 _orderId) public view returns (bytes32);
function getBestOrderId(Order.Types _type, IMarket _market, uint256 _outcome) public view returns (bytes32);
function getWorstOrderId(Order.Types _type, IMarket _market, uint256 _outcome) public view returns (bytes32);
function getLastOutcomePrice(IMarket _market, uint256 _outcome) public view returns (uint256);
function getOrderId(Order.Types _type, IMarket _market, uint256 _fxpAmount, uint256 _price, address _sender, uint256 _blockNumber, uint256 _outcome, uint256 _moneyEscrowed, uint256 _sharesEscrowed) public pure returns (bytes32);
function getTotalEscrowed(IMarket _market) public view returns (uint256);
function isBetterPrice(Order.Types _type, uint256 _price, bytes32 _orderId) public view returns (bool);
function isWorsePrice(Order.Types _type, uint256 _price, bytes32 _orderId) public view returns (bool);
function assertIsNotBetterPrice(Order.Types _type, uint256 _price, bytes32 _betterOrderId) public view returns (bool);
function assertIsNotWorsePrice(Order.Types _type, uint256 _price, bytes32 _worseOrderId) public returns (bool);
function recordFillOrder(bytes32 _orderId, uint256 _sharesFilled, uint256 _tokensFilled) public returns (bool);
function setPrice(IMarket _market, uint256 _outcome, uint256 _price) external returns (bool);
function incrementTotalEscrowed(IMarket _market, uint256 _amount) external returns (bool);
function decrementTotalEscrowed(IMarket _market, uint256 _amount) external returns (bool);
}
contract IShareToken is ITyped, ERC20 {
function initialize(IMarket _market, uint256 _outcome) external returns (bool);
function createShares(address _owner, uint256 _amount) external returns (bool);
function destroyShares(address, uint256 balance) external returns (bool);
function getMarket() external view returns (IMarket);
function getOutcome() external view returns (uint256);
function trustedOrderTransfer(address _source, address _destination, uint256 _attotokens) public returns (bool);
function trustedFillOrderTransfer(address _source, address _destination, uint256 _attotokens) public returns (bool);
function trustedCancelOrderTransfer(address _source, address _destination, uint256 _attotokens) public returns (bool);
}
library Order {
using SafeMathUint256 for uint256;
enum Types {
Bid, Ask
}
enum TradeDirections {
Long, Short
}
struct Data {
IOrders orders;
IMarket market;
IAugur augur;
bytes32 id;
address creator;
uint256 outcome;
Order.Types orderType;
uint256 amount;
uint256 price;
uint256 sharesEscrowed;
uint256 moneyEscrowed;
bytes32 betterOrderId;
bytes32 worseOrderId;
}
function create(IController _controller, address _creator, uint256 _outcome, Order.Types _type, uint256 _attoshares, uint256 _price, IMarket _market, bytes32 _betterOrderId, bytes32 _worseOrderId) internal view returns (Data) {
require(_outcome < _market.getNumberOfOutcomes());
require(_price < _market.getNumTicks());
IOrders _orders = IOrders(_controller.lookup("Orders"));
IAugur _augur = _controller.getAugur();
return Data({
orders: _orders,
market: _market,
augur: _augur,
id: 0,
creator: _creator,
outcome: _outcome,
orderType: _type,
amount: _attoshares,
price: _price,
sharesEscrowed: 0,
moneyEscrowed: 0,
betterOrderId: _betterOrderId,
worseOrderId: _worseOrderId
});
}
function getOrderId(Order.Data _orderData) internal view returns (bytes32) {
if (_orderData.id == bytes32(0)) {
bytes32 _orderId = _orderData.orders.getOrderId(_orderData.orderType, _orderData.market, _orderData.amount, _orderData.price, _orderData.creator, block.number, _orderData.outcome, _orderData.moneyEscrowed, _orderData.sharesEscrowed);
require(_orderData.orders.getAmount(_orderId) == 0);
_orderData.id = _orderId;
}
return _orderData.id;
}
function getOrderTradingTypeFromMakerDirection(Order.TradeDirections _creatorDirection) internal pure returns (Order.Types) {
return (_creatorDirection == Order.TradeDirections.Long) ? Order.Types.Bid : Order.Types.Ask;
}
function getOrderTradingTypeFromFillerDirection(Order.TradeDirections _fillerDirection) internal pure returns (Order.Types) {
return (_fillerDirection == Order.TradeDirections.Long) ? Order.Types.Ask : Order.Types.Bid;
}
function escrowFunds(Order.Data _orderData) internal returns (bool) {
if (_orderData.orderType == Order.Types.Ask) {
return escrowFundsForAsk(_orderData);
} else if (_orderData.orderType == Order.Types.Bid) {
return escrowFundsForBid(_orderData);
}
}
function saveOrder(Order.Data _orderData, bytes32 _tradeGroupId) internal returns (bytes32) {
return _orderData.orders.saveOrder(_orderData.orderType, _orderData.market, _orderData.amount, _orderData.price, _orderData.creator, _orderData.outcome, _orderData.moneyEscrowed, _orderData.sharesEscrowed, _orderData.betterOrderId, _orderData.worseOrderId, _tradeGroupId);
}
function escrowFundsForBid(Order.Data _orderData) private returns (bool) {
require(_orderData.moneyEscrowed == 0);
require(_orderData.sharesEscrowed == 0);
uint256 _attosharesToCover = _orderData.amount;
uint256 _numberOfOutcomes = _orderData.market.getNumberOfOutcomes();
uint256 _attosharesHeld = 2**254;
for (uint256 _i = 0; _i < _numberOfOutcomes; _i++) {
if (_i != _orderData.outcome) {
uint256 _creatorShareTokenBalance = _orderData.market.getShareToken(_i).balanceOf(_orderData.creator);
_attosharesHeld = SafeMathUint256.min(_creatorShareTokenBalance, _attosharesHeld);
}
}
if (_attosharesHeld > 0) {
_orderData.sharesEscrowed = SafeMathUint256.min(_attosharesHeld, _attosharesToCover);
_attosharesToCover -= _orderData.sharesEscrowed;
for (_i = 0; _i < _numberOfOutcomes; _i++) {
if (_i != _orderData.outcome) {
_orderData.market.getShareToken(_i).trustedOrderTransfer(_orderData.creator, _orderData.market, _orderData.sharesEscrowed);
}
}
}
if (_attosharesToCover > 0) {
_orderData.moneyEscrowed = _attosharesToCover.mul(_orderData.price);
require(_orderData.augur.trustedTransfer(_orderData.market.getDenominationToken(), _orderData.creator, _orderData.market, _orderData.moneyEscrowed));
}
return true;
}
function escrowFundsForAsk(Order.Data _orderData) private returns (bool) {
require(_orderData.moneyEscrowed == 0);
require(_orderData.sharesEscrowed == 0);
IShareToken _shareToken = _orderData.market.getShareToken(_orderData.outcome);
uint256 _attosharesToCover = _orderData.amount;
uint256 _attosharesHeld = _shareToken.balanceOf(_orderData.creator);
if (_attosharesHeld > 0) {
_orderData.sharesEscrowed = SafeMathUint256.min(_attosharesHeld, _attosharesToCover);
_attosharesToCover -= _orderData.sharesEscrowed;
_shareToken.trustedOrderTransfer(_orderData.creator, _orderData.market, _orderData.sharesEscrowed);
}
if (_attosharesToCover > 0) {
_orderData.moneyEscrowed = _orderData.market.getNumTicks().sub(_orderData.price).mul(_attosharesToCover);
require(_orderData.augur.trustedTransfer(_orderData.market.getDenominationToken(), _orderData.creator, _orderData.market, _orderData.moneyEscrowed));
}
return true;
}
}