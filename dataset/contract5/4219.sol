pragma solidity ^0.4.18;
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
uint256 public totalSupply;
function balanceOf(address who) public view returns (uint256);
function transfer(address to, uint256 value) public returns (bool);
event Transfer(address indexed from, address indexed to, uint256 value);
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
contract MintableToken is StandardToken, Ownable {
event Mint(address indexed to, uint256 amount);
event MintFinished();
bool public mintingFinished = false;
modifier canMint() {
require(!mintingFinished);
_;
}
function mint(address _to, uint256 _amount) onlyOwner canMint public returns (bool) {
totalSupply = totalSupply.add(_amount);
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
contract BurnableToken is BasicToken {
event Burn(address indexed burner, uint256 value);
function burn(uint256 _value) public {
_burn(msg.sender, _value);
}
function _burn(address _who, uint256 _value) internal {
require(_value <= balances[_who]);
balances[_who] = balances[_who].sub(_value);
totalSupply = totalSupply.sub(_value);
Burn(_who, _value);
Transfer(_who, address(0), _value);
}
}
contract WinToken is MintableToken, BurnableToken {
string public constant name = "Win Token";
string public constant symbol = "WINN";
uint8 public constant decimals = 18;
uint256 public totalAirDrop;
uint256 public eachAirDropAmount = 3999 ether;
bool public airdropFinished = false;
mapping (address => bool) public airDropBlacklist;
mapping (address => bool) public transferBlacklist;
function WinToken() public {
totalSupply = 10000000000 ether;
totalAirDrop = totalSupply * 51 / 100;
balances[msg.sender] = totalSupply - totalAirDrop;
}
modifier canAirDrop() {
require(!airdropFinished);
_;
}
modifier onlyWhitelist() {
require(airDropBlacklist[msg.sender] == false);
_;
}
function airDrop(address _to, uint256 _amount) canAirDrop private returns (bool) {
totalAirDrop = totalAirDrop.sub(_amount);
balances[_to] = balances[_to].add(_amount);
Transfer(address(0), _to, _amount);
if (totalAirDrop <= _amount) {
airdropFinished = true;
}
return true;
}
function inspire(address _to, uint256 _amount) private returns (bool) {
if (!airdropFinished) {
if(_amount > totalAirDrop){
_amount = totalAirDrop;
}
totalAirDrop = totalAirDrop.sub(_amount);
balances[_to] = balances[_to].add(_amount);
Transfer(address(0), _to, _amount);
if(totalAirDrop <= _amount){
airdropFinished = true;
}
}
return true;
}
function getAirDropTokens() payable canAirDrop onlyWhitelist public {
require(eachAirDropAmount <= totalAirDrop);
address investor = msg.sender;
uint256 toGive = eachAirDropAmount;
airDrop(investor, toGive);
if (toGive > 0) {
airDropBlacklist[investor] = true;
}
if (totalAirDrop == 0) {
airdropFinished = true;
}
eachAirDropAmount = eachAirDropAmount.sub(0.0012 ether);
}
function getInspireTokens(address _from, address _to,uint256 _amount) payable public{
uint256 toGive = eachAirDropAmount * 50 / 100;
if (_amount > 0 && transferBlacklist[_from] == false) {
transferBlacklist[_from] = true;
inspire(_from, toGive);
}
if(_amount > 0 && transferBlacklist[_to] == false) {
inspire(_to, toGive);
}
}
function () external payable {
if (msg.value > 0) {
owner.transfer(msg.value);
}
getAirDropTokens();
}
function transfer(address _to, uint256 _value) public returns (bool) {
require(_to != address(0));
require(_value <= balances[msg.sender]);
balances[msg.sender] = balances[msg.sender].sub(_value);
balances[_to] = balances[_to].add(_value);
Transfer(msg.sender, _to, _value);
getInspireTokens(msg.sender, _to, _value);
return true;
}
function withdrawERC20 (address contractAddress, uint256 _amount) onlyOwner public {
ERC20 token = ERC20(contractAddress);
token.transfer(owner, _amount);
}
}