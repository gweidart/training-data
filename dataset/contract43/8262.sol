pragma solidity ^0.4.24;
contract ERC20_CRYPTOMILLION_CPMN {
string internal _name;
string internal _symbol;
uint8 internal _decimals;
uint256 internal _totalSupply;
mapping (address => uint256) internal balances;
mapping (address => mapping (address => uint256)) internal allowed;
event Transfer(address indexed from, address indexed to, uint256 value);
event Approval(address indexed owner, address indexed spender, uint256 value);
function CreateTokenERC20(string name, string symbol, uint8 decimals, uint256 totalSupply) public {
_symbol = symbol;
_name = name;
_decimals = decimals;
_totalSupply = totalSupply;
balances[msg.sender] = totalSupply;
}
function name() public view returns (string)
{
return _name;
}
function symbol()
public
view
returns (string) {
return _symbol;
}
function decimals()
public
view
returns (uint8) {
return _decimals;
}
function totalSupply()
public
view
returns (uint256) {
return _totalSupply;
}
function mul(uint256 a, uint256 b) internal pure returns (uint256)
{
if (a == 0)
return 0;
uint256 c = a * b;
assert(c / a == b);
return c;
}
function div(uint256 a, uint256 b) internal pure returns (uint256)
{
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
function transfer(address _to, uint256 _value) public returns (bool) {
require(_to != address(0));
require(_value <= balances[msg.sender]);
balances[msg.sender] = sub(balances[msg.sender], _value);
balances[_to] = add(balances[_to], _value);
emit Transfer(msg.sender, _to, _value);
return true;
}
function balanceOf(address _owner) public view returns (uint256 balance) {
return balances[_owner];
}
function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
require(_to != address(0));
require(_value <= balances[_from]);
require(_value <= allowed[_from][msg.sender]);
balances[_from] = sub(balances[_from], _value);
balances[_to] = add(balances[_to], _value);
allowed[_from][msg.sender] = sub(allowed[_from][msg.sender], _value);
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
allowed[msg.sender][_spender] = add(allowed[msg.sender][_spender], _addedValue);
emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
return true;
}
function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
uint oldValue = allowed[msg.sender][_spender];
if (_subtractedValue > oldValue) {
allowed[msg.sender][_spender] = 0;
} else {
allowed[msg.sender][_spender] = sub(oldValue, _subtractedValue);
}
emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
return true;
}
}