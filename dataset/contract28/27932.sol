pragma solidity 0.4.18;
contract Owned {
modifier only_owner { require(msg.sender == owner); _; }
event NewOwner(address indexed old, address indexed current);
function setOwner(address _new) only_owner public { NewOwner(owner, _new); owner = _new; }
address public owner = msg.sender;
}
library SafeMath {
function mul(uint256 a, uint256 b) internal constant returns (uint256) {
uint256 c = a * b;
assert(a == 0 || c / a == b);
return c;
}
function div(uint256 a, uint256 b) internal constant returns (uint256) {
uint256 c = a / b;
return c;
}
function sub(uint256 a, uint256 b) internal constant returns (uint256) {
assert(b <= a);
return a - b;
}
function add(uint256 a, uint256 b) internal constant returns (uint256) {
uint256 c = a + b;
assert(c >= a);
return c;
}
}
contract ERC20TokenInterface {
function totalSupply() constant returns (uint256 supply);
function balanceOf(address _owner) constant public returns (uint256 balance);
function transfer(address _to, uint256 _value) public returns (bool success);
function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
function approve(address _spender, uint256 _value) public returns (bool success);
function allowance(address _owner, address _spender) constant public returns (uint256 remaining);
event Transfer(address indexed from, address indexed to, uint256 value);
event Approval(address indexed owner, address indexed spender, uint256 value);
}
contract CanYaCoin is ERC20TokenInterface {
string public constant name = "CanYaCoin";
string public constant symbol = "CAN";
uint256 public constant decimals = 6;
uint256 public constant totalTokens = 100000000 * (10 ** decimals);
mapping (address => uint256) public balances;
mapping (address => mapping (address => uint256)) public allowed;
function CanYaCoin() {
balances[msg.sender] = totalTokens;
}
function totalSupply() constant returns (uint256) {
return totalTokens;
}
function transfer(address _to, uint256 _value) public returns (bool) {
if (balances[msg.sender] >= _value) {
balances[msg.sender] -= _value;
balances[_to] += _value;
Transfer(msg.sender, _to, _value);
return true;
}
return false;
}
function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value) {
balances[_from] -= _value;
allowed[_from][msg.sender] -= _value;
balances[_to] += _value;
Transfer(_from, _to, _value);
return true;
}
return false;
}
function balanceOf(address _owner) constant public returns (uint256) {
return balances[_owner];
}
function approve(address _spender, uint256 _value) public returns (bool) {
allowed[msg.sender][_spender] = _value;
Approval(msg.sender, _spender, _value);
return true;
}
function allowance(address _owner, address _spender) constant public returns (uint256 remaining) {
return allowed[_owner][_spender];
}
}
contract AssetSplit is Owned {
using SafeMath for uint256;
CanYaCoin public CanYaCoinToken;
address public operationalAddress;
address public rewardAddress;
address public charityAddress;
address public constant burnAddress = 0x000000000000000000000000000000000000dEaD;
uint256 public constant operationalSplitPercent = 30;
uint256 public constant rewardSplitPercent = 30;
uint256 public constant charitySplitPercent = 10;
uint256 public constant burnSplitPercent = 30;
event OperationalSplit(uint256 _split);
event RewardSplit(uint256 _split);
event CharitySplit(uint256 _split);
event BurnSplit(uint256 _split);
function AssetSplit (
address _tokenAddress,
address _operational,
address _reward,
address _charity) public {
require(_tokenAddress != 0);
require(_operational != 0);
require(_reward != 0);
require(_charity != 0);
CanYaCoinToken = CanYaCoin(_tokenAddress);
operationalAddress = _operational;
rewardAddress = _reward;
charityAddress = _charity;
}
function split (uint256 _amountToSplit) public only_owner {
require(_amountToSplit != 0);
require(CanYaCoinToken.allowance(owner, this) >= _amountToSplit);
uint256 onePercentOfSplit = _amountToSplit / 100;
uint256 operationalSplitAmount = onePercentOfSplit.mul(operationalSplitPercent);
uint256 rewardSplitAmount = onePercentOfSplit.mul(rewardSplitPercent);
uint256 charitySplitAmount = onePercentOfSplit.mul(charitySplitPercent);
uint256 burnSplitAmount = onePercentOfSplit.mul(burnSplitPercent);
require(
operationalSplitAmount
.add(rewardSplitAmount)
.add(charitySplitAmount)
.add(burnSplitAmount)
<= _amountToSplit
);
require(CanYaCoinToken.transferFrom(owner, operationalAddress, operationalSplitAmount));
require(CanYaCoinToken.transferFrom(owner, rewardAddress, rewardSplitAmount));
require(CanYaCoinToken.transferFrom(owner, charityAddress, charitySplitAmount));
require(CanYaCoinToken.transferFrom(owner, burnAddress, burnSplitAmount));
OperationalSplit(operationalSplitAmount);
RewardSplit(rewardSplitAmount);
CharitySplit(charitySplitAmount);
BurnSplit(burnSplitAmount);
}
}