pragma solidity ^0.4.23;
library SafeMath {
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
contract ERC20Basic {
function totalSupply() public view returns (uint256);
function balanceOf(address who) public view returns (uint256);
function transfer(address to, uint256 value) public returns (bool);
event Transfer(address indexed from, address indexed to, uint256 value);
}
contract ERC20 is ERC20Basic {
function allowance(address owner, address spender) public view returns (uint256);
function transferFrom(address from, address to, uint256 value) public returns (bool);
function approve(address spender, uint256 value) public returns (bool);
event Approval( address indexed owner, address indexed spender, uint256 value );
}
contract BasicToken is ERC20Basic {
using SafeMath for uint256;
mapping(address => uint256) internal balances;
uint256 internal totalSupply_;
function totalSupply() public view returns (uint256) {
return totalSupply_;
}
function transfer(address _to, uint256 _value) public returns (bool) {
require(_to != address(0));
require(_value <= balances[msg.sender]);
balances[msg.sender] = balances[msg.sender].sub(_value);
balances[_to] = balances[_to].add(_value);
emit Transfer(msg.sender, _to, _value);
return true;
}
function balanceOf(address _owner) public view returns (uint256) {
return balances[_owner];
}
}
contract StandardToken is ERC20, BasicToken {
mapping (address => mapping (address => uint256)) internal allowed;
function transferFrom( address _from, address _to, uint256 _value ) public returns (bool) {
require(_to != address(0));
require(_value <= balances[_from]);
require(_value <= allowed[_from][msg.sender]);
balances[_from] = balances[_from].sub(_value);
balances[_to] = balances[_to].add(_value);
allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
emit Transfer(_from, _to, _value);
return true;
}
function approve(address _spender, uint256 _value) public returns (bool) {
allowed[msg.sender][_spender] = _value;
emit Approval(msg.sender, _spender, _value);
return true;
}
function allowance( address _owner, address _spender ) public view returns (uint256) {
return allowed[_owner][_spender];
}
}
contract ShowCoinToken is StandardToken {
string public name;
string public symbol;
uint8 public decimals;
constructor( address initialAccount ) public {
name = "ShowCoin2.0";
symbol = "Show";
decimals = 18;
totalSupply_ = 1e28;
balances[initialAccount] = 9e27;
emit Transfer(address(0), initialAccount, 9e27);
balances[0xC9BA6e5Eda033c66D34ab64d02d14590963Ce0c2]=totalSupply_.sub(balances[initialAccount]);
emit Transfer(address(0), 0xC9BA6e5Eda033c66D34ab64d02d14590963Ce0c2, totalSupply_.sub(balances[initialAccount]));
}
}