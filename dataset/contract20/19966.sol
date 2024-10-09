pragma solidity ^0.4.17;
library SafeMath {
function add(uint a, uint b) internal pure returns (uint c) {
c = a + b;
require(c >= a);
}
function sub(uint a, uint b) internal pure returns (uint c) {
require(b <= a);
c = a - b;
}
function mul(uint a, uint b) internal pure returns (uint c) {
c = a * b;
require(a == 0 || c / a == b);
}
function div(uint a, uint b) internal pure returns (uint c) {
require(b > 0);
c = a / b;
}
}
contract ERC20Interface {
function totalSupply() public constant returns (uint);
function balanceOf(address tokenOwner) public constant returns (uint balance);
function allowance(address tokenOwner, address spender) public constant returns (uint remaining);
function transfer(address to, uint tokens) public returns (bool success);
function approve(address spender, uint tokens) public returns (bool success);
function transferFrom(address from, address to, uint tokens) public returns (bool success);
event Transfer(address indexed from, address indexed to, uint tokens);
event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}
contract Owned {
address public owner;
event OwnershipTransferred(address indexed _from, address indexed _to);
function Owned() public {
owner = msg.sender;
}
modifier onlyOwner {
require(msg.sender == owner);
_;
}
function transferOwnership(address _newOwner) public onlyOwner {
require(_newOwner != address(0x0));
emit OwnershipTransferred(owner,_newOwner);
owner = _newOwner;
}
}
contract NVCTToken is ERC20Interface, Owned {
using SafeMath for uint;
string public symbol;
string public  name;
uint8 public decimals;
uint public _totalSupply;
mapping(address => uint) balances;
mapping(address => mapping(address => uint)) allowed;
event Burn(address indexed burner, uint256 value);
function NVCTToken() public {
symbol = "NVCT";
name = "nVision Cash token";
decimals = 18;
_totalSupply = 850000000 * 10**uint(decimals);
balances[owner] = _totalSupply;
emit Transfer(address(0), owner, _totalSupply);
}
function() public payable {
revert();
}
function totalSupply() public constant returns (uint) {
return _totalSupply;
}
function balanceOf(address tokenOwner) public constant returns (uint balance) {
return balances[tokenOwner];
}
function transfer(address to, uint tokens) public returns (bool success) {
if(balances[msg.sender] >= tokens && tokens > 0 && to!=address(0)) {
balances[msg.sender] = balances[msg.sender].sub(tokens);
balances[to] = balances[to].add(tokens);
emit Transfer(msg.sender, to, tokens);
return true;
} else { return false; }
}
function approve(address spender, uint tokens) public returns (bool success) {
if(tokens > 0 && spender != address(0)) {
allowed[msg.sender][spender] = tokens;
emit Approval(msg.sender, spender, tokens);
return true;
} else { return false; }
}
function transferFrom(address from, address to, uint tokens) public returns (bool success) {
if (balances[from] >= tokens && allowed[from][msg.sender] >= tokens && tokens > 0) {
balances[from] = balances[from].sub(tokens);
allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);
balances[to] = balances[to].add(tokens);
emit Transfer(from, to, tokens);
return true;
} else { return false; }
}
function allowance(address tokenOwner, address spender) public constant returns (uint remaining) {
return allowed[tokenOwner][spender];
}
function burn(uint256 _value) onlyOwner public {
require(_value > 0);
require(_value <= balances[msg.sender]);
address burner = msg.sender;
balances[burner] = balances[burner].sub(_value);
_totalSupply = _totalSupply.sub(_value);
emit Burn(burner, _value);
emit Transfer(burner, address(0), _value);
}
}