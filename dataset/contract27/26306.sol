pragma solidity ^0.4.18;
contract Owned {
modifier onlyOwner { require (msg.sender == owner); _; }
address public owner;
function Owned() public { owner = msg.sender;}
function changeOwner(address _newOwner) public onlyOwner {
owner = _newOwner;
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
contract ClaimRepository is Owned {
using SafeMath for uint256;
mapping (bytes32 => mapping (string => Claim)) claims;
mapping(address => bool) public callers;
uint256 public totalBalanceClaimed;
uint256 public totalClaims;
modifier onlyCaller {
require(callers[msg.sender]);
_;
}
struct Claim {
address solverAddress;
string solver;
uint256 requestBalance;
}
function ClaimRepository() {
}
function addClaim(address _solverAddress, bytes32 _platform, string _platformId, string _solver, uint256 _requestBalance) public onlyCaller returns (bool) {
claims[_platform][_platformId].solver = _solver;
claims[_platform][_platformId].solverAddress = _solverAddress;
claims[_platform][_platformId].requestBalance = _requestBalance;
totalBalanceClaimed = totalBalanceClaimed.add(_requestBalance);
totalClaims = totalClaims.add(1);
return true;
}
function updateCaller(address _caller, bool allowed) public onlyOwner {
callers[_caller] = allowed;
}
}