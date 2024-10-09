pragma solidity 0.4.24;
contract Owned {
address public owner;
function owned() public {
owner = msg.sender;
}
modifier onlyOwner {
require(msg.sender == owner);
_;
}
function transferOwnership(address _newOwner) onlyOwner public {
owner = _newOwner;
}
}
contract ERC20 {
using SafeMath for uint256;
mapping (address => uint256) public balanceOf;
mapping (address => mapping (address => uint256)) allowed;
mapping(address => bool) public isLockedAccount;
string public name;
string public symbol;
uint8 public decimals = 18;
uint256 public totalSupply;
event Approval(address indexed owner, address indexed spender, uint256 value);
event Transfer(address indexed from, address indexed to, uint256 value);
function ERC20(uint256 _initialSupply,string _tokenName, string _tokenSymbol) public {
totalSupply = _initialSupply * 10 ** uint256(decimals);
balanceOf[msg.sender] = totalSupply;
name = _tokenName;
symbol = _tokenSymbol;
}
function transfer(address _to, uint256 _value) public returns (bool) {
require(!isLockedAccount[msg.sender]);
require(!isLockedAccount[_to]);
require(balanceOf[msg.sender] > 0);
require(balanceOf[msg.sender] >= _value);
require(_to != address(0));
require(_value > 0);
require(balanceOf[_to] .add(_value) >= balanceOf[_to]);
require(_to != msg.sender);
balanceOf[msg.sender] = balanceOf[msg.sender].sub(_value);
balanceOf[_to] = balanceOf[_to].add(_value);
emit Transfer(msg.sender, _to, _value);
return true;
}
function transferFrom(
address _from,
address _to,
uint256 _amount
) public returns (bool success)
{
require(balanceOf[_from] >= _amount);
require(allowed[_from][msg.sender] >= _amount);
require(_amount > 0);
require(_to != address(0));
require(_to != msg.sender);
balanceOf[_from] = balanceOf[_from].sub(_amount);
allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_amount);
balanceOf[_to] = balanceOf[_to].add(_amount);
return true;
}
function approve(address _spender, uint256 _amount) public returns (bool success) {
require(_spender != msg.sender);
allowed[msg.sender][_spender] = _amount;
emit Approval(msg.sender, _spender, _amount);
return true;
}
function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
return allowed[_owner][_spender];
}
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
contract RailzToken is Owned, ERC20 {
using SafeMath for uint256;
uint256  tokenSupply = 2000000000;
event Burn(address from, uint256 value);
function RailzToken()
ERC20 (tokenSupply,"Railz","RLZ") public
{
owner = msg.sender;
}
function mintTokens(uint256 _mintedAmount) public onlyOwner {
balanceOf[owner] = balanceOf[owner].add(_mintedAmount);
totalSupply = totalSupply.add(_mintedAmount);
Transfer(0, owner, _mintedAmount);
}
function burn(uint256 _value) public onlyOwner {
require(_value <= balanceOf[msg.sender]);
address burner = msg.sender;
balanceOf[burner] = balanceOf[burner].sub(_value);
totalSupply = totalSupply.sub(_value);
Burn(burner, _value);
}
function lockAccount(address _target) public onlyOwner {
require(_target != address(0));
isLockedAccount[_target] = true;
}
function unlockAccount(address _target) public onlyOwner {
require(_target != address(0));
isLockedAccount[_target] = false;
}
}