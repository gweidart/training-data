pragma solidity ^0.4.11;
contract Utils {
function Utils() {
}
modifier greaterThanZero(uint256 _amount) {
require(_amount > 0);
_;
}
modifier validAddress(address _address) {
require(_address != 0x0);
_;
}
modifier notThis(address _address) {
require(_address != address(this));
_;
}
function safeAdd(uint256 _x, uint256 _y) internal returns (uint256) {
uint256 z = _x + _y;
assert(z >= _x);
return z;
}
function safeSub(uint256 _x, uint256 _y) internal returns (uint256) {
assert(_x >= _y);
return _x - _y;
}
function safeMul(uint256 _x, uint256 _y) internal returns (uint256) {
uint256 z = _x * _y;
assert(_x == 0 || z / _x == _y);
return z;
}
}
contract IOwned {
function owner() public constant returns (address) {}
function transferOwnership(address _newOwner) public;
function acceptOwnership() public;
}
contract Owned is IOwned {
address public owner;
address public newOwner;
event OwnerUpdate(address _prevOwner, address _newOwner);
function Owned() {
owner = msg.sender;
}
modifier ownerOnly {
assert(msg.sender == owner);
_;
}
function transferOwnership(address _newOwner) public ownerOnly {
require(_newOwner != owner);
newOwner = _newOwner;
}
function acceptOwnership() public {
require(msg.sender == newOwner);
OwnerUpdate(owner, newOwner);
owner = newOwner;
newOwner = 0x0;
}
}
contract IERC20Token {
function name() public constant returns (string) {}
function symbol() public constant returns (string) {}
function decimals() public constant returns (uint8) {}
function totalSupply() public constant returns (uint256) {}
function balanceOf(address _owner) public constant returns (uint256) { _owner; }
function allowance(address _owner, address _spender) public constant returns (uint256) { _owner; _spender; }
function transfer(address _to, uint256 _value) public returns (bool success);
function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
function approve(address _spender, uint256 _value) public returns (bool success);
}
contract IStandardFormula {
function calculatePurchaseReturn(uint256 _supply, uint256 _connectorBalance, uint32 _connectorWeight, uint256 _depositAmount) public constant returns (uint256);
function calculateSaleReturn(uint256 _supply, uint256 _connectorBalance, uint32 _connectorWeight, uint256 _sellAmount) public constant returns (uint256);
}
contract IStandardGasPriceLimit {
function gasPrice() public constant returns (uint256) {}
}
contract IStandardQuickConverter {
function convert(IERC20Token[] _path, uint256 _amount, uint256 _minReturn) public payable returns (uint256);
function convertFor(IERC20Token[] _path, uint256 _amount, uint256 _minReturn, address _for) public payable returns (uint256);
}
contract ITokenHolder is IOwned {
function withdrawTokens(IERC20Token _token, address _to, uint256 _amount) public;
}
contract TokenHolder is ITokenHolder, Owned, Utils {
function TokenHolder() {
}
function withdrawTokens(IERC20Token _token, address _to, uint256 _amount)
public
ownerOnly
validAddress(_token)
validAddress(_to)
notThis(_to)
{
assert(_token.transfer(_to, _amount));
}
}
contract IStandardConverterExtensions {
function formula() public constant returns (IStandardFormula) {}
function gasPriceLimit() public constant returns (IStandardGasPriceLimit) {}
function quickConverter() public constant returns (IStandardQuickConverter) {}
}
contract StandardConverterExtensions is IStandardConverterExtensions, TokenHolder {
IStandardFormula public formula;
IStandardGasPriceLimit public gasPriceLimit;
IStandardQuickConverter public quickConverter;
function StandardConverterExtensions(IStandardFormula _formula, IStandardGasPriceLimit _gasPriceLimit, IStandardQuickConverter _quickConverter)
validAddress(_formula)
validAddress(_gasPriceLimit)
validAddress(_quickConverter)
{
formula = _formula;
gasPriceLimit = _gasPriceLimit;
quickConverter = _quickConverter;
}
function setFormula(IStandardFormula _formula)
public
ownerOnly
validAddress(_formula)
notThis(_formula)
{
formula = _formula;
}
function setGasPriceLimit(IStandardGasPriceLimit _gasPriceLimit)
public
ownerOnly
validAddress(_gasPriceLimit)
notThis(_gasPriceLimit)
{
gasPriceLimit = _gasPriceLimit;
}
function setQuickConverter(IStandardQuickConverter _quickConverter)
public
ownerOnly
validAddress(_quickConverter)
notThis(_quickConverter)
{
quickConverter = _quickConverter;
}
}