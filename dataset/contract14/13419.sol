pragma solidity ^0.4.21;
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
contract ContractReceiver {
function tokenFallback(address _from, uint _value, bytes _data) public pure {
}
function doTransfer(address _to, uint256 _index) public returns (uint256 price, address owner);
}
contract Owned {
address public owner;
address public newOwner;
event OwnershipTransferred(address indexed _from, address indexed _to);
function Owned() public {
owner = msg.sender;
}
modifier onlyOwner {
require(msg.sender == owner);
_;
}
function transferOwnership(address _newOwner) public onlyOwner {
newOwner = _newOwner;
}
function acceptOwnership() public {
require(msg.sender == newOwner);
emit OwnershipTransferred(owner, newOwner);
owner = newOwner;
newOwner = address(0);
}
}
contract ERC20Interface {
function totalSupply() public view returns (uint);
function balanceOf(address tokenOwner) public constant returns (uint);
function allowance(address tokenOwner, address spender) public constant returns (uint);
function transfer(address to, uint tokens) public returns (bool);
function approve(address spender, uint tokens) public returns (bool);
function transferFrom(address from, address to, uint tokens) public returns (bool);
function name() public view returns (string);
function symbol() public view returns (string);
function decimals() public view returns (uint8);
event Transfer(address indexed from, address indexed to, uint tokens);
event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}
contract ERC223 is ERC20Interface {
function transfer(address to, uint value, bytes data) public returns (bool);
event Transfer(address indexed from, address indexed to, uint tokens);
event Transfer(address indexed from, address indexed to, uint value, bytes data);
}
contract NeoWorldCash is ERC223, Owned {
using SafeMath for uint256;
mapping(address => uint) balances;
mapping(address => mapping(address => uint)) allowed;
string public name;
string public symbol;
uint8 public decimals;
uint256 public totalSupply;
event Burn(address indexed from, uint256 value);
function NeoWorldCash() public {
symbol = "NASH";
name = "NEOWORLD CASH";
decimals = 18;
totalSupply = 100000000000 * 10**uint(decimals);
balances[msg.sender] = totalSupply;
emit Transfer(address(0), msg.sender, totalSupply, "");
}
function name() public view returns (string) {
return name;
}
function symbol() public view returns (string) {
return symbol;
}
function decimals() public view returns (uint8) {
return decimals;
}
function totalSupply() public view returns (uint256) {
return totalSupply;
}
function transfer(address _to, uint _value, bytes _data) public returns (bool) {
if(isContract(_to)) {
return transferToContract(_to, _value, _data);
}
else {
return transferToAddress(_to, _value, _data);
}
}
function transfer(address _to, uint _value) public returns (bool) {
bytes memory empty;
if(isContract(_to)) {
return transferToContract(_to, _value, empty);
}
else {
return transferToAddress(_to, _value, empty);
}
}
function isContract(address _addr) private view returns (bool) {
uint length;
assembly {
length := extcodesize(_addr)
}
return (length>0);
}
function transferToAddress(address _to, uint _value, bytes _data) private returns (bool) {
if (balanceOf(msg.sender) < _value) revert();
balances[msg.sender] = balanceOf(msg.sender).sub(_value);
balances[_to] = balanceOf(_to).add(_value);
emit Transfer(msg.sender, _to, _value);
emit Transfer(msg.sender, _to, _value, _data);
return true;
}
function transferToContract(address _to, uint _value, bytes _data) private returns (bool) {
ContractReceiver receiver = ContractReceiver(_to);
uint256 price;
address owner;
(price, owner) = receiver.doTransfer(msg.sender, bytesToUint(_data));
if (balanceOf(msg.sender) < price) revert();
balances[msg.sender] = balanceOf(msg.sender).sub(price);
balances[owner] = balanceOf(owner).add(price);
receiver.tokenFallback(msg.sender, price, _data);
emit Transfer(msg.sender, _to, _value);
emit Transfer(msg.sender, _to, _value, _data);
return true;
}
function balanceOf(address _owner) public view returns (uint) {
return balances[_owner];
}
function burn(uint256 _value) public returns (bool) {
require (_value > 0);
require (balanceOf(msg.sender) >= _value);
balances[msg.sender] = balanceOf(msg.sender).sub(_value);
totalSupply = totalSupply.sub(_value);
emit Burn(msg.sender, _value);
return true;
}
function bytesToUint(bytes b) private pure returns (uint result) {
uint i;
result = 0;
for (i = 0; i < b.length; i++) {
uint c = uint(b[i]);
if (c >= 48 && c <= 57) {
result = result * 10 + (c - 48);
}
}
}
function approve(address spender, uint tokens) public returns (bool) {
allowed[msg.sender][spender] = tokens;
emit Approval(msg.sender, spender, tokens);
return true;
}
function transferFrom(address from, address to, uint tokens) public returns (bool) {
balances[from] = balances[from].sub(tokens);
allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);
balances[to] = balances[to].add(tokens);
emit Transfer(from, to, tokens);
return true;
}
function allowance(address tokenOwner, address spender) public constant returns (uint) {
return allowed[tokenOwner][spender];
}
function () public payable {
revert();
}
function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns (bool) {
return ERC20Interface(tokenAddress).transfer(owner, tokens);
}
}