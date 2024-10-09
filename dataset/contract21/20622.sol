pragma solidity ^0.4.18;
contract ERC20 {
event Approval(address indexed owner, address indexed spender, uint256 value);
event Transfer(address indexed from, address indexed to, uint256 value);
function totalSupply() public constant returns (uint256);
function balanceOf(address who) public constant returns (uint256);
function transfer(address to, uint256 value) public returns (bool);
function allowance(address owner, address spender) public constant returns (uint256);
function transferFrom(address from, address to, uint256 value) public returns (bool);
function approve(address spender, uint256 value) public returns (bool);
}
contract ERC20Token is ERC20 {
using SafeMath for uint256;
mapping(address => uint256) balances;
mapping (address => mapping (address => uint256)) allowed;
function balanceOf(address _owner) public constant returns (uint256 balance) {
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
uint256 _allowance = allowed[_from][msg.sender];
balances[_from] = balances[_from].sub(_value);
balances[_to] = balances[_to].add(_value);
allowed[_from][msg.sender] = _allowance.sub(_value);
Transfer(_from, _to, _value);
return true;
}
function approve(address _spender, uint256 _value) public returns (bool) {
allowed[msg.sender][_spender] = _value;
Approval(msg.sender, _spender, _value);
return true;
}
function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
return allowed[_owner][_spender];
}
function increaseApproval (address _spender, uint _addedValue)
public returns (bool success)
{
allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
return true;
}
function decreaseApproval (address _spender, uint _subtractedValue)
public returns (bool success)
{
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
contract Ownable {
address[] public owners;
event OwnerAdded(address indexed authorizer, address indexed newOwner, uint256 index);
event OwnerRemoved(address indexed authorizer, address indexed oldOwner);
function Ownable() public {
owners.push(msg.sender);
OwnerAdded(0x0, msg.sender, 0);
}
modifier onlyOwner() {
bool isOwner = false;
for (uint256 i = 0; i < owners.length; i++) {
if (msg.sender == owners[i]) {
isOwner = true;
break;
}
}
require(isOwner);
_;
}
function addOwner(address newOwner) onlyOwner public {
require(newOwner != address(0));
uint256 i = owners.push(newOwner) - 1;
OwnerAdded(msg.sender, newOwner, i);
}
function removeOwner(uint256 index) onlyOwner public {
address owner = owners[index];
owners[index] = owners[owners.length - 1];
delete owners[owners.length - 1];
OwnerRemoved(msg.sender, owner);
}
function ownersCount() constant public returns (uint256) {
return owners.length;
}
}
contract UpgradableStorage is Ownable {
address internal _implementation;
event NewImplementation(address implementation);
function implementation() public view returns (address) {
return _implementation;
}
}
contract Upgradable is UpgradableStorage {
function initialize() public payable { }
}
contract Base is Upgradable, ERC20Token {
function name() pure public returns (string) {
return 'Knowledge.io';
}
function symbol() pure public returns (string) {
return 'KNW';
}
function decimals() pure public returns (uint8) {
return 8;
}
function INITIAL_SUPPLY() pure public returns (uint) {
return 15000000000000000;
}
function totalSupply() view public returns (uint) {
return INITIAL_SUPPLY();
}
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
}
contract Legacy is Base {
using SafeMath for uint256;
Legacy public prevContract;
event UpgradeFrom(address indexed _from, address indexed _to, uint256 _value);
event PrevContractSet(address contractAddress);
modifier fromPrevContract() {
require(msg.sender == address(prevContract));
_;
}
function upgradeFrom(address holder, uint256 value) fromPrevContract public returns (bool) {
balances[holder] = value;
Transfer(address(0), holder, value);
UpgradeFrom(address(prevContract), holder, value);
return true;
}
function setPrevContract(address contractAddress) onlyOwner public returns (bool) {
require(contractAddress != 0x0);
prevContract = Legacy(contractAddress);
PrevContractSet(contractAddress);
return true;
}
}
contract Payable is Legacy {
struct PaymentRequest {
uint256 fee;
uint256 value;
address seller;
}
mapping (address => mapping(string => PaymentRequest)) private pendingPayments;
event Pay(
address indexed from,
address indexed seller,
address indexed store,
uint256 value,
uint256 fee,
string ref
);
function requestPayment(uint256 value, uint256 fee, string ref, address to) public {
pendingPayments[msg.sender][ref] = PaymentRequest(fee, value, to);
}
function cancelPayment(string ref) public {
delete pendingPayments[msg.sender][ref];
}
function paymentInfo(address store, string ref) public view returns (uint256 value, uint256 fee, address seller) {
PaymentRequest memory paymentRequest = pendingPayments[store][ref];
value = paymentRequest.value;
fee = paymentRequest.fee;
seller = paymentRequest.seller;
}
function pay(address store, string ref) public returns (bool) {
PaymentRequest memory paymentRequest = pendingPayments[store][ref];
if (paymentRequest.fee > 0) {
assert(transfer(store, paymentRequest.fee));
}
assert(transfer(paymentRequest.seller, paymentRequest.value));
Pay(msg.sender, paymentRequest.seller, store, paymentRequest.value, paymentRequest.fee, ref);
delete pendingPayments[store][ref];
return true;
}
}