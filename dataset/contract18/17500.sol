pragma solidity 0.4.21;
library SafeMath {
function mul(uint a, uint b) internal pure returns (uint) {
if (a == 0) {
return 0;
}
uint c = a * b;
assert(c / a == b);
return c;
}
function div(uint a, uint b) internal pure returns (uint) {
uint c = a / b;
return c;
}
function sub(uint a, uint b) internal pure returns (uint) {
assert(b <= a);
return a - b;
}
function add(uint a, uint b) internal pure returns (uint) {
uint c = a + b;
assert(c >= a);
return c;
}
}
contract Ownable {
address public owner;
address public DAO;
function Ownable() public {
owner = msg.sender;
}
modifier onlyOwner() {
require(msg.sender == owner);
_;
}
function transferOwnership(address _owner) public onlyOwner {
owner = _owner;
}
function setDAO(address _DAO) onlyMasters public {
DAO = _DAO;
}
modifier onlyMasters() {
require(msg.sender == owner || msg.sender == DAO);
_;
}
}
contract Dust is Ownable {
using SafeMath for uint;
string public name = "Dust";
string public symbol = "DST";
uint8 public decimals = 0;
uint public totalSupply = 2000000000;
uint public etherToDustPrice = 1000000000000000;
uint public dustToEtherPrice = 800000000000000;
string public information;
mapping(address => uint) private balances;
mapping(address => mapping(address => uint)) private allowed;
event Transfer(address indexed _from, address indexed _to, uint _value);
event Approval(address indexed _owner, address indexed _spender, uint _value);
event Refill(uint _value);
event Withdrawal(uint _value);
function Dust() public {
balances[address(this)] = totalSupply;
emit Transfer(address(0), address(this), totalSupply);
}
function setInformation(string _information) external onlyMasters {
information = _information;
}
function setPrices(uint _etherToDustPrice, uint _dustToEtherPrice) external onlyMasters {
require(_etherToDustPrice > _dustToEtherPrice);
etherToDustPrice = _etherToDustPrice;
dustToEtherPrice = _dustToEtherPrice;
}
function _transfer(address _from, address _to, uint _value) internal returns (bool){
require(_to != address(0));
require(_value > 0);
require(balances[_from] >= _value);
balances[_from] = balances[_from].sub(_value);
balances[_to] = balances[_to].add(_value);
emit Transfer(_from, _to, _value);
return true;
}
function serviceTransfer(address _from, address _to, uint _value) external onlyMasters returns (bool success) {
return _transfer(_from, _to, _value);
}
function transfer(address _to, uint _value) external returns (bool) {
return _transfer(msg.sender, _to, _value);
}
function balanceOf(address _owner) public view returns (uint) {
return balances[_owner];
}
function transferFrom(address _from, address _to, uint _value) external returns (bool) {
require(_value <= allowed[_from][_to]);
allowed[_from][_to] = allowed[_from][_to].sub(_value);
return _transfer(_from, _to, _value);
}
function approve(address _spender, uint _value) external returns (bool) {
require((_value == 0) || (allowed[msg.sender][_spender] == 0));
allowed[msg.sender][_spender] = _value;
emit Approval(msg.sender, _spender, _value);
return true;
}
function allowance(address _owner, address _spender) public view returns (uint) {
return allowed[_owner][_spender];
}
function increaseApproval(address _spender, uint _addedValue) external returns (bool) {
allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
return true;
}
function decreaseApproval(address _spender, uint _subtractedValue) external returns (bool) {
uint oldValue = allowed[msg.sender][_spender];
if (_subtractedValue > oldValue) {
allowed[msg.sender][_spender] = 0;
} else {
allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
}
emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
return true;
}
function() external payable {
convertEtherToDust();
}
function convertEtherToDust() public payable {
uint amount = msg.value.div(etherToDustPrice);
require(amount > 0);
if (amount > balances[this]) {
amount = balances[this];
}
_transfer(this, msg.sender, amount);
uint diff = msg.value.sub(amount.mul(etherToDustPrice));
if (diff > 0) {
msg.sender.transfer(diff);
}
}
function convertDustToEther(uint _amount) external {
uint value = _amount.mul(dustToEtherPrice);
require(address(this).balance >= value);
_transfer(msg.sender, this, _amount);
msg.sender.transfer(value);
}
function withdrawFunds(address _to, uint _value) external onlyMasters {
require(address(this).balance >= _value);
_to.transfer(_value);
emit Withdrawal(_value);
}
function refillFunds() external payable {
require(msg.value >= dustToEtherPrice);
emit Refill(msg.value);
}
}