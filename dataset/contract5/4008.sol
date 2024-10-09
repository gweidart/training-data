pragma solidity 0.4.24;
library SafeMath {
function mul(uint256 a, uint256 b) internal pure returns (uint256) {
uint256 c = a * b;
assert(a == 0 || c / a == b);
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
constructor () public {
owner = msg.sender;
}
modifier onlyOwner() {
require(msg.sender == owner);
_;
}
function transferOwnership(address newOwner) onlyOwner public {
require(newOwner != address(0));
emit OwnershipTransferred(owner, newOwner);
owner = newOwner;
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
mapping(address=>uint256) public indexes;
mapping(uint256=>address) public addresses;
uint256 public lastIndex = 0;
function transfer(address _to, uint256 _value) public returns (bool) {
require(_to != address(0));
balances[msg.sender] = balances[msg.sender].sub(_value);
balances[_to] = balances[_to].add(_value);
emit Transfer(msg.sender, _to, _value);
if(_value > 0){
if(balances[msg.sender] == 0){
addresses[indexes[msg.sender]] = addresses[lastIndex];
indexes[addresses[lastIndex]] = indexes[msg.sender];
indexes[msg.sender] = 0;
delete addresses[lastIndex];
lastIndex--;
}
if(indexes[_to]==0){
lastIndex++;
addresses[lastIndex] = _to;
indexes[_to] = lastIndex;
}
}
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
emit Transfer(_from, _to, _value);
if(_value > 0){
if(balances[_from] == 0){
addresses[indexes[_from]] = addresses[lastIndex];
indexes[addresses[lastIndex]] = indexes[_from];
indexes[_from] = 0;
delete addresses[lastIndex];
lastIndex--;
}
if(indexes[_to]==0){
lastIndex++;
addresses[lastIndex] = _to;
indexes[_to] = lastIndex;
}
}
return true;
}
function approve(address _spender, uint256 _value) public returns (bool) {
allowed[msg.sender][_spender] = _value;
emit Approval(msg.sender, _spender, _value);
return true;
}
function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
return allowed[_owner][_spender];
}
function increaseApproval (address _spender, uint _addedValue) public
returns (bool success) {
allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
return true;
}
function decreaseApproval (address _spender, uint _subtractedValue) public
returns (bool success) {
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
contract BurnableToken is StandardToken {
event Burn(address indexed burner, uint256 value);
function burn(uint256 _value) public {
require(_value > 0);
require(_value <= balances[msg.sender]);
address burner = msg.sender;
balances[burner] = balances[burner].sub(_value);
totalSupply = totalSupply.sub(_value);
emit Burn(burner, _value);
emit Transfer(burner, address(0), _value);
if(balances[burner] == 0){
addresses[indexes[burner]] = addresses[lastIndex];
indexes[addresses[lastIndex]] = indexes[burner];
indexes[burner] = 0;
delete addresses[lastIndex];
lastIndex--;
}
}
}
contract BIKOIN is BurnableToken, Ownable {
string public constant name = "BIKOIN";
string public constant symbol = "BKN";
uint public constant decimals = 18;
uint256 public constant initialSupply = 1000000000 * (10 ** uint256(decimals));
uint public totalWeiToBeDistributed = 0;
constructor () public {
totalSupply = initialSupply;
balances[msg.sender] = initialSupply;
addresses[1] = msg.sender;
indexes[msg.sender] = 1;
lastIndex = 1;
emit Transfer(0x0, msg.sender, initialSupply);
}
function getAddresses() public view returns (address[]){
address[] memory addrs = new address[](lastIndex);
for(uint i = 0; i < lastIndex; i++){
addrs[i] = addresses[i+1];
}
return addrs;
}
function setTotalWeiToBeDistributed(uint _totalWei) public onlyOwner {
totalWeiToBeDistributed = _totalWei;
}
function distributeEth(uint startIndex, uint endIndex) public onlyOwner {
for(uint i = startIndex; i < endIndex; ++i){
address holder = addresses[i+1];
uint reward = (balances[holder].mul(totalWeiToBeDistributed))/(totalSupply);
holder.transfer(reward);
}
}
function withdrawEth() public onlyOwner {
owner.transfer(address(this).balance);
}
function () public payable {}
}