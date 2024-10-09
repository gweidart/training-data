pragma solidity ^0.4.23;
interface BurnableTokenInterface {
event TokensBurned(address indexed _triggerer, address indexed _from, uint256 _tokens);
function burnTokens(uint256 _tokens) external;
}
interface ContractManagerInterface {
event ContractAdded(address indexed _address, string _contractName);
event ContractRemoved(string _contractName);
event ContractUpdated(address indexed _oldAddress, address indexed _newAddress, string _contractName);
event AuthorizationChanged(address indexed _address, bool _authorized, string _contractName);
function authorize(string _contractName, address _accessor) external view returns (bool);
function addContract(string _contractName, address _address) external;
function getContract(string _contractName) external view returns (address _contractAddress);
function removeContract(string _contractName) external;
function updateContract(string _contractName, address _newAddress) external;
function setAuthorizedContract(string _contractName, address _authorizedAddress, bool _authorized) external;
}
interface MintableTokenInterface {
event TokensMinted(address indexed _from, address indexed _to, uint256 _tokens);
event DepositAddressChanged(address indexed _old, address indexed _new);
function mintTokens(uint256 _tokens) external;
function sendBoughtTokens(address _beneficiary, uint256 _tokens) external;
function changeDepositAddress(address _depositAddress) external;
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
function totalSupply() public view returns (uint256);
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
contract BasicToken is ERC20Basic, ERC20 {
using SafeMath for uint256;
mapping(address => uint256) balances;
mapping (address => mapping (address => uint256)) internal allowed;
uint256 totalSupply_;
bool public locked = true;
event TokensUnlocked();
function totalSupply() public view returns (uint256) {
return totalSupply_;
}
function transfer(address _to, uint256 _value) public returns (bool) {
require(!locked);
_transfer(msg.sender, _to, _value);
}
function _transfer(address _from, address _to, uint256 _value) internal returns (bool) {
require(_from != address(0));
require(_to != address(0));
require(_value <= balances[_from]);
balances[_from] = balances[_from].sub(_value);
balances[_to] = balances[_to].add(_value);
emit Transfer(_from, _to, _value);
return true;
}
function balanceOf(address _owner) public view returns (uint256 balance) {
return balances[_owner];
}
function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
require(!locked);
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
require(!locked);
allowed[msg.sender][_spender] = _value;
emit Approval(msg.sender, _spender, _value);
return true;
}
function allowance(address _owner, address _spender) public view returns (uint256) {
require(!locked);
return allowed[_owner][_spender];
}
function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
require(!locked);
allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
return true;
}
function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
require(!locked);
uint oldValue = allowed[msg.sender][_spender];
if (_subtractedValue > oldValue) {
allowed[msg.sender][_spender] = 0;
} else {
allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
}
emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
return true;
}
function unlockTokens() public {
require(locked);
locked = false;
emit TokensUnlocked();
}
}
contract MintableToken is MintableTokenInterface, BasicToken {
address public depositAddress;
string public contractName;
ContractManagerInterface internal contractManager;
constructor(address _depositAddress, string _contractName, address _contractManager) public {
depositAddress = _depositAddress;
contractName = _contractName;
contractManager = ContractManagerInterface(_contractManager);
}
function mintTokens(uint256 _tokens) external {
require(!locked);
require(contractManager.authorize(contractName, msg.sender));
require(_tokens != 0);
totalSupply_ = totalSupply_.add(_tokens);
balances[depositAddress] = balances[depositAddress].add(_tokens);
emit TokensMinted(msg.sender, depositAddress, _tokens);
}
function sendBoughtTokens(address _beneficiary, uint256 _tokens) external {
require(locked);
require(contractManager.authorize(contractName, msg.sender));
require(_beneficiary != address(0));
require(_tokens != 0);
totalSupply_ = totalSupply_.add(_tokens);
balances[depositAddress] = balances[depositAddress].add(_tokens);
emit TokensMinted(msg.sender, depositAddress, _tokens);
_transfer(depositAddress, _beneficiary, _tokens);
}
function changeDepositAddress(address _depositAddress) external {
require(contractManager.authorize(contractName, msg.sender));
require(_depositAddress != address(0));
require(_depositAddress != depositAddress);
address oldDepositAddress = depositAddress;
depositAddress = _depositAddress;
emit DepositAddressChanged(oldDepositAddress, _depositAddress);
}
}
contract BurnableToken is BurnableTokenInterface, MintableToken {
constructor(address _depositAddress, string _contractName, address _contractManager) public MintableToken(_depositAddress, _contractName, _contractManager) {
}
function burnTokens(uint256 _tokens) external {
require(!locked);
require(contractManager.authorize(contractName, msg.sender));
require(depositAddress != address(0));
require(_tokens != 0);
require(_tokens <= balances[depositAddress]);
balances[depositAddress] = balances[depositAddress].sub(_tokens);
totalSupply_ = totalSupply_.sub(_tokens);
emit TokensBurned(msg.sender, depositAddress, _tokens);
}
}
contract FidaToken is BurnableToken {
string public name = "fida";
string public symbol = "fida";
uint8 public decimals = 18;
constructor(address _depositAddress, string _contractName, address _contractManager) public BurnableToken(_depositAddress, _contractName, _contractManager) {}
function unlockTokens() public {
require(contractManager.authorize(contractName, msg.sender));
BasicToken.unlockTokens();
}
}