pragma solidity 0.4.18;
interface ERC20 {
function totalSupply() public view returns (uint supply);
function balanceOf(address _owner) public view returns (uint balance);
function transfer(address _to, uint _value) public returns (bool success);
function transferFrom(address _from, address _to, uint _value) public returns (bool success);
function approve(address _spender, uint _value) public returns (bool success);
function allowance(address _owner, address _spender) public view returns (uint remaining);
function decimals() public view returns(uint digits);
event Approval(address indexed _owner, address indexed _spender, uint _value);
}
interface KyberReserveInterface {
function trade(
ERC20 srcToken,
uint srcAmount,
ERC20 destToken,
address destAddress,
uint conversionRate,
bool validate
)
public
payable
returns(bool);
function getConversionRate(ERC20 src, ERC20 dest, uint srcQty, uint blockNumber) public view returns(uint);
}
contract Utils {
ERC20 constant internal ETH_TOKEN_ADDRESS = ERC20(0x00eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee);
uint  constant internal PRECISION = (10**18);
uint  constant internal MAX_QTY   = (10**28);
uint  constant internal MAX_RATE  = (PRECISION * 10**6);
uint  constant internal MAX_DECIMALS = 18;
uint  constant internal ETH_DECIMALS = 18;
mapping(address=>uint) internal decimals;
function setDecimals(ERC20 token) internal {
if (token == ETH_TOKEN_ADDRESS) decimals[token] = ETH_DECIMALS;
else decimals[token] = token.decimals();
}
function getDecimals(ERC20 token) internal view returns(uint) {
if (token == ETH_TOKEN_ADDRESS) return ETH_DECIMALS;
uint tokenDecimals = decimals[token];
if(tokenDecimals == 0) return token.decimals();
return tokenDecimals;
}
function calcDstQty(uint srcQty, uint srcDecimals, uint dstDecimals, uint rate) internal pure returns(uint) {
require(srcQty <= MAX_QTY);
require(rate <= MAX_RATE);
if (dstDecimals >= srcDecimals) {
require((dstDecimals - srcDecimals) <= MAX_DECIMALS);
return (srcQty * rate * (10**(dstDecimals - srcDecimals))) / PRECISION;
} else {
require((srcDecimals - dstDecimals) <= MAX_DECIMALS);
return (srcQty * rate) / (PRECISION * (10**(srcDecimals - dstDecimals)));
}
}
function calcSrcQty(uint dstQty, uint srcDecimals, uint dstDecimals, uint rate) internal pure returns(uint) {
require(dstQty <= MAX_QTY);
require(rate <= MAX_RATE);
uint numerator;
uint denominator;
if (srcDecimals >= dstDecimals) {
require((srcDecimals - dstDecimals) <= MAX_DECIMALS);
numerator = (PRECISION * dstQty * (10**(srcDecimals - dstDecimals)));
denominator = rate;
} else {
require((dstDecimals - srcDecimals) <= MAX_DECIMALS);
numerator = (PRECISION * dstQty);
denominator = (rate * (10**(dstDecimals - srcDecimals)));
}
return (numerator + denominator - 1) / denominator;
}
}
contract PermissionGroups {
address public admin;
address public pendingAdmin;
mapping(address=>bool) internal operators;
mapping(address=>bool) internal alerters;
address[] internal operatorsGroup;
address[] internal alertersGroup;
uint constant internal MAX_GROUP_SIZE = 50;
function PermissionGroups() public {
admin = msg.sender;
}
modifier onlyAdmin() {
require(msg.sender == admin);
_;
}
modifier onlyOperator() {
require(operators[msg.sender]);
_;
}
modifier onlyAlerter() {
require(alerters[msg.sender]);
_;
}
function getOperators () external view returns(address[]) {
return operatorsGroup;
}
function getAlerters () external view returns(address[]) {
return alertersGroup;
}
event TransferAdminPending(address pendingAdmin);
function transferAdmin(address newAdmin) public onlyAdmin {
require(newAdmin != address(0));
TransferAdminPending(pendingAdmin);
pendingAdmin = newAdmin;
}
function transferAdminQuickly(address newAdmin) public onlyAdmin {
require(newAdmin != address(0));
TransferAdminPending(newAdmin);
AdminClaimed(newAdmin, admin);
admin = newAdmin;
}
event AdminClaimed( address newAdmin, address previousAdmin);
function claimAdmin() public {
require(pendingAdmin == msg.sender);
AdminClaimed(pendingAdmin, admin);
admin = pendingAdmin;
pendingAdmin = address(0);
}
event AlerterAdded (address newAlerter, bool isAdd);
function addAlerter(address newAlerter) public onlyAdmin {
require(!alerters[newAlerter]);
require(alertersGroup.length < MAX_GROUP_SIZE);
AlerterAdded(newAlerter, true);
alerters[newAlerter] = true;
alertersGroup.push(newAlerter);
}
function removeAlerter (address alerter) public onlyAdmin {
require(alerters[alerter]);
alerters[alerter] = false;
for (uint i = 0; i < alertersGroup.length; ++i) {
if (alertersGroup[i] == alerter) {
alertersGroup[i] = alertersGroup[alertersGroup.length - 1];
alertersGroup.length--;
AlerterAdded(alerter, false);
break;
}
}
}
event OperatorAdded(address newOperator, bool isAdd);
function addOperator(address newOperator) public onlyAdmin {
require(!operators[newOperator]);
require(operatorsGroup.length < MAX_GROUP_SIZE);
OperatorAdded(newOperator, true);
operators[newOperator] = true;
operatorsGroup.push(newOperator);
}
function removeOperator (address operator) public onlyAdmin {
require(operators[operator]);
operators[operator] = false;
for (uint i = 0; i < operatorsGroup.length; ++i) {
if (operatorsGroup[i] == operator) {
operatorsGroup[i] = operatorsGroup[operatorsGroup.length - 1];
operatorsGroup.length -= 1;
OperatorAdded(operator, false);
break;
}
}
}
}
contract Withdrawable is PermissionGroups {
event TokenWithdraw(ERC20 token, uint amount, address sendTo);
function withdrawToken(ERC20 token, uint amount, address sendTo) external onlyAdmin {
require(token.transfer(sendTo, amount));
TokenWithdraw(token, amount, sendTo);
}
event EtherWithdraw(uint amount, address sendTo);
function withdrawEther(uint amount, address sendTo) external onlyAdmin {
sendTo.transfer(amount);
EtherWithdraw(amount, sendTo);
}
}
contract OtcInterface {
function getBuyAmount(address, address, uint) public constant returns (uint);
}
contract OasisDirectInterface {
function sellAllAmountPayEth(OtcInterface, ERC20, ERC20, uint)public payable returns (uint);
function sellAllAmountBuyEth(OtcInterface, ERC20, uint, ERC20, uint) public returns (uint);
}
contract KyberOasisReserve is KyberReserveInterface, Withdrawable, Utils {
address public kyberNetwork;
OasisDirectInterface public oasisDirect;
OtcInterface public otc;
ERC20 public wethToken;
ERC20 public tradeToken;
bool public tradeEnabled;
function KyberOasisReserve(
address _kyberNetwork,
OasisDirectInterface _oasisDirect,
OtcInterface _otc,
ERC20 _wethToken,
ERC20 _tradeToken,
address _admin
) public {
require(_admin != address(0));
require(_oasisDirect != address(0));
require(_kyberNetwork != address(0));
require(_otc != address(0));
require(_wethToken != address(0));
require(_tradeToken != address(0));
kyberNetwork = _kyberNetwork;
oasisDirect = _oasisDirect;
otc = _otc;
wethToken = _wethToken;
tradeToken = _tradeToken;
admin = _admin;
tradeEnabled = true;
}
function() public payable {
DepositToken(ETH_TOKEN_ADDRESS, msg.value);
}
event TradeExecute(
address indexed origin,
address src,
uint srcAmount,
address destToken,
uint destAmount,
address destAddress
);
function trade(
ERC20 srcToken,
uint srcAmount,
ERC20 destToken,
address destAddress,
uint conversionRate,
bool validate
)
public
payable
returns(bool)
{
require(tradeEnabled);
require(msg.sender == kyberNetwork);
require(doTrade(srcToken, srcAmount, destToken, destAddress, conversionRate, validate));
return true;
}
event TradeEnabled(bool enable);
function enableTrade() public onlyAdmin returns(bool) {
tradeEnabled = true;
TradeEnabled(true);
return true;
}
function disableTrade() public onlyAlerter returns(bool) {
tradeEnabled = false;
TradeEnabled(false);
return true;
}
event SetContractAddresses(
address kyberNetwork,
OasisDirectInterface oasisDirect,
OtcInterface otc,
ERC20 wethToken,
ERC20 tradeToken
);
function setContracts(
address _kyberNetwork,
OasisDirectInterface _oasisDirect,
OtcInterface _otc,
ERC20 _wethToken,
ERC20 _tradeToken
)
public
onlyAdmin
{
require(_kyberNetwork != address(0));
require(_oasisDirect != address(0));
require(_otc != address(0));
require(_wethToken != address(0));
require(_tradeToken != address(0));
kyberNetwork = _kyberNetwork;
oasisDirect = _oasisDirect;
otc = _otc;
wethToken = _wethToken;
tradeToken = _tradeToken;
setContracts(kyberNetwork, oasisDirect, otc, wethToken, tradeToken);
}
function getDestQty(ERC20 src, ERC20 dest, uint srcQty, uint rate) public view returns(uint) {
uint dstDecimals = getDecimals(dest);
uint srcDecimals = getDecimals(src);
return calcDstQty(srcQty, srcDecimals, dstDecimals, rate);
}
function getConversionRate(ERC20 src, ERC20 dest, uint srcQty, uint blockNumber) public view returns(uint) {
uint  rate;
uint  dstQty;
blockNumber;
if (!tradeEnabled) return 0;
if ((ETH_TOKEN_ADDRESS != src) && (ETH_TOKEN_ADDRESS != dest)) return 0;
if ((tradeToken != src) && (tradeToken != dest)) return 0;
dstQty = otc.getBuyAmount(dest, src, srcQty);
rate = dstQty * PRECISION / srcQty;
return rate;
}
function doTrade(
ERC20 srcToken,
uint srcAmount,
ERC20 destToken,
address destAddress,
uint conversionRate,
bool validate
)
internal
returns(bool)
{
uint actualDestAmount;
require((ETH_TOKEN_ADDRESS == srcToken) || (ETH_TOKEN_ADDRESS == destToken));
require((tradeToken == srcToken) || (tradeToken == destToken));
if (validate) {
require(conversionRate > 0);
if (srcToken == ETH_TOKEN_ADDRESS)
require(msg.value == srcAmount);
else
require(msg.value == 0);
}
uint destAmount = getDestQty(srcToken, destToken, srcAmount, conversionRate);
require(destAmount > 0);
if (srcToken == ETH_TOKEN_ADDRESS) {
actualDestAmount = oasisDirect.sellAllAmountPayEth.value(msg.value)(otc, wethToken, destToken, destAmount);
require(actualDestAmount >= destAmount);
require(destToken.transfer(destAddress, actualDestAmount));
} else {
require(srcToken.transferFrom(msg.sender, this, srcAmount));
if (srcToken.allowance(this, oasisDirect) < srcAmount) {
srcToken.approve(oasisDirect, uint(-1));
}
actualDestAmount = oasisDirect.sellAllAmountBuyEth(otc, srcToken, srcAmount, wethToken, destAmount);
require(actualDestAmount >= destAmount);
destAddress.transfer(actualDestAmount);
}
TradeExecute(msg.sender, srcToken, srcAmount, destToken, actualDestAmount, destAddress);
return true;
}
event DepositToken(ERC20 token, uint amount);
}