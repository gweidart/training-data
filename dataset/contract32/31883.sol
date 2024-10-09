pragma solidity ^0.4.15;
contract Ownable {
address public owner;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
function Ownable() {
owner = msg.sender;
}
modifier onlyOwner() {
require(msg.sender == owner);
_;
}
function transferOwnership(address newOwner) onlyOwner public {
require(newOwner != address(0));
OwnershipTransferred(owner, newOwner);
owner = newOwner;
}
}
library SafeMath {
function mul(uint256 a, uint256 b) internal constant returns (uint256) {
uint256 c = a * b;
assert(a == 0 || c / a == b);
return c;
}
function div(uint256 a, uint256 b) internal constant returns (uint256) {
uint256 c = a / b;
return c;
}
function sub(uint256 a, uint256 b) internal constant returns (uint256) {
assert(b <= a);
return a - b;
}
function add(uint256 a, uint256 b) internal constant returns (uint256) {
uint256 c = a + b;
assert(c >= a);
return c;
}
}
contract ERC20Basic {
uint256 public totalSupply;
function balanceOf(address who) public constant returns (uint256);
function transfer(address to, uint256 value) public returns (bool);
event Transfer(address indexed from, address indexed to, uint256 value);
}
contract BasicToken is ERC20Basic {
using SafeMath for uint256;
mapping(address => uint256) balances;
function transfer(address _to, uint256 _value) public returns (bool) {
require(_to != address(0));
balances[msg.sender] = balances[msg.sender].sub(_value);
balances[_to] = balances[_to].add(_value);
Transfer(msg.sender, _to, _value);
return true;
}
function balanceOf(address _owner) public constant returns (uint256 balance) {
return balances[_owner];
}
}
contract ERC20 is ERC20Basic {
function allowance(address owner, address spender) public constant returns (uint256);
function transferFrom(address from, address to, uint256 value) public returns (bool);
function approve(address spender, uint256 value) public returns (bool);
event Approval(address indexed owner, address indexed spender, uint256 value);
}
contract StandardToken is ERC20, BasicToken {
mapping (address => mapping (address => uint256)) allowed;
function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
require(_to != address(0));
uint256 _allowance = allowed[_from][msg.sender];
balances[_from] = balances[_from].sub(_value);
balances[_to] = balances[_to].add(_value);
allowed[_from][msg.sender] = _allowance.sub(_value);
Transfer(_from, _to, _value);
return true;
}
function approve(address _spender, uint256 _value) public returns (bool) {
allowed[msg.sender][_spender] = _value;
Approval(msg.sender, _spender, _value);
return true;
}
function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
return allowed[_owner][_spender];
}
function increaseApproval (address _spender, uint _addedValue)
returns (bool success) {
allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
return true;
}
function decreaseApproval (address _spender, uint _subtractedValue)
returns (bool success) {
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
contract BurnableToken is StandardToken, Ownable {
event Burn(address indexed burner, uint256 amount);
function burn(uint256 _amount) public {
require(_amount > 0);
require(_amount <= balances[msg.sender]);
address burner = msg.sender;
balances[burner] = balances[burner].sub(_amount);
totalSupply = totalSupply.sub(_amount);
Transfer(burner, address(0), _amount);
Burn(burner, _amount);
}
function burnFrom(address _from, uint256 _amount) onlyOwner public {
require(_from != address(0));
require(_amount > 0);
require(_amount <= balances[_from]);
balances[_from] = balances[_from].sub(_amount);
totalSupply = totalSupply.sub(_amount);
Transfer(_from, address(0), _amount);
Burn(_from, _amount);
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
contract GiftToken is BurnableToken, Pausable {
string constant public name = "Giftcoin";
string constant public symbol = "GIFT";
uint8 constant public decimals = 18;
uint256 constant public INITIAL_TOTAL_SUPPLY = 2e7 * (uint256(10) ** decimals);
address private addressIco;
modifier onlyIco() {
require(msg.sender == addressIco);
_;
}
function GiftToken (address _ico) {
require(_ico != address(0));
addressIco = _ico;
totalSupply = totalSupply.add(INITIAL_TOTAL_SUPPLY);
balances[_ico] = balances[_ico].add(INITIAL_TOTAL_SUPPLY);
Transfer(address(0), _ico, INITIAL_TOTAL_SUPPLY);
pause();
}
function transfer(address _to, uint256 _value) whenNotPaused public returns (bool) {
super.transfer(_to, _value);
}
function transferFrom(address _from, address _to, uint256 _value) whenNotPaused public returns (bool) {
super.transferFrom(_from, _to, _value);
}
function transferFromIco(address _to, uint256 _value) onlyIco public returns (bool) {
super.transfer(_to, _value);
}
}
contract Whitelist is Ownable {
struct WalletInfo {
string data;
bool whitelisted;
}
address private addressApi;
mapping(address => WalletInfo) public whitelist;
uint256 public whitelistLength = 0;
modifier onlyPrivilegeAddresses {
require(msg.sender == addressApi || msg.sender == owner);
_;
}
function setApiAddress(address _api) onlyOwner public {
require(_api != address(0));
addressApi = _api;
}
function addWallet(address _wallet, string _data) onlyPrivilegeAddresses public {
require(_wallet != address(0));
require(!isWhitelisted(_wallet));
whitelist[_wallet].data = _data;
whitelist[_wallet].whitelisted = true;
whitelistLength++;
}
function updateWallet(address _wallet, string _data) onlyPrivilegeAddresses public {
require(_wallet != address(0));
require(isWhitelisted(_wallet));
whitelist[_wallet].data = _data;
}
function removeWallet(address _wallet) onlyPrivilegeAddresses public {
require(_wallet != address(0));
require(isWhitelisted(_wallet));
delete whitelist[_wallet];
whitelistLength--;
}
function isWhitelisted(address _wallet) constant public returns (bool) {
return whitelist[_wallet].whitelisted;
}
function walletData(address _wallet) constant public returns (string) {
return whitelist[_wallet].data;
}
}