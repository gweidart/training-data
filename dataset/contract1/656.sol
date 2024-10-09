pragma solidity ^0.4.24;
contract ERC20Basic {
function totalSupply() public view returns (uint256);
function balanceOf(address _who) public view returns (uint256);
function transfer(address _to, uint256 _value) public returns (bool);
event Transfer(address indexed from, address indexed to, uint256 value);
}
library SafeMath {
function mul(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
if (_a == 0) {
return 0;
}
c = _a * _b;
assert(c / _a == _b);
return c;
}
function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
return _a / _b;
}
function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
assert(_b <= _a);
return _a - _b;
}
function add(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
c = _a + _b;
assert(c >= _a);
return c;
}
}
contract BasicToken is ERC20Basic {
using SafeMath for uint256;
mapping(address => uint256) internal balances;
uint256 internal totalSupply_;
function totalSupply() public view returns (uint256) {
return totalSupply_;
}
function transfer(address _to, uint256 _value) public returns (bool) {
require(_value <= balances[msg.sender]);
require(_to != address(0));
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
function allowance(address _owner, address _spender)
public view returns (uint256);
function transferFrom(address _from, address _to, uint256 _value)
public returns (bool);
function approve(address _spender, uint256 _value) public returns (bool);
event Approval(
address indexed owner,
address indexed spender,
uint256 value
);
}
contract StandardToken is ERC20, BasicToken {
mapping (address => mapping (address => uint256)) internal allowed;
function transferFrom(
address _from,
address _to,
uint256 _value
)
public
returns (bool)
{
require(_value <= balances[_from]);
require(_value <= allowed[_from][msg.sender]);
require(_to != address(0));
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
function allowance(
address _owner,
address _spender
)
public
view
returns (uint256)
{
return allowed[_owner][_spender];
}
function increaseApproval(
address _spender,
uint256 _addedValue
)
public
returns (bool)
{
allowed[msg.sender][_spender] = (
allowed[msg.sender][_spender].add(_addedValue));
emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
return true;
}
function decreaseApproval(
address _spender,
uint256 _subtractedValue
)
public
returns (bool)
{
uint256 oldValue = allowed[msg.sender][_spender];
if (_subtractedValue >= oldValue) {
allowed[msg.sender][_spender] = 0;
} else {
allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
}
emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
return true;
}
}
contract StandardBurnableToken is BurnableToken, StandardToken {
function burnFrom(address _from, uint256 _value) public {
require(_value <= allowed[_from][msg.sender]);
allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
_burn(_from, _value);
}
}
contract Ownable {
address public owner;
event OwnershipRenounced(address indexed previousOwner);
event OwnershipTransferred(
address indexed previousOwner,
address indexed newOwner
);
constructor() public {
owner = msg.sender;
}
modifier onlyOwner() {
require(msg.sender == owner);
_;
}
function renounceOwnership() public onlyOwner {
emit OwnershipRenounced(owner);
owner = address(0);
}
function transferOwnership(address _newOwner) public onlyOwner {
_transferOwnership(_newOwner);
}
function _transferOwnership(address _newOwner) internal {
require(_newOwner != address(0));
emit OwnershipTransferred(owner, _newOwner);
owner = _newOwner;
}
}
contract Ambix is Ownable {
address[][] public A;
uint256[][] public N;
address[] public B;
uint256[] public M;
function appendSource(
address[] _a,
uint256[] _n
) external onlyOwner {
require(_a.length == _n.length);
for (uint256 i = 0; i < _a.length; ++i)
require(_a[i] != 0);
A.push(_a);
N.push(_n);
}
function setSink(
address[] _b,
uint256[] _m
) external onlyOwner{
require(_b.length == _m.length);
for (uint256 i = 0; i < _b.length; ++i)
require(_b[i] != 0);
B = _b;
M = _m;
}
function run(uint256 _ix) public {
require(_ix < A.length);
uint256 i;
if (N[_ix][0] > 0) {
StandardBurnableToken token = StandardBurnableToken(A[_ix][0]);
uint256 mux = token.allowance(msg.sender, this) / N[_ix][0];
require(mux > 0);
for (i = 0; i < A[_ix].length; ++i) {
token = StandardBurnableToken(A[_ix][i]);
require(token.transferFrom(msg.sender, this, mux * N[_ix][i]));
token.burn(mux * N[_ix][i]);
}
for (i = 0; i < B.length; ++i) {
token = StandardBurnableToken(B[i]);
require(token.transfer(msg.sender, M[i] * mux));
}
} else {
require(A[_ix].length == 1 && B.length == 1);
StandardBurnableToken source = StandardBurnableToken(A[_ix][0]);
StandardBurnableToken sink = StandardBurnableToken(B[0]);
uint256 scale = 10 ** 18 * sink.balanceOf(this) / source.totalSupply();
uint256 allowance = source.allowance(msg.sender, this);
require(allowance > 0);
require(source.transferFrom(msg.sender, this, allowance));
source.burn(allowance);
uint256 reward = scale * allowance / 10 ** 18;
require(reward > 0);
require(sink.transfer(msg.sender, reward));
}
}
}