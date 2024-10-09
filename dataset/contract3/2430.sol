pragma solidity ^0.4.24;
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
function min(uint a, uint b) internal pure returns (uint256) {
return a < b ? a : b;
}
}
interface Factory_Interface {
function createToken(uint _supply, address _party, uint _start_date) external returns (address,address, uint);
function payToken(address _party, address _token_add) external;
function deployContract(uint _start_date) external payable returns (address);
function getBase() external view returns(address);
function getVariables() external view returns (address, uint, uint, address,uint);
function isWhitelisted(address _member) external view returns (bool);
}
library DRCTLibrary{
using SafeMath for uint256;
struct Balance {
address owner;
uint amount;
}
struct TokenStorage{
address factory_contract;
uint total_supply;
mapping(address => Balance[]) swap_balances;
mapping(address => mapping(address => uint)) swap_balances_index;
mapping(address => address[]) user_swaps;
mapping(address => mapping(address => uint)) user_swaps_index;
mapping(address => uint) user_total_balances;
mapping(address => mapping(address => uint)) allowed;
}
event Transfer(address indexed _from, address indexed _to, uint _value);
event Approval(address indexed _owner, address indexed _spender, uint _value);
event CreateToken(address _from, uint _value);
function startToken(TokenStorage storage self,address _factory) public {
self.factory_contract = _factory;
}
function isWhitelisted(TokenStorage storage self,address _member) internal view returns(bool){
Factory_Interface _factory = Factory_Interface(self.factory_contract);
return _factory.isWhitelisted(_member);
}
function getFactoryAddress(TokenStorage storage self) external view returns(address){
return self.factory_contract;
}
function createToken(TokenStorage storage self,uint _supply, address _owner, address _swap) public{
require(msg.sender == self.factory_contract);
self.total_supply = self.total_supply.add(_supply);
self.user_total_balances[_owner] = self.user_total_balances[_owner].add(_supply);
if (self.user_swaps[_owner].length == 0)
self.user_swaps[_owner].push(address(0x0));
self.user_swaps_index[_owner][_swap] = self.user_swaps[_owner].length;
self.user_swaps[_owner].push(_swap);
self.swap_balances[_swap].push(Balance({
owner: 0,
amount: 0
}));
self.swap_balances_index[_swap][_owner] = 1;
self.swap_balances[_swap].push(Balance({
owner: _owner,
amount: _supply
}));
emit CreateToken(_owner,_supply);
}
function pay(TokenStorage storage self,address _party, address _swap) public{
require(msg.sender == self.factory_contract);
uint party_balance_index = self.swap_balances_index[_swap][_party];
require(party_balance_index > 0);
uint party_swap_balance = self.swap_balances[_swap][party_balance_index].amount;
self.user_total_balances[_party] = self.user_total_balances[_party].sub(party_swap_balance);
self.total_supply = self.total_supply.sub(party_swap_balance);
self.swap_balances[_swap][party_balance_index].amount = 0;
}
function balanceOf(TokenStorage storage self,address _owner) public constant returns (uint balance) {
return self.user_total_balances[_owner];
}
function totalSupply(TokenStorage storage self) public constant returns (uint _total_supply) {
return self.total_supply;
}
function removeFromSwapBalances(TokenStorage storage self,address _remove, address _swap) internal {
uint last_address_index = self.swap_balances[_swap].length.sub(1);
address last_address = self.swap_balances[_swap][last_address_index].owner;
if (last_address != _remove) {
uint remove_index = self.swap_balances_index[_swap][_remove];
self.swap_balances_index[_swap][last_address] = remove_index;
self.swap_balances[_swap][remove_index] = self.swap_balances[_swap][last_address_index];
}
delete self.swap_balances_index[_swap][_remove];
self.swap_balances[_swap].length = self.swap_balances[_swap].length.sub(1);
}
function transferHelper(TokenStorage storage self,address _from, address _to, uint _amount) internal {
address[] memory from_swaps = self.user_swaps[_from];
for (uint i = from_swaps.length.sub(1); i > 0; i--) {
uint from_swap_user_index = self.swap_balances_index[from_swaps[i]][_from];
Balance memory from_user_bal = self.swap_balances[from_swaps[i]][from_swap_user_index];
if (_amount >= from_user_bal.amount) {
_amount -= from_user_bal.amount;
self.user_swaps[_from].length = self.user_swaps[_from].length.sub(1);
delete self.user_swaps_index[_from][from_swaps[i]];
if (self.user_swaps_index[_to][from_swaps[i]] != 0) {
uint to_balance_index = self.swap_balances_index[from_swaps[i]][_to];
assert(to_balance_index != 0);
self.swap_balances[from_swaps[i]][to_balance_index].amount = self.swap_balances[from_swaps[i]][to_balance_index].amount.add(from_user_bal.amount);
removeFromSwapBalances(self,_from, from_swaps[i]);
} else {
if (self.user_swaps[_to].length == 0){
self.user_swaps[_to].push(address(0x0));
}
self.user_swaps_index[_to][from_swaps[i]] = self.user_swaps[_to].length;
self.user_swaps[_to].push(from_swaps[i]);
self.swap_balances[from_swaps[i]][from_swap_user_index].owner = _to;
self.swap_balances_index[from_swaps[i]][_to] = self.swap_balances_index[from_swaps[i]][_from];
delete self.swap_balances_index[from_swaps[i]][_from];
}
if (_amount == 0)
break;
} else {
uint to_swap_balance_index = self.swap_balances_index[from_swaps[i]][_to];
if (self.user_swaps_index[_to][from_swaps[i]] != 0) {
self.swap_balances[from_swaps[i]][to_swap_balance_index].amount = self.swap_balances[from_swaps[i]][to_swap_balance_index].amount.add(_amount);
} else {
if (self.user_swaps[_to].length == 0){
self.user_swaps[_to].push(address(0x0));
}
self.user_swaps_index[_to][from_swaps[i]] = self.user_swaps[_to].length;
self.user_swaps[_to].push(from_swaps[i]);
self.swap_balances_index[from_swaps[i]][_to] = self.swap_balances[from_swaps[i]].length;
self.swap_balances[from_swaps[i]].push(Balance({
owner: _to,
amount: _amount
}));
}
self.swap_balances[from_swaps[i]][from_swap_user_index].amount = self.swap_balances[from_swaps[i]][from_swap_user_index].amount.sub(_amount);
break;
}
}
}
function transfer(TokenStorage storage self, address _to, uint _amount) public returns (bool) {
require(isWhitelisted(self,_to));
uint balance_owner = self.user_total_balances[msg.sender];
if (
_to == msg.sender ||
_to == address(0) ||
_amount == 0 ||
balance_owner < _amount
) return false;
transferHelper(self,msg.sender, _to, _amount);
self.user_total_balances[msg.sender] = self.user_total_balances[msg.sender].sub(_amount);
self.user_total_balances[_to] = self.user_total_balances[_to].add(_amount);
emit Transfer(msg.sender, _to, _amount);
return true;
}
function transferFrom(TokenStorage storage self, address _from, address _to, uint _amount) public returns (bool) {
require(isWhitelisted(self,_to));
uint balance_owner = self.user_total_balances[_from];
uint sender_allowed = self.allowed[_from][msg.sender];
if (
_to == _from ||
_to == address(0) ||
_amount == 0 ||
balance_owner < _amount ||
sender_allowed < _amount
) return false;
transferHelper(self,_from, _to, _amount);
self.user_total_balances[_from] = self.user_total_balances[_from].sub(_amount);
self.user_total_balances[_to] = self.user_total_balances[_to].add(_amount);
self.allowed[_from][msg.sender] = self.allowed[_from][msg.sender].sub(_amount);
emit Transfer(_from, _to, _amount);
return true;
}
function approve(TokenStorage storage self, address _spender, uint _amount) public returns (bool) {
self.allowed[msg.sender][_spender] = _amount;
emit Approval(msg.sender, _spender, _amount);
return true;
}
function addressCount(TokenStorage storage self, address _swap) public constant returns (uint) {
return self.swap_balances[_swap].length;
}
function getBalanceAndHolderByIndex(TokenStorage storage self, uint _ind, address _swap) public constant returns (uint, address) {
return (self.swap_balances[_swap][_ind].amount, self.swap_balances[_swap][_ind].owner);
}
function getIndexByAddress(TokenStorage storage self, address _owner, address _swap) public constant returns (uint) {
return self.swap_balances_index[_swap][_owner];
}
function allowance(TokenStorage storage self, address _owner, address _spender) public constant returns (uint) {
return self.allowed[_owner][_spender];
}
}