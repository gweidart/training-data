pragma solidity ^0.4.19;
contract OwnableToken {
mapping (address => bool) owners;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
event OwnershipExtended(address indexed host, address indexed guest);
modifier onlyOwner() {
require(owners[msg.sender]);
_;
}
function OwnableToken() public {
owners[msg.sender] = true;
}
function addOwner(address guest) public onlyOwner {
require(guest != address(0));
owners[guest] = true;
emit OwnershipExtended(msg.sender, guest);
}
function transferOwnership(address newOwner) public onlyOwner {
require(newOwner != address(0));
owners[newOwner] = true;
delete owners[msg.sender];
emit OwnershipTransferred(msg.sender, newOwner);
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
contract ABL is StandardToken, OwnableToken {
using SafeMath for uint256;
uint256 public constant SUM = 400000000;
uint256 public constant DISTRIBUTION = 221450000;
uint256 public constant DEVELOPERS = 178550000;
string public constant name = "Airbloc";
string public constant symbol = "ABL";
uint256 public constant decimals = 18;
uint256 public totalSupply = SUM.mul(10 ** uint256(decimals));
bool isTransferable = false;
function ABL(
address _dtb,
address _dev
) public {
require(_dtb != address(0));
require(_dev != address(0));
require(DISTRIBUTION + DEVELOPERS == SUM);
balances[_dtb] = DISTRIBUTION.mul(10 ** uint256(decimals));
emit Transfer(address(0), _dtb, balances[_dtb]);
balances[_dev] = DEVELOPERS.mul(10 ** uint256(decimals));
emit Transfer(address(0), _dev, balances[_dev]);
}
function unlock() external onlyOwner {
isTransferable = true;
}
function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
require(isTransferable || owners[msg.sender]);
return super.transferFrom(_from, _to, _value);
}
function transfer(address _to, uint256 _value) public returns (bool) {
require(isTransferable || owners[msg.sender]);
return super.transfer(_to, _value);
}
function mint(
address _to,
uint256 _amount
) onlyOwner public returns (bool) {
require(_to != address(0));
require(_amount >= 0);
uint256 amount = _amount.mul(10 ** uint256(decimals));
totalSupply = totalSupply.add(amount);
balances[_to] = balances[_to].add(amount);
emit Mint(_to, amount);
emit Transfer(address(0), _to, amount);
return true;
}
function burn(
uint256 _amount
) onlyOwner public {
require(_amount >= 0);
require(_amount <= balances[msg.sender]);
totalSupply = totalSupply.sub(_amount.mul(10 ** uint256(decimals)));
balances[msg.sender] = balances[msg.sender].sub(_amount.mul(10 ** uint256(decimals)));
emit Burn(msg.sender, _amount.mul(10 ** uint256(decimals)));
emit Transfer(msg.sender, address(0), _amount.mul(10 ** uint256(decimals)));
}
event Mint(address indexed _to, uint256 _amount);
event Burn(address indexed _from, uint256 _amount);
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
contract Whitelist is Ownable {
mapping(address => bool) public whitelist;
event WhitelistedAddressAdded(address addr);
event WhitelistedAddressRemoved(address addr);
modifier onlyWhitelisted() {
require(whitelist[msg.sender]);
_;
}
function addAddressToWhitelist(address addr) onlyOwner public returns(bool success) {
if (!whitelist[addr]) {
whitelist[addr] = true;
WhitelistedAddressAdded(addr);
success = true;
}
}
function addAddressesToWhitelist(address[] addrs) onlyOwner public returns(bool success) {
for (uint256 i = 0; i < addrs.length; i++) {
if (addAddressToWhitelist(addrs[i])) {
success = true;
}
}
}
function removeAddressFromWhitelist(address addr) onlyOwner public returns(bool success) {
if (whitelist[addr]) {
whitelist[addr] = false;
WhitelistedAddressRemoved(addr);
success = true;
}
}
function removeAddressesFromWhitelist(address[] addrs) onlyOwner public returns(bool success) {
for (uint256 i = 0; i < addrs.length; i++) {
if (removeAddressFromWhitelist(addrs[i])) {
success = true;
}
}
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
contract PresaleFirst is Whitelist, Pausable {
using SafeMath for uint256;
using SafeERC20 for ERC20;
uint256 public constant maxcap = 1500 ether;
uint256 public constant exceed = 300 ether;
uint256 public constant minimum = 0.5 ether;
uint256 public constant rate = 11500;
uint256 public startNumber;
uint256 public endNumber;
uint256 public weiRaised;
address public wallet;
ERC20 public token;
function PresaleFirst (
uint256 _startNumber,
uint256 _endNumber,
address _wallet,
address _token
) public {
require(_wallet != address(0));
require(_token != address(0));
startNumber = _startNumber;
endNumber = _endNumber;
wallet = _wallet;
token = ERC20(_token);
weiRaised = 0;
}
mapping (address => uint256) public buyers;
address[] private keys;
function () external payable {
collect(msg.sender);
}
function collect(address _buyer) public payable onlyWhitelisted whenNotPaused {
require(_buyer != address(0));
require(weiRaised <= maxcap);
require(preValidation());
require(buyers[_buyer] < exceed);
if(buyers[_buyer] == 0) {
keys.push(_buyer);
}
uint256 purchase = getPurchaseAmount(_buyer);
uint256 refund = (msg.value).sub(purchase);
_buyer.transfer(refund);
uint256 tokenAmount = purchase.mul(rate);
weiRaised = weiRaised.add(purchase);
buyers[_buyer] = buyers[_buyer].add(purchase);
emit BuyTokens(_buyer, purchase, tokenAmount);
}
function preValidation() private constant returns (bool) {
bool a = msg.value >= minimum;
bool b = block.number >= startNumber && block.number <= endNumber;
return a && b;
}
function getPurchaseAmount(address _buyer) private constant returns (uint256) {
return checkOverMaxcap(checkOverExceed(_buyer));
}
function checkOverExceed(address _buyer) private constant returns (uint256) {
if(msg.value >= exceed) {
return exceed;
} else if(msg.value.add(buyers[_buyer]) >= exceed) {
return exceed.sub(buyers[_buyer]);
} else {
return msg.value;
}
}
function checkOverMaxcap(uint256 amount) private constant returns (uint256) {
if((amount + weiRaised) >= maxcap) {
return (maxcap.sub(weiRaised));
} else {
return amount;
}
}
bool finalized = false;
function release() external onlyOwner {
require(!finalized);
require(weiRaised >= maxcap || block.number >= endNumber);
wallet.transfer(address(this).balance);
for(uint256 i = 0; i < keys.length; i++) {
token.safeTransfer(keys[i], buyers[keys[i]].mul(rate));
emit Release(keys[i], buyers[keys[i]].mul(rate));
}
withdraw();
finalized = true;
}
function refund() external onlyOwner {
require(!finalized);
pause();
withdraw();
for(uint256 i = 0; i < keys.length; i++) {
keys[i].transfer(buyers[keys[i]]);
emit Refund(keys[i], buyers[keys[i]]);
}
finalized = true;
}
function withdraw() public onlyOwner {
token.safeTransfer(wallet, token.balanceOf(this));
emit Withdraw(wallet, token.balanceOf(this));
}
event Release(address indexed _to, uint256 _amount);
event Withdraw(address indexed _from, uint256 _amount);
event Refund(address indexed _to, uint256 _amount);
event BuyTokens(address indexed buyer, uint256 price, uint256 tokens);
}