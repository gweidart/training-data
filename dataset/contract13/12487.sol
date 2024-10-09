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
event Approval(address indexed owner, address indexed spender, uint256 value);
}
contract Ownable {
address public owner;
function Ownable() public {
owner = msg.sender;
}
modifier onlyOwner() {
require(msg.sender == owner);
_;
}
function transferOwnership(address newOwner) onlyOwner public {
require(newOwner != address(0));
OwnershipTransferred(owner, newOwner);
owner = newOwner;
}
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
}
contract Pausable is Ownable {
bool public paused = false;
modifier running {
require(!paused);
_;
}
function pause() onlyOwner public {
paused = true;
}
function start() onlyOwner public {
paused = false;
}
}
contract BasicToken is ERC20Basic {
using SafeMath for uint256;
mapping(address => uint256) balances;
uint256 totalSupply_;
function totalSupply() public view returns (uint256) {
return totalSupply_;
}
function transfer(address _to, uint256 _value) public returns (bool) {
require(_to != address(0));
require(_value > 0 && _value <= balances[msg.sender]);
require(balances[_to].add(_value) > balances[_to]);
balances[msg.sender] = balances[msg.sender].sub(_value);
balances[_to] = balances[_to].add(_value);
Transfer(msg.sender, _to, _value);
return true;
}
function balanceOf(address _owner) public view returns (uint256 balance) {
return balances[_owner];
}
}
contract StandardToken is ERC20, BasicToken, Pausable {
mapping (address => mapping (address => uint256)) internal allowed;
mapping (address => bool) public frozen;
function transfer(address _to, uint256 _value) public running returns (bool) {
require(!frozen[_to] && !frozen[msg.sender]);
return super.transfer(_to, _value);
}
function transferFrom(address _from, address _to, uint256 _value) public running returns (bool) {
require(_to != address(0));
require(!frozen[_to] && !frozen[_from]);
require(_value <= balances[_from]);
require(_value > 0 && _value <= allowed[_from][msg.sender]);
require(balances[_to].add(_value) > balances[_to]);
balances[_from] = balances[_from].sub(_value);
balances[_to] = balances[_to].add(_value);
allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
Transfer(_from, _to, _value);
return true;
}
function approve(address _spender, uint256 _value) public running returns (bool) {
require(!frozen[_spender] && !frozen[msg.sender]);
allowed[msg.sender][_spender] = _value;
Approval(msg.sender, _spender, _value);
return true;
}
function allowance(address _owner, address _spender) public view returns (uint256) {
return allowed[_owner][_spender];
}
function burn(uint256 _value) public running onlyOwner returns (bool) {
require(_value > 0);
require(balances[msg.sender] > _value);
balances[msg.sender] = balances[msg.sender].sub(_value);
totalSupply_ = totalSupply_.sub(_value);
Burn(msg.sender, _value);
return true;
}
function mint(uint256 _value) public running onlyOwner returns (bool) {
require(_value > 0);
require(balances[msg.sender].add(_value) > balances[msg.sender]);
require(totalSupply_.add(_value) > totalSupply_);
balances[msg.sender] = balances[msg.sender].add(_value);
totalSupply_ = totalSupply_.add(_value);
return true;
}
function lock(address _addr) public running onlyOwner returns (bool) {
require(_addr != address(0));
frozen[_addr] = true;
Frozen(_addr, true);
return true;
}
function unlock(address _addr) public running onlyOwner returns (bool) {
require(_addr != address(0));
require(frozen[_addr]);
frozen[_addr] = false;
Frozen(_addr, false);
return true;
}
event Burn(address indexed from, uint256 value);
event Frozen(address indexed target, bool status);
}
contract BbeCoin is StandardToken {
string public constant name = "BbeCoin";
string public constant symbol = "BBE";
uint8 public constant decimals = 18;
uint256 public constant INITIAL_SUPPLY = 12 * (10 ** 8) * (10 ** uint256(decimals));
function BbeCoin() public {
totalSupply_ = INITIAL_SUPPLY;
balances[msg.sender] = INITIAL_SUPPLY;
Transfer(0x0, msg.sender, INITIAL_SUPPLY);
}
}