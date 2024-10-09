pragma solidity ^0.4.0;
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
function balanceOf(address _owner) public view returns (uint256 balance) {
return balances[_owner];
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
contract SCCToken is StandardToken {
string public name = "Source Code Chain Token";
string public symbol = "SCC";
uint8 public decimals = 6;
uint public INITIAL_SUPPLY = 10000000000;
uint256 public exchange = 100000 * 10 ** uint256(decimals);
address public target;
address public foundationTarget;
uint256 public totalWeiReceived = 0;
uint public issueIndex = 0;
bool public isProgress = true;
event Issue(uint issueIndex, address addr, uint256 ethAmount, uint256 tokenAmount);
modifier owner {
if (target == msg.sender) {
_;
} else {
revert();
}
}
modifier progress {
if (isProgress) {
_;
} else {
revert();
}
}
function SCCToken(address _target, address _foundationTarget) public {
totalSupply_ = INITIAL_SUPPLY * 10 ** uint256(decimals);
target = _target;
foundationTarget = _foundationTarget;
balances[target] = 2000000000 * 10 ** uint256(decimals);
balances[foundationTarget] = 8000000000 * 10 ** uint256(decimals);
}
function () payable progress public {
assert(balances[target] > 0);
assert(msg.value >= 0.0001 ether);
uint256 tokens;
uint256 usingWeiAmount;
(tokens, usingWeiAmount) = computeTokenAmount(msg.value);
totalWeiReceived = totalWeiReceived.add(usingWeiAmount);
balances[target] = balances[target].sub(tokens);
balances[msg.sender] = balances[msg.sender].add(tokens);
emit Issue(
issueIndex++,
msg.sender,
usingWeiAmount,
tokens
);
if (!target.send(usingWeiAmount)) {
revert();
}
if(usingWeiAmount < msg.value) {
uint256 returnWeiAmount = msg.value - usingWeiAmount;
if(!msg.sender.send(returnWeiAmount)) {
revert();
}
}
}
function computeTokenAmount(uint256 weiAmount) internal view returns (uint256 tokens, uint256 usingWeiAmount) {
tokens = weiAmount.mul(exchange).div(10 ** uint256(18));
if(tokens <= balances[target]) {
usingWeiAmount = weiAmount;
}else {
tokens = balances[target];
usingWeiAmount = tokens.div(exchange).mul(10 ** uint256(18));
}
return (tokens, usingWeiAmount);
}
function changeOwner(address _target) owner public {
if(_target != target) {
balances[_target] = balances[_target].add(balances[target]);
balances[target] = 0;
target = _target;
}
}
}