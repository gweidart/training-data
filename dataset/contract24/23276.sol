pragma solidity ^0.4.18;
contract ReadOnlyToken {
uint256 public totalSupply;
function balanceOf(address who) public constant returns (uint256);
function allowance(address owner, address spender) public constant returns (uint256);
}
contract Token is ReadOnlyToken {
function transfer(address to, uint256 value) public returns (bool);
function transferFrom(address from, address to, uint256 value) public returns (bool);
function approve(address spender, uint256 value) public returns (bool);
event Transfer(address indexed from, address indexed to, uint256 value);
event Approval(address indexed owner, address indexed spender, uint256 value);
}
contract MintableToken is Token {
event Mint(address indexed to, uint256 amount);
function mint(address _to, uint256 _amount) public returns (bool);
}
contract Sale {
event Purchase(address indexed buyer, address token, uint256 value, uint256 sold, uint256 bonus);
event RateAdd(address token);
event RateRemove(address token);
function getRate(address token) constant public returns (uint256);
function getBonus(uint256 sold) constant public returns (uint256);
}
library SafeMath {
function mul(uint256 a, uint256 b) internal pure returns (uint256) {
if (a == 0) {
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
modifier onlyOwner() {
checkOwner();
_;
}
function checkOwner() internal;
}
contract ExternalToken is Token {
event Mint(address indexed to, uint256 value, bytes data);
event Burn(address indexed burner, uint256 value, bytes data);
function burn(uint256 _value, bytes _data) public;
}
contract ReceiveAdapter {
function onReceive(address _token, address _from, uint256 _value, bytes _data) internal;
}
contract ERC20ReceiveAdapter is ReceiveAdapter {
function receive(address _token, uint256 _value, bytes _data) public {
Token token = Token(_token);
token.transferFrom(msg.sender, this, _value);
onReceive(_token, msg.sender, _value, _data);
}
}
contract TokenReceiver {
function onTokenTransfer(address _from, uint256 _value, bytes _data) public;
}
contract ERC223ReceiveAdapter is TokenReceiver, ReceiveAdapter {
function tokenFallback(address _from, uint256 _value, bytes _data) public {
onReceive(msg.sender, _from, _value, _data);
}
function onTokenTransfer(address _from, uint256 _value, bytes _data) public {
onReceive(msg.sender, _from, _value, _data);
}
}
contract EtherReceiver {
function receiveWithData(bytes _data) payable public;
}
contract EtherReceiveAdapter is EtherReceiver, ReceiveAdapter {
function () payable public {
receiveWithData("");
}
function receiveWithData(bytes _data) payable public {
onReceive(address(0), msg.sender, msg.value, _data);
}
}
contract CompatReceiveAdapter is ERC20ReceiveAdapter, ERC223ReceiveAdapter, EtherReceiveAdapter {
}
contract AbstractSale is Sale, CompatReceiveAdapter, Ownable {
using SafeMath for uint256;
event Withdraw(address token, address to, uint256 value);
event Burn(address token, uint256 value, bytes data);
function onReceive(address _token, address _from, uint256 _value, bytes _data) internal {
uint256 sold = getSold(_token, _value);
require(sold > 0);
uint256 bonus = getBonus(sold);
address buyer;
if (_data.length == 20) {
buyer = address(toBytes20(_data, 0));
} else {
require(_data.length == 0);
buyer = _from;
}
checkPurchaseValid(buyer, sold, bonus);
doPurchase(buyer, sold, bonus);
Purchase(buyer, _token, _value, sold, bonus);
onPurchase(buyer, _token, _value, sold, bonus);
}
function getSold(address _token, uint256 _value) constant public returns (uint256) {
uint256 rate = getRate(_token);
require(rate > 0);
return _value.mul(rate).div(10**18);
}
function getBonus(uint256 sold) constant public returns (uint256);
function getRate(address _token) constant public returns (uint256);
function doPurchase(address buyer, uint256 sold, uint256 bonus) internal;
}
}
function toBytes20(bytes b, uint256 _start) pure internal returns (bytes20 result) {
require(_start + 20 <= b.length);
assembly {
let from := add(_start, add(b, 0x20))
result := mload(from)
}
}
function withdrawEth(address _to, uint256 _value) onlyOwner public {
withdraw(address(0), _to, _value);
}
function withdraw(address _token, address _to, uint256 _value) onlyOwner public {
require(_to != address(0));
verifyCanWithdraw(_token, _to, _value);
if (_token == address(0)) {
_to.transfer(_value);
} else {
Token(_token).transfer(_to, _value);
}
Withdraw(_token, _to, _value);
}
function verifyCanWithdraw(address token, address to, uint256 amount) internal;
function burnWithData(address _token, uint256 _value, bytes _data) onlyOwner public {
ExternalToken(_token).burn(_value, _data);
Burn(_token, _value, _data);
}
}
contract MintingSale is AbstractSale {
MintableToken public token;
function MintingSale(address _token) public {
token = MintableToken(_token);
}
function doPurchase(address buyer, uint256 sold, uint256 bonus) internal {
token.mint(buyer, sold.add(bonus));
}
function verifyCanWithdraw(address, address, uint256) internal {
}
}
contract OwnableImpl is Ownable {
address public owner;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
function OwnableImpl() public {
owner = msg.sender;
}
function checkOwner() internal {
require(msg.sender == owner);
}
function transferOwnership(address newOwner) onlyOwner public {
require(newOwner != address(0));
OwnershipTransferred(owner, newOwner);
owner = newOwner;
}
}
contract CappedBonusSale is AbstractSale {
uint256 public cap;
uint256 public initialCap;
function CappedBonusSale(uint256 _cap) public {
cap = _cap;
initialCap = _cap;
}
function checkPurchaseValid(address buyer, uint256 sold, uint256 bonus) internal {
super.checkPurchaseValid(buyer, sold, bonus);
require(cap >= sold.add(bonus));
}
function onPurchase(address buyer, address token, uint256 value, uint256 sold, uint256 bonus) internal {
super.onPurchase(buyer, token, value, sold, bonus);
cap = cap.sub(sold).sub(bonus);
}
}
contract Secured {
modifier only(string role) {
require(msg.sender == getRole(role));
_;
}
function getRole(string role) constant public returns (address);
}
contract SecuredImpl is Ownable, Secured {
mapping(string => address) users;
event RoleTransferred(address indexed previousUser, address indexed newUser, string role);
function getRole(string role) constant public returns (address) {
return users[role];
}
function transferRole(string role, address to) onlyOwner public {
require(to != address(0));
RoleTransferred(users[role], to, role);
users[role] = to;
}
}
contract Whitelist is Secured {
mapping(address => bool) whitelist;
event WhitelistChange(address indexed addr, bool allow);
function isInWhitelist(address addr) constant public returns (bool) {
return whitelist[addr];
}
function setWhitelist(address addr, bool allow) only("operator") public {
setWhitelistInternal(addr, allow);
}
function setWhitelistInternal(address addr, bool allow) internal {
whitelist[addr] = allow;
WhitelistChange(addr, allow);
}
}
contract WhitelistSale is AbstractSale, Whitelist {
function checkPurchaseValid(address buyer, uint256 sold, uint256 bonus) internal {
super.checkPurchaseValid(buyer, sold, bonus);
require(isInWhitelist(buyer));
}
}
contract DaoxCommissionSale is AbstractSale {
function getSold(address _token, uint256 _value) constant public returns (uint256) {
return super.getSold(_token, _value).div(99).mul(100);
}
}
contract ReadOnlyTokenImpl is ReadOnlyToken {
mapping(address => uint256) balances;
mapping(address => mapping(address => uint256)) internal allowed;
function balanceOf(address _owner) public constant returns (uint256 balance) {
return balances[_owner];
}
function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
return allowed[_owner][_spender];
}
}
contract TokenImpl is Token, ReadOnlyTokenImpl {
using SafeMath for uint256;
function transfer(address _to, uint256 _value) public returns (bool) {
require(_to != address(0));
require(_value <= balances[msg.sender]);
balances[msg.sender] = balances[msg.sender].sub(_value);
balances[_to] = balances[_to].add(_value);
emitTransfer(msg.sender, _to, _value);
return true;
}
function emitTransfer(address _from, address _to, uint256 _value) internal {
Transfer(_from, _to, _value);
}
function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
require(_to != address(0));
require(_value <= balances[_from]);
require(_value <= allowed[_from][msg.sender]);
balances[_from] = balances[_from].sub(_value);
balances[_to] = balances[_to].add(_value);
allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
emitTransfer(_from, _to, _value);
return true;
}
function approve(address _spender, uint256 _value) public returns (bool) {
allowed[msg.sender][_spender] = _value;
Approval(msg.sender, _spender, _value);
return true;
}
function increaseApproval (address _spender, uint _addedValue) public returns (bool success) {
allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
return true;
}
function decreaseApproval (address _spender, uint _subtractedValue) public returns (bool success) {
uint oldValue = allowed[msg.sender][_spender];
if (_subtractedValue > oldValue) {
allowed[msg.sender][_spender] = 0;
} else {
allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
}
Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
return true;
}
}
contract BurnableToken is Token {
event Burn(address indexed burner, uint256 value);
function burn(uint256 _value) public;
}
contract BurnableTokenImpl is TokenImpl, BurnableToken {
function burn(uint256 _value) public {
require(_value <= balances[msg.sender]);
address burner = msg.sender;
balances[burner] = balances[burner].sub(_value);
totalSupply = totalSupply.sub(_value);
Burn(burner, _value);
}
}
contract MintableTokenImpl is Ownable, TokenImpl, MintableToken {
function mint(address _to, uint256 _amount) onlyOwner public returns (bool) {
totalSupply = totalSupply.add(_amount);
balances[_to] = balances[_to].add(_amount);
emitMint(_to, _amount);
emitTransfer(address(0), _to, _amount);
return true;
}
function emitMint(address _to, uint256 _value) internal {
Mint(_to, _value);
}
}
contract Pausable is Ownable {
event Pause();
event Unpause();
bool public paused = false;
modifier whenNotPaused() {
require(!paused);
_;
}
modifier whenPaused() {
require(paused);
_;
}
function pause() onlyOwner whenNotPaused public {
paused = true;
Pause();
}
function unpause() onlyOwner whenPaused public {
paused = false;
Unpause();
}
}
contract PausableToken is Pausable, TokenImpl {
function transfer(address _to, uint256 _value) public whenNotPaused returns (bool) {
return super.transfer(_to, _value);
}
function transferFrom(address _from, address _to, uint256 _value) public whenNotPaused returns (bool) {
return super.transferFrom(_from, _to, _value);
}
function approve(address _spender, uint256 _value) public whenNotPaused returns (bool) {
return super.approve(_spender, _value);
}
function increaseApproval(address _spender, uint _addedValue) public whenNotPaused returns (bool success) {
return super.increaseApproval(_spender, _addedValue);
}
function decreaseApproval(address _spender, uint _subtractedValue) public whenNotPaused returns (bool success) {
return super.decreaseApproval(_spender, _subtractedValue);
}
}
contract ZenomeToken is OwnableImpl, PausableToken, MintableTokenImpl, BurnableTokenImpl {
string public constant name = "Zenome";
string public constant symbol = "sZNA";
uint8 public constant decimals = 18;
function burn(uint256 _value) public whenNotPaused {
super.burn(_value);
}
}
contract ZenomeSale is OwnableImpl, SecuredImpl, DaoxCommissionSale, MintingSale, CappedBonusSale, WhitelistSale {
address public btcToken;
uint256 public ethRate = 1350 * 10**18;
uint256 public btcEthRate = 10 * 10**10;
function ZenomeSale(
address _mintableToken,
address _btcToken,
uint256 _cap)
MintingSale(_mintableToken)
CappedBonusSale(_cap) {
btcToken = _btcToken;
RateAdd(address(0));
RateAdd(_btcToken);
}
function getRate(address _token) constant public returns (uint256) {
if (_token == btcToken) {
return btcEthRate * ethRate;
} else if (_token == address(0)) {
return ethRate;
} else {
return 0;
}
}
function getBonus(uint256 sold) constant public returns (uint256) {
if (sold > 850000 * 10**18) {
return sold.mul(50).div(100);
} else if (sold > 340000 * 10**18) {
return sold.mul(33).div(100);
} else if (sold > 85000 * 10**18) {
return sold.mul(20).div(100);
} else {
return 0;
}
}
event EthRateChange(uint256 rate);
function setEthRate(uint256 _ethRate) onlyOwner public {
ethRate = _ethRate;
EthRateChange(_ethRate);
}
event BtcEthRateChange(uint256 rate);
function setBtcEthRate(uint256 _btcEthRate) onlyOwner public {
btcEthRate = _btcEthRate;
BtcEthRateChange(_btcEthRate);
}
function withdrawBtc(bytes _to, uint256 _value) onlyOwner public {
burnWithData(btcToken, _value, _to);
}
function transferTokenOwnership(address newOwner) onlyOwner public {
OwnableImpl(token).transferOwnership(newOwner);
}
function pauseToken() onlyOwner public {
Pausable(token).pause();
}
function unpauseToken() onlyOwner public {
Pausable(token).unpause();
}
function transfer(address beneficiary, uint256 amount) onlyOwner public {
emulatePurchase(beneficiary, address(1), 0, amount, 0);
}
function emulatePurchase(address beneficiary, address paymentMethod, uint256 value, uint256 amount, uint256 bonus) onlyOwner public {
setWhitelistInternal(beneficiary, true);
doPurchase(beneficiary, amount, bonus);
Purchase(beneficiary, paymentMethod, value, amount, bonus);
onPurchase(beneficiary, paymentMethod, value, amount, bonus);
}
}