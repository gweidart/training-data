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
contract ERC20Basic {
uint256 public totalSupply;
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
contract BasicToken is ERC20Basic {
using SafeMath for uint256;
mapping(address => uint256) balances;
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
contract Releasable is Ownable {
event Release();
bool public released = false;
modifier afterReleased() {
require(released);
_;
}
function release() onlyOwner public {
require(!released);
released = true;
Release();
}
}
contract Managed is Releasable {
mapping (address => bool) public manager;
event SetManager(address _addr);
event UnsetManager(address _addr);
function Managed() public {
manager[msg.sender] = true;
}
modifier onlyManager() {
require(manager[msg.sender]);
_;
}
function setManager(address _addr) public onlyOwner {
require(_addr != address(0) && manager[_addr] == false);
manager[_addr] = true;
SetManager(_addr);
}
function unsetManager(address _addr) public onlyOwner {
require(_addr != address(0) && manager[_addr] == true);
manager[_addr] = false;
UnsetManager(_addr);
}
}
contract ReleasableToken is StandardToken, Managed {
function transfer(address _to, uint256 _value) public afterReleased returns (bool) {
return super.transfer(_to, _value);
}
function saleTransfer(address _to, uint256 _value) public onlyManager returns (bool) {
return super.transfer(_to, _value);
}
function transferFrom(address _from, address _to, uint256 _value) public afterReleased returns (bool) {
return super.transferFrom(_from, _to, _value);
}
function approve(address _spender, uint256 _value) public afterReleased returns (bool) {
return super.approve(_spender, _value);
}
function increaseApproval(address _spender, uint _addedValue) public afterReleased returns (bool success) {
return super.increaseApproval(_spender, _addedValue);
}
function decreaseApproval(address _spender, uint _subtractedValue) public afterReleased returns (bool success) {
return super.decreaseApproval(_spender, _subtractedValue);
}
}
contract BurnableToken is ReleasableToken {
event Burn(address indexed burner, uint256 value);
function burn(uint256 _value) onlyManager public {
require(_value > 0);
require(_value <= balances[msg.sender]);
address burner = msg.sender;
balances[burner] = balances[burner].sub(_value);
totalSupply = totalSupply.sub(_value);
Burn(burner, _value);
}
}
contract GanaToken is BurnableToken {
string public constant name = "GANA";
string public constant symbol = "GANA";
uint8 public constant decimals = 18;
event ClaimedTokens(address manager, address _token, uint256 claimedBalance);
function GanaToken() public {
totalSupply = 2400000000 * 1 ether;
balances[msg.sender] = totalSupply;
}
function claimTokens(address _token, uint256 _claimedBalance) public onlyManager afterReleased {
ERC20Basic token = ERC20Basic(_token);
uint256 tokenBalance = token.balanceOf(this);
require(tokenBalance >= _claimedBalance);
address manager = msg.sender;
token.transfer(manager, _claimedBalance);
ClaimedTokens(manager, _token, _claimedBalance);
}
}
contract GanaTokenLocker {
GanaToken gana;
uint256 public releaseTime = 1554076800;
address public owner;
event Unlock();
function GanaTokenLocker(address _gana, address _owner) public {
require(_owner != address(0));
owner = _owner;
gana = GanaToken(_gana);
}
function unlock() public {
require(msg.sender == owner);
require(releaseTime < now);
uint256 unlockGana = gana.balanceOf(this);
gana.transfer(owner, unlockGana);
Unlock();
}
}