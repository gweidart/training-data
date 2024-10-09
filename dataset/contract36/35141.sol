contract FlightDelayControllerInterface {
function isOwner(address _addr) returns (bool _isOwner);
function selfRegister(bytes32 _id) returns (bool result);
function getContract(bytes32 _id) returns (address _addr);
}
contract FlightDelayDatabaseModel {
enum Acc {
Premium,
RiskFund,
Payout,
Balance,
Reward,
OraclizeCosts
}
enum policyState { Applied, Accepted, Revoked, PaidOut, Expired, Declined, SendFailed }
enum oraclizeState { ForUnderwriting, ForPayout }
enum Currency { ETH, EUR, USD, GBP }
struct Policy {
address customer;
uint premium;
bytes32 riskId;
uint weight;
uint calculatedPayout;
uint actualPayout;
policyState state;
uint stateTime;
bytes32 stateMessage;
bytes proof;
Currency currency;
bytes32 customerExternalId;
}
struct Risk {
bytes32 carrierFlightNumber;
bytes32 departureYearMonthDay;
uint arrivalTime;
uint delayInMinutes;
uint8 delay;
uint cumulatedWeightedPremium;
uint premiumMultiplier;
}
struct OraclizeCallback {
uint policyId;
oraclizeState oState;
uint oraclizeTime;
}
struct Customer {
bytes32 customerExternalId;
bool identityConfirmed;
}
}
contract FlightDelayControlledContract is FlightDelayDatabaseModel {
address public controller;
FlightDelayControllerInterface FD_CI;
modifier onlyController() {
require(msg.sender == controller);
_;
}
function setController(address _controller) internal returns (bool _result) {
controller = _controller;
FD_CI = FlightDelayControllerInterface(_controller);
_result = true;
}
function destruct() onlyController {
selfdestruct(controller);
}
function setContracts() onlyController {}
function getContract(bytes32 _id) internal returns (address _addr) {
_addr = FD_CI.getContract(_id);
}
}
contract FlightDelayDatabaseInterface is FlightDelayDatabaseModel {
function setAccessControl(address _contract, address _caller, uint8 _perm);
function setAccessControl(
address _contract,
address _caller,
uint8 _perm,
bool _access
);
function getAccessControl(address _contract, address _caller, uint8 _perm) returns (bool _allowed);
function setLedger(uint8 _index, int _value);
function getLedger(uint8 _index) returns (int _value);
function getCustomerPremium(uint _policyId) returns (address _customer, uint _premium);
function getPolicyData(uint _policyId) returns (address _customer, uint _premium, uint _weight);
function getPolicyState(uint _policyId) returns (policyState _state);
function getRiskId(uint _policyId) returns (bytes32 _riskId);
function createPolicy(address _customer, uint _premium, Currency _currency, bytes32 _customerExternalId, bytes32 _riskId) returns (uint _policyId);
function setState(
uint _policyId,
policyState _state,
uint _stateTime,
bytes32 _stateMessage
);
function setWeight(uint _policyId, uint _weight, bytes _proof);
function setPayouts(uint _policyId, uint _calculatedPayout, uint _actualPayout);
function setDelay(uint _policyId, uint8 _delay, uint _delayInMinutes);
function getRiskParameters(bytes32 _riskId)
returns (bytes32 _carrierFlightNumber, bytes32 _departureYearMonthDay, uint _arrivalTime);
function getPremiumFactors(bytes32 _riskId)
returns (uint _cumulatedWeightedPremium, uint _premiumMultiplier);
function createUpdateRisk(bytes32 _carrierFlightNumber, bytes32 _departureYearMonthDay, uint _arrivalTime)
returns (bytes32 _riskId);
function setPremiumFactors(bytes32 _riskId, uint _cumulatedWeightedPremium, uint _premiumMultiplier);
function getOraclizeCallback(bytes32 _queryId)
returns (uint _policyId, uint _arrivalTime);
function getOraclizePolicyId(bytes32 _queryId)
returns (uint _policyId);
function createOraclizeCallback(
bytes32 _queryId,
uint _policyId,
oraclizeState _oraclizeState,
uint _oraclizeTime
);
function checkTime(bytes32 _queryId, bytes32 _riskId, uint _offset)
returns (bool _result);
}
contract FlightDelayAccessControllerInterface {
function setPermissionById(uint8 _perm, bytes32 _id);
function setPermissionById(uint8 _perm, bytes32 _id, bool _access);
function setPermissionByAddress(uint8 _perm, address _addr);
function setPermissionByAddress(uint8 _perm, address _addr, bool _access);
function checkPermission(uint8 _perm, address _addr) returns (bool _success);
}
contract FlightDelayConstants {
event LogPolicyApplied(
uint _policyId,
address _customer,
bytes32 strCarrierFlightNumber,
uint ethPremium
);
event LogPolicyAccepted(
uint _policyId,
uint _statistics0,
uint _statistics1,
uint _statistics2,
uint _statistics3,
uint _statistics4,
uint _statistics5
);
event LogPolicyPaidOut(
uint _policyId,
uint ethAmount
);
event LogPolicyExpired(
uint _policyId
);
event LogPolicyDeclined(
uint _policyId,
bytes32 strReason
);
event LogPolicyManualPayout(
uint _policyId,
bytes32 strReason
);
event LogSendFunds(
address _recipient,
uint8 _from,
uint ethAmount
);
event LogReceiveFunds(
address _sender,
uint8 _to,
uint ethAmount
);
event LogSendFail(
uint _policyId,
bytes32 strReason
);
event LogOraclizeCall(
uint _policyId,
bytes32 hexQueryId,
string _oraclizeUrl
);
event LogOraclizeCallback(
uint _policyId,
bytes32 hexQueryId,
string _result,
bytes hexProof
);
event LogSetState(
uint _policyId,
uint8 _policyState,
uint _stateTime,
bytes32 _stateMessage
);
event LogExternal(
uint256 _policyId,
address _address,
bytes32 _externalId
);
uint constant MIN_OBSERVATIONS = 10;
uint constant MIN_PREMIUM = 50 finney;
uint constant MAX_PREMIUM = 1 ether;
uint constant MAX_PAYOUT = 1100 finney;
uint constant MIN_PREMIUM_EUR = 1500 wei;
uint constant MAX_PREMIUM_EUR = 29000 wei;
uint constant MAX_PAYOUT_EUR = 30000 wei;
uint constant MIN_PREMIUM_USD = 1700 wei;
uint constant MAX_PREMIUM_USD = 34000 wei;
uint constant MAX_PAYOUT_USD = 35000 wei;
uint constant MIN_PREMIUM_GBP = 1300 wei;
uint constant MAX_PREMIUM_GBP = 25000 wei;
uint constant MAX_PAYOUT_GBP = 270 wei;
uint constant MAX_CUMULATED_WEIGHTED_PREMIUM = 300 ether;
uint8 constant REWARD_PERCENT = 2;
uint8 constant RESERVE_PERCENT = 1;
uint8[6] WEIGHT_PATTERN = [
0,
10,
20,
30,
50,
50
];
uint constant MIN_TIME_BEFORE_DEPARTURE = 24 hours;
uint constant CHECK_PAYOUT_OFFSET = 15 minutes;
uint constant MAX_FLIGHT_DURATION = 2 days;
uint constant CONTRACT_DEAD_LINE = 1922396399;
uint constant MIN_DEPARTURE_LIM = 1508198400;
uint constant MAX_DEPARTURE_LIM = 1509494400;
uint constant ORACLIZE_GAS = 1000000;
string constant ORACLIZE_RATINGS_BASE_URL =
"[URL] json(https:
string constant ORACLIZE_RATINGS_QUERY =
"?${[decrypt] <!--PUT ENCRYPTED_QUERY HERE--> }).ratings[0]['observations','late15','late30','late45','cancelled','diverted','arrivalAirportFsCode']";
string constant ORACLIZE_STATUS_BASE_URL =
"[URL] json(https:
string constant ORACLIZE_STATUS_QUERY =
"?${[decrypt] <!--PUT ENCRYPTED_QUERY HERE--> }&utc=true).flightStatuses[0]['status','delays','operationalTimes']";
}
contract FlightDelayDatabase is FlightDelayControlledContract, FlightDelayDatabaseInterface, FlightDelayConstants {
Policy[] public policies;
mapping (bytes32 => uint[]) public extCustomerPolicies;
mapping (address => Customer) public customers;
mapping (address => uint[]) public customerPolicies;
mapping (bytes32 => OraclizeCallback) public oraclizeCallbacks;
mapping (bytes32 => Risk) public risks;
mapping(address => mapping(address => mapping(uint8 => bool))) public accessControl;
int[6] public ledger;
FlightDelayAccessControllerInterface FD_AC;
function FlightDelayDatabase (address _controller) {
setController(_controller);
}
function setContracts() onlyController {
FD_AC = FlightDelayAccessControllerInterface(getContract("FD.AccessController"));
FD_AC.setPermissionById(101, "FD.NewPolicy");
FD_AC.setPermissionById(101, "FD.Underwrite");
FD_AC.setPermissionById(101, "FD.Payout");
FD_AC.setPermissionById(101, "FD.Ledger");
}
function setAccessControl(
address _contract,
address _caller,
uint8 _perm,
bool _access
) {
require(msg.sender == FD_CI.getContract("FD.AccessController"));
accessControl[_contract][_caller][_perm] = _access;
}
function setAccessControl(address _contract, address _caller, uint8 _perm) {
setAccessControl(
_contract,
_caller,
_perm,
true
);
}
function getAccessControl(address _contract, address _caller, uint8 _perm) returns (bool _allowed) {
_allowed = accessControl[_contract][_caller][_perm];
}
function setLedger(uint8 _index, int _value) {
require(FD_AC.checkPermission(101, msg.sender));
int previous = ledger[_index];
ledger[_index] += _value;
if (_value < 0) {
assert(ledger[_index] < previous);
} else if (_value > 0) {
assert(ledger[_index] > previous);
}
}
function getLedger(uint8 _index) returns (int _value) {
_value = ledger[_index];
}
function getCustomerPremium(uint _policyId) returns (address _customer, uint _premium) {
Policy storage p = policies[_policyId];
_customer = p.customer;
_premium = p.premium;
}
function getPolicyData(uint _policyId) returns (address _customer, uint _weight, uint _premium) {
Policy storage p = policies[_policyId];
_customer = p.customer;
_weight = p.weight;
_premium = p.premium;
}
function getPolicyState(uint _policyId) returns (policyState _state) {
Policy storage p = policies[_policyId];
_state = p.state;
}
function getRiskId(uint _policyId) returns (bytes32 _riskId) {
Policy storage p = policies[_policyId];
_riskId = p.riskId;
}
function createPolicy(address _customer, uint _premium, Currency _currency, bytes32 _customerExternalId, bytes32 _riskId) returns (uint _policyId) {
require(FD_AC.checkPermission(101, msg.sender));
_policyId = policies.length++;
customerPolicies[_customer].push(_policyId);
extCustomerPolicies[_customerExternalId].push(_policyId);
Policy storage p = policies[_policyId];
p.customer = _customer;
p.currency = _currency;
p.customerExternalId = _customerExternalId;
p.premium = _premium;
p.riskId = _riskId;
}
function setState(
uint _policyId,
policyState _state,
uint _stateTime,
bytes32 _stateMessage
) {
require(FD_AC.checkPermission(101, msg.sender));
LogSetState(
_policyId,
uint8(_state),
_stateTime,
_stateMessage
);
Policy storage p = policies[_policyId];
p.state = _state;
p.stateTime = _stateTime;
p.stateMessage = _stateMessage;
}
function setWeight(uint _policyId, uint _weight, bytes _proof) {
require(FD_AC.checkPermission(101, msg.sender));
Policy storage p = policies[_policyId];
p.weight = _weight;
p.proof = _proof;
}
function setPayouts(uint _policyId, uint _calculatedPayout, uint _actualPayout) {
require(FD_AC.checkPermission(101, msg.sender));
Policy storage p = policies[_policyId];
p.calculatedPayout = _calculatedPayout;
p.actualPayout = _actualPayout;
}
function setDelay(uint _policyId, uint8 _delay, uint _delayInMinutes) {
require(FD_AC.checkPermission(101, msg.sender));
Risk storage r = risks[policies[_policyId].riskId];
r.delay = _delay;
r.delayInMinutes = _delayInMinutes;
}
function getRiskParameters(bytes32 _riskId) returns (bytes32 _carrierFlightNumber, bytes32 _departureYearMonthDay, uint _arrivalTime) {
Risk storage r = risks[_riskId];
_carrierFlightNumber = r.carrierFlightNumber;
_departureYearMonthDay = r.departureYearMonthDay;
_arrivalTime = r.arrivalTime;
}
function getPremiumFactors(bytes32 _riskId) returns (uint _cumulatedWeightedPremium, uint _premiumMultiplier) {
Risk storage r = risks[_riskId];
_cumulatedWeightedPremium = r.cumulatedWeightedPremium;
_premiumMultiplier = r.premiumMultiplier;
}
function createUpdateRisk(bytes32 _carrierFlightNumber, bytes32 _departureYearMonthDay, uint _arrivalTime) returns (bytes32 _riskId) {
require(FD_AC.checkPermission(101, msg.sender));
_riskId = sha3(
_carrierFlightNumber,
_departureYearMonthDay,
_arrivalTime
);
Risk storage r = risks[_riskId];
if (r.premiumMultiplier == 0) {
r.carrierFlightNumber = _carrierFlightNumber;
r.departureYearMonthDay = _departureYearMonthDay;
r.arrivalTime = _arrivalTime;
}
}
function setPremiumFactors(bytes32 _riskId, uint _cumulatedWeightedPremium, uint _premiumMultiplier) {
require(FD_AC.checkPermission(101, msg.sender));
Risk storage r = risks[_riskId];
r.cumulatedWeightedPremium = _cumulatedWeightedPremium;
r.premiumMultiplier = _premiumMultiplier;
}
function getOraclizeCallback(bytes32 _queryId) returns (uint _policyId, uint _arrivalTime) {
_policyId = oraclizeCallbacks[_queryId].policyId;
_arrivalTime = risks[policies[_policyId].riskId].arrivalTime;
}
function getOraclizePolicyId(bytes32 _queryId) returns (uint _policyId) {
OraclizeCallback storage o = oraclizeCallbacks[_queryId];
_policyId = o.policyId;
}
function createOraclizeCallback(
bytes32 _queryId,
uint _policyId,
oraclizeState _oraclizeState,
uint _oraclizeTime) {
require(FD_AC.checkPermission(101, msg.sender));
oraclizeCallbacks[_queryId] = OraclizeCallback(_policyId, _oraclizeState, _oraclizeTime);
}
function checkTime(bytes32 _queryId, bytes32 _riskId, uint _offset) returns (bool _result) {
OraclizeCallback storage o = oraclizeCallbacks[_queryId];
Risk storage r = risks[_riskId];
_result = o.oraclizeTime > r.arrivalTime + _offset;
}
}