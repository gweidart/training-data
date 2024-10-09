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
function Ownable() public {
owner = msg.sender;
}
modifier onlyOwner() {
require(msg.sender == owner);
_;
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
contract CanReclaimToken is Ownable {
using SafeERC20 for ERC20Basic;
function reclaimToken(ERC20Basic token) external onlyOwner {
uint256 balance = token.balanceOf(this);
token.safeTransfer(owner, balance);
}
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
contract CappedBurnToken is StandardToken, Ownable {
uint256 public cap;
function CappedBurnToken(uint256 _cap) public {
require(_cap > 0);
cap = _cap;
}
event Mint(address indexed to, uint256 amount);
event Unmint(address indexed from, uint256 amount);
function mint(address _to, uint256 _amount) onlyOwner external returns (bool) {
require(totalSupply_.add(_amount) <= cap);
totalSupply_ = totalSupply_.add(_amount);
balances[_to] = balances[_to].add(_amount);
Mint(_to, _amount);
Transfer(address(0), _to, _amount);
return true;
}
event Burn(address indexed burner, uint256 value);
function burn(uint256 _value) external {
address burner = msg.sender;
require(_value <= balances[burner]);
balances[burner] = balances[burner].sub(_value);
totalSupply_ = totalSupply_.sub(_value);
cap = cap.sub(_value);
Burn(burner, _value);
Transfer(msg.sender, address(0), _value);
}
function unmint(uint256 _value) external {
address burner = msg.sender;
require(_value <= balances[burner]);
balances[burner] = balances[burner].sub(_value);
totalSupply_ = totalSupply_.sub(_value);
Unmint(burner, _value);
Transfer(msg.sender, address(0), _value);
}
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
contract PDP is CappedBurnToken(144200000), DetailedERC20, CanReclaimToken {
uint256 public saleMinShares;
uint256 public salePriceWei;
uint256 public saleSharesAvail;
address internal saleWallet;
uint256 public saleSharesSold;
function PDP() DetailedERC20("PinkDate Platform Token-Share", "PDP", 0) public {
saleWallet = address(0);
salePriceWei = 0;
saleSharesAvail = 0;
saleSharesSold = 0;
}
event Purchase(address indexed to, uint256 shares);
function() external payable {
require(saleWallet != address(0));
uint256 shareTarget = msg.value / salePriceWei;
require(shareTarget >= saleMinShares);
require(shareTarget <= saleSharesAvail);
saleSharesAvail = saleSharesAvail.sub(shareTarget);
saleSharesSold = saleSharesSold.add(shareTarget);
Purchase(msg.sender, shareTarget);
saleWallet.transfer(msg.value);
}
function setSale(uint256 newPriceWei, uint256 newSharesAvail, uint256 newMinShares, address newWallet) onlyOwner external {
if (newWallet == address(0)) {
saleWallet = address(0);
salePriceWei = 0;
saleSharesAvail = 0;
saleMinShares = 0;
} else {
require(totalSupply_ + saleSharesSold + newSharesAvail <= cap);
require(newSharesAvail > 100 && newSharesAvail < 10000000);
require(newMinShares < 20000);
require(newPriceWei > 100000000000000);
saleMinShares = newMinShares;
salePriceWei = newPriceWei;
saleSharesAvail = newSharesAvail;
saleWallet = newWallet;
}
}
function clearSaleSharesSold(uint256 confirm) onlyOwner external {
require(confirm == 1);
require(saleWallet == address(0));
require(totalSupply_ >= saleSharesSold);
saleSharesSold = 0;
}
}