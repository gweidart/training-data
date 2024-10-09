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
contract ERC20Basic {
uint public totalSupply;
function balanceOf(address who) constant returns (uint);
function transfer(address to, uint value);
event Transfer(address indexed from, address indexed to, uint value);
}
contract BasicToken is ERC20Basic {
using SafeMath for uint;
mapping(address => uint) balances;
modifier onlyPayloadSize(uint size) {
if(msg.data.length < size + 4) {
throw;
}
_;
}
function transfer(address _to, uint _value) onlyPayloadSize(2 * 32) {
balances[msg.sender] = balances[msg.sender].sub(_value);
balances[_to] = balances[_to].add(_value);
Transfer(msg.sender, _to, _value);
}
function balanceOf(address _owner) constant returns (uint balance) {
return balances[_owner];
}
}
contract ERC20 is ERC20Basic {
function allowance(address owner, address spender) constant returns (uint);
function transferFrom(address from, address to, uint value);
function approve(address spender, uint value);
event Approval(address indexed owner, address indexed spender, uint value);
}
contract StandardToken is BasicToken, ERC20 {
mapping (address => mapping (address => uint)) allowed;
function transferFrom(address _from, address _to, uint _value) onlyPayloadSize(3 * 32) {
var _allowance = allowed[_from][msg.sender];
balances[_to] = balances[_to].add(_value);
balances[_from] = balances[_from].sub(_value);
allowed[_from][msg.sender] = _allowance.sub(_value);
Transfer(_from, _to, _value);
}
function approve(address _spender, uint _value) {
if ((_value != 0) && (allowed[msg.sender][_spender] != 0)) throw;
allowed[msg.sender][_spender] = _value;
Approval(msg.sender, _spender, _value);
}
function allowance(address _owner, address _spender) constant returns (uint remaining) {
return allowed[_owner][_spender];
}
}
contract CATFreezer {
using SafeMath for uint256;
address public CATContract;
address public postFreezeDevCATDestination;
uint256 public firstAllocation;
uint256 public secondAllocation;
uint256 public firstThawDate;
uint256 public secondThawDate;
bool public firstUnlocked;
function CATFreezer(
address _CATContract,
address _postFreezeDevCATDestination
) {
CATContract = _CATContract;
postFreezeDevCATDestination = _postFreezeDevCATDestination;
firstThawDate = now + 365 days;
secondThawDate = now + 2 * 365 days;
firstUnlocked = false;
}
function unlockFirst() external {
if (firstUnlocked) throw;
if (msg.sender != postFreezeDevCATDestination) throw;
if (now < firstThawDate) throw;
firstUnlocked = true;
uint256 totalBalance = StandardToken(CATContract).balanceOf(this);
firstAllocation = totalBalance.div(2);
secondAllocation = totalBalance.sub(firstAllocation);
uint256 tokens = firstAllocation;
firstAllocation = 0;
StandardToken(CATContract).transfer(msg.sender, tokens);
}
function unlockSecond() external {
if (!firstUnlocked) throw;
if (msg.sender != postFreezeDevCATDestination) throw;
if (now < secondThawDate) throw;
uint256 tokens = secondAllocation;
secondAllocation = 0;
StandardToken(CATContract).transfer(msg.sender, tokens);
}
function changeCATDestinationAddress(address _newAddress) external {
if (msg.sender != postFreezeDevCATDestination) throw;
postFreezeDevCATDestination = _newAddress;
}
}