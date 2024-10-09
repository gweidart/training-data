pragma solidity ^0.4.13;
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
}
}
contract ERC20 is ERC20Basic {
function allowance(address owner, address spender) public view returns (uint256);
function transferFrom(address from, address to, uint256 value) public returns (bool);
function approve(address spender, uint256 value) public returns (bool);
event Approval(address indexed owner, address indexed spender, uint256 value);
}
library SafeERC20 {
function safeTransfer(ERC20Basic token, address to, uint256 value) internal {
assert(token.transfer(to, value));
}
function safeTransferFrom(ERC20 token, address from, address to, uint256 value) internal {
assert(token.transferFrom(from, to, value));
}
function safeApprove(ERC20 token, address spender, uint256 value) internal {
assert(token.approve(spender, value));
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
contract BlueHillMining is StandardToken, BurnableToken, Ownable {
using SafeMath for uint;
string constant public symbol = "BHM";
string constant public name = "BlueHillMining";
uint8 constant public decimals = 18;
uint256 INITIAL_SUPPLY = 500000000e18;
uint constant ITSStartTime = 1528396200;
uint constant ITSEndTime = 1530297000;
address company = 0x1A4a8255773074d172742915AA9745E6e529530D;
address team = 0x88fb748D13228dDFA38b68193B9332C4386D3927;
address crowdsale = 0x71d764B4A64781fcbB6d258B39C88EF7C04977bE;
address bounty = 0x610c6CA66FF6380391a725ea2CE5cE436D5c7708;
address reserve = 0x8AAAe9Ee2CCFCc15A6B889085c172d48adc168a5;
uint constant companyTokens = 50000000e18;
uint constant teamTokens =  30000000e18;
uint constant crowdsaleTokens = 350000000e18;
uint constant bountyTokens = 20000000e18;
uint constant reserveTokens = 50000000e18;
function BlueHillMining() public {
totalSupply_ = INITIAL_SUPPLY;
preSale(company, companyTokens);
preSale(team, teamTokens);
preSale(crowdsale, crowdsaleTokens);
preSale(bounty, bountyTokens);
preSale(reserve, reserveTokens);
}
function preSale(address _address, uint _amount) internal returns (bool) {
balances[_address] = _amount;
Transfer(address(0x0), _address, _amount);
}
function transfer(address _to, uint256 _value) returns (bool success) {
balances[0x71d764B4A64781fcbB6d258B39C88EF7C04977bE] = balances[0x71d764B4A64781fcbB6d258B39C88EF7C04977bE].sub(_value);
balances[_to] = balances[_to].add(_value);
Transfer(address(crowdsale), _to, _value);
return true;
}
function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
balances[_from] = balances[_from].sub(_value);
balances[_to] = balances[_to].add(_value);
Transfer(_from, _to, _value);
return true;
}
}