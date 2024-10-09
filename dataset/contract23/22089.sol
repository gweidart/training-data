pragma solidity ^0.4.16;
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
contract Token {
function totalSupply() constant returns (uint256 supply) {}
function balanceOf(address _owner) constant returns (uint256 balance) {}
function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {}
function approve(address _spender, uint256 _value) returns (bool success) {}
function allowance(address _owner, address _spender) constant returns (uint256 remaining) {}
event Transfer(address indexed _from, address indexed _to, uint256 _value);
event Approval(address indexed _owner, address indexed _spender, uint256 _value);
event Burn(address indexed from, uint256 value);
event FrozenFunds(address target, bool frozen);
event TokenFrozen(uint256 _frozenUntilBlock, string _reason);
}
interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) public; }
contract kBit is Token, owned {
uint256 public tokenFrozenUntilBlock;
uint256 public totalSupply;
string public name;
uint8 public decimals;
string public symbol;
string public version = 'H1.0';
mapping (address => uint256) balances;
mapping (address => mapping (address => uint256)) allowed;
mapping (address => bool) public frozenAccount;
function kBit(
) {
balances[msg.sender] = 555000 * 1000000000000000000;
totalSupply = 555000 * 1000000000000000000;
name = "kBit";
decimals = 18;
symbol = "KBIT";
}
function () {
throw;
}
function approveAndCall(address _spender, uint256 _value, bytes _extraData)
public
returns (bool success) {
tokenRecipient spender = tokenRecipient(_spender);
if (approve(_spender, _value)) {
spender.receiveApproval(msg.sender, _value, this, _extraData);
return true;
}
}
function _transfer(address _from, address _to, uint _value) internal {
require (_to != 0x0);
require (balances[_from] >= _value);
require (balances[_to] + _value > balances[_to]);
require(!frozenAccount[_from]);
require(!frozenAccount[_to]);
balances[_from] -= _value;
balances[_to] += _value;
Transfer(_from, _to, _value);
}
function transfer(address _to, uint256 _value) public {
if (block.number < tokenFrozenUntilBlock) throw;
_transfer(msg.sender, _to, _value);
}
function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
if (block.number < tokenFrozenUntilBlock) throw;
require(_value <= allowed[_from][msg.sender]);
allowed[_from][msg.sender] -= _value;
_transfer(_from, _to, _value);
return true;
}
function balanceOf(address _owner) constant returns (uint256 balance) {
return balances[_owner];
}
function approve(address _spender, uint256 _value) public
returns (bool success) {
if (block.number < tokenFrozenUntilBlock) throw;
allowed[msg.sender][_spender] = _value;
return true;
}
function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
return allowed[_owner][_spender];
}
function burn(uint256 _value) public returns (bool success) {
require(balances[msg.sender] >= _value);
balances[msg.sender] -= _value;
totalSupply -= _value;
Burn(msg.sender, _value);
return true;
}
function burnFrom(address _from, uint256 _value) public returns (bool success) {
require(balances[_from] >= _value);
require(_value <= allowed[_from][msg.sender]);
balances[_from] -= _value;
allowed[_from][msg.sender] -= _value;
totalSupply -= _value;
Burn(_from, _value);
return true;
}
function mintToken(address target, uint256 mintedAmount) onlyOwner public {
balances[target] += mintedAmount;
totalSupply += mintedAmount;
Transfer(0, this, mintedAmount);
Transfer(this, target, mintedAmount);
}
function freezeAccount(address target, bool freeze) onlyOwner public {
frozenAccount[target] = freeze;
FrozenFunds(target, freeze);
}
function freezeTransfersUntil(uint256 _frozenUntilBlock, string _reason) onlyOwner {
tokenFrozenUntilBlock = _frozenUntilBlock;
TokenFrozen(_frozenUntilBlock, _reason);
}
}