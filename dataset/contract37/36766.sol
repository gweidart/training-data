pragma solidity ^0.4.11;
contract IOwned {
function owner() public constant returns (address owner) { owner; }
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
contract IBancorFormula {
function calculatePurchaseReturn(uint256 _supply, uint256 _reserveBalance, uint32 _reserveRatio, uint256 _depositAmount) public constant returns (uint256);
function calculateSaleReturn(uint256 _supply, uint256 _reserveBalance, uint32 _reserveRatio, uint256 _sellAmount) public constant returns (uint256);
}
contract BancorFormulaProxy is IBancorFormula, Owned, Utils {
IBancorFormula public formula;
function BancorFormulaProxy(IBancorFormula _formula)
validAddress(_formula)
{
formula = _formula;
}
function setFormula(IBancorFormula _formula)
public
ownerOnly
validAddress(_formula)
notThis(_formula)
{
formula = _formula;
}
function calculatePurchaseReturn(uint256 _supply, uint256 _reserveBalance, uint32 _reserveRatio, uint256 _depositAmount) public constant returns (uint256) {
return formula.calculatePurchaseReturn(_supply, _reserveBalance, _reserveRatio, _depositAmount);
}
function calculateSaleReturn(uint256 _supply, uint256 _reserveBalance, uint32 _reserveRatio, uint256 _sellAmount) public constant returns (uint256) {
return formula.calculateSaleReturn(_supply, _reserveBalance, _reserveRatio, _sellAmount);
}
}