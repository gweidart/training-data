pragma solidity ^0.4.18;
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
contract FishbankUtils is Ownable {
uint32[100] cooldowns = [
720 minutes, 720 minutes, 720 minutes, 720 minutes, 720 minutes,
660 minutes, 660 minutes, 660 minutes, 660 minutes, 660 minutes,
600 minutes, 600 minutes, 600 minutes, 600 minutes, 600 minutes,
540 minutes, 540 minutes, 540 minutes, 540 minutes, 540 minutes,
480 minutes, 480 minutes, 480 minutes, 480 minutes, 480 minutes,
420 minutes, 420 minutes, 420 minutes, 420 minutes, 420 minutes,
360 minutes, 360 minutes, 360 minutes, 360 minutes, 360 minutes,
300 minutes, 300 minutes, 300 minutes, 300 minutes, 300 minutes,
240 minutes, 240 minutes, 240 minutes, 240 minutes, 240 minutes,
180 minutes, 180 minutes, 180 minutes, 180 minutes, 180 minutes,
120 minutes, 120 minutes, 120 minutes, 120 minutes, 120 minutes,
90 minutes,  90 minutes,  90 minutes,  90 minutes,  90 minutes,
75 minutes,  75 minutes,  75 minutes,  75 minutes,  75 minutes,
60 minutes,  60 minutes,  60 minutes,  60 minutes,  60 minutes,
50 minutes,  50 minutes,  50 minutes,  50 minutes,  50 minutes,
40 minutes,  40 minutes,  40 minutes,  40 minutes,  40 minutes,
30 minutes,  30 minutes,  30 minutes,  30 minutes,  30 minutes,
20 minutes,  20 minutes,  20 minutes,  20 minutes,  20 minutes,
10 minutes,  10 minutes,  10 minutes,  10 minutes,  10 minutes,
5 minutes,   5 minutes,   5 minutes,   5 minutes,   5 minutes
];
function setCooldowns(uint32[100] _cooldowns) onlyOwner public {
cooldowns = _cooldowns;
}
function getFishParams(uint256 hashSeed1, uint256 hashSeed2, uint256 fishesLength, address coinbase) external pure returns (uint32[4]) {
bytes32[5] memory hashSeeds;
hashSeeds[0] = keccak256(hashSeed1 ^ hashSeed2);
hashSeeds[1] = keccak256(hashSeeds[0], fishesLength);
hashSeeds[2] = keccak256(hashSeeds[1], coinbase);
hashSeeds[3] = keccak256(hashSeeds[2], coinbase, fishesLength);
hashSeeds[4] = keccak256(hashSeeds[1], hashSeeds[2], hashSeeds[0]);
uint24[6] memory seeds = [
uint24(uint(hashSeeds[3]) % 10e6 + 1),
uint24(uint(hashSeeds[0]) % 420 + 1),
uint24(uint(hashSeeds[1]) % 420 + 1),
uint24(uint(hashSeeds[2]) % 150 + 1),
uint24(uint(hashSeeds[4]) % 16 + 1),
uint24(uint(hashSeeds[4]) % 5000 + 1)
];
uint32[4] memory fishParams;
if (seeds[0] == 1000000) {
if (seeds[4] == 1) {
fishParams = [140 + uint8(seeds[1] / 42), 140 + uint8(seeds[2] / 42), 75 + uint8(seeds[3] / 6), uint32(500000)];
if(fishParams[0] == 140) {
fishParams[0]++;
}
if(fishParams[1] == 140) {
fishParams[1]++;
}
if(fishParams[2] == 75) {
fishParams[2]++;
}
} else if (seeds[4] < 4) {
fishParams = [130 + uint8(seeds[1] / 42), 130 + uint8(seeds[2] / 42), 75 + uint8(seeds[3] / 6), uint32(500000)];
if(fishParams[0] == 130) {
fishParams[0]++;
}
if(fishParams[1] == 130) {
fishParams[1]++;
}
if(fishParams[2] == 75) {
fishParams[2]++;
}
} else {
fishParams = [115 + uint8(seeds[1] / 28), 115 + uint8(seeds[2] / 28), 75 + uint8(seeds[3] / 6), uint32(500000)];
if(fishParams[0] == 115) {
fishParams[0]++;
}
if(fishParams[1] == 115) {
fishParams[1]++;
}
if(fishParams[2] == 75) {
fishParams[2]++;
}
}
} else {
if (seeds[5] == 5000) {
fishParams = [85 + uint8(seeds[1] / 14), 85 + uint8(seeds[2] / 14), uint8(50 + seeds[3] / 3), uint32(1000)];
if(fishParams[0] == 85) {
fishParams[0]++;
}
if(fishParams[1] == 85) {
fishParams[1]++;
}
} else if (seeds[5] > 4899) {
fishParams = [50 + uint8(seeds[1] / 12), 50 + uint8(seeds[2] / 12), uint8(25 + seeds[3] / 2), uint32(300)];
if(fishParams[0] == 50) {
fishParams[0]++;
}
if(fishParams[1] == 50) {
fishParams[1]++;
}
} else if (seeds[5] > 4000) {
fishParams = [20 + uint8(seeds[1] / 14), 20 + uint8(seeds[2] / 14), uint8(25 + seeds[3] / 3), uint32(100)];
if(fishParams[0] == 20) {
fishParams[0]++;
}
if(fishParams[1] == 20) {
fishParams[1]++;
}
} else {
fishParams = [uint8(seeds[1] / 21), uint8(seeds[2] / 21), uint8(seeds[3] / 3), uint32(36)];
if (fishParams[0] == 0) {
fishParams[0] = 1;
}
if (fishParams[1] == 0) {
fishParams[1] = 1;
}
if (fishParams[2] == 0) {
fishParams[2] = 1;
}
}
}
return fishParams;
}
function getCooldown(uint16 speed) external view returns (uint64){
return uint64(now + cooldowns[speed - 1]);
}
function ceil(uint base, uint divider) internal pure returns (uint) {
return base / divider + ((base % divider > 0) ? 1 : 0);
}
}