pragma solidity ^0.4.21;
library SafeMath {
function mul(uint256 a, uint256 b) internal returns (uint256) {
uint256 c = a * b;
assert(a == 0 || c / a == b);
return c;
}
function div(uint256 a, uint256 b) internal returns (uint256) {
uint256 c = a / b;
return c;
}
function sub(uint256 a, uint256 b) internal returns (uint256) {
assert(b <= a);
return a - b;
}
function add(uint256 a, uint256 b) internal returns (uint256) {
uint256 c = a + b;
assert(c >= a);
return c;
}
}
contract Ownable {
address public owner;
function Ownable() public {
owner = msg.sender;
}
modifier onlyOwner() {
require(msg.sender == owner);
_;
}
function transferOwnership(address newOwner) onlyOwner external {
require(newOwner != address(0));
owner = newOwner;
}
}
contract ERC20Basic {
uint256 public totalSupply;
function balanceOf(address who) external constant returns (uint256);
function transfer(address to, uint256 value) external returns (bool);
event Transfer(address indexed from, address indexed to, uint256 value);
}
contract ERC20 is ERC20Basic {
function allowance(address owner, address spender) external constant returns (uint256);
function transferFrom(address from, address to, uint256 value) external returns (bool);
function approve(address spender, uint256 value) external returns (bool);
event Approval(address indexed owner, address indexed spender, uint256 value);
}
contract GameGoldTokenStandard {
uint256 public stakeStartTime;
uint256 public stakeMinAge;
uint256 public stakeMaxAge;
function mint() public returns (bool);
function coinAge() external constant returns (uint256);
function annualInterest() external constant returns (uint256);
event Mint(address indexed _address, uint _reward);
}
contract GameGoldToken is ERC20,GameGoldTokenStandard,Ownable {
using SafeMath for uint256;
string constant name = "Game Gold Token";
string constant symbol = "GGT";
uint constant decimals = 18;
uint public chainStartTime;
uint public chainStartBlockNumber;
uint public stakeStartTime;
uint constant stakeMinAge = 3 days;
uint constant stakeMaxAge = 90 days;
uint public maxMintProofOfStake;
uint public totalSupply;
uint public saleSupply;
uint public tokenPrice;
uint public alreadySold;
bool public saleIsGoing;
struct transferInStruct {
uint128 amount;
uint64 time;
}
mapping(address => uint256) balances;
mapping(address => mapping (address => uint256)) allowed;
mapping(address => transferInStruct[]) transferIns;
event Burn(address indexed burner, uint256 value);
modifier onlyPayloadSize(uint size) {
require(msg.data.length >= size + 4);
_;
}
modifier onlyIfSaleIsGoing() {
require(saleIsGoing);
_;
}
function GameGoldToken() public {
chainStartTime = now;
chainStartBlockNumber = block.number;
totalSupply = 555000000*10**decimals;
saleSupply = 294150000*10**decimals;
tokenPrice = 0.00035 ether;
alreadySold = 0;
balances[owner] = totalSupply;
Transfer(address(0), owner, totalSupply);
maxMintProofOfStake = 138750000*10**decimals;
saleIsGoing = true;
}
function updateSaleStatus() external onlyOwner returns(bool) {
saleIsGoing = !saleIsGoing;
return true;
}
function setPrice(uint _newPrice) external onlyOwner returns(bool) {
require(_newPrice >= 0);
tokenPrice = _newPrice;
return true;
}
function balanceOf(address _owner) constant external returns (uint256 balance) {
return balances[_owner];
}
function transfer(address _to, uint256 _value) onlyPayloadSize(2 * 32) external returns (bool) {
if(msg.sender == _to) return mint();
balances[msg.sender] = balances[msg.sender].sub(_value);
balances[_to] = balances[_to].add(_value);
Transfer(msg.sender, _to, _value);
if(transferIns[msg.sender].length > 0) delete transferIns[msg.sender];
uint64 _now = uint64(now);
transferIns[msg.sender].push(transferInStruct(uint128(balances[msg.sender]),_now));
transferIns[_to].push(transferInStruct(uint128(_value),_now));
return true;
}
function transferFrom(address _from, address _to, uint256 _value) onlyPayloadSize(3 * 32) external returns (bool) {
require(_to != address(0));
uint _allowance = uint(allowed[_from][msg.sender]);
balances[_from] = balances[_from].sub(_value);
balances[_to] = balances[_to].add(_value);
allowed[_from][msg.sender] = _allowance.sub(_value);
Transfer(_from, _to, _value);
if(transferIns[_from].length > 0) delete transferIns[_from];
uint64 _now = uint64(now);
transferIns[_from].push(transferInStruct(uint128(balances[_from]),_now));
transferIns[_to].push(transferInStruct(uint128(_value),_now));
return true;
}
function approve(address _spender, uint256 _value) external returns (bool) {
require(_value == 0 || allowed[msg.sender][_spender] == 0);
allowed[msg.sender][_spender] = _value;
Approval(msg.sender, _spender, _value);
return true;
}
function allowance(address _owner, address _spender) external constant returns (uint256 remaining) {
return allowed[_owner][_spender];
}
function withdraw(uint amount) public onlyOwner returns(bool) {
require(amount <= address(this).balance);
owner.transfer(address(this).balance);
return true;
}
function ownerMint(uint _amount) public onlyOwner returns (bool) {
uint amount = _amount * 10**decimals;
require(totalSupply.add(amount) <= 2**256 - 1 && balances[owner].add(amount) <= 2**256 - 1);
totalSupply = totalSupply.add(amount);
balances[owner] = balances[owner].add(amount);
Transfer(address(0), owner, amount);
return true;
}
function mint() public returns (bool) {
if(balances[msg.sender] <= 0 || transferIns[msg.sender].length <= 0) return false;
uint reward = getProofOfStakeReward(msg.sender);
if(reward <= 0) return false;
totalSupply = totalSupply.add(reward);
balances[msg.sender] = balances[msg.sender].add(reward);
delete transferIns[msg.sender];
transferIns[msg.sender].push(transferInStruct(uint128(balances[msg.sender]),uint64(now)));
Mint(msg.sender, reward);
return true;
}
function getBlockNumber() external constant returns (uint blockNumber) {
blockNumber = block.number.sub(chainStartBlockNumber);
}
function coinAge() external constant returns (uint myCoinAge) {
myCoinAge = getCoinAge(msg.sender,now);
}
function annualInterest() external constant returns(uint) {
return maxMintProofOfStake;
}
function getProofOfStakeReward(address _address) internal constant returns (uint) {
require( (now >= stakeStartTime) && (stakeStartTime > 0) );
uint _now = now;
uint _coinAge = getCoinAge(_address, _now);
if(_coinAge <= 0) return 0;
uint interest = maxMintProofOfStake;
return (_coinAge * interest).div(365 * (10**decimals));
}
function getCoinAge(address _address, uint _now) internal constant returns (uint _coinAge) {
if(transferIns[_address].length <= 0) return 0;
for (uint i = 0; i < transferIns[_address].length; i++){
if( _now < uint(transferIns[_address][i].time).add(stakeMinAge) ) continue;
uint nCoinSeconds = _now.sub(uint(transferIns[_address][i].time));
if( nCoinSeconds > stakeMaxAge ) nCoinSeconds = stakeMaxAge;
_coinAge = _coinAge.add(uint(transferIns[_address][i].amount) * nCoinSeconds.div(1 days));
}
}
function ownerSetStakeStartTime(uint timestamp) onlyOwner external {
require((stakeStartTime <= 0) && (timestamp >= chainStartTime));
stakeStartTime = timestamp;
}
function ownerBurnToken(uint _value) onlyOwner external {
require(_value > 0);
balances[msg.sender] = balances[msg.sender].sub(_value);
delete transferIns[msg.sender];
transferIns[msg.sender].push(transferInStruct(uint128(balances[msg.sender]),uint64(now)));
totalSupply = totalSupply.sub(_value);
Burn(msg.sender, _value);
}
function batchTransfer(address[] _recipients, uint[] _values) onlyOwner public returns (uint) {
require( _recipients.length > 0 && _recipients.length == _values.length);
uint total = 0;
assembly {
let len := mload(_values)
for { let i := 0 } lt(i, len) { i := add(i, 1) } {
total := add(total, mload(add(add(_values, 0x20), mul(i, 0x20))))
}
}
require(total <= balances[msg.sender]);
uint64 _now = uint64(now);
for(uint j = 0; j < _recipients.length; j++){
balances[_recipients[j]] = balances[_recipients[j]].add(_values[j]);
transferIns[_recipients[j]].push(transferInStruct(uint128(_values[j]),_now));
Transfer(msg.sender, _recipients[j], _values[j]);
}
balances[msg.sender] = balances[msg.sender].sub(total);
if(transferIns[msg.sender].length > 0) delete transferIns[msg.sender];
if(balances[msg.sender] > 0) transferIns[msg.sender].push(transferInStruct(uint128(balances[msg.sender]),_now));
return total;
}
function() public onlyIfSaleIsGoing payable {
require(msg.value >= tokenPrice);
uint tokenAmount = (msg.value / tokenPrice) * 10 ** decimals;
require(alreadySold.add(tokenAmount) <= saleSupply);
balances[owner] = balances[owner].sub(tokenAmount);
balances[msg.sender] = balances[msg.sender].add(tokenAmount);
alreadySold = alreadySold.add(tokenAmount);
Transfer(owner, msg.sender, tokenAmount);
}
}