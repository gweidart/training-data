pragma solidity ^0.4.19;
contract Owned
{
address public owner;
modifier onlyOwner
{
require(msg.sender == owner);
_;
}
function transferOwnership(address newOwner) public onlyOwner()
{
owner = newOwner;
}
}
contract EIP20Interface {
uint256 public totalSupply;
function balanceOf(address _owner) public view returns (uint256 balance);
function transfer(address _to, uint256 _value) public returns (bool success);
function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
function approve(address _spender, uint256 _value) public returns (bool success);
function allowance(address _owner, address _spender) public view returns (uint256 remaining);
event Transfer(address indexed _from, address indexed _to, uint256 _value);
event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}
contract EIP20 is EIP20Interface {
uint256 constant MAX_UINT256 = 2**256 - 1;
string public name;
uint8 public decimals;
string public symbol;
function EIP20(
uint256 _initialAmount,
string _tokenName,
uint8 _decimalUnits,
string _tokenSymbol
) public {
balances[msg.sender] = _initialAmount;
totalSupply = _initialAmount;
name = _tokenName;
decimals = _decimalUnits;
symbol = _tokenSymbol;
}
function transfer(address _to, uint256 _value) public returns (bool success) {
require(balances[msg.sender] >= _value);
balances[msg.sender] -= _value;
balances[_to] += _value;
Transfer(msg.sender, _to, _value);
return true;
}
function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
uint256 allowance = allowed[_from][msg.sender];
require(balances[_from] >= _value && allowance >= _value);
balances[_to] += _value;
balances[_from] -= _value;
if (allowance < MAX_UINT256) {
allowed[_from][msg.sender] -= _value;
}
Transfer(_from, _to, _value);
return true;
}
function balanceOf(address _owner) view public returns (uint256 balance) {
return balances[_owner];
}
function approve(address _spender, uint256 _value) public returns (bool success) {
allowed[msg.sender][_spender] = _value;
Approval(msg.sender, _spender, _value);
return true;
}
function allowance(address _owner, address _spender)
view public returns (uint256 remaining) {
return allowed[_owner][_spender];
}
mapping (address => uint256) balances;
mapping (address => mapping (address => uint256)) allowed;
}
contract Gabicoin is Owned, EIP20
{
struct IcoBalance
{
bool hasTransformed;
uint[3] balances;
}
event Mint(address indexed to, uint value, uint phaseNumber);
event Activate();
function Gabicoin() EIP20(0, "Gabicoin", 2, "GCO") public
{
owner = msg.sender;
}
function mint(address to, uint value, uint phase) onlyOwner() external
{
require(!isActive);
icoBalances[to].balances[phase] += value;
Mint(to, value, phase);
}
function activate(bool i0, bool i1, bool i2) onlyOwner() external
{
require(!isActive);
activatedPhases[0] = i0;
activatedPhases[1] = i1;
activatedPhases[2] = i2;
Activate();
isActive = true;
}
function transform(address addr) public
{
require(isActive);
require(!icoBalances[addr].hasTransformed);
for (uint i = 0; i < 3; i++)
{
if (activatedPhases[i])
{
balances[addr] += icoBalances[addr].balances[i];
Transfer(0x00, addr, icoBalances[addr].balances[i]);
icoBalances[addr].balances[i] = 0;
}
}
icoBalances[addr].hasTransformed = true;
}
function () payable external
{
transform(msg.sender);
msg.sender.transfer(msg.value);
}
bool[3] public activatedPhases;
bool public isActive;
mapping (address => IcoBalance) public icoBalances;
}