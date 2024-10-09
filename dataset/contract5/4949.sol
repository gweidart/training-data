pragma solidity ^0.4.24;
contract ERC20 {
function name() constant public returns (string);
function symbol() constant public returns (string);
function decimals() constant public returns (uint8);
function totalSupply() constant public returns (uint256);
function balanceOf(address owner) public view returns (uint256);
function transfer(address to, uint256 value) public returns (bool);
function transferFrom(address from, address to, uint256 value) public returns (bool);
function approve(address spender, uint256 value) public returns (bool);
function allowance(address owner, address spender) public view returns (uint256);
event Transfer(address indexed from, address indexed to, uint256 value);
event Approval(address indexed owner, address indexed spender, uint256 value);
}
contract StandardToken is ERC20 {
string  internal _name;
string  internal _symbol;
uint8   internal _decimals;
uint256 internal _totalSupply;
mapping (address => uint256) public balances;
mapping (address => mapping (address => uint256)) internal allowed;
function name() public view returns (string) {
return _name;
}
function symbol() public view returns (string) {
return _symbol;
}
function decimals() public view returns (uint8) {
return _decimals;
}
function totalSupply() public view returns (uint256) {
return _totalSupply;
}
function balanceOf(address _owner) public view returns (uint256) {
return balances[_owner];
}
function transfer(address _to, uint256 _value) public returns (bool) {
if (balances[msg.sender] >= _value && _value > 0) {
balances[msg.sender] -= _value;
balances[_to] += _value;
emit Transfer(msg.sender, _to, _value);
return true;
}
else {
return false;
}
}
function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && balances[_to] + _value > balances[_to]) {
balances[_to] += _value;
balances[_from] -= _value;
allowed[_from][msg.sender] -= _value;
emit Transfer(_from, _to, _value);
return true;
}
else {
return false;
}
}
function approve(address _spender, uint256 _value) public returns (bool) {
allowed[msg.sender][_spender] = _value;
emit Approval(msg.sender, _spender, _value);
return true;
}
function allowance(address _owner, address _spender) public view returns (uint256) {
return allowed[_owner][_spender];
}
}
contract Ownable {
address public owner;
event OwnershipRenounced(address indexed previousOwner);
event OwnershipTransferred(
address indexed previousOwner,
address indexed newOwner
);
constructor() public {
owner = msg.sender;
}
modifier onlyOwner() {
require(msg.sender == owner);
_;
}
function renounceOwnership() public onlyOwner {
emit OwnershipRenounced(owner);
owner = address(0);
}
function transferOwnership(address _newOwner) public onlyOwner {
_transferOwnership(_newOwner);
}
function _transferOwnership(address _newOwner) internal {
require(_newOwner != address(0));
emit OwnershipTransferred(owner, _newOwner);
owner = _newOwner;
}
}
contract Mintable is StandardToken {
event Issuance(uint256 _amount);
function issue(address _to, uint256 _amount)
internal
{
_totalSupply = _totalSupply + _amount;
balances[_to] = balances[_to] + _amount;
emit Issuance(_amount);
emit Transfer(this, _to, _amount);
}
}
contract EthereumGAS is Mintable, Ownable {
function transfer(address _to, uint256 _value)
public
returns (bool)
{
super.transfer(_to, _value);
super.issue(msg.sender, gasleft());
}
uint256 addPrice = 10 ether;
mapping (address => bool) public listContracts;
constructor() public {
_name = "Ethereum GAS";
_symbol = "EGAS";
_decimals = 18;
_totalSupply = 1000000000*(10**uint256(_decimals));
balances[msg.sender] = _totalSupply;
}
function mintEGAS() internal {
balances[msg.sender] = balances[msg.sender] + gasleft();
_totalSupply = _totalSupply + gasleft();
emit Transfer(this, msg.sender, gasleft());
}
function setPrice(uint256 _price) public onlyOwner {
addPrice = _price;
}
function addContract(address _contract)
public
payable
validAdd
returns (bool)
{
listContracts[_contract] = true;
address(owner).transfer(msg.value);
return true;
}
function removeContract(address _contract)
public
onlyOwner
returns (bool)
{
listContracts[_contract] = false;
return true;
}
function callData(address contractAddress, bytes data)
public
validContract(contractAddress)
{
if(!contractAddress.call(data)) revert("request error, not valid data sent");
EthereumGAS.mintEGAS();
}
modifier validAdd() {
require(msg.sender == owner || msg.value >= addPrice);
_;
}
modifier validContract(address _input) {
require(listContracts[_input] != false, "contract not found");
_;
}
function() public payable {
address(owner).transfer(msg.value);
}
}