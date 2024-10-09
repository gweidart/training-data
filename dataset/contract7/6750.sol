pragma solidity ^0.4.24;
library SafeMath {
function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
if (a == 0) {
return 0;
}
c = a * b;
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
function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
c = a + b;
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
function balanceOf(address _owner) public view returns (uint256) {
return balances[_owner];
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
totalSupply_ = totalSupply_.sub(_value);
emit Burn(_who, _value);
emit Transfer(_who, address(0), _value);
}
}
contract ERC20 is ERC20Basic {
function allowance(address owner, address spender)
public view returns (uint256);
function transferFrom(address from, address to, uint256 value)
public returns (bool);
function approve(address spender, uint256 value) public returns (bool);
event Approval(
address indexed owner,
address indexed spender,
uint256 value
);
}
contract DetailedERC20 is ERC20 {
string public name;
string public symbol;
uint8 public decimals;
constructor(string _name, string _symbol, uint8 _decimals) public {
name = _name;
symbol = _symbol;
decimals = _decimals;
}
}
library Roles {
struct Role {
mapping (address => bool) bearer;
}
function add(Role storage role, address addr)
internal
{
role.bearer[addr] = true;
}
function remove(Role storage role, address addr)
internal
{
role.bearer[addr] = false;
}
function check(Role storage role, address addr)
view
internal
{
require(has(role, addr));
}
function has(Role storage role, address addr)
view
internal
returns (bool)
{
return role.bearer[addr];
}
}
contract RBAC {
using Roles for Roles.Role;
mapping (string => Roles.Role) private roles;
event RoleAdded(address addr, string roleName);
event RoleRemoved(address addr, string roleName);
function checkRole(address addr, string roleName)
view
public
{
roles[roleName].check(addr);
}
function hasRole(address addr, string roleName)
view
public
returns (bool)
{
return roles[roleName].has(addr);
}
function addRole(address addr, string roleName)
internal
{
roles[roleName].add(addr);
emit RoleAdded(addr, roleName);
}
function removeRole(address addr, string roleName)
internal
{
roles[roleName].remove(addr);
emit RoleRemoved(addr, roleName);
}
modifier onlyRole(string roleName)
{
checkRole(msg.sender, roleName);
_;
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
contract StandardToken is ERC20, BasicToken {
mapping (address => mapping (address => uint256)) internal allowed;
function transferFrom(
address _from,
address _to,
uint256 _value
)
public
returns (bool)
{
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
function allowance(
address _owner,
address _spender
)
public
view
returns (uint256)
{
return allowed[_owner][_spender];
}
function increaseApproval(
address _spender,
uint _addedValue
)
public
returns (bool)
{
allowed[msg.sender][_spender] = (
allowed[msg.sender][_spender].add(_addedValue));
emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
return true;
}
function decreaseApproval(
address _spender,
uint _subtractedValue
)
public
returns (bool)
{
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
contract MintableToken is StandardToken, Ownable {
event Mint(address indexed to, uint256 amount);
event MintFinished();
bool public mintingFinished = false;
modifier canMint() {
require(!mintingFinished);
_;
}
modifier hasMintPermission() {
require(msg.sender == owner);
_;
}
function mint(
address _to,
uint256 _amount
)
hasMintPermission
canMint
public
returns (bool)
{
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
contract RBACMintableToken is MintableToken, RBAC {
string public constant ROLE_MINTER = "minter";
modifier hasMintPermission() {
checkRole(msg.sender, ROLE_MINTER);
_;
}
function addMinter(address minter) onlyOwner public {
addRole(minter, ROLE_MINTER);
}
function removeMinter(address minter) onlyOwner public {
removeRole(minter, ROLE_MINTER);
}
}
contract ERC827 is ERC20 {
function approveAndCall(
address _spender,
uint256 _value,
bytes _data
)
public
payable
returns (bool);
function transferAndCall(
address _to,
uint256 _value,
bytes _data
)
public
payable
returns (bool);
function transferFromAndCall(
address _from,
address _to,
uint256 _value,
bytes _data
)
public
payable
returns (bool);
}
pragma solidity ^0.4.23;
contract ERC827Token is ERC827, StandardToken {
function approveAndCall(
address _spender,
uint256 _value,
bytes _data
)
public
payable
returns (bool)
{
require(_spender != address(this));
super.approve(_spender, _value);
require(_spender.call.value(msg.value)(_data));
return true;
}
function transferAndCall(
address _to,
uint256 _value,
bytes _data
)
public
payable
returns (bool)
{
require(_to != address(this));
super.transfer(_to, _value);
require(_to.call.value(msg.value)(_data));
return true;
}
function transferFromAndCall(
address _from,
address _to,
uint256 _value,
bytes _data
)
public payable returns (bool)
{
require(_to != address(this));
super.transferFrom(_from, _to, _value);
require(_to.call.value(msg.value)(_data));
return true;
}
function increaseApprovalAndCall(
address _spender,
uint _addedValue,
bytes _data
)
public
payable
returns (bool)
{
require(_spender != address(this));
super.increaseApproval(_spender, _addedValue);
require(_spender.call.value(msg.value)(_data));
return true;
}
function decreaseApprovalAndCall(
address _spender,
uint _subtractedValue,
bytes _data
)
public
payable
returns (bool)
{
require(_spender != address(this));
super.decreaseApproval(_spender, _subtractedValue);
require(_spender.call.value(msg.value)(_data));
return true;
}
}
contract GastroAdvisorToken is DetailedERC20, ERC827Token, RBACMintableToken, BurnableToken {
modifier canTransfer() {
require(mintingFinished);
_;
}
constructor()
DetailedERC20("GastroAdvisorToken", "FORK", 18)
public
{}
function transfer(address _to, uint256 _value) canTransfer public returns (bool) {
return super.transfer(_to, _value);
}
function transferFrom(address _from, address _to, uint256 _value) canTransfer public returns (bool) {
return super.transferFrom(_from, _to, _value);
}
function transferAndCall(
address _to,
uint256 _value,
bytes _data)
canTransfer public payable returns (bool)
{
return super.transferAndCall(_to, _value, _data);
}
function transferFromAndCall(
address _from,
address _to,
uint256 _value,
bytes _data)
canTransfer public payable returns (bool)
{
return super.transferFromAndCall(
_from,
_to,
_value,
_data
);
}
function transferAnyERC20Token(address _tokenAddress, uint256 _tokens) onlyOwner public returns (bool success) {
return ERC20Basic(_tokenAddress).transfer(owner, _tokens);
}
}
contract CappedBountyMinter is Ownable {
using SafeMath for uint256;
GastroAdvisorToken public token;
uint256 public cap;
uint256 public totalGivenBountyTokens;
mapping (address => uint256) public givenBountyTokens;
uint256 decimals;
constructor(address _token, uint256 _cap) public {
require(_token != address(0));
require(_cap > 0);
token = GastroAdvisorToken(_token);
decimals = uint256(token.decimals());
cap = _cap * (10 ** decimals);
}
function multiSend(address[] addresses, uint256[] amounts) public onlyOwner {
require(addresses.length > 0);
require(amounts.length > 0);
require(addresses.length == amounts.length);
for (uint i = 0; i < addresses.length; i++) {
address to = addresses[i];
uint256 value = amounts[i] * (10 ** decimals);
givenBountyTokens[to] = givenBountyTokens[to].add(value);
totalGivenBountyTokens = totalGivenBountyTokens.add(value);
require(totalGivenBountyTokens <= cap);
token.mint(to, value);
}
}
function remainingTokens() public view returns(uint256) {
return cap.sub(totalGivenBountyTokens);
}
function transferAnyERC20Token(address _tokenAddress, uint256 _tokens) onlyOwner public returns (bool success) {
return ERC20Basic(_tokenAddress).transfer(owner, _tokens);
}
}