pragma solidity ^0.4.17;
library SafeMath {
function mul(uint a, uint b) internal pure returns (uint) {
uint c = a * b;
assert(a == 0 || c / a == b);
return c;
}
function div(uint a, uint b) internal pure returns (uint) {
uint c = a / b;
return c;
}
function sub(uint a, uint b) internal pure returns (uint) {
assert(b <= a);
return a - b;
}
function add(uint a, uint b) internal pure returns (uint) {
uint c = a + b;
assert(c >= a);
return c;
}
}
contract Ownable {
address public owner;
event OwnershipTransferred(address from, address to);
function Ownable() public {
owner = msg.sender;
}
modifier onlyOwner {
require(msg.sender == owner);
_;
}
function transferOwnership(address _newOwner) public onlyOwner {
require(_newOwner != 0x0);
OwnershipTransferred(owner, _newOwner);
owner = _newOwner;
}
}
contract ERC20Basic {
uint public totalSupply;
function balanceOf(address who) public constant returns (uint);
function transfer(address to, uint value) public;
event Transfer(address indexed from, address indexed to, uint value);
}
contract ERC20 is ERC20Basic {
function allowance(address owner, address spender) public constant returns (uint);
function transferFrom(address from, address to, uint value) public;
function approve(address spender, uint value) public;
event Approval(address indexed owner, address indexed spender, uint value);
}
contract BasicToken is ERC20Basic, Ownable {
using SafeMath for uint;
mapping(address => uint) balances;
modifier onlyPayloadSize(uint size) {
if (msg.data.length < size + 4) {
revert();
}
_;
}
function transfer(address _to, uint _value) public onlyPayloadSize(2 * 32) {
balances[msg.sender] = balances[msg.sender].sub(_value);
balances[_to] = balances[_to].add(_value);
Transfer(msg.sender, _to, _value);
}
function balanceOf(address _owner) public constant returns (uint balance) {
return balances[_owner];
}
}
contract StandardToken is BasicToken, ERC20 {
mapping (address => mapping (address => uint256)) allowances;
function transferFrom(address _from, address _to, uint256 _amount) public onlyPayloadSize(3 * 32) {
require(allowances[_from][msg.sender] >= _amount && balances[_from] >= _amount);
allowances[_from][msg.sender] = allowances[_from][msg.sender].sub(_amount);
balances[_from] = balances[_from].sub(_amount);
balances[_to] = balances[_to].add(_amount);
Transfer(_from, _to, _amount);
}
function approve(address _spender, uint256 _amount) public {
require((_amount == 0) || (allowances[msg.sender][_spender] == 0));
allowances[msg.sender][_spender] = _amount;
Approval(msg.sender, _spender, _amount);
}
function allowance(address _owner, address _spender) public constant returns (uint256) {
return allowances[_owner][_spender];
}
}
contract MintableToken is StandardToken {
event Mint(address indexed to, uint256 amount);
event MintFinished();
bool public mintingFinished = false;
modifier canMint() {
require(!mintingFinished);
_;
}
function mint(address _to, uint256 _amount) public onlyOwner canMint onlyPayloadSize(2 * 32) returns (bool) {
totalSupply = totalSupply.add(_amount);
balances[_to] = balances[_to].add(_amount);
Mint(_to, _amount);
Transfer(0x0, _to, _amount);
return true;
}
function finishMinting() public onlyOwner returns (bool) {
mintingFinished = true;
MintFinished();
return true;
}
}
contract Ethercloud is MintableToken {
uint8 public decimals;
string public name;
string public symbol;
function Ethercloud() public {
totalSupply = 0;
decimals = 18;
name = "Ethercloud";
symbol = "ETCL";
}
}