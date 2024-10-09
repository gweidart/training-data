pragma solidity ^0.4.18;
contract Owned {
address public owner = msg.sender;
address public potentialOwner;
modifier onlyOwner {
require(msg.sender == owner);
_;
}
modifier onlyPotentialOwner {
require(msg.sender == potentialOwner);
_;
}
event NewOwner(address old, address current);
event NewPotentialOwner(address old, address potential);
function setOwner(address _new)
public
onlyOwner
{
NewPotentialOwner(owner, _new);
potentialOwner = _new;
}
function confirmOwnership()
public
onlyPotentialOwner
{
NewOwner(owner, potentialOwner);
owner = potentialOwner;
potentialOwner = 0;
}
}
contract AbstractToken {
function balanceOf(address owner) public view returns (uint256 balance);
function transfer(address to, uint256 value) public returns (bool success);
function transferFrom(address from, address to, uint256 value) public returns (bool success);
function approve(address spender, uint256 value) public returns (bool success);
function allowance(address owner, address spender) public view returns (uint256 remaining);
event Transfer(address indexed from, address indexed to, uint256 value);
event Approval(address indexed owner, address indexed spender, uint256 value);
event Issuance(address indexed to, uint256 value);
}
contract StandardToken is AbstractToken, Owned {
mapping (address => uint256) balances;
mapping (address => mapping (address => uint256)) allowed;
uint256 public totalSupply;
function transfer(address _to, uint256 _value) public returns (bool success) {
if (balances[msg.sender] >= _value && balances[_to] + _value > balances[_to]) {
balances[msg.sender] -= _value;
balances[_to] += _value;
Transfer(msg.sender, _to, _value);
return true;
}
else {
return false;
}
}
function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && balances[_to] + _value > balances[_to]) {
balances[_to] += _value;
balances[_from] -= _value;
allowed[_from][msg.sender] -= _value;
Transfer(_from, _to, _value);
return true;
}
else {
return false;
}
}
function balanceOf(address _owner) public view returns (uint256 balance) {
return balances[_owner];
}
function approve(address _spender, uint256 _value) public returns (bool success) {
allowed[msg.sender][_spender] = _value;
Approval(msg.sender, _spender, _value);
return true;
}
function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
return allowed[_owner][_spender];
}
}
contract SafeMath {
function mul(uint a, uint b) internal pure returns (uint) {
uint c = a * b;
assert(a == 0 || c / a == b);
return c;
}
function div(uint a, uint b) internal pure returns (uint) {
assert(b > 0);
uint c = a / b;
assert(a == b * c + a % b);
return c;
}
function sub(uint a, uint b) internal pure returns (uint) {
assert(b <= a);
return a - b;
}
function add(uint a, uint b) internal pure returns (uint) {
uint c = a + b;
assert(c >= a);
return c;
}
function pow(uint a, uint b) internal pure returns (uint) {
uint c = a ** b;
assert(c >= a);
return c;
}
}
contract Token is StandardToken, SafeMath {
uint public creationTime;
function Token() public {
creationTime = now;
}
function transferERC20Token(address tokenAddress)
public
onlyOwner
returns (bool)
{
uint balance = AbstractToken(tokenAddress).balanceOf(this);
return AbstractToken(tokenAddress).transfer(owner, balance);
}
function withDecimals(uint number, uint decimals)
internal
pure
returns (uint)
{
return mul(number, pow(10, decimals));
}
}
contract SberToken is Token {
string constant public name = "SberToken";
string constant public symbol = "SRUB";
uint8 constant public decimals = 8;
address constant public foundationReserve = address(0xFFfFfFffFFfffFFfFFfFFFFFffFFFffffFfFFFfF);
address constant public mintAddress = address(0x1111111111111111111111111111111111111111);
address constant public burnAddress = address(0x0000000000000000000000000000000000000000);
function SberToken()
public
{
totalSupply = withDecimals(pow(10,9), decimals);
balances[foundationReserve] = totalSupply;
allowed[foundationReserve][owner] = balanceOf(foundationReserve);
Transfer(mintAddress, foundationReserve, balanceOf(foundationReserve));
Issuance(foundationReserve, balanceOf(foundationReserve));
}
function mint(uint256 amount)
public
onlyOwner
{
uint256 mintedSupply = withDecimals(amount, decimals);
totalSupply = add(totalSupply, mintedSupply);
balances[foundationReserve] = add(balanceOf(foundationReserve), mintedSupply);
allowed[foundationReserve][owner] = balanceOf(foundationReserve);
Transfer(mintAddress, foundationReserve, mintedSupply);
Issuance(foundationReserve, mintedSupply);
}
function burn(uint256 amount)
public
onlyOwner
{
uint256 burnedSupply = withDecimals(amount, decimals);
require(burnedSupply <= balanceOf(foundationReserve));
totalSupply = sub(totalSupply, burnedSupply);
balances[foundationReserve] = sub(balanceOf(foundationReserve), burnedSupply);
allowed[foundationReserve][owner] = balanceOf(foundationReserve);
Transfer(foundationReserve, burnAddress, burnedSupply);
}
function confirmOwnership()
public
onlyPotentialOwner
{
allowed[foundationReserve][owner] = 0;
allowed[foundationReserve][msg.sender] = balanceOf(foundationReserve);
super.confirmOwnership();
}
function withdrawFromReserve(address _to, uint256 amount)
public
onlyOwner
{
require(transferFrom(foundationReserve, _to, withDecimals(amount, decimals)));
}
}