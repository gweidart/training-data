pragma solidity ^0.4.24;
interface ERC223 {
function balanceOf(address _owner) external constant returns (uint256);
function name() external constant returns  (string _name);
function symbol() external constant returns  (string _symbol);
function decimals() external constant returns (uint8 _decimals);
function totalSupply() external constant returns (uint256 _totalSupply);
function transfer(address _to, uint256 _value) external returns (bool ok);
function transfer(address _to, uint256 _value, bytes _data) public returns (bool ok);
function sell(uint256 _value) external returns (bool);
event Transfer(address indexed _from, address indexed _to, uint256 _value);
event ERC223Transfer(address indexed _from, address indexed _to, uint256 _value, bytes _data);
event Sell(address indexed from, uint value);
}
contract ERC223ReceivingContract {
function tokenFallback(address _from, uint _value, bytes _data) public;
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
address public owner;
event OwnershipRenounced(address indexed previousOwner);
event OwnershipTransferred(
address indexed previousOwner,
address indexed newOwner
);
constructor() public {
owner = msg.sender;
}
modifier onlyOwner() {
require(msg.sender == owner);
_;
}
function renounceOwnership() public onlyOwner {
emit OwnershipRenounced(owner);
owner = address(0);
}
function transferOwnership(address _newOwner) public onlyOwner {
_transferOwnership(_newOwner);
}
function _transferOwnership(address _newOwner) internal {
require(_newOwner != address(0));
emit OwnershipTransferred(owner, _newOwner);
owner = _newOwner;
}
}
contract C3Coin is ERC223, Ownable {
using SafeMath for uint;
string public name;
string public symbol;
uint8 public decimals;
uint256 public totalSupply;
constructor() public {
name = "C3 Coin";
symbol = "CCC";
decimals = 18;
totalSupply = 100000000000000000000000000000;
balances[msg.sender] = totalSupply;
}
mapping (address => uint256) internal balances;
address public icoContract;
function name() external constant returns (string _name) {
return name;
}
function symbol() external constant returns (string _symbol) {
return symbol;
}
function decimals() external constant returns (uint8 _decimals) {
return decimals;
}
function totalSupply() external constant returns (uint256 _totalSupply) {
return totalSupply;
}
function transfer(address _to, uint256 _value) external returns (bool) {
require(_to != address(0));
require(_value <= balances[msg.sender] && balances[_to] + _value >= balances[_to]);
require(!isContract(_to));
balances[msg.sender] = balances[msg.sender].sub(_value);
balances[_to] = balances[_to].add(_value);
emit Transfer(msg.sender, _to, _value);
return true;
}
function balanceOf(address _owner) external constant returns (uint256 balance) {
return balances[_owner];
}
function transfer(address _to, uint _value, bytes _data) public returns (bool) {
require(_to != address(0));
require(_value <= balances[msg.sender] && balances[_to] + _value >= balances[_to]);
if(isContract(_to)) {
ERC223ReceivingContract receiver = ERC223ReceivingContract(_to);
receiver.tokenFallback(msg.sender, _value, _data);
}
balances[msg.sender] = balances[msg.sender].sub(_value);
balances[_to] = balances[_to].add(_value);
emit ERC223Transfer(msg.sender, _to, _value, _data);
return true;
}
function isContract(address _addr) private returns (bool is_contract) {
uint length;
assembly {
length := extcodesize(_addr)
}
return (length>0);
}
function setIcoContract(address _icoContract) public onlyOwner {
if (_icoContract != address(0)) {
icoContract = _icoContract;
}
}
function sell(uint256 _value) public onlyOwner returns (bool) {
require(icoContract != address(0));
require(_value <= balances[msg.sender] && balances[icoContract] + _value >= balances[icoContract]);
balances[msg.sender] = balances[msg.sender].sub(_value);
balances[icoContract] = balances[icoContract].add(_value);
emit Sell(msg.sender, _value);
return true;
}
function () public payable {
revert();
}
}