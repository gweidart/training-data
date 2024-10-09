pragma solidity 0.4.23;
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
contract Ownable {
address public owner;
constructor() public {
owner = 0x6eDABCe168c6A63EB528B4fb83A0767d4e40E3B4;
}
modifier onlyOwner() {
require(msg.sender == owner);
_;
}
function transferOwnership(address newOwner) onlyOwner public {
require(newOwner != address(0));
owner = newOwner;
}
}
contract ERC20Basic {
uint256 public totalSupply;
function balanceOf(address who) constant public returns (uint256);
function transfer(address to, uint256 value) public returns (bool);
event Transfer(address indexed from, address indexed to, uint256 value);
}
contract ERC20 is ERC20Basic {
function allowance(address owner, address spender) constant public returns (uint256);
function transferFrom(address from, address to, uint256 value) public returns (bool);
function approve(address spender, uint256 value) public returns (bool);
event Approval(address indexed owner, address indexed spender, uint256 value);
}
contract PoSTokenStandard {
uint256 public stakeStartTime;
uint256 public stakeMinAge;
uint256 public stakeMaxAge;
function mint() public returns (bool);
function coinAge() constant public returns (uint256);
function annualInterest() constant public returns (uint256);
event Mint(address indexed _address, uint _reward);
}
contract PallyNetwork is ERC20,PoSTokenStandard,Ownable {
using SafeMath for uint256;
string public name = "PallyNetwork";
string public symbol = "Pally";
uint public decimals = 4;
uint public chainStartTime;
uint public stakeStartTime;
uint public stakeMinAge = 3 days;
uint public stakeMaxAge = 30 days;
uint public baseIntCalc = 10**uint256(decimals - 1);
uint public totalSupply;
uint public maxTotalSupply;
uint public totalInitialSupply;
struct transferInStruct{
uint128 amount;
uint64 time;
}
address GamificationRewards = 0x62874D9863626684ab0c7e8Bd8a977680304771D;
address AirdropDistribution = 0xCb58865a7DDf4B70354D689d640102F029C05b1f;
address BlockchainDev = 0xC493640aE532F41E1c3188985913eD3Ca8d31Fb9;
address MarketingAllocation = 0x609CBCa5674a1Ac2B8aA44214Cd6A4A8256Fd27f;
address BountyPayments = 0x1d0585571518F705E4fB12fc5C01659b6eDf71E6;
address PallyFoundation = 0x70F580B083D67949854A3A5cE1D6941504542AA8;
address TeamSalaries = 0x840Bf950be68260fcAa127111787f98c02a4d329;
mapping(address => uint256) balances;
mapping(address => mapping (address => uint256)) allowed;
mapping(address => transferInStruct[]) transferIns;
event Burn(address indexed burner, uint256 value);
modifier canPoSMint() {
require(totalSupply < maxTotalSupply);
_;
}
constructor() public {
uint64 _now = uint64(now);
maxTotalSupply = 7073844 * 10 ** uint256(decimals);
totalInitialSupply = 300000 * 10 ** uint256(decimals);
totalSupply = totalInitialSupply;
chainStartTime = now;
stakeStartTime = now;
balances[GamificationRewards] = 200000 * 10 ** uint256(decimals);
transferIns[GamificationRewards].push(transferInStruct(uint128(balances[GamificationRewards]),_now));
balances[AirdropDistribution] = 60000 * 10 ** uint256(decimals);
transferIns[AirdropDistribution].push(transferInStruct(uint128(balances[AirdropDistribution]),_now));
balances[BlockchainDev] =  10000 * 10 ** uint256(decimals);
transferIns[BlockchainDev].push(transferInStruct(uint128(balances[BlockchainDev]),_now));
balances[MarketingAllocation] =  10000 * 10 ** uint256(decimals);
transferIns[MarketingAllocation].push(transferInStruct(uint128(balances[MarketingAllocation]),_now));
balances[BountyPayments] =  5000 * 10 ** uint256(decimals);
transferIns[BountyPayments].push(transferInStruct(uint128(balances[BountyPayments]),_now));
balances[PallyFoundation] =  5000 * 10 ** uint256(decimals);
transferIns[PallyFoundation].push(transferInStruct(uint128(balances[PallyFoundation]),_now));
balances[TeamSalaries] =  10000 * 10 ** uint256(decimals);
transferIns[TeamSalaries].push(transferInStruct(uint128(balances[TeamSalaries]),_now));
emit Transfer(address(0), GamificationRewards, balances[GamificationRewards]);
emit Transfer(address(0), AirdropDistribution, balances[AirdropDistribution]);
emit Transfer(address(0), BlockchainDev, balances[BlockchainDev]);
emit Transfer(address(0), MarketingAllocation, balances[MarketingAllocation]);
emit Transfer(address(0), BountyPayments, balances[BountyPayments]);
emit Transfer(address(0), PallyFoundation, balances[PallyFoundation]);
emit Transfer(address(0), TeamSalaries, balances[TeamSalaries]);
}
function transfer(address _to, uint256 _value) public returns (bool) {
if(msg.sender == _to || _to == address(0)) return mint();
balances[msg.sender] = balances[msg.sender].sub(_value);
balances[_to] = balances[_to].add(_value);
emit Transfer(msg.sender, _to, _value);
if(transferIns[msg.sender].length > 0) delete transferIns[msg.sender];
uint64 _now = uint64(now);
transferIns[msg.sender].push(transferInStruct(uint128(balances[msg.sender]),_now));
transferIns[_to].push(transferInStruct(uint128(_value),_now));
return true;
}
function balanceOf(address _owner) constant public returns (uint256 balance) {
return balances[_owner];
}
function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
require(_to != address(0));
uint256 _allowance = allowed[_from][msg.sender];
balances[_from] = balances[_from].sub(_value);
balances[_to] = balances[_to].add(_value);
allowed[_from][msg.sender] = _allowance.sub(_value);
emit Transfer(_from, _to, _value);
if(transferIns[_from].length > 0) delete transferIns[_from];
uint64 _now = uint64(now);
transferIns[_from].push(transferInStruct(uint128(balances[_from]),_now));
transferIns[_to].push(transferInStruct(uint128(_value),_now));
return true;
}
function approve(address _spender, uint256 _value) public returns (bool) {
require((_value == 0) || (allowed[msg.sender][_spender] == 0));
allowed[msg.sender][_spender] = _value;
emit Approval(msg.sender, _spender, _value);
return true;
}
function allowance(address _owner, address _spender) constant public returns (uint256 remaining) {
return allowed[_owner][_spender];
}
function mint() canPoSMint public returns (bool) {
if(balances[msg.sender] <= 0) return false;
if(transferIns[msg.sender].length <= 0) return false;
uint reward = getProofOfStakeReward(msg.sender);
if(reward <= 0) return false;
totalSupply = totalSupply.add(reward);
balances[msg.sender] = balances[msg.sender].add(reward);
delete transferIns[msg.sender];
transferIns[msg.sender].push(transferInStruct(uint128(balances[msg.sender]),uint64(now)));
emit Mint(msg.sender, reward);
return true;
}
function coinAge() constant public returns (uint myCoinAge) {
return myCoinAge = getCoinAge(msg.sender,now);
}
function annualInterest() constant public returns(uint interest) {
uint _now = now;
interest = 0;
if((_now.sub(stakeStartTime)).div(1 years) == 0) {
interest = (2573 * baseIntCalc).div(100);
} else if((_now.sub(stakeStartTime)).div(1 years) <= 10){
interest = (97 * baseIntCalc).div(100);
}
}
function getProofOfStakeReward(address _address) public view returns (uint) {
require( (now >= stakeStartTime) && (stakeStartTime > 0) );
uint _now = now;
uint _coinAge = getCoinAge(_address, _now);
if(_coinAge == 0) return 0;
uint interest = 0;
if((_now.sub(stakeStartTime)).div(1 years) == 0) {
interest = (2573 * baseIntCalc).div(100);
} else if((_now.sub(stakeStartTime)).div(1 years) <= 10){
interest = (97 * baseIntCalc).div(100);
}
return (_coinAge * interest).div(365 * (10**uint256(decimals)));
}
function getCoinAge(address _address, uint _now) internal view returns (uint _coinAge) {
if(transferIns[_address].length <= 0) return 0;
for (uint i = 0; i < transferIns[_address].length; i++){
if( _now < uint(transferIns[_address][i].time).add(stakeMinAge) ) continue;
uint nCoinSeconds = _now.sub(uint(transferIns[_address][i].time));
if( nCoinSeconds > stakeMaxAge ) nCoinSeconds = stakeMaxAge;
_coinAge = _coinAge.add(uint(transferIns[_address][i].amount) * nCoinSeconds.div(1 days));
}
}
function ownerBurnToken(uint _value) onlyOwner public {
require(_value > 0);
balances[msg.sender] = balances[msg.sender].sub(_value);
delete transferIns[msg.sender];
transferIns[msg.sender].push(transferInStruct(uint128(balances[msg.sender]),uint64(now)));
totalSupply = totalSupply.sub(_value);
emit Burn(msg.sender, _value);
}
function batchTransfer(address[] _recipients, uint[] _values) onlyOwner public returns (bool) {
require( _recipients.length > 0 && _recipients.length == _values.length);
uint total = 0;
for(uint i = 0; i < _values.length; i++){
total = total.add(_values[i]);
}
require(total <= balances[msg.sender]);
uint64 _now = uint64(now);
for(uint j = 0; j < _recipients.length; j++){
balances[_recipients[j]] = balances[_recipients[j]].add(_values[j]);
transferIns[_recipients[j]].push(transferInStruct(uint128(_values[j]),_now));
emit Transfer(msg.sender, _recipients[j], _values[j]);
}
balances[msg.sender] = balances[msg.sender].sub(total);
if(transferIns[msg.sender].length > 0) delete transferIns[msg.sender];
if(balances[msg.sender] > 0) transferIns[msg.sender].push(transferInStruct(uint128(balances[msg.sender]),_now));
return true;
}
}