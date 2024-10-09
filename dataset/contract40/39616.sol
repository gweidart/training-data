pragma solidity ^0.4.8;
contract Owned {
address public owner;
function Owned() {
owner = msg.sender;
}
modifier onlyOwner() {
if (msg.sender != owner) {
throw;
}
_;
}
}
contract SikobaPresale is Owned {
uint256 public totalFunding;
uint256 public constant MINIMUM_PARTICIPATION_AMOUNT =   0 ether;
uint256 public constant MAXIMUM_PARTICIPATION_AMOUNT = 250 ether;
uint256 public constant PRESALE_MINIMUM_FUNDING =  1 ether;
uint256 public constant PRESALE_MAXIMUM_FUNDING = 2 ether;
uint256 public constant TOTAL_PREALLOCATION = 0 ether;
uint256 public constant PRESALE_START_DATE = now;
uint256 public constant PRESALE_END_DATE = PRESALE_START_DATE + 15 minutes;
uint256 public constant OWNER_CLAWBACK_DATE = PRESALE_START_DATE + 20 minutes;
mapping (address => uint256) public balanceOf;
event LogParticipation(address indexed sender, uint256 value, uint256 timestamp);
function SikobaPresale () payable {
assertEquals(TOTAL_PREALLOCATION, msg.value);
assertEquals(TOTAL_PREALLOCATION, totalFunding);
}
function () payable {
if (now < PRESALE_START_DATE) throw;
if (now > PRESALE_END_DATE) throw;
if (msg.value < MINIMUM_PARTICIPATION_AMOUNT) throw;
if (msg.value > MAXIMUM_PARTICIPATION_AMOUNT) throw;
if (safeIncrement(totalFunding, msg.value) > PRESALE_MAXIMUM_FUNDING) throw;
addBalance(msg.sender, msg.value);
}
function ownerWithdraw(uint256 value) external onlyOwner {
if (now <= PRESALE_END_DATE) throw;
if (totalFunding < PRESALE_MINIMUM_FUNDING) throw;
if (!owner.send(value)) throw;
}
function participantWithdrawIfMinimumFundingNotReached(uint256 value) external {
if (now <= PRESALE_END_DATE) throw;
if (totalFunding >= PRESALE_MINIMUM_FUNDING) throw;
if (balanceOf[msg.sender] < value) throw;
balanceOf[msg.sender] = safeDecrement(balanceOf[msg.sender], value);
if (!msg.sender.send(value)) throw;
}
function ownerClawback() external onlyOwner {
if (now < OWNER_CLAWBACK_DATE) throw;
if (!owner.send(this.balance)) throw;
}
function addBalance(address participant, uint256 value) private {
balanceOf[participant] = safeIncrement(balanceOf[participant], value);
totalFunding = safeIncrement(totalFunding, value);
LogParticipation(participant, value, now);
}
function assertEquals(uint256 expectedValue, uint256 actualValue) private constant {
if (expectedValue != actualValue) throw;
}
function safeIncrement(uint256 base, uint256 increment) private constant returns (uint256) {
uint256 result = base + increment;
if (result < base) throw;
return result;
}
function safeDecrement(uint256 base, uint256 increment) private constant returns (uint256) {
uint256 result = base - increment;
if (result > base) throw;
return result;
}
}