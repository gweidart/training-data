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
contract ERC20Basic {
uint256 public totalSupply;
function balanceOf(address who) public view returns (uint256);
function transfer(address to, uint256 value) public returns (bool);
event Transfer(address indexed from, address indexed to, uint256 value);
}
contract ERC20 {
uint256 public totalSupply;
function balanceOf(address _owner) public constant returns (uint256 balance);
function transfer(address _to, uint256 _value) public returns (bool success);
function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
function approve(address _spender, uint256 _value) public returns (bool success);
function allowance(address _owner, address _spender) public constant returns (uint256 remaining);
event Transfer(address indexed _from, address indexed _to, uint256 _value);
event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}
contract BasicToken is ERC20Basic {
using SafeMath for uint256;
mapping (address => uint256) balances;
uint256 public endTimeLockedTokensTeam = 1601510399;
uint256 public endTimeLockedTokensAdvisor = 1554076800;
address public walletTeam = 0xdEffB0629FD35AD1A462C13D65f003E9079C3bb1;
address public walletAdvisor = 0xD437f2289B4d20988EcEAc5E050C6b4860FFF4Ac;
modifier onlyPayloadSize(uint numwords) {
assert(msg.data.length == numwords * 32 + 4);
_;
}
function transfer(address _to, uint256 _value) public onlyPayloadSize(2) returns (bool) {
require(_to != address(0));
require(_value <= balances[msg.sender]);
if ((msg.sender == walletAdvisor) && (now < endTimeLockedTokensAdvisor)) {
revert();
}
if((msg.sender == walletTeam) && (now < endTimeLockedTokensTeam)) {
revert();
}
balances[msg.sender] = balances[msg.sender].sub(_value);
balances[_to] = balances[_to].add(_value);
Transfer(msg.sender, _to, _value);
return true;
}
function balanceOf(address _owner) public constant returns (uint256 balance) {
return balances[_owner];
}
}
contract StandardToken is ERC20, BasicToken {
mapping (address => mapping (address => uint256)) internal allowed;
function transferFrom(address _from, address _to, uint256 _value) public onlyPayloadSize(3) returns (bool) {
require(_to != address(0));
require(_value <= balances[_from]);
require(_value <= allowed[_from][msg.sender]);
balances[_from] = balances[_from].sub(_value);
balances[_to] = balances[_to].add(_value);
allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
Transfer(_from, _to, _value);
return true;
}
function approve(address _spender, uint256 _value) public returns (bool) {
allowed[msg.sender][_spender] = _value;
Approval(msg.sender, _spender, _value);
return true;
}
function allowance(address _owner, address _spender) public onlyPayloadSize(2) constant returns (uint256 remaining) {
return allowed[_owner][_spender];
}
function increaseApproval(address _spender, uint _addedValue) public returns (bool success) {
allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
return true;
}
function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool success) {
uint oldValue = allowed[msg.sender][_spender];
if (_subtractedValue > oldValue) {
allowed[msg.sender][_spender] = 0;
}
else {
allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
}
Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
return true;
}
}
contract Ownable {
address public owner;
address public ownerTwo;
struct PermissionFunction {
bool approveOwner;
bool approveOwnerTwo;
}
PermissionFunction[] public permissions;
function Ownable() public {
permissions.push(PermissionFunction(false, false));
}
modifier onlyOwner() {
require(msg.sender == owner || msg.sender == ownerTwo);
_;
}
function setApproveOwner(uint8 _numberFunction, bool _permValue) onlyOwner public {
if(msg.sender == owner){
permissions[_numberFunction].approveOwner = _permValue;
}
if(msg.sender == ownerTwo){
permissions[_numberFunction].approveOwnerTwo = _permValue;
}
}
function removePermission(uint8 _numberFunction) public onlyOwner {
permissions[_numberFunction].approveOwner = false;
permissions[_numberFunction].approveOwnerTwo = false;
}
}
contract MintableToken is StandardToken, Ownable {
string public constant name = "Greencoin";
string public constant symbol = "GNC";
uint8 public constant decimals = 18;
event Mint(address indexed to, uint256 amount);
function mint(address _to, uint256 _amount, address _owner) internal returns (bool) {
balances[_to] = balances[_to].add(_amount);
balances[_owner] = balances[_owner].sub(_amount);
Mint(_to, _amount);
Transfer(_owner, _to, _amount);
return true;
}
function claimTokens(address _token) public  onlyOwner {
if (_token == 0x0) {
owner.transfer(this.balance);
return;
}
MintableToken token = MintableToken(_token);
uint256 balance = token.balanceOf(this);
token.transfer(owner, balance);
Transfer(_token, owner, balance);
}
}
contract Crowdsale is Ownable {
using SafeMath for uint256;
address public wallet;
uint256 public weiRaised;
uint256 public tokenAllocated;
uint256 public hardWeiCap = 60000 * (10 ** 18);
function Crowdsale(
address _wallet
)
public
{
require(_wallet != address(0));
wallet = _wallet;
}
}
contract GNCCrowdsale is Ownable, Crowdsale, MintableToken {
using SafeMath for uint256;
uint256[] public rates  = [575, 550, 525, 500];
uint256 public weiMinSale =  1 * 10**17;
mapping (address => uint256) public deposited;
mapping(address => bool) public whitelist;
uint256 public constant INITIAL_SUPPLY = 50 * (10 ** 6) * (10 ** uint256(decimals));
uint256 public fundForSale = 30 *   (10 ** 6) * (10 ** uint256(decimals));
uint256 public fundTeam =    7500 * (10 ** 3) * (10 ** uint256(decimals));
uint256 public fundAdvisor = 4500 * (10 ** 3) * (10 ** uint256(decimals));
uint256 public fundBounty =  500 *  (10 ** 3) * (10 ** uint256(decimals));
uint256 public fundPreIco =  6000 * (10 ** 3) * (10 ** uint256(decimals));
address public addressBounty = 0xE3dd17FdFaCa8b190D2fd71f3a34cA95Cdb0f635;
uint256 public countInvestor;
event TokenPurchase(address indexed beneficiary, uint256 value, uint256 amount);
event TokenLimitReached(uint256 tokenRaised, uint256 purchasedToken);
event Burn(address indexed burner, uint256 value);
event HardCapReached();
event Finalized();
function GNCCrowdsale(
address _owner,
address _wallet,
address _ownerTwo
)
public
Crowdsale(_wallet)
{
require(_wallet != address(0));
require(_owner != address(0));
require(_ownerTwo != address(0));
owner = _owner;
ownerTwo = _ownerTwo;
totalSupply = INITIAL_SUPPLY;
bool resultMintForOwner = mintForFund(owner);
require(resultMintForOwner);
}
function() payable public {
buyTokens(msg.sender);
}
function buyTokens(address _investor) public payable returns (uint256){
require(_investor != address(0));
uint256 weiAmount = msg.value;
uint256 tokens = validPurchaseTokens(weiAmount);
if (tokens == 0) {revert();}
weiRaised = weiRaised.add(weiAmount);
tokenAllocated = tokenAllocated.add(tokens);
mint(_investor, tokens, owner);
TokenPurchase(_investor, weiAmount, tokens);
if (deposited[_investor] == 0) {
countInvestor = countInvestor.add(1);
}
deposit(_investor);
wallet.transfer(weiAmount);
return tokens;
}
function getTotalAmountOfTokens(uint256 _weiAmount) internal returns (uint256) {
uint256 currentDate = now;
uint256 currentPeriod = getPeriod(currentDate);
uint256 amountOfTokens = 0;
if(currentPeriod < 4){
amountOfTokens = _weiAmount.mul(rates[currentPeriod]);
if(whitelist[msg.sender]){
amountOfTokens = amountOfTokens.mul(105).div(100);
}
if (currentPeriod == 0) {
if (tokenAllocated.add(amountOfTokens) > fundPreIco) {
TokenLimitReached(tokenAllocated, amountOfTokens);
return 0;
}
}
}
return amountOfTokens;
}
function getPeriod(uint256 _currentDate) public pure returns (uint) {
if( 1527811200 <= _currentDate && _currentDate <= 1530403199){
return 0;
}
if( 1533081600 <= _currentDate && _currentDate <= 1534377599){
return 1;
}
if( 1534377600 <= _currentDate && _currentDate <= 1535759999){
return 2;
}
if( 1535760000 <= _currentDate && _currentDate <= 1538351999){
return 3;
}
return 10;
}
function deposit(address investor) internal {
deposited[investor] = deposited[investor].add(msg.value);
}
function mintForFund(address _wallet) internal returns (bool result) {
result = false;
require(_wallet != address(0));
balances[_wallet] = balances[_wallet].add(INITIAL_SUPPLY.sub(fundTeam).sub(fundAdvisor).sub(fundBounty));
balances[walletTeam] = balances[walletTeam].add(fundTeam);
balances[walletAdvisor] = balances[walletAdvisor].add(fundAdvisor);
balances[addressBounty] = balances[addressBounty].add(fundBounty);
result = true;
}
function getDeposited(address _investor) public view returns (uint256){
return deposited[_investor];
}
function validPurchaseTokens(uint256 _weiAmount) public returns (uint256) {
uint256 addTokens = getTotalAmountOfTokens(_weiAmount);
if(_weiAmount < weiMinSale){
return 0;
}
if (tokenAllocated.add(addTokens) > fundForSale) {
TokenLimitReached(tokenAllocated, addTokens);
return 0;
}
if (weiRaised.add(_weiAmount) > hardWeiCap) {
HardCapReached();
return 0;
}
return addTokens;
}
function ownerBurnToken(uint _value) public onlyOwner returns (bool) {
require(_value > 0);
require(_value <= balances[owner]);
require(permissions[0].approveOwner == true && permissions[0].approveOwnerTwo == true);
balances[owner] = balances[owner].sub(_value);
totalSupply = totalSupply.sub(_value);
Burn(owner, _value);
removePermission(0);
return true;
}
function addToWhitelist(address _beneficiary) external onlyOwner {
whitelist[_beneficiary] = true;
}
function addManyToWhitelist(address[] _beneficiaries) external onlyOwner {
for (uint256 i = 0; i < _beneficiaries.length; i++) {
whitelist[_beneficiaries[i]] = true;
}
}
function removeFromWhitelist(address _beneficiary) external onlyOwner {
whitelist[_beneficiary] = false;
}
}