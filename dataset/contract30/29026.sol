pragma solidity ^0.4.17;
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
contract DRCT_Token {
using SafeMath for uint256;
struct Balance {
address owner;
uint amount;
}
address public master_contract;
uint public total_supply;
mapping(address => Balance[]) swap_balances;
mapping(address => mapping(address => uint)) swap_balances_index;
mapping(address => address[]) user_swaps;
mapping(address => mapping(address => uint)) user_swaps_index;
mapping(address => uint) user_total_balances;
mapping(address => mapping(address => uint)) allowed;
event Transfer(address indexed _from, address indexed _to, uint _value);
event Approval(address indexed _owner, address indexed _spender, uint _value);
modifier onlyMaster() {
require(msg.sender == master_contract);
_;
}
function DRCT_Token(address _factory) public {
master_contract = _factory;
}
function createToken(uint _supply, address _owner, address _swap) public onlyMaster() {
total_supply = total_supply.add(_supply);
user_total_balances[_owner] = user_total_balances[_owner].add(_supply);
if (user_swaps[_owner].length == 0)
user_swaps[_owner].push(address(0x0));
user_swaps_index[_owner][_swap] = user_swaps[_owner].length;
user_swaps[_owner].push(_swap);
swap_balances[_swap].push(Balance({
owner: 0,
amount: 0
}));
swap_balances_index[_swap][_owner] = 1;
swap_balances[_swap].push(Balance({
owner: _owner,
amount: _supply
}));
}
function pay(address _party, address _swap) public onlyMaster() {
uint party_balance_index = swap_balances_index[_swap][_party];
uint party_swap_balance = swap_balances[_swap][party_balance_index].amount;
user_total_balances[_party] = user_total_balances[_party].sub(party_swap_balance);
total_supply = total_supply.sub(party_swap_balance);
swap_balances[_swap][party_balance_index].amount = 0;
}
function balanceOf(address _owner) public constant returns (uint balance) { return user_total_balances[_owner]; }
function totalSupply() public constant returns (uint _total_supply) { return total_supply; }
function addressInSwap(address _swap, address _owner) public view returns (bool) {
return user_swaps_index[_owner][_swap] != 0;
}
function removeFromSwapBalances(address _remove, address _swap) internal {
uint last_address_index = swap_balances[_swap].length.sub(1);
address last_address = swap_balances[_swap][last_address_index].owner;
if (last_address != _remove) {
uint remove_index = swap_balances_index[_swap][_remove];
swap_balances_index[_swap][last_address] = remove_index;
swap_balances[_swap][remove_index] = swap_balances[_swap][last_address_index];
}
delete swap_balances_index[_swap][_remove];
swap_balances[_swap].length = swap_balances[_swap].length.sub(1);
}
function transferHelper(address _from, address _to, uint _amount) internal {
address[] memory from_swaps = user_swaps[_from];
for (uint i = from_swaps.length.sub(1); i > 0; i--) {
uint from_swap_user_index = swap_balances_index[from_swaps[i]][_from];
Balance memory from_user_bal = swap_balances[from_swaps[i]][from_swap_user_index];
if (_amount >= from_user_bal.amount) {
_amount -= from_user_bal.amount;
user_swaps[_from].length = user_swaps[_from].length.sub(1);
delete user_swaps_index[_from][from_swaps[i]];
if (addressInSwap(from_swaps[i], _to)) {
uint to_balance_index = swap_balances_index[from_swaps[i]][_to];
assert(to_balance_index != 0);
swap_balances[from_swaps[i]][to_balance_index].amount = swap_balances[from_swaps[i]][to_balance_index].amount.add(from_user_bal.amount);
removeFromSwapBalances(_from, from_swaps[i]);
} else {
if (user_swaps[_to].length == 0)
user_swaps_index[_to][from_swaps[i]] = 1;
else
user_swaps_index[_to][from_swaps[i]] = user_swaps[_to].length;
user_swaps[_to].push(from_swaps[i]);
swap_balances[from_swaps[i]][from_swap_user_index].owner = _to;
swap_balances_index[from_swaps[i]][_to] = swap_balances_index[from_swaps[i]][_from];
delete swap_balances_index[from_swaps[i]][_from];
}
if (_amount == 0)
break;
} else {
uint to_swap_balance_index = swap_balances_index[from_swaps[i]][_to];
if (addressInSwap(from_swaps[i], _to)) {
swap_balances[from_swaps[i]][to_swap_balance_index].amount = swap_balances[from_swaps[i]][to_swap_balance_index].amount.add(_amount);
} else {
if (user_swaps[_to].length == 0)
user_swaps_index[_to][from_swaps[i]] = 1;
else
user_swaps_index[_to][from_swaps[i]] = user_swaps[_to].length;
user_swaps[_to].push(from_swaps[i]);
swap_balances_index[from_swaps[i]][_to] = swap_balances[from_swaps[i]].length;
swap_balances[from_swaps[i]].push(Balance({
owner: _to,
amount: _amount
}));
}
swap_balances[from_swaps[i]][from_swap_user_index].amount = swap_balances[from_swaps[i]][from_swap_user_index].amount.sub(_amount);
break;
}
}
}
function transfer(address _to, uint _amount) public returns (bool success) {
uint balance_owner = user_total_balances[msg.sender];
if (
_to == msg.sender ||
_to == address(0) ||
_amount == 0 ||
balance_owner < _amount
) return false;
transferHelper(msg.sender, _to, _amount);
user_total_balances[msg.sender] = user_total_balances[msg.sender].sub(_amount);
user_total_balances[_to] = user_total_balances[_to].add(_amount);
Transfer(msg.sender, _to, _amount);
return true;
}
function transferFrom(address _from, address _to, uint _amount) public returns (bool success) {
uint balance_owner = user_total_balances[_from];
uint sender_allowed = allowed[_from][msg.sender];
if (
_to == _from ||
_to == address(0) ||
_amount == 0 ||
balance_owner < _amount ||
sender_allowed < _amount
) return false;
transferHelper(_from, _to, _amount);
user_total_balances[_from] = user_total_balances[_from].sub(_amount);
user_total_balances[_to] = user_total_balances[_to].add(_amount);
allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_amount);
Transfer(_from, _to, _amount);
return true;
}
function approve(address _spender, uint _amount) public returns (bool success) {
allowed[msg.sender][_spender] = _amount;
Approval(msg.sender, _spender, _amount);
return true;
}
function addressCount(address _swap) public constant returns (uint count) { return swap_balances[_swap].length; }
function getHolderByIndex(uint _ind, address _swap) public constant returns (address holder) { return swap_balances[_swap][_ind].owner; }
function getBalanceByIndex(uint _ind, address _swap) public constant returns (uint bal) { return swap_balances[_swap][_ind].amount; }
function getIndexByAddress(address _owner, address _swap) public constant returns (uint index) { return swap_balances_index[_swap][_owner]; }
function allowance(address _owner, address _spender) public constant returns (uint amount) { return allowed[_owner][_spender]; }
}
contract Tokendeployer {
address owner;
address public factory;
function Tokendeployer(address _factory) public {
factory = _factory;
owner = msg.sender;
}
function newToken() public returns (address created) {
require(msg.sender == factory);
address new_token = new DRCT_Token(factory);
return new_token;
}
function setVars(address _factory, address _owner) public {
require (msg.sender == owner);
factory = _factory;
owner = _owner;
}
}