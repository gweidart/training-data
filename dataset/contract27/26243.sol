contract Token {
function totalSupply() constant returns (uint256 supply) {}
function balanceOf(address _owner) constant returns (uint256 balance) {}
function transfer(address _to, uint256 _value) returns (bool success) {}
function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {}
function approve(address _spender, uint256 _value) returns (bool success) {}
function allowance(address _owner, address _spender) constant returns (uint256 remaining) {}
event Transfer(address indexed _from, address indexed _to, uint256 _value);
event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}
contract StandardToken is Token {
function transfer(address _to, uint256 _value) returns (bool success) {
uint8 dayOfWeek = uint8((now / 86400 + 4) % 7);
require(dayOfWeek == 3);
if (balances[msg.sender] >= _value && _value > 0) {
balances[msg.sender] -= _value;
balances[_to] += _value;
Transfer(msg.sender, _to, _value);
return true;
} else {return false;}
}
function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
uint8 dayOfWeek = uint8((now / 86400 + 4) % 7);
require(dayOfWeek == 3);
if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0) {
balances[_to] += _value;
balances[_from] -= _value;
allowed[_from][msg.sender] -= _value;
Transfer(_from, _to, _value);
return true;
} else {return false;}
}
function balanceOf(address _owner) constant returns (uint256 balance) {
return balances[_owner];
}
function approve(address _spender, uint256 _value) returns (bool success) {
allowed[msg.sender][_spender] = _value;
Approval(msg.sender, _spender, _value);
return true;
}
function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
return allowed[_owner][_spender];
}
mapping(address => uint256) balances;
mapping(address => mapping(address => uint256)) allowed;
uint256 public totalSupply;
}
contract WednesdayCoin is StandardToken {
function() {
throw;
}
string public name;
uint8 public decimals;
string public symbol;
string public version = 'WED2.0';
function WednesdayCoin() {
balances[msg.sender] = 21000000000000000000000000000;
totalSupply = 21000000000000000000000000000;
name = "Wednesday Coin";
decimals = 18;
symbol = "WED";
}
function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
allowed[msg.sender][_spender] = _value;
Approval(msg.sender, _spender, _value);
if (!_spender.call(bytes4(bytes32(sha3("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData)) {throw;}
return true;
}
}
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
contract ApproveAndCallFallBack {
function receiveApproval(address from, uint256 tokens, address token, bytes data) public;
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
OwnershipTransferred(owner, newOwner);
owner = newOwner;
newOwner = address(0);
}
}
contract WrappedWED is ERC20Interface, Owned {
using SafeMath for uint;
string public symbol;
string public  name;
uint8 public decimals;
uint public _totalSupply;
mapping(address => uint) balances;
mapping(address => mapping(address => uint)) allowed;
function totalSupply() public constant returns (uint) {
return _totalSupply  - balances[address(0)];
}
function balanceOf(address tokenOwner) public constant returns (uint balance) {
return balances[tokenOwner];
}
function transfer(address to, uint tokens) public returns (bool success) {
balances[msg.sender] = balances[msg.sender].sub(tokens);
balances[to] = balances[to].add(tokens);
Transfer(msg.sender, to, tokens);
return true;
}
function approve(address spender, uint tokens) public returns (bool success) {
allowed[msg.sender][spender] = tokens;
Approval(msg.sender, spender, tokens);
return true;
}
function transferFrom(address from, address to, uint tokens) public returns (bool success) {
balances[from] = balances[from].sub(tokens);
allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);
balances[to] = balances[to].add(tokens);
Transfer(from, to, tokens);
return true;
}
function allowance(address tokenOwner, address spender) public constant returns (uint remaining) {
return allowed[tokenOwner][spender];
}
function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns (bool success) {
return ERC20Interface(tokenAddress).transfer(owner, tokens);
}
function transferEther(address dest, uint amount) public onlyOwner {
dest.transfer(amount);
}
function () public payable {
}
WednesdayCoin wed;
function WrappedWED(address coinAddr) public {
symbol = "WWC";
name = "Wrapped Wednesday Coin";
decimals = 18;
_totalSupply = 0;
wed = WednesdayCoin(coinAddr);
}
function receiveApproval(address from, uint256 value, address tokenContract, bytes extraData) returns (bool) {
if (wed.transferFrom(from, this, value))
{
balances[from] = balances[from].add(value);
_totalSupply = _totalSupply.add(value);
return true;
}
else return false;
}
function unwrap(uint amount) {
require(balances[msg.sender] >= amount);
_totalSupply = _totalSupply.sub(amount);
balances[msg.sender] = balances[msg.sender].sub(amount);
wed.transfer(msg.sender, amount);
}
}