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
contract FundRepository is Owned {
using SafeMath for uint256;
uint256 public totalNumberOfFunders;
mapping (address => uint256) funders;
uint256 public totalFunded;
uint256 public requestsFunded;
uint256 public totalBalance;
mapping (bytes32 => mapping (string => Funding)) funds;
mapping(address => bool) public callers;
struct Funding {
address[] funders;
mapping (address => uint256) balances;
uint256 totalBalance;
}
modifier onlyCaller {
require(callers[msg.sender]);
_;
}
function FundRepository() {
}
function updateFunders(address _from, bytes32 _platform, string _platformId, uint256 _value) public onlyCaller {
bool existing = funds[_platform][_platformId].balances[_from] > 0;
if (!existing) {
funds[_platform][_platformId].funders.push(_from);
}
if (funders[_from] <= 0) {
totalNumberOfFunders = totalNumberOfFunders.add(1);
funders[_from].add(_value);
}
}
function updateBalances(address _from, bytes32 _platform, string _platformId, uint256 _value) public onlyCaller {
if (funds[_platform][_platformId].totalBalance <= 0) {
requestsFunded = requestsFunded.add(1);
}
funds[_platform][_platformId].balances[_from] = funds[_platform][_platformId].balances[_from].add(_value);
funds[_platform][_platformId].totalBalance = funds[_platform][_platformId].totalBalance.add(_value);
totalBalance = totalBalance.add(_value);
totalFunded = totalFunded.add(_value);
}
function resolveFund(bytes32 platform, string platformId) public onlyCaller returns (uint) {
var funding = funds[platform][platformId];
var requestBalance = funding.totalBalance;
totalBalance = totalBalance.sub(requestBalance);
for (uint i = 0; i < funding.funders.length; i++) {
var funder = funding.funders[i];
delete (funding.balances[funder]);
}
delete (funds[platform][platformId]);
return requestBalance;
}
function getFundInfo(bytes32 _platform, string _platformId, address _funder) public view returns (uint256, uint256, uint256) {
return (
getFunderCount(_platform, _platformId),
balance(_platform, _platformId),
amountFunded(_platform, _platformId, _funder)
);
}
function getFunderCount(bytes32 _platform, string _platformId) public view returns (uint){
return funds[_platform][_platformId].funders.length;
}
function amountFunded(bytes32 _platform, string _platformId, address _funder) public view returns (uint256){
return funds[_platform][_platformId].balances[_funder];
}
function balance(bytes32 _platform, string _platformId) view public returns (uint256) {
return funds[_platform][_platformId].totalBalance;
}
function updateCaller(address _caller, bool allowed) public onlyOwner {
callers[_caller] = allowed;
}
}