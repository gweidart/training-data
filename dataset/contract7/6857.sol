pragma solidity ^0.4.23;
contract ERC20Interface {
function allowance(address owner, address spender) public view returns (uint256);
function transferFrom(address from, address to, uint256 value) public returns (bool);
function approve(address spender, uint256 value) public returns (bool);
event Approval(
address indexed owner,
address indexed spender,
uint256 value
);
function totalSupply() public view returns (uint256);
function balanceOf(address who) public view returns (uint256);
function transfer(address to, uint256 value) public returns (bool);
event Transfer(address indexed from, address indexed to, uint256 value);
}
contract StandardERC20 is ERC20Interface {
using SafeMath for uint256;
mapping(address => uint256) balances;
uint256 totalSupply_;
function totalSupply() public view returns (uint256) {
return totalSupply_;
}
function transfer(address _to, uint256 _value) public returns (bool) {
require(_to != address(0));
require(_value <= balances[msg.sender]);
balances[msg.sender] = balances[msg.sender].sub(_value);
balances[_to] = balances[_to].add(_value);
emit Transfer(msg.sender, _to, _value);
return true;
}
function balanceOf(address _owner) public view returns (uint256) {
return balances[_owner];
}
mapping (address => mapping (address => uint256)) internal allowed;
function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
require(_to != address(0));
require(_value <= balances[_from]);
require(_value <= allowed[_from][msg.sender]);
balances[_from] = balances[_from].sub(_value);
balances[_to] = balances[_to].add(_value);
allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
emit Transfer(_from, _to, _value);
return true;
}
function approve(address _spender, uint256 _value) public returns (bool) {
allowed[msg.sender][_spender] = _value;
emit Approval(msg.sender, _spender, _value);
return true;
}
function allowance(address _owner, address _spender) public view returns (uint256) {
return allowed[_owner][_spender];
}
function increaseApproval(address _spender, uint256 _addedValue) public returns (bool) {
allowed[msg.sender][_spender] = (
allowed[msg.sender][_spender].add(_addedValue));
emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
return true;
}
function decreaseApproval(address _spender, uint256 _subtractedValue) public returns (bool) {
uint256 oldValue = allowed[msg.sender][_spender];
if (_subtractedValue > oldValue) {
allowed[msg.sender][_spender] = 0;
} else {
allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
}
emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
return true;
}
}
contract Token is StandardERC20 {
string public name    = "Genuine Token";
string public symbol  = "GNU";
uint8  public decimals = 18;
address owner;
bool burnable;
event Transfer(address indexed from, address indexed to, uint value, bytes data);
event Burn(address indexed burner, uint256 value);
constructor() public {
balances[msg.sender] = 340000000 * (uint(10) ** decimals);
totalSupply_ = balances[msg.sender];
owner = msg.sender;
burnable = false;
}
function transferOwnership(address tbo) public {
require(msg.sender == owner, 'Unauthorized');
owner = tbo;
}
function name() public view returns (string _name) {
return name;
}
function symbol() public view returns (string _symbol) {
return symbol;
}
function decimals() public view returns (uint8 _decimals) {
return decimals;
}
function totalSupply() public view returns (uint256 _totalSupply) {
return totalSupply_;
}
function transfer(address _to, uint _value, bytes _data, string _custom_fallback) public returns (bool success) {
require(_to != address(0));
if (isContract(_to)) {
if (balanceOf(msg.sender) < _value) revert();
balances[msg.sender] = balanceOf(msg.sender).sub(_value);
balances[_to] = balanceOf(_to).add(_value);
assert(_to.call.value(0)(bytes4(sha3(_custom_fallback)), msg.sender, _value, _data));
emit Transfer(msg.sender, _to, _value, _data);
emit Transfer(msg.sender, _to, _value);
return true;
} else {
return transferToAddress(_to, _value, _data);
}
}
function transfer(address _to, uint _value, bytes _data) public returns (bool success) {
require(_to != address(0));
if (isContract(_to)) {
return transferToContract(_to, _value, _data);
}
else {
return transferToAddress(_to, _value, _data);
}
}
function transfer(address _to, uint _value) public returns (bool success) {
require(_to != address(0));
bytes memory empty;
if (isContract(_to)) {
return transferToContract(_to, _value, empty);
}
else {
return transferToAddress(_to, _value, empty);
}
}
function isContract(address _addr) private view returns (bool is_contract) {
uint length;
assembly {
length := extcodesize(_addr)
}
return (length > 0);
}
function transferToAddress(address _to, uint _value, bytes _data) private returns (bool success) {
if (balanceOf(msg.sender) < _value) revert("Insufficient balance");
balances[msg.sender] = balanceOf(msg.sender).sub(_value);
balances[_to] = balanceOf(_to).add(_value);
emit Transfer(msg.sender, _to, _value, _data);
emit Transfer(msg.sender, _to, _value);
return true;
}
function transferToContract(address _to, uint _value, bytes _data) private returns (bool success) {
if (balanceOf(msg.sender) < _value) revert("Insufficient balance");
balances[msg.sender] = balanceOf(msg.sender).sub(_value);
balances[_to] = balanceOf(_to).add(_value);
ContractReceiver receiver = ContractReceiver(_to);
receiver.tokenFallback(msg.sender, _value, _data);
emit Transfer(msg.sender, _to, _value, _data);
emit Transfer(msg.sender, _to, _value);
return true;
}
function setBurnable(bool _burnable) public {
require (msg.sender == owner);
burnable = _burnable;
}
function burn(uint256 _value) public {
_burn(msg.sender, _value);
}
function _burn(address _who, uint256 _value) internal {
require(burnable == true || _who == owner);
require(_value <= balances[_who]);
balances[_who] = balances[_who].sub(_value);
totalSupply_ = totalSupply_.sub(_value);
emit Burn(_who, _value);
emit Transfer(_who, address(0), _value);
}
}
pragma solidity ^0.4.23;
library SafeMath {
function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
if (a == 0) {
return 0;
}
c = a * b;
assert(c / a == b);
return c;
}
function div(uint256 a, uint256 b) internal pure returns (uint256) {
return a / b;
}
function sub(uint256 a, uint256 b) internal pure returns (uint256) {
assert(b <= a);
return a - b;
}
function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
c = a + b;
assert(c >= a);
return c;
}
}
contract ContractReceiver {
function tokenFallback(address _from, uint _value, bytes _data) public;
}