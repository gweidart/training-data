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
contract Ownable {
address public owner;
function Ownable() public {
}
modifier onlyOwner() {
require(msg.sender == owner);
_;
}
function transferOwnership(address newOwner) internal onlyOwner {
require(newOwner != address(0));
owner = newOwner;
}
}
contract ERC20Basic {
uint256 public totalSupply;
function balanceOf(address who) public returns (uint256);
function transfer(address to, uint256 value) public returns (bool);
event Transfer(address indexed from, address indexed to, uint256 value);
}
contract ERC20 is ERC20Basic {
function allowance(address owner, address spender) public returns (uint256);
function transferFrom(address from, address to, uint256 value) public returns (bool);
function approve(address spender, uint256 value) public returns (bool);
event Approval(address indexed owner, address indexed spender, uint256 value);
}
contract PoSTokenStandard {
uint256 public stakeStartTime;
uint256 public stakeMinAge;
uint256 public stakeMaxAge;
function mine() public  returns (bool);
function coinAge(address who) public  returns (uint256);
function annualInterest() public  returns (uint256);
event Mine(address indexed _address, uint _reward);
}
contract CoinVila is ERC20,PoSTokenStandard,Ownable {
using SafeMath for uint256;
string public name = "CoinVila";
string public symbol = "VILA";
uint public decimals = 18;
uint public chainStartTime;
uint public chainStartBlockNumber;
uint public stakeStartTime;
uint public stakeMinAge = 3 days;
uint public stakeMaxAge = 90 days;
uint public maxMintProofOfStake = 10**17;
uint public totalSupply;
uint public maxTotalSupply = 27 * (10**6) * (10**uint256(decimals));
uint public totalInitialSupply = 250 * (10**3) * (10**uint256(decimals));
uint256 public INITIAL_SUPPLY = 250 * (10**3) * (10 ** uint256(decimals));
address public addressFundTeam = 0x457b4c64F4Fe2854CD2039d4595AA130FAF109Fe;
address public addressFundAirdrop = 0xC16994e63E1A24511A5a1f7BA842f3738fa003f5;
address public addressFundBounty = 0xbCCCd34da9b5E73036AdEBEd25460F0c29f16EC9;
address public addressFundPlatform = 0x4853E66582Bd4c0787785Fc31584a14CB43c5DC3;
address public addressFundHolder = 0x771582104379Bb5C6AFf39023843F19aF046ADE8;
uint256 public amountFundTeam = 25 * (10**3) * (10**uint256(decimals));
uint256 public amountFundAirdrop = 130 * (10**3) * (10**uint256(decimals));
uint256 public amountFundBounty = 20 * (10**3) * (10**uint256(decimals));
uint256 public amountFundPlatform = 50 * (10**3) * (10**uint256(decimals));
uint256 public amountFundHolder = 25 * (10**3) * (10**uint256(decimals));
struct transferInStruct{
uint128 amount;
uint64 time;
}
mapping(address => uint256) balances;
mapping(address => mapping (address => uint256)) allowed;
mapping(address => transferInStruct[]) transferIns;
modifier onlyPayloadSize(uint size) {
require(msg.data.length >= size + 4);
_;
}
modifier canPoSMint() {
require(totalSupply < maxTotalSupply);
_;
}
function CoinVila(address _owner) public {
require(_owner != address(0));
owner = _owner;
CoinVilaStart();
}
function CoinVilaStart() private {
uint64 _now = uint64(now);
totalSupply = totalInitialSupply;
chainStartTime = now;
chainStartBlockNumber = block.number;
balances[addressFundTeam] = amountFundTeam;
transferIns[addressFundTeam].push(transferInStruct(uint128(amountFundTeam),_now));
balances[addressFundHolder] = amountFundHolder;
transferIns[addressFundHolder].push(transferInStruct(uint128(amountFundHolder),_now));
balances[addressFundAirdrop] = amountFundAirdrop;
transferIns[addressFundAirdrop].push(transferInStruct(uint128(amountFundAirdrop),_now));
balances[addressFundBounty] = amountFundBounty;
transferIns[addressFundBounty].push(transferInStruct(uint128(amountFundBounty),_now));
balances[addressFundPlatform] = amountFundPlatform;
transferIns[addressFundPlatform].push(transferInStruct(uint128(amountFundPlatform),_now));
}
function transfer(address _to, uint256 _value) onlyPayloadSize(2 * 32) public returns (bool) {
if(msg.sender == _to) return mine();
balances[msg.sender] = balances[msg.sender].sub(_value);
balances[_to] = balances[_to].add(_value);
Transfer(msg.sender, _to, _value);
if(transferIns[msg.sender].length > 0) delete transferIns[msg.sender];
uint64 _now = uint64(now);
transferIns[msg.sender].push(transferInStruct(uint128(balances[msg.sender]),_now));
transferIns[_to].push(transferInStruct(uint128(_value),_now));
return true;
}
function balanceOf(address _owner) public returns (uint256 balance) {
return balances[_owner];
}
function transferFrom(address _from, address _to, uint256 _value) onlyPayloadSize(3 * 32) public returns (bool) {
require(_to != address(0));
var _allowance = allowed[_from][msg.sender];
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
function approve(address _spender, uint256 _value) public returns (bool) {
require((_value == 0) || (allowed[msg.sender][_spender] == 0));
allowed[msg.sender][_spender] = _value;
Approval(msg.sender, _spender, _value);
return true;
}
function allowance(address _owner, address _spender) public returns (uint256 remaining) {
return allowed[_owner][_spender];
}
function mine() canPoSMint public returns (bool) {
if(balances[msg.sender] <= 0) return false;
if(transferIns[msg.sender].length <= 0) return false;
uint reward = getProofOfStakeReward(msg.sender);
if(reward <= 0) return false;
totalSupply = totalSupply.add(reward);
balances[msg.sender] = balances[msg.sender].add(reward);
delete transferIns[msg.sender];
transferIns[msg.sender].push(transferInStruct(uint128(balances[msg.sender]),uint64(now)));
Mine(msg.sender, reward);
return true;
}
function getBlockNumber() public view returns (uint blockNumber) {
blockNumber = block.number.sub(chainStartBlockNumber);
}
function coinAge(address who) public returns (uint myCoinAge) {
myCoinAge = getCoinAge(who,now);
}
function annualInterest() public returns(uint interest) {
uint _now = now;
interest = maxMintProofOfStake;
if((_now.sub(stakeStartTime)).div(1 years) == 0) {
interest = (1650 * maxMintProofOfStake).div(100);
} else if((_now.sub(stakeStartTime).div(1 years) == 1) || (_now.sub(stakeStartTime).div(1 years) == 2) ||
(_now.sub(stakeStartTime).div(1 years) == 3)){
interest = (770 * maxMintProofOfStake).div(100);
} else if((_now.sub(stakeStartTime).div(1 years) == 4) || (_now.sub(stakeStartTime).div(1 years) == 5) ||
(_now.sub(stakeStartTime).div(1 years) == 6)){
interest = (435 * maxMintProofOfStake).div(100);
}
}
function getProofOfStakeReward(address _address) internal view returns (uint) {
require( (now >= stakeStartTime) && (stakeStartTime > 0) );
uint _now = now;
uint _coinAge = getCoinAge(_address, _now);
if(_coinAge <= 0) return 0;
uint interest = maxMintProofOfStake;
if((_now.sub(stakeStartTime)).div(1 years) == 0) {
interest = (1650 * maxMintProofOfStake).div(100);
} else if((_now.sub(stakeStartTime).div(1 years) == 1) || (_now.sub(stakeStartTime).div(1 years) == 2) ||
(_now.sub(stakeStartTime).div(1 years) == 3)) {
interest = (770 * maxMintProofOfStake).div(100);
} else if((_now.sub(stakeStartTime).div(1 years) == 4) || (_now.sub(stakeStartTime).div(1 years) == 5) ||
(_now.sub(stakeStartTime).div(1 years) == 6)) {
interest = (435 * maxMintProofOfStake).div(100);
}
return (_coinAge * interest).div(365 * (10**decimals));
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
function ownerSetStakeStartTime(uint timestamp) public onlyOwner {
require((stakeStartTime <= 0) && (timestamp >= chainStartTime));
stakeStartTime = timestamp;
}
function claimTokens() public onlyOwner {
uint256 balance = balanceOf(this);
transfer(owner, balance);
Transfer(this, owner, balance);
owner.transfer(this.balance);
}
}