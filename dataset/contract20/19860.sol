pragma solidity ^0.4.21;
contract ERC20Basic {
uint256 public totalSupply;
function balanceOf(address who) public view returns (uint256);
function transfer(address to, uint256 value) public returns (bool);
event Transfer(address indexed from, address indexed to, uint256 value);
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
contract MintableToken is StandardToken, Ownable {
uint public totalSupply = 0;
address private minter;
bool public mintingEnabled = true;
modifier onlyMinter() {
require(minter == msg.sender);
_;
}
function setMinter(address _minter) public onlyOwner {
minter = _minter;
}
function mint(address _to, uint _amount) public onlyMinter {
require(mintingEnabled);
totalSupply = totalSupply.add(_amount);
balances[_to] = balances[_to].add(_amount);
Transfer(address(0x0), _to, _amount);
}
function stopMinting() public onlyMinter {
mintingEnabled = false;
}
}
contract ERC23 is ERC20Basic {
function transfer(address to, uint value, bytes data) public;
event TransferData(address indexed from, address indexed to, uint value, bytes data);
}
contract ERC23PayableReceiver {
function tokenFallback(address _from, uint _value, bytes _data) public payable;
}
contract ERC23PayableToken is BasicToken, ERC23 {
function transfer(address to, uint value, bytes data) public {
transferAndPay(to, value, data);
}
function transfer(address to, uint value) public returns (bool) {
bytes memory empty;
transfer(to, value, empty);
return true;
}
function transferAndPay(address to, uint value, bytes data) public payable {
uint codeLength;
assembly {
codeLength := extcodesize(to)
}
balances[msg.sender] = balances[msg.sender].sub(value);
balances[to] = balances[to].add(value);
if (codeLength > 0) {
ERC23PayableReceiver receiver = ERC23PayableReceiver(to);
receiver.tokenFallback.value(msg.value)(msg.sender, value, data);
}else if (msg.value > 0) {
to.transfer(msg.value);
}
Transfer(msg.sender, to, value);
if (data.length > 0)
TransferData(msg.sender, to, value, data);
}
}
contract EtherusToken is MintableToken, ERC23PayableToken {
string public constant name = "EtherusToken";
string public constant symbol = "ETR";
uint public constant decimals = 18;
bool public transferEnabled = false;
uint private constant CAP = 15*(10**6)*(10**decimals);
function EtherusToken(address multisigOwner) public {
transferOwnership(multisigOwner);
}
function mint(address _to, uint _amount) public {
require(totalSupply.add(_amount) <= CAP);
super.mint(_to, _amount);
}
function transferAndPay(address to, uint value, bytes data) public payable {
require(transferEnabled);
super.transferAndPay(to, value, data);
}
function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
require(transferEnabled);
return super.transferFrom(_from, _to, _value);
}
function enableTransfer(bool enabled) public onlyOwner {
transferEnabled = enabled;
}
function withdrawFrom(address from) private {
uint tokens = balanceOf(from);
require(tokens > 0);
balances[from] = 0;
totalSupply = totalSupply.sub(tokens);
from.transfer(tokens);
Transfer(from, 0, tokens);
}
function withdraw() public {
withdrawFrom(msg.sender);
}
function withdrawFor(address to) public onlyOwner {
withdrawFrom(to);
}
function withdrawForMany(address[] tos) public onlyOwner {
for(uint i=0; i<tos.length; ++i){
withdrawFrom(tos[i]);
}
}
function () public payable {
}
}