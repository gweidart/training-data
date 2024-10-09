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
contract admined {
address public admin;
function admined() internal {
admin = msg.sender;
emit Admined(admin);
}
modifier onlyAdmin() {
require(msg.sender == admin);
_;
}
function transferAdminship(address _newAdmin) onlyAdmin public {
require(_newAdmin != 0);
admin = _newAdmin;
emit TransferAdminship(admin);
}
event TransferAdminship(address newAdminister);
event Admined(address administer);
}
contract ERC20TokenInterface {
function balanceOf(address _owner) public constant returns (uint256 balance);
function transfer(address _to, uint256 _value) public returns (bool success);
function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
function approve(address _spender, uint256 _value) public returns (bool success);
function allowance(address _owner, address _spender) public constant returns (uint256 remaining);
}
contract ERC20Token is admined, ERC20TokenInterface {
using SafeMath for uint256;
uint256 public totalSupply;
mapping (address => uint256) balances;
mapping (address => mapping (address => uint256)) allowed;
function balanceOf(address _owner) public constant returns (uint256 value) {
return balances[_owner];
}
function transfer(address _to, uint256 _value) public returns (bool success) {
require(_to != address(0));
balances[msg.sender] = balances[msg.sender].sub(_value);
balances[_to] = balances[_to].add(_value);
emit Transfer(msg.sender, _to, _value);
return true;
}
function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
require(_to != address(0));
balances[_from] = balances[_from].sub(_value);
allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
balances[_to] = balances[_to].add(_value);
emit Transfer(_from, _to, _value);
return true;
}
function approve(address _spender, uint256 _value) public returns (bool success) {
require(_value == 0 || allowed[msg.sender][_spender] == 0);
allowed[msg.sender][_spender] = _value;
emit Approval(msg.sender, _spender, _value);
return true;
}
function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
return allowed[_owner][_spender];
}
event Transfer(address indexed _from, address indexed _to, uint256 _value);
event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}
contract AssetDK3 is ERC20Token {
string public name ='Donkey3';
uint8 public decimals = 18;
string public symbol = 'DK3';
string public version = '1';
function AssetDK3() public {
totalSupply = 700000000 * (10 ** uint256(decimals));
balances[msg.sender] = totalSupply;
emit Transfer(0, this, totalSupply);
emit Transfer(this, msg.sender, totalSupply);
}
function claimTokens(ERC20TokenInterface _address, address _to) onlyAdmin public{
require(_to != address(0));
uint256 remainder = _address.balanceOf(this);
_address.transfer(_to,remainder);
}
function() public {
revert();
}
}