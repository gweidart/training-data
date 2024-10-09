pragma solidity ^0.4.18;
contract ERC20 {
uint256 public totalSupply;
function balanceOf(address who) public view returns (uint256);
function transfer(address to, uint256 value) public returns (bool);
event Transfer(address indexed from, address indexed to, uint256 value);
function allowance(address owner, address spender) public view returns (uint256);
function transferFrom(address from, address to, uint256 value) public returns (bool);
function approve(address spender, uint256 value) public returns (bool);
event Approval(address indexed owner, address indexed spender, uint256 value);
}
contract BasicToken is ERC20 {
using SafeMath for uint256;
mapping(address => uint256) balances;
mapping (address => mapping (address => uint256)) allowed;
function transfer(address _to, uint256 _value) public returns (bool) {
if (balances[msg.sender] >= _value && balances[_to] + _value > balances[_to]) {
balances[msg.sender] = balances[msg.sender].sub(_value);
balances[_to] = balances[_to].add(_value);
Transfer(msg.sender, _to, _value);
return true;
}else {
return false;
}
}
function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && balances[_to] + _value > balances[_to]) {
uint256 _allowance = allowed[_from][msg.sender];
allowed[_from][msg.sender] = _allowance.sub(_value);
balances[_to] = balances[_to].add(_value);
balances[_from] = balances[_from].sub(_value);
Transfer(_from, _to, _value);
return true;
} else {
return false;
}
}
function balanceOf(address _owner) public view returns (uint256 balance) {
return balances[_owner];
}
function approve(address _spender, uint256 _value) public returns (bool) {
require((_value == 0) || (allowed[msg.sender][_spender] == 0));
allowed[msg.sender][_spender] = _value;
Approval(msg.sender, _spender, _value);
return true;
}
function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
return allowed[_owner][_spender];
}
}
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
contract ANOToken is BasicToken {
using SafeMath for uint256;
string public name = "Anonium";
string public symbol = "ANO";
uint8 public decimals = 18;
uint256 public totalSupply = 21000000000 * 10**18;
uint256 public tokensAllocatedToCrowdFund;
uint256 public totalAllocatedTokens;
address public crowdFundAddress;
address public founderMultiSigAddress;
event ChangeFoundersWalletAddress(uint256  _blockTimeStamp, address indexed _foundersWalletAddress);
modifier onlyCrowdFundAddress() {
require(msg.sender == crowdFundAddress);
_;
}
modifier nonZeroAddress(address _to) {
require(_to != 0x0);
_;
}
modifier onlyFounders() {
require(msg.sender == founderMultiSigAddress);
_;
}
function ANOToken (address _crowdFundAddress) public {
crowdFundAddress = _crowdFundAddress;
founderMultiSigAddress = msg.sender;
tokensAllocatedToCrowdFund = totalSupply;
balances[crowdFundAddress] = tokensAllocatedToCrowdFund;
}
function changeSupply(uint256 _amount) public onlyCrowdFundAddress {
totalAllocatedTokens += _amount;
}
function changeFounderMultiSigAddress(address _newFounderMultiSigAddress) public onlyFounders nonZeroAddress(_newFounderMultiSigAddress) {
founderMultiSigAddress = _newFounderMultiSigAddress;
ChangeFoundersWalletAddress(now, founderMultiSigAddress);
}
function burnToken() public onlyCrowdFundAddress returns (bool) {
totalSupply = totalSupply.sub(balances[msg.sender]);
balances[msg.sender] = 0;
return true;
}
}