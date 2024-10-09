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
contract BitkomToken is StandardToken, Ownable {
string  public constant name = "Bitkom Token";
string  public constant symbol = "BTT";
uint8   public constant decimals = 18;
uint256 public constant INITIAL_SUPPLY = 50000000 * 1 ether;
uint256 public constant CROWDSALE_ALLOWANCE =  33500000 * 1 ether;
uint256 public constant TEAM_ALLOWANCE =  16500000 * 1 ether;
uint256 public crowdsaleAllowance;
uint256 public teamAllowance;
address public crowdsaleAddr;
address public teamAddr;
bool    public transferEnabled = false;
modifier onlyWhenTransferEnabled() {
if (!transferEnabled) {
require(msg.sender == teamAddr || msg.sender == crowdsaleAddr);
}
_;
}
event Burn(address indexed burner, uint256 value);
modifier validDestination(address _to) {
require(_to != address(0x0));
require(_to != address(this));
require(_to != owner);
require(_to != address(teamAddr));
require(_to != address(crowdsaleAddr));
_;
}
function BitkomToken(address _team) public {
require(msg.sender != _team);
totalSupply = INITIAL_SUPPLY;
crowdsaleAllowance = CROWDSALE_ALLOWANCE;
teamAllowance = TEAM_ALLOWANCE;
balances[msg.sender] = totalSupply;
Transfer(address(0x0), msg.sender, totalSupply);
teamAddr = _team;
approve(teamAddr, teamAllowance);
}
function setCrowdsale(address _crowdsaleAddr, uint256 _amountForSale) external onlyOwner {
require(!transferEnabled);
require(_amountForSale <= crowdsaleAllowance);
uint amount = (_amountForSale == 0) ? crowdsaleAllowance : _amountForSale;
approve(crowdsaleAddr, 0);
approve(_crowdsaleAddr, amount);
crowdsaleAddr = _crowdsaleAddr;
}
function enableTransfer() external onlyOwner {
transferEnabled = true;
approve(crowdsaleAddr, 0);
approve(teamAddr, 0);
crowdsaleAllowance = 0;
teamAllowance = 0;
}
function transfer(address _to, uint256 _value) public onlyWhenTransferEnabled validDestination(_to) returns (bool) {
return super.transfer(_to, _value);
}
function transferFrom(address _from, address _to, uint256 _value) public onlyWhenTransferEnabled validDestination(_to) returns (bool) {
bool result = super.transferFrom(_from, _to, _value);
if (result) {
if (msg.sender == crowdsaleAddr)
crowdsaleAllowance = crowdsaleAllowance.sub(_value);
if (msg.sender == teamAddr)
teamAllowance = teamAllowance.sub(_value);
}
return result;
}
function burn(uint256 _value) public {
require(_value > 0);
require(_value <= balances[msg.sender]);
require(transferEnabled || msg.sender == owner);
address burner = msg.sender;
balances[burner] = balances[burner].sub(_value);
totalSupply = totalSupply.sub(_value);
Burn(burner, _value);
Transfer(msg.sender, address(0x0), _value);
}
}