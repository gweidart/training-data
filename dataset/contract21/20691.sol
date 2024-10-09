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
library Math {
function max64(uint64 a, uint64 b) internal pure returns (uint64) {
return a >= b ? a : b;
}
function min64(uint64 a, uint64 b) internal pure returns (uint64) {
return a < b ? a : b;
}
function max256(uint256 a, uint256 b) internal pure returns (uint256) {
return a >= b ? a : b;
}
function min256(uint256 a, uint256 b) internal pure returns (uint256) {
return a < b ? a : b;
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
contract DetailedERC20 is ERC20 {
string public name;
string public symbol;
uint8 public decimals;
function DetailedERC20(string _name, string _symbol, uint8 _decimals) public {
name = _name;
symbol = _symbol;
decimals = _decimals;
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
contract CanReclaimToken is Ownable {
using SafeERC20 for ERC20Basic;
function reclaimToken(ERC20Basic token) external onlyOwner {
uint256 balance = token.balanceOf(this);
token.safeTransfer(owner, balance);
}
}
contract Destructible is Ownable {
function Destructible() public payable { }
function destroy() onlyOwner public {
selfdestruct(owner);
}
function destroyAndSend(address _recipient) onlyOwner public {
selfdestruct(_recipient);
}
}
contract Pausable is Ownable {
event Pause();
event Unpause();
bool public paused = false;
modifier whenNotPaused() {
require(!paused);
_;
}
modifier whenPaused() {
require(paused);
_;
}
function pause() onlyOwner whenNotPaused public {
paused = true;
Pause();
}
function unpause() onlyOwner whenPaused public {
paused = false;
Unpause();
}
}
contract Claimable is Ownable {
address public pendingOwner;
modifier onlyPendingOwner() {
require(msg.sender == pendingOwner);
_;
}
function transferOwnership(address newOwner) onlyOwner public {
pendingOwner = newOwner;
}
function claimOwnership() onlyPendingOwner public {
OwnershipTransferred(owner, pendingOwner);
owner = pendingOwner;
pendingOwner = address(0);
}
}
contract BurnableToken is BasicToken {
event Burn(address indexed burner, uint256 value);
function burn(uint256 _value) public {
require(_value <= balances[msg.sender]);
address burner = msg.sender;
balances[burner] = balances[burner].sub(_value);
totalSupply = totalSupply.sub(_value);
Burn(burner, _value);
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
contract HasNoEther is Ownable {
function HasNoEther() public payable {
require(msg.value == 0);
}
function() external {
}
function reclaimEther() external onlyOwner {
assert(owner.send(this.balance));
}
}
contract DelayedClaimable is Claimable {
uint256 public end;
uint256 public start;
function setLimits(uint256 _start, uint256 _end) onlyOwner public {
require(_start <= _end);
end = _end;
start = _start;
}
function claimOwnership() onlyPendingOwner public {
require((block.number <= end) && (block.number >= start));
OwnershipTransferred(owner, pendingOwner);
owner = pendingOwner;
pendingOwner = address(0);
end = 0;
}
}
contract HasNoContracts is Ownable {
function reclaimContract(address contractAddr) external onlyOwner {
Ownable contractInst = Ownable(contractAddr);
contractInst.transferOwnership(owner);
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
string public constant ROLE_ADMIN = "admin";
function RBAC()
public
{
addRole(msg.sender, ROLE_ADMIN);
}
function addRole(address addr, string roleName)
internal
{
roles[roleName].add(addr);
RoleAdded(addr, roleName);
}
function removeRole(address addr, string roleName)
internal
{
roles[roleName].remove(addr);
RoleRemoved(addr, roleName);
}
function checkRole(address addr, string roleName)
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
function adminAddRole(address addr, string roleName)
onlyAdmin
public
{
addRole(addr, roleName);
}
function adminRemoveRole(address addr, string roleName)
onlyAdmin
public
{
removeRole(addr, roleName);
}
modifier onlyRole(string roleName)
{
checkRole(msg.sender, roleName);
_;
}
modifier onlyAdmin()
{
checkRole(msg.sender, ROLE_ADMIN);
_;
}
}
contract HasNoTokens is CanReclaimToken {
function tokenFallback(address from_, uint256 value_, bytes data_) external {
from_;
value_;
data_;
revert();
}
}
contract Contactable is Ownable{
string public contactInformation;
function setContactInformation(string info) onlyOwner public {
contactInformation = info;
}
}
contract NoOwner is HasNoEther, HasNoTokens, HasNoContracts {
}
contract SimpleToken is StandardToken {
string public constant name = "SimpleToken";
string public constant symbol = "SIM";
uint8 public constant decimals = 18;
uint256 public constant INITIAL_SUPPLY = 10000 * (10 ** uint256(decimals));
function SimpleToken() public {
totalSupply = INITIAL_SUPPLY;
balances[msg.sender] = INITIAL_SUPPLY;
}
}
contract PausableToken is StandardToken, Pausable {
function transfer(address _to, uint256 _value) public whenNotPaused returns (bool) {
return super.transfer(_to, _value);
}
function transferFrom(address _from, address _to, uint256 _value) public whenNotPaused returns (bool) {
return super.transferFrom(_from, _to, _value);
}
function approve(address _spender, uint256 _value) public whenNotPaused returns (bool) {
return super.approve(_spender, _value);
}
function increaseApproval(address _spender, uint _addedValue) public whenNotPaused returns (bool success) {
return super.increaseApproval(_spender, _addedValue);
}
function decreaseApproval(address _spender, uint _subtractedValue) public whenNotPaused returns (bool success) {
return super.decreaseApproval(_spender, _subtractedValue);
}
}
contract Migrations is Ownable {
uint256 public lastCompletedMigration;
function setCompleted(uint256 completed) onlyOwner public {
lastCompletedMigration = completed;
}
function upgrade(address newAddress) onlyOwner public {
Migrations upgraded = Migrations(newAddress);
upgraded.setCompleted(lastCompletedMigration);
}
}
contract TokenDestructible is Ownable {
function TokenDestructible() public payable { }
function destroy(address[] tokens) onlyOwner public {
for(uint256 i = 0; i < tokens.length; i++) {
ERC20Basic token = ERC20Basic(tokens[i]);
uint256 balance = token.balanceOf(this);
token.transfer(owner, balance);
}
selfdestruct(owner);
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
contract CappedToken is MintableToken {
uint256 public cap;
function CappedToken(uint256 _cap) public {
require(_cap > 0);
cap = _cap;
}
function mint(address _to, uint256 _amount) onlyOwner canMint public returns (bool) {
require(totalSupply.add(_amount) <= cap);
return super.mint(_to, _amount);
}
}
contract ForceEther  {
function ForceEther() public payable { }
function destroyAndSend(address _recipient) public {
selfdestruct(_recipient);
}
}
interface Gateway {
function open(uint _introId, uint _bid, uint _creationTime, string _hashedInfo) public;
function accept(uint _introId, address _ambassador, uint _updateTime) public;
function endorse(uint _introId, uint _updateTime) public;
function dispute(uint _introId, uint _updateTime) public;
function withdraw(uint _introId, uint _updateTime) public;
function resolve(uint _introId, uint _updateTime, string _resolution, bool _isSpam) public;
}
interface Score {
function setScore(address user, uint score) public;
function getScore(address user) public view returns (uint score);
function scoreDown(address user) public returns (bool res);
function scoreUp(address user) public returns (bool res);
}
interface Share {
function rolloutDividends(address receiver) public;
function distributeDividends(address receiver, uint tokensPerShare) public;
}
contract InbotProxy is RBAC, Pausable {
MintableToken	token;
MintableToken	share;
Score 			score;
Gateway 		gateway;
function InbotProxy(
address _token,
address _share,
address _score,
address _gateway
) public
{
token = MintableToken(_token);
share = MintableToken(_share);
score = Score(_score);
gateway = Gateway(_gateway);
}
function setToken(address _token) public onlyAdmin {
token = MintableToken(_token);
}
function getToken() whenNotPaused public view returns (MintableToken) {
return token;
}
function setShare(address _share) public onlyAdmin {
share = MintableToken(_share);
}
function getShare() whenNotPaused public view returns (MintableToken) {
return share;
}
function setScore(address _score) public onlyAdmin {
score = Score(_score);
}
function getScore() public whenNotPaused view returns (Score) {
return score;
}
function setGateway(address _gateway) public onlyAdmin {
gateway = Gateway(_gateway);
}
function getgateway() whenNotPaused public view returns (Gateway) {
return gateway;
}
}
contract InbotControlled is RBAC {
string public constant ROLE_VENDOR = "vendor";
}
contract InbotContract is InbotControlled, TokenDestructible, CanReclaimToken, Pausable {
using SafeMath for uint;
uint public constant WAD = 10**18;
uint public constant RAY = 10**27;
InbotProxy public proxy;
modifier proxyExists() {
require(proxy != address(0x0));
_;
}
function setProxy(address _proxy) public onlyAdmin {
proxy = InbotProxy(_proxy);
}
function reclaimToken() public proxyExists onlyOwner {
this.reclaimToken(proxy.getToken());
}
function pause() public onlyAdmin whenNotPaused {
paused = true;
Pause();
}
function unpause() public onlyAdmin whenPaused {
paused = false;
Unpause();
}
function getTime(uint _time) internal view returns (uint t) {
return _time == 0 ? now : _time;
}
function min(uint x, uint y) internal pure returns (uint z) {
return x <= y ? x : y;
}
function max(uint x, uint y) internal pure returns (uint z) {
return x >= y ? x : y;
}
function wmul(uint x, uint y) internal pure returns (uint z) {
z = x.mul(y).add(WAD.div(2)).div(WAD);
}
function rmul(uint x, uint y) internal pure returns (uint z) {
z = x.mul(y).add(RAY.div(2)).div(RAY);
}
function wdiv(uint x, uint y) internal pure returns (uint z) {
z = x.mul(WAD).add(y.div(2)).div(y);
}
function rdiv(uint x, uint y) internal pure returns (uint z) {
z = x.mul(RAY).add(y.div(2)).div(y);
}
}
contract ERC223ReceivingContract {
event TokenReceived(address indexed from, uint value, bytes data);
function tokenFallback(address _from, uint _value, bytes _data) public;
}
contract InbotToken is InbotContract, MintableToken, BurnableToken, PausableToken, DetailedERC20 {
event InbotTokenTransfer(address indexed from, address indexed to, uint value, bytes data);
function InbotToken (string _name, string _symbol, uint8 _decimals) DetailedERC20(_name, _symbol, _decimals) public {
}
function callTokenFallback(address _from, address _to, uint256 _value, bytes _data) internal returns (bool) {
uint codeLength;
assembly {
codeLength := extcodesize(_to)
}
if(codeLength > 0) {
ERC223ReceivingContract receiver = ERC223ReceivingContract(_to);
receiver.tokenFallback(_from, _value, _data);
}
InbotTokenTransfer(_from, _to, _value, _data);
return true;
}
function mint(address _to, uint256 _amount) public onlyAdmin canMint returns (bool) {
totalSupply = totalSupply.add(_amount);
balances[_to] = balances[_to].add(_amount);
Mint(_to, _amount);
Transfer(address(0), _to, _amount);
return true;
}
function transferFrom(address _from, address _to, uint256 _value, bytes _data) public whenNotPaused returns (bool) {
assert(super.transferFrom(_from, _to, _value));
return callTokenFallback(_from, _to, _value, _data);
}
function transferFrom(address _from, address _to, uint256 _value) public whenNotPaused returns (bool) {
bytes memory empty;
return transferFrom(_from, _to, _value, empty);
}
function transfer(address _to, uint256 _value, bytes _data) public whenNotPaused returns (bool) {
assert(super.transfer(_to, _value));
return callTokenFallback(msg.sender, _to, _value, _data);
}
function transfer(address _to, uint _value) public whenNotPaused returns (bool) {
bytes memory empty;
return transfer(_to, _value, empty);
}
}
contract InToken is InbotToken("InToken", "IN", 18) {
uint public constant MAX_SUPPLY = 13*RAY;
function InToken() public {
}
function mint(address _to, uint256 _amount) onlyAdmin canMint public returns (bool) {
require(totalSupply.add(_amount) <= MAX_SUPPLY);
return super.mint(_to, _amount);
}
}