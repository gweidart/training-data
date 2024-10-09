pragma solidity ^0.4.18;
library SafeMath {
function mul(uint256 a, uint256 b) internal pure returns (uint256) {
uint256 c = a * b;
assert(a == 0 || c / a == b);
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
contract owned {
address public owner;
function owned() public {
owner = msg.sender;
}
modifier onlyOwner {
require(msg.sender == owner);
_;
}
function transferOwnership(address newOwner) onlyOwner public {
owner = newOwner;
}
}
interface tokenRecipient {
function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) public;
}
contract ERC20 {
function balanceOf(address _to) public constant returns (uint256);
function transfer(address to, uint256 value) public;
function transferFrom(address from, address to, uint256 value) public;
function approve(address spender, uint256 value) public;
function allowance(address owner, address spender) public constant returns(uint256);
event Transfer(address indexed from, address indexed to, uint256 value);
event Approval(address indexed owner, address indexed spender, uint256 value);
}
contract StandardToken is ERC20{
using SafeMath for uint256;
mapping (address => uint256) balances;
mapping (address => mapping(address => uint256)) allowed;
function balanceOf(address _to) public constant returns (uint256) {
return balances[_to];
}
function transfer(address to, uint256 value) public {
require (
balances[msg.sender] >= value && value > 0
);
balances[msg.sender] = balances[msg.sender].sub(value);
balances[to] = balances[to].add(value);
Transfer(msg.sender, to, value);
}
function transferFrom(address from, address to, uint256 value) public {
require (
allowed[from][msg.sender] >= value && balances[from] >= value && value > 0
);
balances[from] = balances[from].sub(value);
balances[to] = balances[to].add(value);
allowed[from][msg.sender] = allowed[from][msg.sender].sub(value);
Transfer(from, to, value);
}
function approve(address spender, uint256 value) public {
require (
balances[msg.sender] >= value && value > 0
);
allowed[msg.sender][spender] = value;
Approval(msg.sender, spender, value);
}
function allowance(address _owner, address spender) public constant returns (uint256) {
return allowed[_owner][spender];
}
}
contract TokenMoney is owned,StandardToken {
string public name = "TokenMoney";
string public symbol = "TOM";
uint8 public decimals = 18;
uint256 public totalSupply;
uint256 public initialSupply;
string public version = "v1.0";
mapping (address => uint256) public balanceOf;
mapping (address => mapping (address => uint256)) public allowance;
event Transfer(address indexed from, address indexed to, uint256 value);
function TokenMoney() public {
initialSupply = 3600000;
totalSupply = initialSupply * 10 ** uint256(decimals);
balanceOf[msg.sender] = totalSupply;
}
function _transfer(address _from, address _to, uint _value) internal {
require(_to != 0x0);
require(balanceOf[_from] >= _value);
require(balanceOf[_to] + _value > balanceOf[_to]);
uint previousBalances = balanceOf[_from] + balanceOf[_to];
balanceOf[_from] -= _value;
balanceOf[_to] += _value;
Transfer(_from, _to, _value);
assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
}
function transfer(address _to, uint256 _value) public {
_transfer(msg.sender, _to, _value);
}
}