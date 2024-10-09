pragma solidity ^0.4.18;
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
contract Ownable {
address public owner;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
function Ownable() public{
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
contract BusinessCreditStop is Ownable{
bool public stopped;
modifier stoppable {
assert (!stopped);
_;
}
function stop() public onlyOwner {
stopped = true;
}
function start()  public onlyOwner {
stopped = false;
}
}
contract ERC20 {
function totalSupply() public view returns (uint256);
function balanceOf( address _owner ) public view returns (uint256);
function allowance( address owner, address spender )public view returns (uint256);
function transfer(address to, uint256 value) public returns (bool);
function transferFrom( address from, address to, uint256 value)public returns (bool);
function approve( address spender, uint256 value )public returns (bool);
event Transfer( address indexed from, address indexed to, uint256 value);
event Approval( address indexed owner, address indexed spender, uint256 value);
}
contract BusinessCreditTokenBase is ERC20,BusinessCreditStop {
using SafeMath for uint256;
uint256                                                     _supply;
mapping (address => uint256)                                _balances;
mapping (address => mapping (address => uint256)) internal  _approvals;
function totalSupply() public view returns (uint256) {
return _supply;
}
function balanceOf(address _owner) public view returns (uint256 balance) {
return _balances[_owner];
}
function allowance(address _owner, address _spender)  public view returns (uint256) {
return _approvals[_owner][_spender];
}
function transfer(address _to, uint256 _value) stoppable public returns (bool) {
require(_value <= _balances[msg.sender]);
_balances[msg.sender] = _balances[msg.sender].sub(_value);
_balances[_to] = _balances[_to].add(_value);
Transfer(msg.sender, _to, _value);
return true;
}
function transferFrom(address _from, address _to, uint256 _value) stoppable public returns (bool) {
require(_value <= _balances[_from]);
require(_value <= _approvals[_from][msg.sender]);
_balances[_from] = _balances[_from].sub(_value);
_balances[_to] = _balances[_to].add(_value);
_approvals[_from][msg.sender] = _approvals[_from][msg.sender].sub(_value);
Transfer(_from, _to, _value);
return true;
}
function approve(address _spender, uint256 _value) stoppable public returns (bool) {
_approvals[msg.sender][_spender] = _value;
Approval(msg.sender, _spender, _value);
return true;
}
}
contract BusinessCreditToken is BusinessCreditTokenBase{
string  public name = "Business Credit Token";
uint8   public decimals = 18;
string  public symbol = 'BCT';
string  public version = 'v0.1';
uint256 supply = 100000000 * 100 * 10 ** 18;
function BusinessCreditToken() public{
_balances[msg.sender] = supply;
_supply = supply;
}
modifier burnStopped() {
require(_balances[0x0] <= 100000000 * 90 * 10 ** 18);
_;
}
function burn(uint256 _value) onlyOwner stoppable burnStopped public {
require(_balances[msg.sender] >= _value);
_balances[msg.sender] = _balances[msg.sender].sub(_value);
_balances[0x0] = _balances[0x0].add(_value);
Transfer(msg.sender, 0x0, _value);
}
function burnBalance() onlyOwner public view returns (uint256) {
return _balances[0x0];
}
function increaseApproval(address _spender, uint256 _addedValue) stoppable public returns (bool) {
_approvals[msg.sender][_spender] = _approvals[msg.sender][_spender].add(_addedValue);
Approval(msg.sender, _spender, _approvals[msg.sender][_spender]);
return true;
}
function decreaseApproval(address _spender, uint256 _subtractedValue) stoppable public returns (bool) {
uint256 oldValue = _approvals[msg.sender][_spender];
if (_subtractedValue > oldValue) {
_approvals[msg.sender][_spender] = 0;
}
else {
_approvals[msg.sender][_spender] = oldValue.sub(_subtractedValue);
}
Approval(msg.sender, _spender, _approvals[msg.sender][_spender]);
return true;
}
}