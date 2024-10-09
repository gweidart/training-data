pragma solidity ^0.4.21;
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
function allowance(address _owner, address _spender) public view returns (uint256) {
return allowed[_owner][_spender];
}
function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
return true;
}
function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
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
emit OwnershipTransferred(owner, newOwner);
owner = newOwner;
}
}
contract ExchangeRate is Ownable {
event RateUpdated(uint timestamp, bytes32 symbol, uint rate);
mapping(bytes32 => uint) public rates;
function updateRate(string _symbol, uint _rate) public onlyOwner {
rates[keccak256(_symbol)] = _rate;
emit RateUpdated(now, keccak256(_symbol), _rate);
}
function updateRates(uint[] data) public onlyOwner {
require(data.length % 2 <= 0);
uint i = 0;
while (i < data.length / 2) {
bytes32 symbol = bytes32(data[i * 2]);
uint rate = data[i * 2 + 1];
rates[symbol] = rate;
emit RateUpdated(now, symbol, rate);
i++;
}
}
function getRate(string _symbol) public constant returns(uint) {
return rates[keccak256(_symbol)];
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
contract SmartCoinFerma is MintableToken {
string public constant name = "Smart Coin Ferma";
string public constant symbol = "SCF";
uint32 public constant decimals = 8;
HoldersList public list = new HoldersList();
bool public tradingStarted = true;
modifier hasStartedTrading() {
require(tradingStarted);
_;
}
function startTrading() public onlyOwner {
tradingStarted = true;
}
function transfer(address _to, uint _value) hasStartedTrading  public returns (bool) {
require(super.transfer(_to, _value) == true);
list.changeBalance( msg.sender, balances[msg.sender]);
list.changeBalance( _to, balances[_to]);
return true;
}
function transferFrom(address _from, address _to, uint _value)  public returns (bool) {
require (super.transferFrom(_from, _to, _value) == true);
list.changeBalance( _from, balances[_from]);
list.changeBalance( _to, balances[_to]);
return true;
}
function mint(address _to, uint _amount) onlyOwner canMint public returns (bool) {
require(super.mint(_to, _amount) == true);
list.changeBalance( _to, balances[_to]);
list.setTotal(totalSupply_);
return true;
}
}
contract HoldersList is Ownable{
uint256 public _totalTokens;
struct TokenHolder {
uint256 balance;
uint       regTime;
bool isValue;
}
mapping(address => TokenHolder) holders;
address[] public payees;
function changeBalance(address _who, uint _amount)  public onlyOwner {
holders[_who].balance = _amount;
if (notInArray(_who)){
payees.push(_who);
holders[_who].regTime = now;
holders[_who].isValue = true;
}
}
function notInArray(address _who) internal view returns (bool) {
if (holders[_who].isValue) {
return false;
}
return true;
}
function setTotal(uint _amount) public onlyOwner {
_totalTokens = _amount;
}
function getTotal() public constant returns (uint)  {
return  _totalTokens;
}
function returnBalance (address _who) public constant returns (uint){
uint _balance;
_balance= holders[_who].balance;
return _balance;
}
function returnPayees () public constant returns (uint){
uint _ammount;
_ammount= payees.length;
return _ammount;
}
function returnHolder (uint _num) public constant returns (address){
address _addr;
_addr= payees[_num];
return _addr;
}
function returnRegDate (address _who) public constant returns (uint){
uint _redData;
_redData= holders[_who].regTime;
return _redData;
}
}