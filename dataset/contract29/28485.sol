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
Pause();
}
function unpause() onlyOwner whenPaused public {
paused = false;
Unpause();
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
contract ERC20Basic {
uint256 public totalSupply;
function balanceOf(address who) public view returns (uint256);
function transfer(address to, uint256 value) public returns (bool);
event Transfer(address indexed from, address indexed to, uint256 value);
}
contract BasicToken is ERC20Basic {
using SafeMath for uint256;
mapping(address => uint256) balances;
function transfer(address _to, uint256 _value) public returns (bool) {
require(_to != address(0));
require(_value <= balances[msg.sender]);
balances[msg.sender] = balances[msg.sender].sub(_value);
balances[_to] = balances[_to].add(_value);
Transfer(msg.sender, _to, _value);
return true;
}
function balanceOf(address _owner) public view returns (uint256 balance) {
return balances[_owner];
}
}
contract ERC20 is ERC20Basic {
function allowance(address owner, address spender) public view returns (uint256);
function transferFrom(address from, address to, uint256 value) public returns (bool);
function approve(address spender, uint256 value) public returns (bool);
event Approval(address indexed owner, address indexed spender, uint256 value);
}
contract StandardToken is ERC20, BasicToken {
mapping (address => mapping (address => uint256)) internal allowed;
function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
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
function allowance(address _owner, address _spender) public view returns (uint256) {
return allowed[_owner][_spender];
}
function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
return true;
}
function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
uint oldValue = allowed[msg.sender][_spender];
if (_subtractedValue > oldValue) {
allowed[msg.sender][_spender] = 0;
} else {
allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
}
Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
return true;
}
}
contract DropletToken is StandardToken, Pausable {
string public constant name = "Droplet Token";
string public constant symbol = "DPLT";
uint32 public constant decimals = 18;
function DropletToken(uint _totalSupply) public {
require (_totalSupply > 0);
totalSupply = _totalSupply;
balances[msg.sender] = _totalSupply;
}
function transfer(address _to, uint _value) public whenNotPaused returns (bool) {
return super.transfer(_to, _value);
}
function transferFrom(address _from, address _to, uint _value) public whenNotPaused returns (bool) {
return super.transferFrom(_from, _to, _value);
}
}
contract DropletCrowdSale is Pausable {
using SafeMath for uint256;
address beneficiaryAddress;
DropletToken public token;
uint256 public maxTokensAmount;
uint256 public issuedTokensAmount = 0;
uint256 public tokenRate;
uint256 public endDate;
bool public isFinished = false;
bool public isUnlocked = false;
mapping(address => uint256) public tokens;
mapping(uint32 => address) public tokenReceivers;
uint32 public receiversCount = 0;
event TokenBought(address indexed _buyer, uint256 _tokens, uint256 _amount);
event TokenAdded(address indexed _receiver, uint256 _tokens, uint256 _equivalentAmount);
event TokenToppedUp(address indexed _receiver, uint256 _tokens, uint256 _equivalentAmount);
event TokenSubtracted(address indexed _receiver, uint256 _tokens, uint256 _equivalentAmount);
event TokenSent(address indexed _receiver, uint256 _tokens);
modifier inProgress() {
require (!isFinished);
require (issuedTokensAmount < maxTokensAmount);
require (now <= endDate);
_;
}
function DropletCrowdSale(
address _tokenAddress,
address _beneficiaryAddress,
uint256 _tokenRate,
uint256 _maxTokensAmount,
uint256 _endDate
) public {
token = DropletToken(_tokenAddress);
beneficiaryAddress = _beneficiaryAddress;
tokenRate = _tokenRate;
maxTokensAmount = _maxTokensAmount;
endDate = _endDate;
}
function setTokenRate(uint256 _tokenRate) public onlyOwner {
require (_tokenRate > 0);
tokenRate = _tokenRate;
}
function setEndDate(uint256 _endDate) public onlyOwner {
endDate = _endDate;
}
function buy() public payable inProgress whenNotPaused {
uint256 payAmount = msg.value;
uint256 returnAmount = 0;
uint256 tokensAmount = tokenRate.mul(payAmount);
if (issuedTokensAmount + tokensAmount > maxTokensAmount) {
tokensAmount = maxTokensAmount.sub(issuedTokensAmount);
payAmount = tokensAmount.div(tokenRate);
returnAmount = msg.value.sub(payAmount);
}
issuedTokensAmount = issuedTokensAmount.add(tokensAmount);
require (issuedTokensAmount <= maxTokensAmount);
storeTokens(msg.sender, tokensAmount);
TokenBought(msg.sender, tokensAmount, payAmount);
beneficiaryAddress.transfer(payAmount);
if (returnAmount > 0) {
msg.sender.transfer(returnAmount);
}
}
function add(address _receiver, uint256 _equivalentEthAmount) public onlyOwner inProgress whenNotPaused {
uint256 tokensAmount = tokenRate.mul(_equivalentEthAmount);
issuedTokensAmount = issuedTokensAmount.add(tokensAmount);
storeTokens(_receiver, tokensAmount);
TokenAdded(_receiver, tokensAmount, _equivalentEthAmount);
}
function topUp(address _receiver, uint256 _equivalentEthAmount) public onlyOwner whenNotPaused {
uint256 tokensAmount = tokenRate.mul(_equivalentEthAmount);
issuedTokensAmount = issuedTokensAmount.add(tokensAmount);
storeTokens(_receiver, tokensAmount);
TokenToppedUp(_receiver, tokensAmount, _equivalentEthAmount);
}
function sub(address _receiver, uint256 _equivalentEthAmount) public onlyOwner whenNotPaused {
uint256 tokensAmount = tokenRate.mul(_equivalentEthAmount);
require (tokens[_receiver] >= tokensAmount);
tokens[_receiver] = tokens[_receiver].sub(tokensAmount);
issuedTokensAmount = issuedTokensAmount.sub(tokensAmount);
TokenSubtracted(_receiver, tokensAmount, _equivalentEthAmount);
}
function storeTokens(address _receiver, uint256 _tokensAmount) internal whenNotPaused {
if (tokens[_receiver] == 0) {
tokenReceivers[receiversCount] = _receiver;
receiversCount++;
}
tokens[_receiver] = tokens[_receiver].add(_tokensAmount);
}
function claim() public whenNotPaused {
claimFor(msg.sender);
}
function claimOne(address _receiver) public onlyOwner whenNotPaused {
claimFor(_receiver);
}
function claimAll() public onlyOwner whenNotPaused {
for (uint32 i = 0; i < receiversCount; i++) {
address receiver = tokenReceivers[i];
if (isUnlocked && tokens[receiver] > 0) {
claimFor(receiver);
}
}
}
function claimFor(address _receiver) internal whenNotPaused {
require(isUnlocked);
require(tokens[_receiver] > 0);
uint256 tokensToSend = tokens[_receiver];
tokens[_receiver] = 0;
require(token.transferFrom(owner, _receiver, tokensToSend));
TokenSent(_receiver, tokensToSend);
}
function unLockTokens() public onlyOwner whenNotPaused {
isUnlocked = true;
}
function lockTokens() public onlyOwner whenNotPaused {
isUnlocked = false;
}
function finish() public onlyOwner {
require (!isFinished);
isFinished = true;
}
function getReceiversCount() public constant onlyOwner returns (uint32) {
return receiversCount;
}
function getReceiver(uint32 i) public constant onlyOwner returns (address) {
return tokenReceivers[i];
}
function() external payable {
buy();
}
}