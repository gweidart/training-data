pragma solidity ^0.4.23;
contract ERC20Basic {
function totalSupply() public view returns (uint256);
function balanceOf(address who) public view returns(uint256);
function transfer(address to, uint256 value) public returns (bool);
event Transfer(address indexed from, address indexed to, uint256 value);
}
library SafeMath {
function mul(uint256 a, uint256 b) internal pure returns (uint256){
if(a==0){
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
function sub(uint256 a, uint256 b) internal pure returns (uint256){
assert(b <= a);
return a - b;
}
function add(uint256 a, uint256 b) internal pure returns (uint256){
uint256 c = a + b;
assert(c >= a);
return c;
}
}
contract BasicToken is ERC20Basic {
using SafeMath for uint256;
mapping(address => uint256) internal balances;
uint256 internal totalSupply_;
function totalSupply() public view returns (uint256) {
return totalSupply_;
}
function transfer (address _to, uint256 _value) public returns (bool){
require(_to != address(0));
require(_value <= balances[msg.sender]);
balances[msg.sender] = balances[msg.sender].sub(_value);
balances[_to] = balances[_to].add(_value);
emit Transfer(msg.sender, _to, _value);
return true;
}
function balanceOf(address _owner) public view returns(uint256 balance){
return balances[_owner];
}
}
contract BurnableToken is BasicToken {
event Burn(address indexed burner, uint256 value);
function burn(uint256 _value) public {
_burn(msg.sender, _value);
}
function _burn(address _who, uint256 _value) internal {
require(_value <= balances[_who]);
balances[_who] = balances[_who].sub(_value);
totalSupply_ = totalSupply_.sub(_value);
emit Burn(_who, _value);
emit Transfer(_who, address(0), _value);
}
}
contract DRToken is BurnableToken {
string public constant name = "DrawingRun";
string public constant symbol = "DR";
uint8 public constant decimals = 18;
uint256 public totalSupply;
constructor() public{
totalSupply = 30000000000 * 10**uint256(decimals);
balances[msg.sender] = totalSupply;
}
}