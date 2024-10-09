pragma solidity ^0.4.11;
library SafeMath {
function mul(uint a, uint b) internal returns (uint) {
uint c = a * b;
assert(a == 0 || c / a == b);
return c;
}
function div(uint a, uint b) internal returns (uint) {
uint c = a / b;
return c;
}
function sub(uint a, uint b) internal returns (uint) {
assert(b <= a);
return a - b;
}
function add(uint a, uint b) internal returns (uint) {
uint c = a + b;
assert(c >= a);
return c;
}
function max64(uint64 a, uint64 b) internal constant returns (uint64) {
return a >= b ? a : b;
}
function min64(uint64 a, uint64 b) internal constant returns (uint64) {
return a < b ? a : b;
}
function max256(uint256 a, uint256 b) internal constant returns (uint256) {
return a >= b ? a : b;
}
function min256(uint256 a, uint256 b) internal constant returns (uint256) {
return a < b ? a : b;
}
function assert(bool assertion) internal {
if (!assertion) {
throw;
}
}
}
contract ERC223Interface {
uint public totalSupply;
function balanceOf(address who) constant returns (uint);
function transfer(address to, uint value) public returns (bool ok);
function batch_transfer(address[] to, uint[] value) public returns (bool ok);
function transfer(address to, uint value, bytes data) public returns (bool ok);
event Transfer(address indexed from, address indexed to, uint value);
}
contract ERC223ReceivingContract {
function tokenFallback(address _from, uint _value, bytes _data);
}
contract Owned {
address public owner;
address public proposedOwner;
bool public paused = false;
event OwnershipTransferInitiated(address indexed _proposedOwner);
event OwnershipTransferCompleted(address indexed _newOwner);
function Owned() public {
owner = msg.sender;
}
modifier onlyOwner() {
require(isOwner(msg.sender));
_;
}
function pause() onlyOwner whenNotPaused public {
paused = true;
}
function resume() onlyOwner whenPaused public {
paused = false;
}
modifier whenNotPaused() {
require(!paused);
_;
}
modifier whenPaused() {
require(paused);
_;
}
function isOwner(address _address) internal view returns (bool) {
return (_address == owner);
}
function initiateOwnershipTransfer(address _proposedOwner) public onlyOwner returns (bool) {
proposedOwner = _proposedOwner;
OwnershipTransferInitiated(_proposedOwner);
return true;
}
function completeOwnershipTransfer() public returns (bool) {
require(msg.sender == proposedOwner);
owner = proposedOwner;
proposedOwner = address(0);
OwnershipTransferCompleted(owner);
return true;
}
}
contract TRNDToken is ERC223Interface, Owned {
using SafeMath for uint;
string public constant symbol="TRND";
string public constant name="trend42";
uint8 public constant decimals=2;
uint public totalSupply = 42000000 * 10 ** uint(decimals);
mapping(address => uint256) balances;
mapping(address => mapping(address => uint256)) allowed;
function TRNDToken() {
owner = msg.sender;
balances[owner] = totalSupply;
}
event Burn(address indexed burner, uint256 value);
function burn(uint256 _value) public whenNotPaused {
_burn(msg.sender, _value);
}
function _burn(address _who, uint256 _value) internal {
require(_value <= balances[_who]);
balances[_who] = SafeMath.sub(balances[_who], _value);
totalSupply = SafeMath.sub(totalSupply, _value);
emit Burn(_who, _value);
emit Transfer(_who, address(0), _value);
}
function transfer(address _to, uint _value, bytes _data) public whenNotPaused returns (bool success) {
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
return true;
}
function transfer(address _to, uint _value) public whenNotPaused returns (bool success) {
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
return true;
}
function batch_transfer(address[] _to, uint[] _value) public whenNotPaused returns (bool success) {
require(_to.length <= 255);
require(_to.length == _value.length);
for (uint8 i = 0; i < _to.length; i++) {
transfer(_to[i], _value[i]);
}
return true;
}
function balanceOf(address _owner) constant returns (uint balance) {
return balances[_owner];
}
}