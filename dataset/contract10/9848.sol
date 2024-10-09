pragma solidity ^0.4.24;
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
interface ERC20 {
function name()
external
view
returns (string _name);
function symbol()
external
view
returns (string _symbol);
function decimals()
external
view
returns (uint8 _decimals);
function totalSupply()
external
view
returns (uint256 _totalSupply);
function balanceOf(
address _owner
)
external
view
returns (uint256 _balance);
function transfer(
address _to,
uint256 _value
)
external
returns (bool _success);
function transferFrom(
address _from,
address _to,
uint256 _value
)
external
returns (bool _success);
function approve(
address _spender,
uint256 _value
)
external
returns (bool _success);
function allowance(
address _owner,
address _spender
)
external
view
returns (uint256 _remaining);
event Transfer(
address indexed _from,
address indexed _to,
uint256 _value
);
event Approval(
address indexed _owner,
address indexed _spender,
uint256 _value
);
}
contract Token is ERC20
{
using SafeMath for uint256;
string internal tokenName;
string internal tokenSymbol;
uint8 internal tokenDecimals;
uint256 internal tokenTotalSupply;
mapping (address => uint256) internal balances;
mapping (address => mapping (address => uint256)) internal allowed;
event Transfer(
address indexed _from,
address indexed _to,
uint256 _value
);
event Approval(
address indexed _owner,
address indexed _spender,
uint256 _value
);
function name()
external
view
returns (string _name)
{
_name = tokenName;
}
function symbol()
external
view
returns (string _symbol)
{
_symbol = tokenSymbol;
}
function decimals()
external
view
returns (uint8 _decimals)
{
_decimals = tokenDecimals;
}
function totalSupply()
external
view
returns (uint256 _totalSupply)
{
_totalSupply = tokenTotalSupply;
}
function balanceOf(
address _owner
)
external
view
returns (uint256 _balance)
{
_balance = balances[_owner];
}
function transfer(
address _to,
uint256 _value
)
public
returns (bool _success)
{
require(_value <= balances[msg.sender]);
balances[msg.sender] = balances[msg.sender].sub(_value);
balances[_to] = balances[_to].add(_value);
emit Transfer(msg.sender, _to, _value);
_success = true;
}
function approve(
address _spender,
uint256 _value
)
public
returns (bool _success)
{
require((_value == 0) || (allowed[msg.sender][_spender] == 0));
allowed[msg.sender][_spender] = _value;
emit Approval(msg.sender, _spender, _value);
_success = true;
}
function allowance(
address _owner,
address _spender
)
external
view
returns (uint256 _remaining)
{
_remaining = allowed[_owner][_spender];
}
function transferFrom(
address _from,
address _to,
uint256 _value
)
public
returns (bool _success)
{
require(_value <= balances[_from]);
require(_value <= allowed[_from][msg.sender]);
balances[_from] = balances[_from].sub(_value);
balances[_to] = balances[_to].add(_value);
allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
emit Transfer(_from, _to, _value);
_success = true;
}
}
contract CYC is Token {
constructor()
public
{
tokenName = "ChangeYourCoin";
tokenSymbol = "CYC";
tokenDecimals = 0;
tokenTotalSupply = 15000000;
balances[msg.sender] = tokenTotalSupply;
}
}