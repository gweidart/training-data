pragma solidity ^0.4.21;
library AddressUtils {
function isContract(address addr) internal view returns (bool) {
uint256 size;
assembly { size := extcodesize(addr) }
return size > 0;
}
}
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
return a / b;
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
emit Transfer(msg.sender, _to, _value);
return true;
}
function balanceOf(address _owner) public view returns (uint256 balance) {
return balances[_owner];
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
emit Transfer(_from, _to, _value);
return true;
}
function approve(address _spender, uint256 _value) public returns (bool) {
allowed[msg.sender][_spender] = _value;
emit Approval(msg.sender, _spender, _value);
return true;
}
function allowance(address _owner, address _spender) public view returns (uint256) {
return allowed[_owner][_spender];
}
function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
return true;
}
function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
uint oldValue = allowed[msg.sender][_spender];
if (_subtractedValue > oldValue) {
allowed[msg.sender][_spender] = 0;
} else {
allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
}
emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
return true;
}
}
contract Receiver {
function tokenFallback(address from, uint value) public;
}
contract FallBackToken is StandardToken {
function transfer(address _to, uint256 _value) public returns (bool) {
require(super.transfer(_to, _value));
if (AddressUtils.isContract(_to)) {
Receiver(_to).tokenFallback(msg.sender, _value);
}
return true;
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
emit OwnershipTransferred(owner, newOwner);
owner = newOwner;
}
}
contract Freezable is Ownable {
event FrozenFunds(address target, bool freeze);
mapping(address => bool) freezeHolders;
function isFreezeAccount(address _holderAddress) public view returns (bool) {
return freezeHolders[_holderAddress];
}
modifier whenNotFrozen(address _holderAddress) {
require(!freezeHolders[_holderAddress]);
_;
}
modifier whenFrozen(address _holderAddress) {
require(freezeHolders[_holderAddress]);
_;
}
function freezeAccount(address target, bool freeze) onlyOwner public {
require(target != address(0));
freezeHolders[target] = freeze;
emit FrozenFunds(target, freeze);
}
}
contract FreezableToken is StandardToken, Freezable {
function transfer(address _to, uint256 _value) public  whenNotFrozen(msg.sender) whenNotFrozen(_to) returns (bool) {
return super.transfer(_to, _value);
}
function transferFrom(address _from, address _to, uint256 _value) public whenNotFrozen(msg.sender) whenNotFrozen(_to) whenNotFrozen(_from) returns (bool) {
return super.transferFrom(_from, _to, _value);
}
function approve(address _spender, uint256 _value) public whenNotFrozen(_spender) whenNotFrozen(msg.sender) returns (bool) {
return super.approve(_spender, _value);
}
function increaseApproval(address _spender, uint _addedValue) public whenNotFrozen(msg.sender) whenNotFrozen(_spender) returns (bool success) {
return super.increaseApproval(_spender, _addedValue);
}
function decreaseApproval(address _spender, uint _subtractedValue) public whenNotFrozen(msg.sender) whenNotFrozen(_spender) returns (bool success) {
return super.decreaseApproval(_spender, _subtractedValue);
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
emit Mint(_to, _amount);
emit Transfer(address(0), _to, _amount);
return true;
}
function finishMinting() onlyOwner canMint public returns (bool) {
mintingFinished = true;
emit MintFinished();
return true;
}
}
contract ReleasableToken is MintableToken {
bool public released = false;
event Release();
modifier isReleased () {
require(mintingFinished);
require(released);
_;
}
function release() public onlyOwner returns (bool) {
require(mintingFinished);
require(!released);
released = true;
emit Release();
return true;
}
function transfer(address _to, uint256 _value) public isReleased returns (bool) {
return super.transfer(_to, _value);
}
function transferFrom(address _from, address _to, uint256 _value) public isReleased returns (bool) {
return super.transferFrom(_from, _to, _value);
}
function approve(address _spender, uint256 _value) public isReleased returns (bool) {
return super.approve(_spender, _value);
}
function increaseApproval(address _spender, uint _addedValue) public isReleased returns (bool success) {
return super.increaseApproval(_spender, _addedValue);
}
function decreaseApproval(address _spender, uint _subtractedValue) public isReleased returns (bool success) {
return super.decreaseApproval(_spender, _subtractedValue);
}
}
contract ApprovalReceiver {
function receiveApproval(address from, uint value, address tokenContract, bytes extraData) public returns (bool);
}
contract StandardTokenWithCall is StandardToken {
function approveAndCall(address _spender, uint256 _value, bytes _extraData) public returns (bool success) {
assert(approve(_spender, _value));
return ApprovalReceiver(_spender).receiveApproval(msg.sender, _value, this, _extraData);
}
}
contract BCoinToken is StandardTokenWithCall, ReleasableToken, FreezableToken, FallBackToken {
string public constant name = "BCOIN";
string public constant symbol = "BCOIN";
uint256 public constant decimals = 2;
}