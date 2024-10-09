pragma solidity 0.4.18;
contract ERC20 {
uint public totalSupply;
function balanceOf(address _owner) constant public returns (uint balance);
function transfer(address _to, uint _value) public returns (bool success);
function transferFrom(address _from, address _to, uint _value) public returns (bool success);
function approve(address _spender, uint _value) public returns (bool success);
function allowance(address _owner, address _spender) public constant returns (uint remaining);
event Transfer(address indexed from, address indexed to, uint value);
event Approval(address indexed owner, address indexed spender, uint value);
}
contract BasicToken is ERC20 {
using SafeMath for uint256;
uint256 public totalSupply;
mapping (address => mapping (address => uint256)) allowed;
mapping (address => uint256) balances;
event Approval(address indexed owner, address indexed spender, uint256 value);
event Transfer(address indexed from, address indexed to, uint256 value);
function approve(address _spender, uint256 _value) public returns (bool) {
if ((_value != 0) && (allowed[msg.sender][_spender] != 0)) {
revert();
}
allowed[msg.sender][_spender] = _value;
Approval(msg.sender, _spender, _value);
return true;
}
function allowance(address _owner, address _spender) constant public returns (uint256 remaining) {
return allowed[_owner][_spender];
}
function balanceOf(address _owner) constant public returns (uint256 balance) {
return balances[_owner];
}
function transfer(address _to, uint256 _value) public returns (bool) {
require(_to != address(0));
balances[msg.sender] = balances[msg.sender].sub(_value);
balances[_to] = balances[_to].add(_value);
Transfer(msg.sender, _to, _value);
return true;
}
function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
require(_to != address(0));
var _allowance = allowed[_from][msg.sender];
balances[_from] = balances[_from].sub(_value);
balances[_to] = balances[_to].add(_value);
allowed[_from][msg.sender] = _allowance.sub(_value);
Transfer(_from, _to, _value);
return true;
}
}
contract ERC677 is ERC20 {
function transferAndCall(address to, uint value, bytes data) public returns (bool ok);
event TransferAndCall(address indexed from, address indexed to, uint value, bytes data);
}
library SafeMath {
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
function toPower2(uint256 a) internal pure returns (uint256) {
return mul(a, a);
}
function sqrt(uint256 a) internal pure returns (uint256) {
uint256 c = (a + 1) / 2;
uint256 b = a;
while (c < b) {
b = c;
c = (a / c + c) / 2;
}
return b;
}
}
contract Standard677Token is ERC677, BasicToken {
function transferAndCall(address _to, uint _value, bytes _data) public returns (bool) {
require(super.transfer(_to, _value));
TransferAndCall(msg.sender, _to, _value, _data);
if (isContract(_to)) return contractFallback(_to, _value, _data);
return true;
}
function contractFallback(address _to, uint _value, bytes _data) private returns (bool) {
ERC223Receiver receiver = ERC223Receiver(_to);
require(receiver.tokenFallback(msg.sender, _value, _data));
return true;
}
function isContract(address _addr) private constant returns (bool is_contract) {
uint length;
assembly { length := extcodesize(_addr) }
return length > 0;
}
}
contract Ownable {
address public owner;
address public newOwnerCandidate;
event OwnershipRequested(address indexed _by, address indexed _to);
event OwnershipTransferred(address indexed _from, address indexed _to);
function Ownable() public {
owner = msg.sender;
}
modifier onlyOwner() {
require(msg.sender == owner);
_;
}
modifier onlyOwnerCandidate() {
require(msg.sender == newOwnerCandidate);
_;
}
function requestOwnershipTransfer(address _newOwnerCandidate) external onlyOwner {
require(_newOwnerCandidate != address(0));
newOwnerCandidate = _newOwnerCandidate;
OwnershipRequested(msg.sender, newOwnerCandidate);
}
function acceptOwnership() external onlyOwnerCandidate {
address previousOwner = owner;
owner = newOwnerCandidate;
newOwnerCandidate = address(0);
OwnershipTransferred(previousOwner, owner);
}
}
contract TokenHolder is Ownable {
function transferAnyERC20Token(address _tokenAddress, uint256 _amount) public onlyOwner returns (bool success) {
return ERC20(_tokenAddress).transfer(owner, _amount);
}
}
contract ColuLocalCurrency is Ownable, Standard677Token, TokenHolder {
using SafeMath for uint256;
string public name;
string public symbol;
uint8 public decimals;
function ColuLocalCurrency(string _name, string _symbol, uint8 _decimals, uint256 _totalSupply) public {
require(_totalSupply != 0);
require(bytes(_name).length != 0);
require(bytes(_symbol).length != 0);
totalSupply = _totalSupply;
name = _name;
symbol = _symbol;
decimals = _decimals;
balances[msg.sender] = totalSupply;
}
}
contract ERC223Receiver {
function tokenFallback(address _sender, uint _value, bytes _data) external returns (bool ok);
}
contract Standard223Receiver is ERC223Receiver {
Tkn tkn;
struct Tkn {
address addr;
address sender;
uint256 value;
}
bool __isTokenFallback;
modifier tokenPayable {
require(__isTokenFallback);
_;
}
function tokenFallback(address _sender, uint _value, bytes _data) external returns (bool ok) {
if (!supportsToken(msg.sender)) {
return false;
}
tkn = Tkn(msg.sender, _sender, _value);
__isTokenFallback = true;
if (!address(this).delegatecall(_data)) {
__isTokenFallback = false;
return false;
}
__isTokenFallback = false;
return true;
}
function supportsToken(address token) public constant returns (bool);
}
contract TokenOwnable is Standard223Receiver, Ownable {
modifier onlyTokenOwner() {
require(tkn.sender == owner);
_;
}
}
contract MarketMaker is ERC223Receiver {
function getCurrentPrice() public constant returns (uint _price);
function change(address _fromToken, uint _amount, address _toToken) public returns (uint _returnAmount);
function change(address _fromToken, uint _amount, address _toToken, uint _minReturn) public returns (uint _returnAmount);
function change(address _toToken) public returns (uint _returnAmount);
function change(address _toToken, uint _minReturn) public returns (uint _returnAmount);
function quote(address _fromToken, uint _amount, address _toToken) public constant returns (uint _returnAmount);
function openForPublicTrade() public returns (bool success);
function isOpenForPublic() public returns (bool success);
event Change(address indexed fromToken, uint inAmount, address indexed toToken, uint returnAmount, address indexed account);
}
contract EllipseMarketMaker is TokenOwnable {
uint256 public constant PRECISION = 10 ** 18;
ERC20 public token1;
ERC20 public token2;
uint256 public R1;
uint256 public R2;
uint256 public S1;
uint256 public S2;
bool public operational;
bool public openForPublic;
address public mmLib;
function EllipseMarketMaker(address _mmLib, address _token1, address _token2) public {
require(_mmLib != address(0));
bytes4 sig = 0x6dd23b5b;
uint256 argsSize = 3 * 32;
uint256 dataSize = 4 + argsSize;
bytes memory m_data = new bytes(dataSize);
assembly {
mstore(add(m_data, 0x20), sig)
mstore(add(m_data, 0x24), _mmLib)
mstore(add(m_data, 0x44), _token1)
mstore(add(m_data, 0x64), _token2)
}
require(_mmLib.delegatecall(m_data));
}
function supportsToken(address token) public constant returns (bool) {
return (token1 == token || token2 == token);
}
function() public {
address _mmLib = mmLib;
if (msg.data.length > 0) {
assembly {
calldatacopy(0xff, 0, calldatasize)
let retVal := delegatecall(gas, _mmLib, 0xff, calldatasize, 0, 0x20)
switch retVal case 0 { revert(0,0) } default { return(0, 0x20) }
}
}
}
}
contract IEllipseMarketMaker is MarketMaker {
uint256 public constant PRECISION = 10 ** 18;
ERC20 public token1;
ERC20 public token2;
uint256 public R1;
uint256 public R2;
uint256 public S1;
uint256 public S2;
bool public operational;
bool public openForPublic;
address public mmLib;
function supportsToken(address token) public constant returns (bool);
function calcReserve(uint256 _R1, uint256 _S1, uint256 _S2) public pure returns (uint256);
function validateReserves() public view returns (bool);
function withdrawExcessReserves() public returns (uint256);
function initializeAfterTransfer() public returns (bool);
function initializeOnTransfer() public returns (bool);
function getPrice(uint256 _R1, uint256 _R2, uint256 _S1, uint256 _S2) public constant returns (uint256);
}
contract CurrencyFactory is Standard223Receiver, TokenHolder {
struct CurrencyStruct {
string name;
uint8 decimals;
uint256 totalSupply;
address owner;
address mmAddress;
}
mapping (address => CurrencyStruct) public currencyMap;
address public clnAddress;
address public mmLibAddress;
address[] public tokens;
event MarketOpen(address indexed marketMaker);
event TokenCreated(address indexed token, address indexed owner);
modifier tokenIssuerOnly(address token, address owner) {
require(currencyMap[token].owner == owner);
_;
}
modifier CLNOnly() {
require(msg.sender == clnAddress);
_;
}
function CurrencyFactory(address _mmLib, address _clnAddress) public {
require(_mmLib != address(0));
require(_clnAddress != address(0));
mmLibAddress = _mmLib;
clnAddress = _clnAddress;
}
function createCurrency(string _name,
string _symbol,
uint8 _decimals,
uint256 _totalSupply) public
returns (address) {
ColuLocalCurrency subToken = new ColuLocalCurrency(_name, _symbol, _decimals, _totalSupply);
EllipseMarketMaker newMarketMaker = new EllipseMarketMaker(mmLibAddress, clnAddress, subToken);
require(subToken.transfer(newMarketMaker, _totalSupply));
require(IEllipseMarketMaker(newMarketMaker).initializeAfterTransfer());
currencyMap[subToken] = CurrencyStruct({ name: _name, decimals: _decimals, totalSupply: _totalSupply, mmAddress: newMarketMaker, owner: msg.sender});
tokens.push(subToken);
TokenCreated(subToken, msg.sender);
return subToken;
}
function insertCLNtoMarketMaker(address _token,
uint256 _clnAmount) public
tokenIssuerOnly(_token, msg.sender)
returns (uint256 _subTokenAmount) {
require(_clnAmount > 0);
address marketMakerAddress = getMarketMakerAddressFromToken(_token);
require(ERC20(clnAddress).transferFrom(msg.sender, this, _clnAmount));
require(ERC20(clnAddress).approve(marketMakerAddress, _clnAmount));
_subTokenAmount = IEllipseMarketMaker(marketMakerAddress).change(clnAddress, _clnAmount, _token);
require(ERC20(_token).transfer(msg.sender, _subTokenAmount));
}
function insertCLNtoMarketMaker(address _token) public
tokenPayable
CLNOnly
tokenIssuerOnly(_token, tkn.sender)
returns (uint256 _subTokenAmount) {
address marketMakerAddress = getMarketMakerAddressFromToken(_token);
require(ERC20(clnAddress).approve(marketMakerAddress, tkn.value));
_subTokenAmount = IEllipseMarketMaker(marketMakerAddress).change(clnAddress, tkn.value, _token);
require(ERC20(_token).transfer(tkn.sender, _subTokenAmount));
}
function extractCLNfromMarketMaker(address _token,
uint256 _ccAmount) public
tokenIssuerOnly(_token, msg.sender)
returns (uint256 _clnTokenAmount) {
address marketMakerAddress = getMarketMakerAddressFromToken(_token);
require(ERC20(_token).transferFrom(msg.sender, this, _ccAmount));
require(ERC20(_token).approve(marketMakerAddress, _ccAmount));
_clnTokenAmount = IEllipseMarketMaker(marketMakerAddress).change(_token, _ccAmount, clnAddress);
require(ERC20(clnAddress).transfer(msg.sender, _clnTokenAmount));
}
function extractCLNfromMarketMaker() public
tokenPayable
tokenIssuerOnly(msg.sender, tkn.sender)
returns (uint256 _clnTokenAmount) {
address marketMakerAddress = getMarketMakerAddressFromToken(msg.sender);
require(ERC20(msg.sender).approve(marketMakerAddress, tkn.value));
_clnTokenAmount = IEllipseMarketMaker(marketMakerAddress).change(msg.sender, tkn.value, clnAddress);
require(ERC20(clnAddress).transfer(tkn.sender, _clnTokenAmount));
}
function openMarket(address _token) public
tokenIssuerOnly(_token, msg.sender)
returns (bool) {
address marketMakerAddress = getMarketMakerAddressFromToken(_token);
require(MarketMaker(marketMakerAddress).openForPublicTrade());
Ownable(marketMakerAddress).requestOwnershipTransfer(msg.sender);
MarketOpen(marketMakerAddress);
return true;
}
function supportsToken(address _token) public constant returns (bool) {
return (clnAddress == _token || currencyMap[_token].totalSupply > 0);
}
function getMarketMakerAddressFromToken(address _token) public constant returns (address _marketMakerAddress) {
_marketMakerAddress = currencyMap[_token].mmAddress;
require(_marketMakerAddress != address(0));
}
}
contract IssuanceFactory is CurrencyFactory {
using SafeMath for uint256;
uint256 public PRECISION;
struct IssuanceStruct {
uint256 hardcap;
uint256 reserve;
uint256 startTime;
uint256 endTime;
uint256 targetPrice;
uint256 clnRaised;
}
uint256 public totalCLNcustodian;
mapping (address => IssuanceStruct) public issueMap;
uint256 public CLNTotalSupply;
event CLNRaised(address indexed token, address indexed participant, uint256 amount);
event CLNRefunded(address indexed token, address indexed participant, uint256 amount);
event SaleFinalized(address indexed token, uint256 clnRaised);
modifier saleOpen(address _token) {
require(now >= issueMap[_token].startTime && issueMap[_token].endTime >= now);
require(issueMap[_token].clnRaised < issueMap[_token].hardcap);
_;
}
modifier hasEnded(address _token) {
require(issueMap[_token].endTime < now);
_;
}
modifier saleWasSuccessfull(address _token) {
require(issueMap[_token].clnRaised >= issueMap[_token].reserve);
_;
}
modifier saleHasFailed(address _token) {
require(issueMap[_token].clnRaised < issueMap[_token].reserve);
_;
}
modifier marketClosed(address _token) {
require(!MarketMaker(currencyMap[_token].mmAddress).isOpenForPublic());
_;
}
function IssuanceFactory(address _mmLib, address _clnAddress) public CurrencyFactory(_mmLib, _clnAddress) {
CLNTotalSupply = ERC20(_clnAddress).totalSupply();
PRECISION = IEllipseMarketMaker(_mmLib).PRECISION();
}
function createIssuance( uint256 _startTime,
uint256 _durationTime,
uint256 _hardcap,
uint256 _reserveAmount,
string _name,
string _symbol,
uint8 _decimals,
uint256 _totalSupply) public
returns (address) {
require(_startTime > now);
require(_durationTime > 0);
require(_hardcap > 0);
uint256 R2 = IEllipseMarketMaker(mmLibAddress).calcReserve(_reserveAmount, CLNTotalSupply, _totalSupply);
uint256 targetPrice = IEllipseMarketMaker(mmLibAddress).getPrice(_reserveAmount, R2, CLNTotalSupply, _totalSupply);
require(isValidIssuance(_hardcap, targetPrice, _totalSupply, R2));
address tokenAddress = super.createCurrency(_name,  _symbol,  _decimals,  _totalSupply);
addToMap(tokenAddress, _startTime, _startTime + _durationTime, _hardcap, _reserveAmount, targetPrice);
return tokenAddress;
}
function addToMap(address _token,
uint256 _startTime,
uint256 _endTime,
uint256 _hardcap,
uint256 _reserveAmount,
uint256 _targetPrice) private {
issueMap[_token] = IssuanceStruct({ hardcap: _hardcap,
reserve: _reserveAmount,
startTime: _startTime,
endTime: _endTime,
clnRaised: 0,
targetPrice: _targetPrice});
}
function participate(address _token,
uint256 _clnAmount) public
saleOpen(_token)
returns (uint256 releaseAmount) {
require(_clnAmount > 0);
address marketMakerAddress = getMarketMakerAddressFromToken(_token);
uint256 transferToReserveAmount;
uint256 participationAmount;
(transferToReserveAmount, participationAmount) = getParticipationAmounts(_clnAmount, _token);
require(ERC20(clnAddress).transferFrom(msg.sender, this, participationAmount));
approveAndChange(clnAddress, _token, transferToReserveAmount, marketMakerAddress);
releaseAmount = participationAmount.mul(issueMap[_token].targetPrice).div(PRECISION);
issueMap[_token].clnRaised = issueMap[_token].clnRaised.add(participationAmount);
totalCLNcustodian = totalCLNcustodian.add(participationAmount);
CLNRaised(_token, msg.sender, participationAmount);
require(ERC20(_token).transfer(msg.sender, releaseAmount));
}
function participate(address _token)
public
tokenPayable
saleOpen(_token)
returns (uint256 releaseAmount) {
require(tkn.value > 0 && msg.sender == clnAddress);
uint256 transferToReserveAmount;
uint256 participationAmount;
(transferToReserveAmount, participationAmount) = getParticipationAmounts(tkn.value, _token);
address marketMakerAddress = getMarketMakerAddressFromToken(_token);
approveAndChange(clnAddress, _token, transferToReserveAmount, marketMakerAddress);
releaseAmount = participationAmount.mul(issueMap[_token].targetPrice).div(PRECISION);
issueMap[_token].clnRaised = issueMap[_token].clnRaised.add(participationAmount);
totalCLNcustodian = totalCLNcustodian.add(participationAmount);
CLNRaised(_token, tkn.sender, participationAmount);
require(ERC20(_token).transfer(tkn.sender, releaseAmount));
if (tkn.value > participationAmount)
require(ERC20(clnAddress).transfer(tkn.sender, tkn.value.sub(participationAmount)));
}
function finalize(address _token) public
tokenIssuerOnly(_token, msg.sender)
hasEnded(_token)
saleWasSuccessfull(_token)
marketClosed(_token)
returns (bool) {
address marketMakerAddress = getMarketMakerAddressFromToken(_token);
uint256 clnAmount = issueMap[_token].clnRaised.sub(issueMap[_token].reserve);
totalCLNcustodian = totalCLNcustodian.sub(clnAmount);
uint256 ccAmount = ERC20(_token).balanceOf(this);
require(MarketMaker(marketMakerAddress).openForPublicTrade());
require(ERC20(_token).transfer(msg.sender, ccAmount));
require(ERC20(clnAddress).transfer(msg.sender, clnAmount));
SaleFinalized(_token, issueMap[_token].clnRaised);
return true;
}
function refund(address _token,
uint256 _ccAmount) public
hasEnded(_token)
saleHasFailed(_token)
marketClosed(_token)
returns (bool) {
require(_ccAmount > 0);
address marketMakerAddress = getMarketMakerAddressFromToken(_token);
require(ERC20(_token).transferFrom(msg.sender, this, _ccAmount));
uint256 factoryCCAmount = ERC20(_token).balanceOf(this);
require(ERC20(_token).approve(marketMakerAddress, factoryCCAmount));
require(MarketMaker(marketMakerAddress).change(_token, factoryCCAmount, clnAddress) > 0);
uint256 returnAmount = _ccAmount.mul(PRECISION).div(issueMap[_token].targetPrice);
issueMap[_token].clnRaised = issueMap[_token].clnRaised.sub(returnAmount);
totalCLNcustodian = totalCLNcustodian.sub(returnAmount);
CLNRefunded(_token, msg.sender, returnAmount);
require(ERC20(clnAddress).transfer(msg.sender, returnAmount));
return true;
}
function refund() public
tokenPayable
hasEnded(msg.sender)
saleHasFailed(msg.sender)
marketClosed(msg.sender)
returns (bool) {
require(tkn.value > 0);
address marketMakerAddress = getMarketMakerAddressFromToken(msg.sender);
uint256 factoryCCAmount = ERC20(msg.sender).balanceOf(this);
require(ERC20(msg.sender).approve(marketMakerAddress, factoryCCAmount));
require(MarketMaker(marketMakerAddress).change(msg.sender, factoryCCAmount, clnAddress) > 0);
uint256 returnAmount = tkn.value.mul(PRECISION).div(issueMap[msg.sender].targetPrice);
issueMap[msg.sender].clnRaised = issueMap[msg.sender].clnRaised.sub(returnAmount);
totalCLNcustodian = totalCLNcustodian.sub(returnAmount);
CLNRefunded(msg.sender, tkn.sender, returnAmount);
require(ERC20(clnAddress).transfer(tkn.sender, returnAmount));
return true;
}
function insertCLNtoMarketMaker(address, uint256) public returns (uint256) {
require(false);
return 0;
}
function insertCLNtoMarketMaker(address) public returns (uint256) {
require(false);
return 0;
}
function extractCLNfromMarketMaker(address, uint256) public returns (uint256) {
require(false);
return 0;
}
function extractCLNfromMarketMaker() public returns (uint256) {
require(false);
return 0;
}
function openMarket(address) public returns (bool) {
require(false);
return false;
}
function isValidIssuance(uint256 _hardcap,
uint256 _price,
uint256 _S2,
uint256 _R2) public view
returns (bool) {
return (_S2 > _R2 && _S2.sub(_R2).mul(PRECISION) >= _hardcap.mul(_price));
}
function getMarketMakerAddressFromToken(address _token) public constant returns (address) {
return currencyMap[_token].mmAddress;
}
function approveAndChange(address _token,
address _token2,
uint256 _amount,
address _marketMakerAddress) private
returns (uint256) {
if (_amount > 0) {
require(ERC20(_token).approve(_marketMakerAddress, _amount));
return MarketMaker(_marketMakerAddress).change(_token, _amount, _token2);
}
return 0;
}
function getParticipationAmounts(uint256 _clnAmount,
address _token) private view
returns (uint256 transferToReserveAmount, uint256 participationAmount) {
uint256 clnRaised = issueMap[_token].clnRaised;
uint256 reserve = issueMap[_token].reserve;
uint256 hardcap = issueMap[_token].hardcap;
participationAmount = SafeMath.min256(_clnAmount, hardcap.sub(clnRaised));
if (reserve > clnRaised) {
transferToReserveAmount = SafeMath.min256(participationAmount, reserve.sub(clnRaised));
}
}
function getIssuanceCount(bool _pending, bool _started, bool _successful, bool _failed)
public
view
returns (uint _count)
{
for (uint i = 0; i < tokens.length; i++) {
IssuanceStruct memory issuance = issueMap[tokens[i]];
if ((_pending && issuance.startTime > now)
|| (_started && now >= issuance.startTime && issuance.endTime >= now && issuance.clnRaised < issuance.hardcap)
|| (_successful && issuance.endTime < now && issuance.clnRaised >= issuance.reserve)
|| (_successful && issuance.endTime >= now && issuance.clnRaised == issuance.hardcap)
|| (_failed && issuance.endTime < now && issuance.clnRaised < issuance.reserve))
_count += 1;
}
}
function getIssuanceIds(bool _pending, bool _started, bool _successful, bool _failed, uint _offset, uint _limit)
public
view
returns (address[] _issuanceIds)
{
require(_limit >= 1);
require(_limit <= 100);
_issuanceIds = new address[](_limit);
uint filteredIssuancesCount = 0;
uint retrieveIssuancesCount = 0;
for (uint i = 0; i < tokens.length; i++) {
IssuanceStruct memory issuance = issueMap[tokens[i]];
if ((_pending && issuance.startTime > now)
|| (_started && now >= issuance.startTime && issuance.endTime >= now && issuance.clnRaised < issuance.hardcap)
|| (_successful && issuance.endTime < now && issuance.clnRaised >= issuance.reserve)
|| (_successful && issuance.endTime >= now && issuance.clnRaised == issuance.hardcap)
|| (_failed && issuance.endTime < now && issuance.clnRaised < issuance.reserve))
{
if (filteredIssuancesCount >= _offset) {
_issuanceIds[retrieveIssuancesCount] = tokens[i];
retrieveIssuancesCount += 1;
}
if (retrieveIssuancesCount == _limit) {
return _issuanceIds;
}
filteredIssuancesCount += 1;
}
}
if (retrieveIssuancesCount < _limit) {
address[] memory _issuanceIdsTemp = new address[](retrieveIssuancesCount);
for (i = 0; i < retrieveIssuancesCount; i++) {
_issuanceIdsTemp[i] = _issuanceIds[i];
}
return _issuanceIdsTemp;
}
}
function transferAnyERC20Token(address _tokenAddress, uint256 _amount) public onlyOwner returns (bool success) {
if (_tokenAddress == clnAddress) {
uint256 excessCLN = ERC20(clnAddress).balanceOf(this).sub(totalCLNcustodian);
require(excessCLN <= _amount);
}
if (issueMap[_tokenAddress].hardcap > 0) {
require(MarketMaker(currencyMap[_tokenAddress].mmAddress).isOpenForPublic());
}
return ERC20(_tokenAddress).transfer(owner, _amount);
}
}