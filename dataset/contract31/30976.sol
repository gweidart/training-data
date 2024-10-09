pragma solidity 0.4.19;
contract Base {
function isContract(address _addr) constant internal returns(bool) {
uint size;
if (_addr == 0) return false;
assembly {
size := extcodesize(_addr)
}
return size > 0;
}
}
contract RngRequester {
function acceptRandom(bytes32 id, bytes result);
}
contract CryptoLuckRng {
function requestRandom(uint8 numberOfBytes) payable returns(bytes32);
function getFee() returns(uint256);
}
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
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
function Ownable() public {
owner = msg.sender;
}
modifier onlyOwner() {
require(msg.sender == owner);
_;
}
function transferOwnership(address newOwner) public onlyOwner {
require(newOwner != address(0));
OwnershipTransferred(owner, newOwner);
owner = newOwner;
}
}
contract StateQuickEth is Ownable {
modifier gameStopped {
require(!gameRunning);
_;
}
uint16 internal constant MANUAL_WITHDRAW_INTERVAL = 1 hours;
bool public gameRunning;
bool public stopGameOnNextRound;
uint32 public minGasForDrawing = 350000;
uint256 public minGasPriceForDrawing = 6000000000;
uint256 public rewardForDrawing = 2 finney;
uint8 public houseFee = 10;
uint256 public minContribution = 20 finney;
uint256 public maxContribution = 1 ether;
uint256 public maxBonusTickets = 5;
uint8 public bonusTicketsPercentage = 1;
uint16 public requiredEntries = 5;
uint256 public requiredTimeBetweenDraws = 60 minutes;
address public rngAddress;
function updateHouseFee(uint8 _value) public onlyOwner gameStopped {
houseFee = _value;
}
function updateMinContribution(uint256 _value) public onlyOwner gameStopped {
minContribution = _value;
}
function updateMaxContribution(uint256 _value) public onlyOwner gameStopped {
maxContribution = _value;
}
function updateRequiredEntries(uint16 _value) public onlyOwner gameStopped {
requiredEntries = _value;
}
function updateRequiredTimeBetweenDraws(uint256 _value) public onlyOwner gameStopped {
requiredTimeBetweenDraws = _value;
}
function updateMaxBonusTickets(uint256 _value) public onlyOwner {
maxBonusTickets = _value;
}
function updateBonusTicketsPercentage(uint8 _value) public onlyOwner {
bonusTicketsPercentage = _value;
}
function updateStopGameOnNextRound(bool _value) public onlyOwner {
stopGameOnNextRound = _value;
}
function restartGame() public onlyOwner {
gameRunning = true;
}
function updateMinGasForDrawing(uint32 newGasAmount) public onlyOwner {
minGasForDrawing = newGasAmount;
}
function updateMinGasPriceForDrawing(uint32 newGasPrice) public onlyOwner {
minGasPriceForDrawing = newGasPrice;
}
function updateRngAddress(address newAddress) public onlyOwner {
require(rngAddress != 0x0);
rngAddress = newAddress;
}
function updateRewardForDrawing(uint256 newRewardForDrawing) public onlyOwner {
require(newRewardForDrawing > 0);
rewardForDrawing = newRewardForDrawing;
}
}