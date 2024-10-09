pragma solidity 0.4.24;
library SafeMath {
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
contract admined {
address public admin;
address public allowedAddress;
bool public lockSupply;
bool public lockTransfer = true;
constructor() internal {
admin = 0xEFfea09df22E0B25655BD3f23D9B531ba47d2A8B;
emit Admined(admin);
}
modifier onlyAdmin() {
require(msg.sender == admin);
_;
}
modifier onlyAllowed() {
require(msg.sender == allowedAddress || msg.sender == admin || lockTransfer == false);
_;
}
modifier supplyLock() {
require(lockSupply == false);
_;
}
function transferAdminship(address _newAdmin) onlyAdmin public {
require(_newAdmin != 0);
admin = _newAdmin;
emit TransferAdminship(admin);
}
function setAllowed(address _newAllowed) onlyAdmin public {
allowedAddress = _newAllowed;
emit SetAllowedAddress(allowedAddress);
}
function setSupplyLock(bool _flag) onlyAdmin public {
lockSupply = _flag;
emit SetSupplyLock(lockSupply);
}
function setTransferLock(bool _flag) onlyAdmin public {
lockTransfer = _flag;
emit SetTransferLock(lockTransfer);
}
event SetSupplyLock(bool _set);
event SetTransferLock(bool _set);
event SetAllowedAddress(address newAllowed);
event TransferAdminship(address newAdminister);
event Admined(address administer);
}
contract ERC20 {
function totalSupply() public view returns (uint256);
function balanceOf(address who) public view returns (uint256);
function transfer(address to, uint256 value) public returns (bool);
function allowance(address owner, address spender) public view returns (uint256);
function transferFrom(address from, address to, uint256 value) public returns (bool);
function approve(address spender, uint256 value) public returns (bool);
event Transfer(address indexed from, address indexed to, uint256 value);
event Approval(address indexed owner, address indexed spender, uint256 value);
}
contract ERC20Token is admined, ERC20 {
using SafeMath for uint256;
mapping (address => uint256) internal balances;
mapping (address => mapping (address => uint256)) internal allowed;
uint256 internal totalSupply_;
function totalSupply() public view returns (uint256) {
return totalSupply_;
}
function balanceOf(address _who) public view returns (uint256) {
return balances[_who];
}
function transfer(address _to, uint256 _value) onlyAllowed() public returns (bool) {
require(_to != address(0));
balances[msg.sender] = balances[msg.sender].sub(_value);
balances[_to] = balances[_to].add(_value);
emit Transfer(msg.sender, _to, _value);
return true;
}
function allowance(address _owner, address _spender) public view returns (uint256) {
return allowed[_owner][_spender];
}
function transferFrom(address _from, address _to, uint256 _value) onlyAllowed() public returns (bool) {
require(_to != address(0));
balances[_from] = balances[_from].sub(_value);
allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
balances[_to] = balances[_to].add(_value);
emit Transfer(_from, _to, _value);
return true;
}
function approve(address _spender, uint256 _value) public returns (bool) {
require((_value == 0) || (allowed[msg.sender][_spender] == 0));
allowed[msg.sender][_spender] = _value;
emit Approval(msg.sender, _spender, _value);
return true;
}
function burnToken(uint256 _burnedAmount) supplyLock() onlyAllowed() public returns (bool){
balances[msg.sender] = SafeMath.sub(balances[msg.sender], _burnedAmount);
totalSupply_ = SafeMath.sub(totalSupply_, _burnedAmount);
emit Burned(msg.sender, _burnedAmount);
return true;
}
event Burned(address indexed _target, uint256 _value);
}
contract AssetCirca is ERC20Token {
string public name = 'Circa';
uint8 public decimals = 18;
string public symbol = 'CIR';
string public version = '1';
constructor() public {
totalSupply_ = 1000000000 * 10 ** uint256(decimals);
balances[0xEB53AD38f0C37C0162E3D1D4666e63a55EfFC65f] = totalSupply_ / 1000;
balances[0xEFfea09df22E0B25655BD3f23D9B531ba47d2A8B] = totalSupply_.sub(balances[0xEB53AD38f0C37C0162E3D1D4666e63a55EfFC65f]);
emit Transfer(0, this, totalSupply_);
emit Transfer(this, 0xEB53AD38f0C37C0162E3D1D4666e63a55EfFC65f, balances[0xEB53AD38f0C37C0162E3D1D4666e63a55EfFC65f]);
emit Transfer(this, 0xEFfea09df22E0B25655BD3f23D9B531ba47d2A8B, balances[0xEFfea09df22E0B25655BD3f23D9B531ba47d2A8B]);
}
function() public {
revert();
}
}