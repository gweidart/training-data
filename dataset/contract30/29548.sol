pragma solidity ^0.4.15;
contract Owned {
modifier onlyOwner() {
require(msg.sender == owner);
_;
}
address public owner;
function Owned() {
owner = msg.sender;
}
address public newOwner;
function changeOwner(address _newOwner) onlyOwner {
if(msg.sender == owner) {
owner = _newOwner;
}
}
}
library SafeMath {
function mul(uint a, uint b) internal returns (uint) {
uint c = a * b;
assert(a == 0 || c / a == b);
return c;
}
function div(uint a, uint b) internal returns (uint) {
uint c = a / b;
return c;
}
function sub(uint a, uint b) internal returns (uint) {
assert(b <= a);
return a - b;
}
function add(uint a, uint b) internal returns (uint) {
uint c = a + b;
assert(c >= a);
return c;
}
function max64(uint64 a, uint64 b) internal constant returns (uint64) {
return a >= b ? a : b;
}
function min64(uint64 a, uint64 b) internal constant returns (uint64) {
return a < b ? a : b;
}
function max256(uint256 a, uint256 b) internal constant returns (uint256) {
return a >= b ? a : b;
}
function min256(uint256 a, uint256 b) internal constant returns (uint256) {
return a < b ? a : b;
}
}
contract SentimentAnalysis is Owned {
using SafeMath for uint256;
mapping (address => Reputation) reputations;
event ReputationUpdated(string reputation, uint correct, uint incorrect, string lastUpdateDate, string lastFormulaApplied, address user);
struct Reputation {
string reputation;
uint correct;
uint incorrect;
string lastUpdateDate;
string lastFormulaApplied;
}
function ()  payable {
revert();
}
function getReputation(
address user
)
public
constant
returns (string, uint, uint, string, string)
{
return (reputations[user].reputation, reputations[user].correct, reputations[user].incorrect, reputations[user].lastUpdateDate, reputations[user].lastFormulaApplied);
}
function updateReputation(
string reputation,
uint correct,
uint incorrect,
string date,
string formulaApplied,
address user
)
onlyOwner
public
{
reputations[user].reputation = reputation;
reputations[user].correct = correct;
reputations[user].incorrect = incorrect;
reputations[user].lastUpdateDate = date;
reputations[user].lastFormulaApplied = formulaApplied;
ReputationUpdated(reputations[user].reputation, reputations[user].correct, reputations[user].incorrect, reputations[user].lastUpdateDate, reputations[user].lastFormulaApplied, user);
}
}