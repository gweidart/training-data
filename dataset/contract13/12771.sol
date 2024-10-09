pragma solidity ^0.4.18;
contract IERC20Token {
function name() public view returns (string) {}
function symbol() public view returns (string) {}
function decimals() public view returns (uint8) {}
function totalSupply() public view returns (uint256) {}
function balanceOf(address _owner) public view returns (uint256) { _owner; }
function allowance(address _owner, address _spender) public view returns (uint256) { _owner; _spender; }
function transfer(address _to, uint256 _value) public returns (bool success);
function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
function approve(address _spender, uint256 _value) public returns (bool success);
}
contract IOwned {
function owner() public view returns (address) {}
function transferOwnership(address _newOwner) public;
function acceptOwnership() public;
}
contract IBancorQuickConverter {
function convert(IERC20Token[] _path, uint256 _amount, uint256 _minReturn) public payable returns (uint256);
function convertFor(IERC20Token[] _path, uint256 _amount, uint256 _minReturn, address _for) public payable returns (uint256);
function convertForPrioritized(IERC20Token[] _path, uint256 _amount, uint256 _minReturn, address _for, uint256 _block, uint256 _nonce, uint8 _v, bytes32 _r, bytes32 _s) public payable returns (uint256);
}
contract IBancorGasPriceLimit {
function gasPrice() public view returns (uint256) {}
function validateGasPrice(uint256) public view;
}
contract IBancorFormula {
function calculatePurchaseReturn(uint256 _supply, uint256 _connectorBalance, uint32 _connectorWeight, uint256 _depositAmount) public view returns (uint256);
function calculateSaleReturn(uint256 _supply, uint256 _connectorBalance, uint32 _connectorWeight, uint256 _sellAmount) public view returns (uint256);
function calculateCrossConnectorReturn(uint256 _connector1Balance, uint32 _connector1Weight, uint256 _connector2Balance, uint32 _connector2Weight, uint256 _amount) public view returns (uint256);
}
contract IBancorConverterExtensions {
function formula() public view returns (IBancorFormula) {}
function gasPriceLimit() public view returns (IBancorGasPriceLimit) {}
function quickConverter() public view returns (IBancorQuickConverter) {}
}
contract Owned is IOwned {
address public owner;
address public newOwner;
event OwnerUpdate(address indexed _prevOwner, address indexed _newOwner);
constructor () public {
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
emit OwnerUpdate(owner, newOwner);
owner = newOwner;
newOwner = address(0);
}
}
contract Utils {
modifier greaterThanZero(uint256 _amount) {
require(_amount > 0);
_;
}
modifier validAddress(address _address) {
require(_address != address(0));
_;
}
modifier notThis(address _address) {
require(_address != address(this));
_;
}
function safeAdd(uint256 _x, uint256 _y) internal pure returns (uint256) {
uint256 z = _x + _y;
assert(z >= _x);
return z;
}
function safeSub(uint256 _x, uint256 _y) internal pure returns (uint256) {
assert(_x >= _y);
return _x - _y;
}
function safeMul(uint256 _x, uint256 _y) internal pure returns (uint256) {
uint256 z = _x * _y;
assert(_x == 0 || z / _x == _y);
return z;
}
}
contract ITokenHolder is IOwned {
function withdrawTokens(IERC20Token _token, address _to, uint256 _amount) public;
}
contract TokenHolder is ITokenHolder, Owned, Utils {
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
contract BancorConverterExtensions is IBancorConverterExtensions, TokenHolder {
IBancorFormula public formula;
IBancorGasPriceLimit public gasPriceLimit;
IBancorQuickConverter public quickConverter;
function BancorConverterExtensions(IBancorFormula _formula, IBancorGasPriceLimit _gasPriceLimit, IBancorQuickConverter _quickConverter)
public
validAddress(_formula)
validAddress(_gasPriceLimit)
validAddress(_quickConverter)
{
formula = _formula;
gasPriceLimit = _gasPriceLimit;
quickConverter = _quickConverter;
}
function setFormula(IBancorFormula _formula)
public
ownerOnly
validAddress(_formula)
notThis(_formula)
{
formula = _formula;
}
function setGasPriceLimit(IBancorGasPriceLimit _gasPriceLimit)
public
ownerOnly
validAddress(_gasPriceLimit)
notThis(_gasPriceLimit)
{
gasPriceLimit = _gasPriceLimit;
}
function setQuickConverter(IBancorQuickConverter _quickConverter)
public
ownerOnly
validAddress(_quickConverter)
notThis(_quickConverter)
{
quickConverter = _quickConverter;
}
}