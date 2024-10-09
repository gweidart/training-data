pragma solidity ^0.4.18;
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
interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) public; }
interface TokenUpgraderInterface{ function upgradeFor(address _for, uint256 _value) public returns (bool success); function upgradeFrom(address _by, address _for, uint256 _value) public returns (bool success); }
contract TokenERC20 {
using SafeMath for uint256;
address public owner = msg.sender;
string public name = "VIOLA";
string public symbol = "VIOLA";
uint8 public decimals = 18;
uint256 public totalSupply = 250000000 * 10 ** uint256(decimals);
bool public upgradable = false;
bool public upgraderSet = false;
TokenUpgraderInterface public upgrader;
mapping (address => uint256) public balanceOf;
mapping (address => mapping (address => uint256)) public allowance;
mapping (address => mapping (address => uint256)) allowed;
event Transfer(address indexed from, address indexed to, uint256 value);
event Burn(address indexed from, uint256 value);
modifier onlyOwner() {
require(msg.sender == owner);
_;
}
function TokenERC20() public {
balanceOf[msg.sender] = totalSupply;
}
function _transfer(address _from, address _to, uint _value) internal {
require(_to != 0x0);
require(balanceOf[_from] >= _value);
require(balanceOf[_to] + _value > balanceOf[_to]);
uint previousBalances = balanceOf[_from] + balanceOf[_to];
balanceOf[_from] -= _value;
balanceOf[_to] += _value;
Transfer(_from, _to, _value);
assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
}
function transfer(address _to, uint256 _value) public {
_transfer(msg.sender, _to, _value);
}
function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
require(_value <= allowance[_from][msg.sender]);
allowance[_from][msg.sender] -= _value;
_transfer(_from, _to, _value);
return true;
}
function approve(address _spender, uint256 _value) public
returns (bool success) {
allowance[msg.sender][_spender] = _value;
return true;
}
function approveAndCall(address _spender, uint256 _value, bytes _extraData)
public
returns (bool success) {
tokenRecipient spender = tokenRecipient(_spender);
if (approve(_spender, _value)) {
spender.receiveApproval(msg.sender, _value, this, _extraData);
return true;
}
}
function burn(uint256 _value) public returns (bool success) {
require(balanceOf[msg.sender] >= _value);
balanceOf[msg.sender] -= _value;
totalSupply -= _value;
Burn(msg.sender, _value);
return true;
}
function burnFrom(address _from, uint256 _value) public returns (bool success) {
require(balanceOf[_from] >= _value);
require(_value <= allowance[_from][msg.sender]);
balanceOf[_from] -= _value;
allowance[_from][msg.sender] -= _value;
totalSupply -= _value;
Burn(_from, _value);
return true;
}
function allowUpgrading(bool _newState) onlyOwner public returns (bool success) {
upgradable = _newState;
return true;
}
function setUpgrader(address _upgraderAddress) onlyOwner public returns (bool success) {
require(!upgraderSet);
require(_upgraderAddress != address(0));
upgraderSet = true;
upgrader = TokenUpgraderInterface(_upgraderAddress);
return true;
}
function upgrade() public returns (bool success) {
require(upgradable);
require(upgraderSet);
require(upgrader != TokenUpgraderInterface(0));
uint256 value = balanceOf[msg.sender];
assert(value > 0);
delete balanceOf[msg.sender];
totalSupply = totalSupply.sub(value);
assert(upgrader.upgradeFor(msg.sender, value));
return true;
}
function upgradeFor(address _for, uint256 _value) public returns (bool success) {
require(upgradable);
require(upgraderSet);
require(upgrader != TokenUpgraderInterface(0));
uint256 _allowance = allowed[_for][msg.sender];
require(_allowance >= _value);
balanceOf[_for] = balanceOf[_for].sub(_value);
allowed[_for][msg.sender] = _allowance.sub(_value);
totalSupply = totalSupply.sub(_value);
assert(upgrader.upgradeFrom(msg.sender, _for, _value));
return true;
}
function () payable external {
if (upgradable) {
assert(upgrade());
return;
}
revert();
}
}