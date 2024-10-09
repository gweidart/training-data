pragma solidity 0.4.24;
library SafeMath {
function mul(uint256 a, uint256 b) internal pure returns (uint256) {
if (a == 0 || b == 0) {
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
require(msg.sender == owner, "Invalid owner");
_;
}
function transferOwnership(address newOwner) public onlyOwner {
require(newOwner != address(0), "Zero address");
emit OwnershipTransferred(owner, newOwner);
owner = newOwner;
}
}
contract ERC20 {
function totalSupply() public view returns (uint256);
function balanceOf(address _owner) public view returns (uint256);
function transfer(address to, uint256 value) public returns (bool);
function allowance(address owner, address spender) public view returns (uint256);
function transferFrom(address from, address to, uint256 value) public returns (bool);
function approve(address spender, uint256 value) public returns (bool);
event Transfer(address indexed from, address indexed to, uint256 value);
event Approval(address indexed owner, address indexed spender, uint256 value);
}
contract EyeToken is ERC20, Ownable {
using SafeMath for uint256;
struct Frozen {
bool frozen;
uint until;
}
string public name = "EyeCoin";
string public symbol = "EYE";
uint8 public decimals = 18;
mapping(address => uint256) internal balances;
mapping(address => mapping(address => uint256)) internal allowed;
mapping(address => Frozen) public frozenAccounts;
uint256 internal totalSupplyTokens;
bool internal isICO;
address public wallet;
function EyeToken() public Ownable() {
wallet = msg.sender;
isICO = true;
totalSupplyTokens = 10000000000 * 10 ** uint256(decimals);
balances[wallet] = totalSupplyTokens;
}
function finalizeICO() public onlyOwner {
isICO = false;
}
function totalSupply() public view returns (uint256) {
return totalSupplyTokens;
}
function freeze(address _account) public onlyOwner {
freeze(_account, 0);
}
function freeze(address _account, uint _until) public onlyOwner {
if (_until == 0 || (_until != 0 && _until > now)) {
frozenAccounts[_account] = Frozen(true, _until);
}
}
function unfreeze(address _account) public onlyOwner {
if (frozenAccounts[_account].frozen) {
delete frozenAccounts[_account];
}
}
modifier allowTransfer(address _from) {
assert(!isICO);
if (frozenAccounts[_from].frozen) {
require(frozenAccounts[_from].until != 0 && frozenAccounts[_from].until < now, "Frozen account");
delete frozenAccounts[_from];
}
_;
}
function transfer(address _to, uint256 _value) public returns (bool) {
bool result = _transfer(msg.sender, _to, _value);
emit Transfer(msg.sender, _to, _value);
return result;
}
function transferICO(address _to, uint256 _value) public onlyOwner returns (bool) {
assert(isICO);
require(_to != address(0), "Zero address 'To'");
require(_value <= balances[wallet], "Not enought balance");
balances[wallet] = balances[wallet].sub(_value);
balances[_to] = balances[_to].add(_value);
emit Transfer(wallet, _to, _value);
return true;
}
function balanceOf(address _owner) public view returns (uint256) {
return balances[_owner];
}
function transferFrom(address _from, address _to, uint256 _value) public allowTransfer(_from) returns (bool) {
require(_value <= allowed[_from][msg.sender], "Not enought allowance");
bool result = _transfer(_from, _to, _value);
if (result) {
allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
emit Transfer(_from, _to, _value);
}
return result;
}
function approve(address _spender, uint256 _value) public returns (bool) {
allowed[msg.sender][_spender] = _value;
emit Approval(msg.sender, _spender, _value);
return true;
}
function allowance(address _owner, address _spender) public view returns (uint256) {
return allowed[_owner][_spender];
}
function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
return true;
}
function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
uint oldValue = allowed[msg.sender][_spender];
if (_subtractedValue > oldValue) {
allowed[msg.sender][_spender] = 0;
} else {
allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
}
emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
return true;
}
function _transfer(address _from, address _to, uint256 _value) internal allowTransfer(_from) returns (bool) {
require(_to != address(0), "Zero address 'To'");
require(_from != address(0), "Zero address 'From'");
require(_value <= balances[_from], "Not enought balance");
balances[_from] = balances[_from].sub(_value);
balances[_to] = balances[_to].add(_value);
return true;
}
}
contract CrowdSale is Ownable {
using SafeMath for uint256;
event Payment(
address wallet,
uint date,
uint256 amountEth,
uint256 amountCoin,
uint8 bonusPercent
);
uint constant internal MIN_TOKEN_AMOUNT = 5000;
uint constant internal SECONDS_IN_DAY = 86400;
uint constant internal SECONDS_IN_YEAR = 31557600;
int8 constant internal PHASE_NOT_STARTED = -5;
int8 constant internal PHASE_BEFORE_PRESALE = -4;
int8 constant internal PHASE_BETWEEN_PRESALE_ICO = -3;
int8 constant internal PHASE_ICO_FINISHED = -2;
int8 constant internal PHASE_FINISHED = -1;
int8 constant internal PHASE_PRESALE = 0;
int8 constant internal PHASE_ICO_1 = 1;
int8 constant internal PHASE_ICO_2 = 2;
int8 constant internal PHASE_ICO_3 = 3;
int8 constant internal PHASE_ICO_4 = 4;
int8 constant internal PHASE_ICO_5 = 5;
address internal manager;
EyeToken internal token;
address internal base_wallet;
uint256 internal dec_mul;
address internal vest_1;
address internal vest_2;
address internal vest_3;
address internal vest_4;
int8 internal phase_i;
uint internal presale_start = 1533020400;
uint internal presale_end = 1534316400;
uint internal ico_start = 1537254000;
uint internal ico_phase_1_days = 7;
uint internal ico_phase_2_days = 7;
uint internal ico_phase_3_days = 7;
uint internal ico_phase_4_days = 7;
uint internal ico_phase_5_days = 7;
uint internal ico_phase_1_end;
uint internal ico_phase_2_end;
uint internal ico_phase_3_end;
uint internal ico_phase_4_end;
uint internal ico_phase_5_end;
uint8[6] public bonus_percents = [50, 40, 30, 20, 10, 0];
uint internal finish_date;
uint public exchange_rate;
uint256 public lastPayerOverflow = 0;
function CrowdSale() Ownable() public {
phase_i = PHASE_NOT_STARTED;
manager = address(0);
}
modifier onlyOwnerOrManager(){
require(msg.sender == owner || (msg.sender == manager && manager != address(0)), "Invalid owner or manager");
_;
}
function getManager() public view onlyOwnerOrManager returns (address) {
return manager;
}
function setManager(address _manager) public onlyOwner {
manager = _manager;
}
function setRate(uint _rate) public onlyOwnerOrManager {
require(_rate > 0, "Invalid exchange rate");
exchange_rate = _rate;
}
function _addPayment(address wallet, uint256 amountEth, uint256 amountCoin, uint8 bonusPercent) internal {
emit Payment(wallet, now, amountEth, amountCoin, bonusPercent);
}
function start(address _token, uint256 _rate) public onlyOwnerOrManager {
require(_rate > 0, "Invalid exchange rate");
assert(phase_i == PHASE_NOT_STARTED);
token = EyeToken(_token);
base_wallet = token.wallet();
dec_mul = 10 ** uint256(token.decimals());
address org_exp = 0x45709fcBeb5D133bFA336d8c70FFFF98eE815359;
address ear_brd = 0xE640b346E1d9A1eb3F809608a8a92f041D02F3BE;
address com_dev = 0xdC2c6398F7a9cF2CbdCfEcB37CF732f486642316;
address special = 0x1dBcDb11c6C05a4EA541227fBdEeB02d6492BD07;
vest_1 = 0xC49d11a05aF6D5BDeBfd18E0010516D9840f3610;
vest_2 = 0x7Fd486029C8D81f4894e4ef0D460c2bD97187aeF;
vest_3 = 0xcCcC86e1086015AEE865165f6f93a82dE591Cb3C;
vest_4 = 0xd7569317e6af13D4d3832613F930cc5b7cecaE6e;
token.transferICO(org_exp, 600000000 * dec_mul);
token.transferICO(ear_brd, 1000000000 * dec_mul);
token.transferICO(com_dev, 1000000000 * dec_mul);
token.transferICO(special, 800000000 * dec_mul);
token.transferICO(vest_1, 500000000 * dec_mul);
token.transferICO(vest_2, 500000000 * dec_mul);
token.transferICO(vest_3, 500000000 * dec_mul);
token.transferICO(vest_4, 500000000 * dec_mul);
exchange_rate = _rate;
phase_i = PHASE_BEFORE_PRESALE;
_updatePhaseTimes();
}
function _finalizeICO() internal {
assert(phase_i != PHASE_NOT_STARTED && phase_i != PHASE_FINISHED);
phase_i = PHASE_ICO_FINISHED;
uint curr_date = now;
finish_date = (curr_date < ico_phase_5_end ? ico_phase_5_end : curr_date).add(SECONDS_IN_DAY * 10);
}
function _finalize() internal {
assert(phase_i != PHASE_NOT_STARTED && phase_i != PHASE_FINISHED);
uint date = now.add(SECONDS_IN_YEAR);
token.freeze(vest_1, date);
date = date.add(SECONDS_IN_YEAR);
token.freeze(vest_2, date);
date = date.add(SECONDS_IN_YEAR);
token.freeze(vest_3, date);
date = date.add(SECONDS_IN_YEAR);
token.freeze(vest_4, date);
token.finalizeICO();
token.transferOwnership(base_wallet);
phase_i = PHASE_FINISHED;
}
function finalize() public onlyOwner {
_finalize();
}
function _calcPhase() internal view returns (int8) {
if (phase_i == PHASE_FINISHED || phase_i == PHASE_NOT_STARTED)
return phase_i;
uint curr_date = now;
if (curr_date >= ico_phase_5_end || token.balanceOf(base_wallet) == 0)
return PHASE_ICO_FINISHED;
if (curr_date < presale_start)
return PHASE_BEFORE_PRESALE;
if (curr_date <= presale_end)
return PHASE_PRESALE;
if (curr_date < ico_start)
return PHASE_BETWEEN_PRESALE_ICO;
if (curr_date < ico_phase_1_end)
return PHASE_ICO_1;
if (curr_date < ico_phase_2_end)
return PHASE_ICO_2;
if (curr_date < ico_phase_3_end)
return PHASE_ICO_3;
if (curr_date < ico_phase_4_end)
return PHASE_ICO_4;
return PHASE_ICO_5;
}
function phase() public view returns (int8) {
return _calcPhase();
}
function _updatePhase(bool check_can_sale) internal {
uint curr_date = now;
if (phase_i == PHASE_ICO_FINISHED) {
if (curr_date >= finish_date)
_finalize();
}
else
if (phase_i != PHASE_NOT_STARTED && phase_i != PHASE_FINISHED) {
int8 new_phase = _calcPhase();
if (new_phase == PHASE_ICO_FINISHED && phase_i != PHASE_ICO_FINISHED)
_finalizeICO();
else
phase_i = new_phase;
}
if (check_can_sale)
assert(phase_i >= 0);
}
function _updatePhaseTimes() internal {
assert(phase_i != PHASE_NOT_STARTED && phase_i != PHASE_FINISHED);
if (phase_i < PHASE_ICO_1)
ico_phase_1_end = ico_start.add(SECONDS_IN_DAY.mul(ico_phase_1_days));
if (phase_i < PHASE_ICO_2)
ico_phase_2_end = ico_phase_1_end.add(SECONDS_IN_DAY.mul(ico_phase_2_days));
if (phase_i < PHASE_ICO_3)
ico_phase_3_end = ico_phase_2_end.add(SECONDS_IN_DAY.mul(ico_phase_3_days));
if (phase_i < PHASE_ICO_4)
ico_phase_4_end = ico_phase_3_end.add(SECONDS_IN_DAY.mul(ico_phase_4_days));
if (phase_i < PHASE_ICO_5)
ico_phase_5_end = ico_phase_4_end.add(SECONDS_IN_DAY.mul(ico_phase_5_days));
if (phase_i != PHASE_ICO_FINISHED)
finish_date = ico_phase_5_end.add(SECONDS_IN_DAY.mul(10));
_updatePhase(false);
}
function transferICO(address _to, uint256 _amount_coin) public onlyOwnerOrManager {
_updatePhase(true);
uint256 remainedCoin = token.balanceOf(base_wallet);
require(remainedCoin >= _amount_coin, "Not enough coins");
token.transferICO(_to, _amount_coin);
if (remainedCoin == _amount_coin)
_finalizeICO();
}
function() public payable {
_updatePhase(true);
address sender = msg.sender;
uint256 amountEth = msg.value;
uint256 remainedCoin = token.balanceOf(base_wallet);
if (remainedCoin == 0) {
sender.transfer(amountEth);
_finalizeICO();
} else {
uint8 percent = bonus_percents[uint256(phase_i)];
uint256 amountCoin = calcTokensFromEth(amountEth);
assert(amountCoin >= MIN_TOKEN_AMOUNT);
if (amountCoin > remainedCoin) {
lastPayerOverflow = amountCoin.sub(remainedCoin);
amountCoin = remainedCoin;
}
base_wallet.transfer(amountEth);
token.transferICO(sender, amountCoin);
_addPayment(sender, amountEth, amountCoin, percent);
if (amountCoin == remainedCoin)
_finalizeICO();
}
}
function calcTokensFromEth(uint256 ethAmount) internal view returns (uint256) {
uint8 percent = bonus_percents[uint256(phase_i)];
uint256 bonusRate = uint256(percent).add(100);
uint256 totalCoins = ethAmount.mul(exchange_rate).div(1000);
uint256 totalFullCoins = (totalCoins.add(dec_mul.div(2))).div(dec_mul);
uint256 tokensWithBonusX100 = bonusRate.mul(totalFullCoins);
uint256 fullCoins = (tokensWithBonusX100.add(50)).div(100);
return fullCoins.mul(dec_mul);
}
function freeze(address[] _accounts) public onlyOwnerOrManager {
assert(phase_i != PHASE_NOT_STARTED && phase_i != PHASE_FINISHED);
uint i;
for (i = 0; i < _accounts.length; i++) {
require(_accounts[i] != address(0), "Zero address");
require(_accounts[i] != base_wallet, "Freeze self");
}
for (i = 0; i < _accounts.length; i++) {
token.freeze(_accounts[i]);
}
}
function unfreeze(address[] _accounts) public onlyOwnerOrManager {
assert(phase_i != PHASE_NOT_STARTED && phase_i != PHASE_FINISHED);
uint i;
for (i = 0; i < _accounts.length; i++) {
require(_accounts[i] != address(0), "Zero address");
require(_accounts[i] != base_wallet, "Freeze self");
}
for (i = 0; i < _accounts.length; i++) {
token.unfreeze(_accounts[i]);
}
}
function getTimes() public view returns (uint, uint, uint, uint, uint, uint, uint, uint) {
return (presale_start, presale_end, ico_start, ico_phase_1_end, ico_phase_2_end, ico_phase_3_end, ico_phase_4_end, ico_phase_5_end);
}
function setPresaleDates(uint _presale_start, uint _presale_end) public onlyOwnerOrManager {
_updatePhase(false);
assert(phase_i == PHASE_BEFORE_PRESALE);
require(_presale_start < _presale_end);
require(_presale_end < ico_start);
presale_start = _presale_start;
presale_end = _presale_end;
}
function setICODates(uint _ico_start, uint _ico_1_days, uint _ico_2_days, uint _ico_3_days, uint _ico_4_days, uint _ico_5_days) public onlyOwnerOrManager {
_updatePhase(false);
assert(phase_i != PHASE_FINISHED && phase_i != PHASE_ICO_FINISHED && phase_i < PHASE_ICO_1);
require(presale_end < _ico_start);
ico_start = _ico_start;
ico_phase_1_days = _ico_1_days;
ico_phase_2_days = _ico_2_days;
ico_phase_3_days = _ico_3_days;
ico_phase_4_days = _ico_4_days;
ico_phase_5_days = _ico_5_days;
_updatePhaseTimes();
}
}