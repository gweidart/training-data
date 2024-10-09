pragma solidity ^0.4.24;
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
contract Controlled {
address public controller;
modifier onlyController { require(msg.sender == controller); _; }
constructor() public { controller = msg.sender;}
function changeController(address _newController) public onlyController {
controller = _newController;
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
contract SofiaToken is ERC20Interface,Controlled {
using SafeMath for uint;
string public symbol;
string public  name;
uint8 public decimals;
uint public totalSupply;
mapping(address => uint) balances;
mapping(address => mapping(address => uint)) allowed;
constructor(uint _totalSupply) public {
symbol = "SFX";
name = "Sofia Token";
decimals = 18;
totalSupply = _totalSupply.mul(1 ether);
balances[msg.sender] = totalSupply;
emit Transfer(address(0),controller,totalSupply);
}
function totalSupply() public view returns (uint){
return totalSupply;
}
function balanceOf(address tokenOwner) public view returns (uint balance){
return balances[tokenOwner];
}
function allowance(address tokenOwner, address spender) public view returns (uint remaining){
if (allowed[tokenOwner][spender] < balances[tokenOwner]) {
return allowed[tokenOwner][spender];
}
return balances[tokenOwner];
}
function transfer(address to, uint tokens) public  returns (bool success){
return doTransfer(msg.sender,to,tokens);
}
function transferFrom(address from, address to, uint tokens) public returns (bool success){
if(allowed[from][msg.sender] > 0 && allowed[from][msg.sender] >= tokens)
{
allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);
return doTransfer(from,to,tokens);
}
return false;
}
function doTransfer(address from,address to, uint tokens) internal returns (bool success){
if( tokens > 0 && balances[from] >= tokens){
balances[from] = balances[from].sub(tokens);
balances[to] = balances[to].add(tokens);
emit Transfer(from,to,tokens);
return true;
}
return false;
}
function approve(address spender, uint tokens) public returns (bool success){
if(balances[msg.sender] >= tokens){
allowed[msg.sender][spender] = tokens;
emit Approval(msg.sender,spender,tokens);
return true;
}
return false;
}
function () public payable {
revert();
}
function burn(uint _value) public onlyController{
require(_value <= balances[msg.sender]);
balances[msg.sender] = balances[msg.sender].sub(_value);
totalSupply = totalSupply.sub(_value);
emit Burn(msg.sender, _value);
emit Transfer(msg.sender, address(0), _value);
}
event Transfer(address indexed from, address indexed to, uint tokens);
event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
event Burn(address indexed burner, uint value);
}