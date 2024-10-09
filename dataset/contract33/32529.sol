library SafeMath {
function mul(uint256 a, uint256 b)
internal
pure
returns (uint256)
{
uint256 c = a * b;
require(a == 0 || c / a == b);
return c;
}
function div(uint256 a, uint256 b)
internal
pure
returns (uint256)
{
uint256 c = a / b;
return c;
}
function sub(uint256 a, uint256 b)
internal
pure
returns (uint256)
{
require(b <= a);
return a - b;
}
function add(uint256 a, uint256 b)
internal
pure
returns (uint256)
{
uint256 c = a + b;
require(c >= a);
return c;
}
}
contract Token {
event Transfer(address indexed from, address indexed to, uint256 value);
event Approval(address indexed owner, address indexed spender, uint256 value);
function transfer(address to, uint256 value) public returns (bool);
function transferFrom(address from, address to, uint256 value) public returns (bool);
function approve(address spender, uint256 value) public returns (bool);
function balanceOf(address owner) public constant returns (uint256);
function allowance(address owner, address spender) public constant returns (uint256);
uint256 public totalSupply;
}
contract StandardToken is Token {
using SafeMath for uint256;
mapping (address => uint256) public balances;
mapping (address => mapping (address => uint256)) public allowances;
uint256 public totalSupply;
function transfer(address to, uint256 value)
public
returns (bool)
{
require(to != address(0));
require(value <= balances[msg.sender]);
balances[msg.sender] = balances[msg.sender].sub(value);
balances[to] = balances[to].add(value);
Transfer(msg.sender, to, value);
return true;
}
function transferFrom(address from, address to, uint256 value)
public
returns (bool)
{
require(to != address(0));
require(value <= balances[from]);
require(value <= allowances[from][msg.sender]);
balances[to] = balances[to].add(value);
balances[from] = balances[from].sub(value);
allowances[from][msg.sender] = allowances[from][msg.sender].sub(value);
Transfer(from, to, value);
return true;
}
function approve(address _spender, uint256 value)
public
returns (bool success)
{
require((value == 0) || (allowances[msg.sender][_spender] == 0));
allowances[msg.sender][_spender] = value;
Approval(msg.sender, _spender, value);
return true;
}
function increaseApproval(address _spender, uint _addedValue)
public
returns (bool)
{
allowances[msg.sender][_spender] = allowances[msg.sender][_spender].add(_addedValue);
Approval(msg.sender, _spender, allowances[msg.sender][_spender]);
return true;
}
function decreaseApproval(address _spender, uint _subtractedValue)
public
returns (bool)
{
uint oldValue = allowances[msg.sender][_spender];
if (_subtractedValue > oldValue) {
allowances[msg.sender][_spender] = 0;
} else {
allowances[msg.sender][_spender] = oldValue.sub(_subtractedValue);
}
Approval(msg.sender, _spender, allowances[msg.sender][_spender]);
return true;
}
function allowance(address _owner, address _spender)
public
constant
returns (uint256)
{
return allowances[_owner][_spender];
}
function balanceOf(address _owner)
public
constant
returns (uint256)
{
return balances[_owner];
}
}
contract Balehubuck is StandardToken {
using SafeMath for uint256;
string public constant name = "balehubuck";
string public constant symbol = "BUX";
uint8 public constant decimals = 18;
uint256 public constant TOTAL_SUPPLY = 1000000000 * 10**18;
uint256 public constant TOKEN_SALE_ALLOCATION = 199125000 * 10**18;
uint256 public constant WALLET_ALLOCATION = 800875000 * 10**18;
function Balehubuck(address wallet)
public
{
totalSupply = TOTAL_SUPPLY;
balances[msg.sender] = TOKEN_SALE_ALLOCATION;
balances[wallet] = WALLET_ALLOCATION;
require(TOKEN_SALE_ALLOCATION + WALLET_ALLOCATION == TOTAL_SUPPLY);
}
}