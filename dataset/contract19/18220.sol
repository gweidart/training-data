pragma solidity ^0.4.21;
library SafeMath {
function mul(uint256 a, uint256 b) internal pure returns (uint256) {
if (a == 0) {
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
contract BasicToken is ERC20Basic {
using SafeMath for uint256;
mapping(address => uint256) balances;
uint256 totalSupply_;
function totalSupply() public view returns (uint256) {
return totalSupply_;
}
function transfer(address _to, uint256 _value) public returns (bool) {
require(_to != address(0));
require(_value <= balances[msg.sender]);
balances[msg.sender] = balances[msg.sender].sub(_value);
balances[_to] = balances[_to].add(_value);
Transfer(msg.sender, _to, _value);
return true;
}
function balanceOf(address _owner) public view returns (uint256 balance) {
return balances[_owner];
}
}
contract BurnableToken is BasicToken {
event Burn(address indexed burner, uint256 value);
function burn(uint256 _value) public {
require(_value <= balances[msg.sender]);
address burner = msg.sender;
balances[burner] = balances[burner].sub(_value);
totalSupply_ = totalSupply_.sub(_value);
Burn(burner, _value);
Transfer(burner, address(0), _value);
}
}
contract Ownable {
address public owner;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
function Ownable() public {
owner = msg.sender;
}
modifier onlyOwner() {
require(msg.sender == owner);
_;
}
function transferOwnership(address newOwner) public onlyOwner {
require(newOwner != address(0));
OwnershipTransferred(owner, newOwner);
owner = newOwner;
}
}
contract ERC20 is ERC20Basic {
function allowance(address owner, address spender) public view returns (uint256);
function transferFrom(address from, address to, uint256 value) public returns (bool);
function approve(address spender, uint256 value) public returns (bool);
event Approval(address indexed owner, address indexed spender, uint256 value);
}
contract StandardToken is ERC20, BasicToken {
mapping (address => mapping (address => uint256)) internal allowed;
function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
require(_to != address(0));
require(_value <= balances[_from]);
require(_value <= allowed[_from][msg.sender]);
balances[_from] = balances[_from].sub(_value);
balances[_to] = balances[_to].add(_value);
allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
Transfer(_from, _to, _value);
return true;
}
function approve(address _spender, uint256 _value) public returns (bool) {
allowed[msg.sender][_spender] = _value;
Approval(msg.sender, _spender, _value);
return true;
}
function allowance(address _owner, address _spender) public view returns (uint256) {
return allowed[_owner][_spender];
}
function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
return true;
}
function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
uint oldValue = allowed[msg.sender][_spender];
if (_subtractedValue > oldValue) {
allowed[msg.sender][_spender] = 0;
} else {
allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
}
Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
return true;
}
}
contract MintableToken is StandardToken, Ownable {
event Mint(address indexed to, uint256 amount);
event MintFinished();
bool public mintingFinished = false;
modifier canMint() {
require(!mintingFinished);
_;
}
function mint(address _to, uint256 _amount) onlyOwner canMint public returns (bool) {
totalSupply_ = totalSupply_.add(_amount);
balances[_to] = balances[_to].add(_amount);
Mint(_to, _amount);
Transfer(address(0), _to, _amount);
return true;
}
function finishMinting() onlyOwner canMint public returns (bool) {
mintingFinished = true;
MintFinished();
return true;
}
}
contract CappedToken is MintableToken {
uint256 public cap;
function CappedToken(uint256 _cap) public {
require(_cap > 0);
cap = _cap;
}
function mint(address _to, uint256 _amount) onlyOwner canMint public returns (bool) {
require(totalSupply_.add(_amount) <= cap);
return super.mint(_to, _amount);
}
}
contract ERC827 is ERC20 {
function approve( address _spender, uint256 _value, bytes _data ) public returns (bool);
function transfer( address _to, uint256 _value, bytes _data ) public returns (bool);
function transferFrom( address _from, address _to, uint256 _value, bytes _data ) public returns (bool);
}
contract ERC827Token is ERC827, StandardToken {
function approve(address _spender, uint256 _value, bytes _data) public returns (bool) {
require(_spender != address(this));
super.approve(_spender, _value);
require(_spender.call(_data));
return true;
}
function transfer(address _to, uint256 _value, bytes _data) public returns (bool) {
require(_to != address(this));
super.transfer(_to, _value);
require(_to.call(_data));
return true;
}
function transferFrom(address _from, address _to, uint256 _value, bytes _data) public returns (bool) {
require(_to != address(this));
super.transferFrom(_from, _to, _value);
require(_to.call(_data));
return true;
}
function increaseApproval(address _spender, uint _addedValue, bytes _data) public returns (bool) {
require(_spender != address(this));
super.increaseApproval(_spender, _addedValue);
require(_spender.call(_data));
return true;
}
function decreaseApproval(address _spender, uint _subtractedValue, bytes _data) public returns (bool) {
require(_spender != address(this));
super.decreaseApproval(_spender, _subtractedValue);
require(_spender.call(_data));
return true;
}
}
contract AbstractQuintessenceToken is CappedToken, ERC827Token, BurnableToken {
string public name = "Quintessence Token";
string public symbol = "QST";
function AbstractQuintessenceToken(uint256 initial_supply, uint256 _cap)
CappedToken(_cap) public {
mint(msg.sender, initial_supply);
}
}
contract QuintessenceToken is AbstractQuintessenceToken {
uint256 public constant decimals = 18;
uint256 public constant TOKEN_CAP = 56000000 * (10 ** decimals);
uint256 public constant TEAM_SUPPLY = (TOKEN_CAP * 4) / 100;
function QuintessenceToken() AbstractQuintessenceToken(TEAM_SUPPLY, TOKEN_CAP) public {
}
}