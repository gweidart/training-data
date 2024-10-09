pragma solidity 0.4.24;
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
assert(b > 0);
uint256 c = a / b;
assert(a == b * c + a % b);
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
contract owned {
address public owner;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
constructor() public {
owner = msg.sender;
}
modifier onlyOwner {
require(msg.sender == owner , "Unauthorized Access");
_;
}
function transferOwnership(address newOwner) onlyOwner public {
require(newOwner != address(0));
emit OwnershipTransferred(owner, newOwner);
owner = newOwner;
}
}
contract Pausable is owned {
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
emit Pause();
}
function unpause() onlyOwner whenPaused public {
paused = false;
emit Unpause();
}
}
interface ERC223Interface {
function balanceOf(address who) constant external returns (uint);
function transfer(address to, uint value)  external returns (bool success);
function transfer(address to, uint value, bytes data) external returns (bool success);
event Transfer(address indexed from, address indexed to, uint value, bytes data);
event Transfer(address indexed _from, address indexed _to, uint256 _value);
}
contract ERC223ReceivingContract {
function tokenFallback(address _from, uint _value, bytes _data) external;
}
contract ERC223Token is ERC223Interface, Pausable {
using SafeMath for uint;
uint256 public _CAP;
mapping(address => uint256) balances;
function transfer(address _to, uint _value, bytes _data) whenNotPaused external returns (bool success){
require(balances[msg.sender] >= _value && _value > 0);
if(isContract(_to)){
return transferToContract(_to, _value, _data);
}
else
{
return transferToAddress(_to, _value,  _data);
}
}
function transfer(address _to, uint _value) whenNotPaused external returns (bool success){
require(balances[msg.sender] >= _value && _value > 0);
bytes memory empty;
if(isContract(_to)){
return transferToContract(_to, _value, empty);
}
else
{
return transferToAddress(_to, _value, empty);
}
}
function isContract(address _addr) internal view returns (bool is_contract) {
uint length;
assembly { length := extcodesize(_addr) }
if (length > 0)
return true;
else
return false;
}
function transferToAddress(address _to, uint _value, bytes _data) private whenNotPaused returns (bool success) {
require(_to != address(0));
require(balances[msg.sender] >= _value && _value > 0);
balances[msg.sender] = balances[msg.sender].sub(_value);
balances[_to] = balances[_to].add(_value);
emit Transfer(msg.sender, _to, _value);
emit Transfer(msg.sender, _to, _value, _data);
return true;
}
function transferToContract(address _to, uint _value, bytes _data) private whenNotPaused returns (bool success) {
require(_to != address(0));
require(balances[msg.sender] >= _value && _value > 0);
balances[msg.sender] = balances[msg.sender].sub(_value);
balances[_to] = balances[_to].add(_value);
ERC223ReceivingContract receiver = ERC223ReceivingContract(_to);
receiver.tokenFallback(msg.sender, _value, _data);
emit Transfer(msg.sender, _to, _value);
emit Transfer(msg.sender, _to, _value, _data);
return true;
}
function balanceOf(address _owner) constant external returns (uint balance) {
return balances[_owner];
}
}
contract ERC20BackedERC223 is ERC223Token{
modifier onlyPayloadSize(uint size) {
assert(msg.data.length >= size.add(4));
_;
}
function transferFrom(address _from, address _to, uint256 _value) onlyPayloadSize(3 * 32) whenNotPaused external returns (bool success) {
require(_to != address(0));
require(_value <= balances[_from]);
require(_value <= allowed[_from][msg.sender]);
balances[_from] = balances[_from].sub(_value);
balances[_to] = balances[_to].add(_value);
allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
emit Transfer(_from, _to, _value);
return true;
}
function approve(address _spender, uint256 _value) whenNotPaused public returns (bool success) {
require((balances[msg.sender] >= _value) && ((_value == 0) || (allowed[msg.sender][_spender] == 0)));
allowed[msg.sender][_spender] = _value;
emit Approval(msg.sender, _spender, _value);
return true;
}
function disApprove(address _spender) whenNotPaused public returns (bool success)
{
allowed[msg.sender][_spender] = 0;
assert(allowed[msg.sender][_spender] == 0);
emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
return true;
}
function increaseApproval(address _spender, uint _addedValue) whenNotPaused public returns (bool success) {
require(balances[msg.sender] >= allowed[msg.sender][_spender].add(_addedValue), "Callers balance not enough");
allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
return true;
}
function decreaseApproval(address _spender, uint _subtractedValue) whenNotPaused public returns (bool success) {
uint oldValue = allowed[msg.sender][_spender];
require((_subtractedValue != 0) && (oldValue > _subtractedValue) , "The amount to be decreased is incorrect");
allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
return true;
}
function allowance(address _owner, address _spender) constant public returns (uint256 remaining) {
return allowed[_owner][_spender];
}
event Approval(address indexed _owner, address indexed _spender, uint256 _value);
mapping (address => mapping (address => uint256)) allowed;
}
contract burnableERC223 is ERC20BackedERC223{
uint256  public _totalBurnedTokens = 0;
event Burn(address indexed from, uint256 value);
function burn(uint256 _value) onlyOwner public returns (bool success) {
require(balances[msg.sender] >= _value, "Sender doesn't have enough balance");
balances[msg.sender] = balances[msg.sender].sub(_value);
_CAP = _CAP.sub(_value);
_totalBurnedTokens = _totalBurnedTokens.add(_value);
emit Burn(msg.sender, _value);
emit Transfer(msg.sender, address(0), _value);
return true;
}
function burnFrom(address _from, uint256 _value) onlyOwner public returns (bool success) {
require(balances[_from] >= _value , "target balance is not enough");
require(_value <= allowed[_from][msg.sender]);
balances[_from] = balances[_from].sub(_value);
allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
_CAP = _CAP.sub(_value);
emit Burn(_from, _value);
emit Transfer(_from, address(0), _value);
return true;
}
}
contract mintableERC223 is burnableERC223{
uint256 public _totalMinedSupply;
uint256 public _initialSupply;
event Mint(address indexed to, uint256 amount);
event MintFinished();
bool public mintingFinished = false;
modifier canMint() {
require(!mintingFinished);
_;
}
function mint(address _to, uint256 _amount) onlyOwner canMint public returns (bool) {
bytes memory empty;
uint256 availableMinedSupply;
availableMinedSupply =  (_totalMinedSupply.sub(_totalBurnedTokens)).add(_amount);
require(_CAP >= availableMinedSupply , "All tokens minted, Cap reached");
_totalMinedSupply = _totalMinedSupply.add(_amount);
if(_CAP <= _totalMinedSupply.sub(_totalBurnedTokens))
mintingFinished = true;
balances[_to] = balances[_to].add(_amount);
emit Mint(_to, _amount);
emit Transfer(address(0), _to, _amount);
emit Transfer(address(0), _to, _amount, empty);
return true;
}
function finishMinting() onlyOwner canMint public returns (bool) {
mintingFinished = true;
emit MintFinished();
return true;
}
function maximumSupply() public view returns (uint256 supply){
return _CAP;
}
function totalMinedSupply() public view returns (uint256 supply){
return _totalMinedSupply;
}
function preMinedSupply() public view returns (uint256 supply){
return _initialSupply;
}
function totalBurnedTokens() public view returns (uint256 supply){
return _totalBurnedTokens;
}
function totalSupply() public view returns (uint256 supply){
return _totalMinedSupply.sub(_totalBurnedTokens);
}
}
contract CyBitInternal is mintableERC223{
string public name;
uint256 public decimals;
string public symbol;
string public version;
uint256 private totalsupply;
constructor() public
{
decimals = 8;
name = "CyBit-Internal-Token";
symbol = "iCBT";
version = "V1.0";
totalsupply = 5000000000;
_CAP = totalsupply.mul(10 ** decimals);
_initialSupply = totalsupply.mul(10 ** decimals);
_totalMinedSupply = _initialSupply;
balances[msg.sender] = _initialSupply;
}
function() public {
revert();
}
function version() public view returns (string _v) {
return version;
}
function name() public view returns (string _name) {
return name;
}
function symbol() public view returns (string _symbol) {
return symbol;
}
function decimals() public view returns (uint256 _decimals) {
return decimals;
}
}