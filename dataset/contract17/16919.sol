pragma solidity ^0.4.20;
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
emit OwnershipTransferred(owner, newOwner);
owner = newOwner;
}
}
contract Pausable is Ownable {
event Pause();
event Unpause();
bool public paused = false;
modifier whenNotPaused() {
require(!paused);
_;
}
modifier whenPaused() {
require(paused);
_;
}
function pause() onlyOwner whenNotPaused public {
paused = true;
emit Pause();
}
function unpause() onlyOwner whenPaused public {
paused = false;
emit Unpause();
}
}
contract ConfigInterface
{
function isConfig() public pure returns (bool);
function getCooldownIndexFromGeneration(uint16 _generation) public view returns (uint16);
function getCooldownEndTimeFromIndex(uint16 _cooldownIndex) public view returns (uint40);
function getCooldownIndexCount() public view returns (uint256);
function getBabyGen(uint16 _momGen, uint16 _dadGen) public pure returns (uint16);
function getTutorialBabyGen(uint16 _dadGen) public pure returns (uint16);
function getBreedingFee(uint40 _momId, uint40 _dadId) public pure returns (uint256);
}
contract Config is Ownable, ConfigInterface
{
function isConfig() public pure returns (bool)
{
return true;
}
uint32[14] public cooldowns = [
uint32(1 minutes),
uint32(2 minutes),
uint32(5 minutes),
uint32(10 minutes),
uint32(30 minutes),
uint32(1 hours),
uint32(2 hours),
uint32(4 hours),
uint32(8 hours),
uint32(16 hours),
uint32(1 days),
uint32(2 days),
uint32(4 days),
uint32(7 days)
];
function getCooldownIndexFromGeneration(uint16 _generation) public view returns (uint16)
{
uint16 result = uint16(_generation / 2);
if (result > getCooldownIndexCount()) {
result = uint16(getCooldownIndexCount() - 1);
}
return result;
}
function getCooldownEndTimeFromIndex(uint16 _cooldownIndex) public view returns (uint40)
{
return uint40(now + cooldowns[_cooldownIndex]);
}
function getCooldownIndexCount() public view returns (uint256)
{
return cooldowns.length;
}
function getBabyGen(uint16 _momGen, uint16 _dadGen) public pure returns (uint16)
{
uint16 babyGen = _momGen;
if (_dadGen > _momGen) {
babyGen = _dadGen;
}
babyGen = babyGen + 1;
return babyGen;
}
function getTutorialBabyGen(uint16 _dadGen) public pure returns (uint16)
{
return getBabyGen(26, _dadGen);
}
public
pure
returns (uint256)
{
return 2000000000000000;
}
}