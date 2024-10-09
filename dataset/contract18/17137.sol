pragma solidity 0.4.23;
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
contract TokenSale {
using SafeMath for uint256;
address public owner;
address public wallet;
uint256 public amountRaised;
uint256 public saleLimit = 25000 ether;
uint256 public minContribution = 0.5 ether;
uint256 public maxContribution = 500 ether;
bool public isAcceptingPayments;
mapping (address => bool) public tokenSaleAdmins;
mapping (address => bool) public whitelist;
mapping (address => uint256) public amountPaid;
modifier onlyOwner() {
require(msg.sender == owner);
_;
}
modifier onlyAdmin() {
require(tokenSaleAdmins[msg.sender]);
_;
}
modifier isWhitelisted() {
require(whitelist[msg.sender]);
_;
}
modifier acceptingPayments() {
require(isAcceptingPayments);
_;
}
constructor(address _wallet) public {
require(_wallet != address(0));
owner = msg.sender;
wallet = _wallet;
tokenSaleAdmins[msg.sender] = true;
}
function () isWhitelisted acceptingPayments payable public {
uint256 _contribution = msg.value;
require(_contribution >= minContribution);
require(_contribution <= maxContribution);
require(msg.sender != address(0));
amountPaid[msg.sender] += _contribution;
amountRaised = amountRaised.add(_contribution);
if (amountRaised > saleLimit) {
uint256 _refundAmount = amountRaised.sub(saleLimit);
msg.sender.transfer(_refundAmount);
_contribution = _contribution.sub(_refundAmount);
_refundAmount = 0;
amountRaised = saleLimit;
isAcceptingPayments = false;
}
wallet.transfer(_contribution);
}
function acceptPayments() onlyAdmin public  {
isAcceptingPayments = true;
}
function rejectPayments() onlyAdmin public  {
isAcceptingPayments = false;
}
function addAdmin(address _admin) onlyOwner public {
tokenSaleAdmins[_admin] = true;
}
function removeAdmin(address _admin) onlyOwner public {
tokenSaleAdmins[_admin] = false;
}
function whitelistAddress(address _contributor) onlyAdmin public  {
whitelist[_contributor] = true;
}
function whitelistAddresses(address[] _contributors) onlyAdmin public {
for (uint256 i = 0; i < _contributors.length; i++) {
whitelist[_contributors[i]] = true;
}
}
function unWhitelistAddress(address _contributor) onlyAdmin public  {
whitelist[_contributor] = false;
}
function unWhitelistAddresses(address[] _contributors) onlyAdmin public {
for (uint256 i = 0; i < _contributors.length; i++) {
whitelist[_contributors[i]] = false;
}
}
function updateSaleLimit(uint256 _saleLimit) onlyAdmin public {
saleLimit = _saleLimit;
}
function updateMinContribution(uint256 _minContribution) onlyAdmin public {
minContribution = _minContribution;
}
function updateMaxContribution(uint256 _maxContribution) onlyAdmin public {
maxContribution = _maxContribution;
}
}