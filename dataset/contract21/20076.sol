pragma solidity 0.4.21;
library SafeMath {
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
contract ERC20TokenInterface {
function balanceOf(address _owner) public constant returns (uint256 value);
function transfer(address _to, uint256 _value) public returns (bool success);
function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
function approve(address _spender, uint256 _value) public returns (bool success);
function allowance(address _owner, address _spender) public constant returns (uint256 remaining);
}
contract admined {
address public admin;
bool public lockSupply;
bool public lockTransfer;
address public allowedAddress;
function admined() internal {
admin = msg.sender;
emit Admined(admin);
}
function setAllowedAddress(address _to) onlyAdmin public {
allowedAddress = _to;
emit AllowedSet(_to);
}
modifier onlyAdmin() {
require(msg.sender == admin);
_;
}
modifier supplyLock() {
require(lockSupply == false);
_;
}
modifier transferLock() {
require(lockTransfer == false || allowedAddress == msg.sender);
_;
}
function transferAdminship(address _newAdmin) onlyAdmin public {
require(_newAdmin != 0);
admin = _newAdmin;
emit TransferAdminship(admin);
}
function setSupplyLock(bool _set) onlyAdmin public {
lockSupply = _set;
emit SetSupplyLock(_set);
}
function setTransferLock(bool _set) onlyAdmin public {
lockTransfer = _set;
emit SetTransferLock(_set);
}
event AllowedSet(address _to);
event SetSupplyLock(bool _set);
event SetTransferLock(bool _set);
event TransferAdminship(address newAdminister);
event Admined(address administer);
}
contract ERC20Token is ERC20TokenInterface, admined {
using SafeMath for uint256;
uint256 public totalSupply;
mapping (address => uint256) balances;
mapping (address => mapping (address => uint256)) allowed;
function balanceOf(address _owner) public constant returns (uint256 value) {
return balances[_owner];
}
function transfer(address _to, uint256 _value) transferLock public returns (bool success) {
require(_to != address(0));
balances[msg.sender] = balances[msg.sender].sub(_value);
balances[_to] = balances[_to].add(_value);
emit Transfer(msg.sender, _to, _value);
return true;
}
function transferFrom(address _from, address _to, uint256 _value) transferLock public returns (bool success) {
require(_to != address(0));
allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
balances[_from] = balances[_from].sub(_value);
balances[_to] = balances[_to].add(_value);
emit Transfer(_from, _to, _value);
return true;
}
function approve(address _spender, uint256 _value) public returns (bool success) {
allowed[msg.sender][_spender] = _value;
emit Approval(msg.sender, _spender, _value);
return true;
}
function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
return allowed[_owner][_spender];
}
function mintToken(uint256 _mintedAmount) onlyAdmin supplyLock public {
require(totalSupply.add(_mintedAmount) < 250000000 * (10**18));
balances[msg.sender] = SafeMath.add(balances[msg.sender], _mintedAmount);
totalSupply = SafeMath.add(totalSupply, _mintedAmount);
emit Transfer(0, this, _mintedAmount);
emit Transfer(this, msg.sender, _mintedAmount);
}
function burnToken(uint256 _burnedAmount) onlyAdmin supplyLock public {
balances[msg.sender] = SafeMath.sub(balances[msg.sender], _burnedAmount);
totalSupply = SafeMath.sub(totalSupply, _burnedAmount);
emit Burned(msg.sender, _burnedAmount);
}
function batch(address[] data,uint256[] amount) public {
require(data.length == amount.length);
for (uint i=0; i<data.length; i++) {
transfer(data[i],amount[i]);
}
}
event Transfer(address indexed _from, address indexed _to, uint256 _value);
event Approval(address indexed _owner, address indexed _spender, uint256 _value);
event Burned(address indexed _target, uint256 _value);
}
contract Asset is ERC20Token {
string public name = 'Citereum';
uint8 public decimals = 18;
string public symbol = 'CTR';
string public version = '1';
function Asset() public {
totalSupply = 12500000 * (10**uint256(decimals));
balances[msg.sender] = totalSupply;
emit Transfer(0, this, totalSupply);
emit Transfer(this, msg.sender, balances[msg.sender]);
}
function() public {
revert();
}
}