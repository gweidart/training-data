pragma solidity ^0.4.18;
contract SafeMath {
function SafeMath() {
}
function safeAdd(uint256 _x, uint256 _y) internal returns (uint256) {
uint256 z = _x + _y;
assert(z >= _x);
return z;
}
function safeSub(uint256 _x, uint256 _y) internal returns (uint256) {
assert(_x >= _y);
return _x - _y;
}
function safeMul(uint256 _x, uint256 _y) internal returns (uint256) {
uint256 z = _x * _y;
assert(_x == 0 || z / _x == _y);
return z;
}
}
contract ERC20Token is SafeMath {
string public constant standard = 'Token 0.1';
uint8 public constant decimals = 18;
string public constant name = 'Apollo Operating System';
string public constant symbol = 'AOS';
uint256 public totalSupply = 10**9 * 10**uint256(decimals);
mapping (address => uint256) public balanceOf;
mapping (address => mapping (address => uint256)) public allowance;
event Transfer(address indexed _from, address indexed _to, uint256 _value);
event Approval(address indexed _owner, address indexed _spender, uint256 _value);
function ERC20Token() public {
balanceOf[msg.sender] = totalSupply;
}
modifier validAddress(address _address) {
require(_address != 0x0);
_;
}
function transfer(address _to, uint256 _value)
public
validAddress(_to)
returns (bool success)
{
balanceOf[msg.sender] = safeSub(balanceOf[msg.sender], _value);
balanceOf[_to] = safeAdd(balanceOf[_to], _value);
Transfer(msg.sender, _to, _value);
return true;
}
function transferFrom(address _from, address _to, uint256 _value)
public
validAddress(_from)
validAddress(_to)
returns (bool success)
{
allowance[_from][msg.sender] = safeSub(allowance[_from][msg.sender], _value);
balanceOf[_from] = safeSub(balanceOf[_from], _value);
balanceOf[_to] = safeAdd(balanceOf[_to], _value);
Transfer(_from, _to, _value);
return true;
}
function approve(address _spender, uint256 _value)
public
validAddress(_spender)
returns (bool success)
{
require(_value == 0 || allowance[msg.sender][_spender] == 0);
allowance[msg.sender][_spender] = _value;
Approval(msg.sender, _spender, _value);
return true;
}
function () public payable {
revert();
}
}