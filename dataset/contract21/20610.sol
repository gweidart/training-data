pragma solidity ^0.4.18;
contract CrowdsaleParameters {
uint256 public constant generalSaleStartDate = 1524182400;
uint256 public constant generalSaleEndDate = 1529452800;
struct AddressTokenAllocation {
address addr;
uint256 amount;
}
AddressTokenAllocation internal generalSaleWallet = AddressTokenAllocation(0x5aCdaeF4fa410F38bC26003d0F441d99BB19265A, 22800000);
AddressTokenAllocation internal bounty = AddressTokenAllocation(0xc1C77Ff863bdE913DD53fD6cfE2c68Dfd5AE4f7F, 2000000);
AddressTokenAllocation internal partners = AddressTokenAllocation(0x307744026f34015111B04ea4D3A8dB9FdA2650bb, 3200000);
AddressTokenAllocation internal team = AddressTokenAllocation(0xCC4271d219a2c33a92aAcB4C8D010e9FBf664D1c, 12000000);
AddressTokenAllocation internal featureDevelopment = AddressTokenAllocation(0x06281A31e1FfaC1d3877b29150bdBE93073E043B, 0);
}
contract Owned {
address public owner;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
function Owned() public {
owner = msg.sender;
}
modifier onlyOwner() {
require(msg.sender == owner);
_;
}
function changeOwner(address newOwner) onlyOwner public {
require(newOwner != address(0));
require(newOwner != owner);
OwnershipTransferred(owner, newOwner);
owner = newOwner;
}
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
contract SBIToken is Owned, CrowdsaleParameters {
using SafeMath for uint256;
string public standard = 'ERC20/SBI';
string public name = 'Subsoil Blockchain Investitions';
string public symbol = 'SBI';
uint8 public decimals = 18;
mapping (address => uint256) private balances;
mapping (address => mapping (address => uint256)) private allowed;
mapping (address => mapping (address => bool)) private allowanceUsed;
event Transfer(address indexed from, address indexed to, uint tokens);
event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
event Issuance(uint256 _amount);
event Destruction(uint256 _amount);
event NewSBIToken(address _token);
uint256 public totalSupply = 0;
bool public transfersEnabled = true;
function SBIToken() public {
owner = msg.sender;
mintToken(generalSaleWallet);
mintToken(bounty);
mintToken(partners);
mintToken(team);
NewSBIToken(address(this));
}
modifier transfersAllowed {
require(transfersEnabled);
_;
}
modifier onlyPayloadSize(uint size) {
assert(msg.data.length >= size + 4);
_;
}
function approveCrowdsale(address _crowdsaleAddress) external onlyOwner {
approveAllocation(generalSaleWallet, _crowdsaleAddress);
}
function approveAllocation(AddressTokenAllocation tokenAllocation, address _crowdsaleAddress) internal {
uint uintDecimals = decimals;
uint exponent = 10**uintDecimals;
uint amount = tokenAllocation.amount * exponent;
allowed[tokenAllocation.addr][_crowdsaleAddress] = amount;
Approval(tokenAllocation.addr, _crowdsaleAddress, amount);
}
function balanceOf(address _address) public constant returns (uint256 balance) {
return balances[_address];
}
function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
return allowed[_owner][_spender];
}
function transfer(address _to, uint256 _value) public transfersAllowed onlyPayloadSize(2*32) returns (bool success) {
require(_to != address(0));
require(_value <= balances[msg.sender]);
balances[msg.sender] = balances[msg.sender].sub(_value);
balances[_to] = balances[_to].add(_value);
Transfer(msg.sender, _to, _value);
return true;
}
function mintToken(AddressTokenAllocation tokenAllocation) internal {
uint uintDecimals = decimals;
uint exponent = 10**uintDecimals;
uint mintedAmount = tokenAllocation.amount * exponent;
balances[tokenAllocation.addr] += mintedAmount;
totalSupply += mintedAmount;
Issuance(mintedAmount);
Transfer(address(this), tokenAllocation.addr, mintedAmount);
}
function approve(address _spender, uint256 _value) public onlyPayloadSize(2*32) returns (bool success) {
require(_value == 0 || allowanceUsed[msg.sender][_spender] == false);
allowed[msg.sender][_spender] = _value;
allowanceUsed[msg.sender][_spender] = false;
Approval(msg.sender, _spender, _value);
return true;
}
function transferFrom(address _from, address _to, uint256 _value) public transfersAllowed onlyPayloadSize(3*32) returns (bool success) {
require(_to != address(0));
require(_value <= balances[_from]);
require(_value <= allowed[_from][msg.sender]);
balances[_from] = balances[_from].sub(_value);
balances[_to] = balances[_to].add(_value);
allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
Transfer(_from, _to, _value);
return true;
}
function() public {}
function toggleTransfers(bool _enable) external onlyOwner {
transfersEnabled = _enable;
}
}
contract SBITokenCrowdsale is Owned, CrowdsaleParameters {
using SafeMath for uint256;
string public name = 'Subsoil Blockchain Investitions Crowdsale';
SBIToken private token;
address public bank;
address saleWalletAddress;
uint private tokenMultiplier = 10;
uint public totalCollected = 0;
uint public saleStartTimestamp;
uint public saleStopTimestamp;
uint public saleGoal;
bool public goalReached = false;
uint public tokensPerEth = 48000;
mapping (address => uint256) private investmentRecords;
address crowdsaleAddress = this;
event TokenSale(address indexed tokenReceiver, uint indexed etherAmount, uint indexed tokenAmount, uint tokensPerEther);
event FundTransfer(address indexed from, address indexed to, uint indexed amount);
function SBITokenCrowdsale(address _tokenAddress, address _bankAddress) public {
token = SBIToken(_tokenAddress);
bank = _bankAddress;
tokenMultiplier = tokenMultiplier ** token.decimals();
saleWalletAddress = generalSaleWallet.addr;
saleGoal = generalSaleWallet.amount;
}
function isICOActive() public constant returns (bool active) {
active = ((generalSaleStartDate <= now) && (now < generalSaleEndDate) && (!goalReached));
return active;
}
function setTokenRate(uint rate) public onlyOwner {
tokensPerEth = rate;
}
function processPayment(address investorAddress, uint amount) internal {
require(isICOActive());
assert(msg.value > 0 finney);
FundTransfer(investorAddress, address(this), amount);
uint tokenAmount = amount * tokensPerEth / 1e18;
uint remainingTokenBalance = token.balanceOf(saleWalletAddress) / tokenMultiplier;
if (remainingTokenBalance <= tokenAmount) {
tokenAmount = remainingTokenBalance;
goalReached = true;
}
uint acceptedAmount = tokenAmount * 1e18 / tokensPerEth;
token.transferFrom(saleWalletAddress, investorAddress, tokenAmount * tokenMultiplier);
TokenSale(investorAddress, amount, tokenAmount, tokensPerEth);
uint change = amount - acceptedAmount;
if (change > 0) {
investorAddress.transfer(change);
FundTransfer(address(this), investorAddress, change);
}
investmentRecords[investorAddress] += acceptedAmount;
totalCollected += acceptedAmount;
}
function safeWithdrawal() external onlyOwner {
bank.transfer(crowdsaleAddress.balance);
FundTransfer(crowdsaleAddress, bank, crowdsaleAddress.balance);
}
function () external payable {
processPayment(msg.sender, msg.value);
}
function kill() external onlyOwner {
require(!isICOActive());
if (crowdsaleAddress.balance > 0) {
revert();
}
if (now < generalSaleStartDate) {
selfdestruct(owner);
}
uint featureDevelopmentAmount = token.balanceOf(saleWalletAddress);
token.transferFrom(saleWalletAddress, featureDevelopment.addr, featureDevelopmentAmount);
FundTransfer(crowdsaleAddress, msg.sender, crowdsaleAddress.balance);
selfdestruct(owner);
}
}