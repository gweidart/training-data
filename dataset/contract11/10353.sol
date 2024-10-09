pragma solidity 0.4.23;
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
contract MaradonaCoinToken is Ownable, BurnableToken, StandardToken {
using SafeMath for uint256;
string public constant symbol = "MC";
string public constant name = "Maradona Coin Token";
uint256 public constant decimals = 18;
uint256 public constant INITIAL_SUPPLY = 3000000000 * 10 ** uint256(decimals);
bool public transferable = false;
mapping (address => bool) public whitelistedTransfer;
modifier validAddress(address addr) {
require(addr != address(0x0));
require(addr != address(this));
_;
}
modifier onlyWhenTransferable() {
if (!transferable) {
require(whitelistedTransfer[msg.sender]);
}
_;
}
constructor(address admin) validAddress(admin) public {
require(msg.sender != admin);
whitelistedTransfer[admin] = true;
totalSupply_ = INITIAL_SUPPLY;
balances[admin] = totalSupply_;
emit Transfer(address(0x0), admin, totalSupply_);
transferOwnership(admin);
}
function addWhitelistedTransfer(address _address) onlyOwner public {
whitelistedTransfer[_address] = true;
}
function batchAddWhitelistedTransfer(address[] _addresses) onlyOwner public {
for (uint256 i = 0; i < _addresses.length; i++) {
whitelistedTransfer[_addresses[i]] = true;
}
}
function removeWhitelistedTransfer(address _address) onlyOwner public {
whitelistedTransfer[_address] = false;
}
function activeTransfer() onlyOwner public {
transferable = true;
}
function transfer(address _to, uint _value) public
validAddress(_to)
onlyWhenTransferable
returns (bool) {
return super.transfer(_to, _value);
}
function transferFrom(address _from, address _to, uint _value) public
validAddress(_to)
onlyWhenTransferable
returns (bool) {
return super.transferFrom(_from, _to, _value);
}
function batchTransfer(address[] _recipients, uint _value) public onlyWhenTransferable returns (bool) {
uint count = _recipients.length;
require(count > 0 && count <= 20);
uint needAmount = count.mul(_value);
require(_value > 0 && balances[msg.sender] >= needAmount);
for (uint i = 0; i < count; i++) {
transfer(_recipients[i], _value);
}
return true;
}
function burn(uint _value) public onlyWhenTransferable onlyOwner {
super.burn(_value);
}
}