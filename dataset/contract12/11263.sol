pragma solidity ^0.4.11;
contract ERC223ReceivingContract {
function tokenFallback(address _from, uint _value, bytes _data) public;
}
library SafeMath {
function mul(uint a, uint b) pure internal returns (uint) {
uint c = a * b;
assert(a == 0 || c / a == b);
return c;
}
function div(uint a, uint b) pure internal returns (uint) {
uint c = a / b;
return c;
}
function sub(uint a, uint b) pure internal returns (uint) {
assert(b <= a);
return a - b;
}
function add(uint a, uint b) pure internal returns (uint) {
uint c = a + b;
assert(c >= a);
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
}
contract ERC20CompatibleToken {
using SafeMath for uint;
mapping(address => uint) balances;
event Transfer(address indexed from, address indexed to, uint value);
event Approval(address indexed owner, address indexed spender, uint256 value);
mapping (address => mapping (address => uint256)) internal allowed;
function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
uint codeLength;
bytes memory empty;
assembly {
codeLength := extcodesize(_to)
}
require(_to != address(0));
require(_value <= balances[_from]);
require(_value <= allowed[_from][msg.sender]);
balances[_from] = balances[_from].sub(_value);
balances[_to] = balances[_to].add(_value);
allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
if(codeLength>0) {
ERC223ReceivingContract receiver = ERC223ReceivingContract(_to);
receiver.tokenFallback(_from, _value, empty);
}
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
function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
return true;
}
function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
uint oldValue = allowed[msg.sender][_spender];
if (_subtractedValue > oldValue) {
allowed[msg.sender][_spender] = 0;
} else {
allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
}
emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
return true;
}
}
contract ERC223Interface {
uint public totalSupply;
function balanceOf(address who) constant public returns (uint);
function transfer(address to, uint value) public;
function transfer(address to, uint value, bytes data) public;
}
contract WubCoin is ERC223Interface, ERC20CompatibleToken {
using SafeMath for uint;
string  public name    = "WubCoin";
string  public symbol  = "WUB";
uint8   public decimals = 18;
uint256 public totalSupply = 15000000 * 10 ** 18;
constructor(address companyWallet) public {
balances[companyWallet] = balances[companyWallet].add(totalSupply);
emit Transfer(0x0, companyWallet, totalSupply);
}
function() public payable {
revert();
}
function transfer(address _to, uint _value, bytes _data) public {
uint codeLength;
assembly {
codeLength := extcodesize(_to)
}
balances[msg.sender] = balances[msg.sender].sub(_value);
balances[_to] = balances[_to].add(_value);
if(codeLength>0) {
ERC223ReceivingContract receiver = ERC223ReceivingContract(_to);
receiver.tokenFallback(msg.sender, _value, _data);
}
emit Transfer(msg.sender, _to, _value);
}
function transfer(address _to, uint _value) public {
uint codeLength;
bytes memory empty;
assembly {
codeLength := extcodesize(_to)
}
balances[msg.sender] = balances[msg.sender].sub(_value);
balances[_to] = balances[_to].add(_value);
if(codeLength>0) {
ERC223ReceivingContract receiver = ERC223ReceivingContract(_to);
receiver.tokenFallback(msg.sender, _value, empty);
}
emit Transfer(msg.sender, _to, _value);
}
function balanceOf(address _owner) public constant returns (uint balance) {
return balances[_owner];
}
}