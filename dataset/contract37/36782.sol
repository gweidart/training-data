contract SafeMath {
function safeMul(uint a, uint b) internal returns (uint) {
uint c = a * b;
assert(a == 0 || c / a == b);
return c;
}
function safeSub(uint a, uint b) internal returns (uint) {
assert(b <= a);
return a - b;
}
function safeAdd(uint a, uint b) internal returns (uint) {
uint c = a + b;
assert(c>=a && c>=b);
return c;
}
function assert(bool assertion) internal {
if (!assertion) throw;
}
}
contract Token {
function totalSupply() constant returns (uint256 supply) {}
function balanceOf(address _owner) constant returns (uint256 balance) {}
function transfer(address _to, uint256 _value) returns (bool success) {}
function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {}
function approve(address _spender, uint256 _value) returns (bool success) {}
function allowance(address _owner, address _spender) constant returns (uint256 remaining) {}
event Transfer(address indexed _from, address indexed _to, uint256 _value);
event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}
contract StandardToken is Token {
function transfer(address _to, uint256 _value) returns (bool success) {
if (balances[msg.sender] >= _value && balances[_to] + _value > balances[_to]) {
balances[msg.sender] -= _value;
balances[_to] += _value;
Transfer(msg.sender, _to, _value);
return true;
} else { return false; }
}
function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && balances[_to] + _value > balances[_to]) {
balances[_to] += _value;
balances[_from] -= _value;
allowed[_from][msg.sender] -= _value;
Transfer(_from, _to, _value);
return true;
} else { return false; }
}
function balanceOf(address _owner) constant returns (uint256 balance) {
return balances[_owner];
}
function approve(address _spender, uint256 _value) returns (bool success) {
allowed[msg.sender][_spender] = _value;
Approval(msg.sender, _spender, _value);
return true;
}
function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
return allowed[_owner][_spender];
}
mapping(address => uint256) balances;
mapping (address => mapping (address => uint256)) allowed;
uint256 public totalSupply;
}
contract CTest1 is StandardToken, SafeMath {
string public name = "CTest1 Token";
string public symbol = "CTest1";
uint public decimals = 18;
uint256 public totalSupply = 1000000;
address public owner = msg.sender;
address public Founder1 = 0xB5D39A8Ea30005f9114Bf936025De2D6f353813E;
address public Founder2 = 0x00A591199F53907480E1f5A00958b93B43200Fe4;
address public Founder3 = 0x0d19C131400e73c71bBB2bC1666dBa8Fe22d242D;
event Buy(address indexed sender, uint eth, uint fbt);
function transfer(address _to, uint256 _value) returns (bool success) {
return super.transfer(_to, _value);
}
function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
return super.transferFrom(_from, _to, _value);
}
function () payable {
if (totalSupply < 1)
{
throw;
}
uint256 rate = 0;
address recipient = msg.sender;
if (totalSupply > 975000)
{
rate = 3340;
}
if (totalSupply < 975001)
{
rate = 668;
}
if (totalSupply < 875001)
{
rate = 334;
}
if (totalSupply < 475001)
{
rate = 134;
}
uint256 tokens = safeMul(msg.value, rate);
tokens = tokens/1 ether;
if (tokens < 1)
{
throw;
}
uint256 check = safeSub(totalSupply, tokens);
if (check < 0)
{
throw;
}
if (totalSupply > 975000 && check < 975000)
{
throw;
}
if (totalSupply > 875000 && check < 875000)
{
throw;
}
if (totalSupply > 475000 && check < 475000)
{
throw;
}
if ((balances[recipient] + tokens) > 50 && totalSupply > 975000)
{
throw;
}
balances[recipient] = safeAdd(balances[recipient], tokens);
totalSupply = safeSub(totalSupply, tokens);
Founder1.transfer((msg.value/3));
Founder2.transfer((msg.value/3));
Founder3.transfer((msg.value/3));
Buy(recipient, msg.value, tokens);
}
function Burn () {
if (msg.sender == owner && totalSupply > 0)
{
totalSupply = 0;
} else {throw;}
}
}