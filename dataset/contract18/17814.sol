pragma solidity 0.4.21;
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
function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
return allowed[_owner][_spender];
}
function increaseApproval (address _spender, uint _addedValue) public returns (bool success) {
allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
return true;
}
function decreaseApproval (address _spender, uint _subtractedValue) public returns (bool success) {
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
contract BurnableToken is StandardToken {
event Burn(address indexed burner, uint256 value);
function burn(uint256 _value) public {
require(_value > 0);
require(_value <= balances[msg.sender]);
address burner = msg.sender;
balances[burner] = balances[burner].sub(_value);
totalSupply_ = totalSupply_.sub(_value);
emit Burn(burner, _value);
}
}
contract Owned {
address public owner;
function Owned() public {
owner = msg.sender;
}
modifier onlyOwner {
require(msg.sender == owner);
_;
}
}
contract LigerToken is BurnableToken {
string public constant name = "LIGER";
string public constant symbol = "LIC";
uint8 public constant decimals = 18;
uint256 public constant HARD_CAP = 2700000000 * 10**uint256(decimals);
address public ligerAdminAddress;
address public teamTokensAddress;
address public advisorsTokensAddress;
address public saleTokensAddress;
address public bountyTokensAddress;
mapping(address => bool) public whitelisted;
bool public tradingOpen = false;
modifier onlyAdmin {
require(msg.sender == ligerAdminAddress);
_;
}
function LigerToken(address _ligerAdminAddress, address _teamTokensAddress, address _advisorsTokensAddress,
address _saleTokensAddress, address _bountyTokensAddress) public {
require(_ligerAdminAddress != address(0));
require(_teamTokensAddress != address(0));
require(_advisorsTokensAddress != address(0));
require(_saleTokensAddress != address(0));
require(_bountyTokensAddress != address(0));
ligerAdminAddress = _ligerAdminAddress;
teamTokensAddress = _teamTokensAddress;
advisorsTokensAddress = _advisorsTokensAddress;
saleTokensAddress = _saleTokensAddress;
bountyTokensAddress = _bountyTokensAddress;
whitelisted[saleTokensAddress] = true;
whitelisted[bountyTokensAddress] = true;
uint256 saleTokens = 2025000000 * 10**uint256(decimals);
totalSupply_ = saleTokens;
balances[saleTokensAddress] = saleTokens;
uint256 teamTokens = 405000000 * 10**uint256(decimals);
totalSupply_ = totalSupply_.add(teamTokens);
balances[teamTokensAddress] = teamTokens;
uint256 advisorsTokens = 135000000 * 10**uint256(decimals);
totalSupply_ = totalSupply_.add(advisorsTokens);
balances[advisorsTokensAddress] = advisorsTokens;
uint256 bountyTokens = 135000000 * 10**uint256(decimals);
totalSupply_ = totalSupply_.add(bountyTokens);
balances[bountyTokensAddress] = bountyTokens;
require(totalSupply_ <= HARD_CAP);
}
function whitelist(address _address) external onlyAdmin {
whitelisted[_address] = true;
}
function openTrading() external onlyAdmin {
tradingOpen = true;
}
function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
if(tradingOpen || whitelisted[msg.sender]) {
return super.transferFrom(_from, _to, _value);
}
return false;
}
function transfer(address _to, uint256 _value) public returns (bool) {
if(tradingOpen || whitelisted[msg.sender]) {
return super.transfer(_to, _value);
}
return false;
}
}