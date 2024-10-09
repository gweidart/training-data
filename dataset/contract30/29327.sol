pragma solidity ^0.4.18;
contract SafeMath {
function safeAdd(uint256 x, uint256 y) pure internal returns(uint256) {
uint256 z = x + y;
assert((z >= x) && (z >= y));
return z;
}
function safeSub(uint256 x, uint256 y) pure internal returns(uint256) {
assert(x >= y);
uint256 z = x - y;
return z;
}
function safeMult(uint256 x, uint256 y) pure internal returns(uint256) {
uint256 z = x * y;
assert((x == 0)||(z/x == y));
return z;
}
}
contract owned {
address public owner;
function owned() public {
owner = msg.sender;
}
modifier onlyOwner {
assert(msg.sender == owner);
_;
}
function transferOwnership(address newOwner) public onlyOwner {
owner = newOwner;
}
}
contract tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) public; }
contract Token is owned {
uint256 public totalSupply;
function balanceOf(address _owner) public constant returns (uint256 balance);
function transfer(address _to, uint256 _value) public returns (bool success);
function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
function approve(address _spender, uint256 _value) public returns (bool success);
function allowance(address _owner, address _spender) public constant returns (uint256 remaining);
event Transfer(address indexed _from, address indexed _to, uint256 _value);
event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}
contract StandardToken is SafeMath, Token {
function transfer(address _to, uint256 _value) public returns (bool success) {
if (balances[msg.sender] >= _value && _value > 0) {
balances[msg.sender] = safeSub(balances[msg.sender], _value);
balances[_to] = safeAdd(balances[_to], _value);
Transfer(msg.sender, _to, _value);
return true;
} else {
return false;
}
}
function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0) {
balances[_to] = safeAdd(balances[_to], _value);
balances[_from] = safeSub(balances[_from], _value);
allowed[_from][msg.sender] = safeSub(allowed[_from][msg.sender], _value);
Transfer(_from, _to, _value);
return true;
} else {
return false;
}
}
function balanceOf(address _owner) public view returns (uint256 balance) {
return balances[_owner];
}
function approve(address _spender, uint256 _value) public returns (bool success) {
assert((_value == 0) || (allowed[msg.sender][_spender] == 0));
allowed[msg.sender][_spender] = _value;
Approval(msg.sender, _spender, _value);
return true;
}
function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
return allowed[_owner][_spender];
}
mapping (address => uint256) balances;
mapping (address => mapping (address => uint256)) allowed;
}
contract KDTToken is StandardToken {
string public constant name = "Kradit Token";
string public constant symbol = "KDT";
uint256 public constant decimals = 18;
string public version = "1.0";
address public ethFundDeposit;
address public kdtFundDeposit;
bool public isFinalized;
uint256 public fundingStartBlock;
uint256 public fundingEndBlock;
uint256 public crowdsaleSupply = 0;
uint256 public tokenExchangeRate = 6500;
uint256 public constant tokenCreationCap =  1 * (10**9) * 10**decimals;
uint256 public tokenCrowdsaleCap =  1 * (10**8) * 10**decimals;
event CreateKDT(address indexed _to, uint256 _value);
function KDTToken(
address _ethFundDeposit,
address _kdtFundDeposit,
uint256 _tokenExchangeRate,
uint256 _fundingStartBlock,
uint256 _fundingEndBlock) public
{
isFinalized = false;
ethFundDeposit = _ethFundDeposit;
kdtFundDeposit = _kdtFundDeposit;
tokenExchangeRate = _tokenExchangeRate;
fundingStartBlock = _fundingStartBlock;
fundingEndBlock = _fundingEndBlock;
totalSupply = tokenCreationCap;
balances[kdtFundDeposit] = tokenCreationCap;
CreateKDT(kdtFundDeposit, tokenCreationCap);
}
function () public payable {
assert(!isFinalized);
require(block.number >= fundingStartBlock);
require(block.number < fundingEndBlock);
require(msg.value > 0);
uint256 tokens = safeMult(msg.value, tokenExchangeRate);
crowdsaleSupply = safeAdd(crowdsaleSupply, tokens);
require(tokenCrowdsaleCap >= crowdsaleSupply);
balances[msg.sender] += tokens;
balances[kdtFundDeposit] = safeSub(balances[kdtFundDeposit], tokens);
CreateKDT(msg.sender, tokens);
}
function createTokens() payable external {
assert(!isFinalized);
require(block.number >= fundingStartBlock);
require(block.number < fundingEndBlock);
require(msg.value > 0);
uint256 tokens = safeMult(msg.value, tokenExchangeRate);
crowdsaleSupply = safeAdd(crowdsaleSupply, tokens);
require(tokenCrowdsaleCap >= crowdsaleSupply);
balances[msg.sender] += tokens;
balances[kdtFundDeposit] = safeSub(balances[kdtFundDeposit], tokens);
CreateKDT(msg.sender, tokens);
}
function approveAndCall(address _spender, uint256 _value, bytes _extraData) public
returns (bool success) {
tokenRecipient spender = tokenRecipient(_spender);
if (approve(_spender, _value)) {
spender.receiveApproval(msg.sender, _value, this, _extraData);
return true;
}
}
function updateParams(
uint256 _tokenExchangeRate,
uint256 _tokenCrowdsaleCap,
uint256 _fundingStartBlock,
uint256 _fundingEndBlock) onlyOwner external
{
assert(block.number < fundingStartBlock);
assert(!isFinalized);
tokenExchangeRate = _tokenExchangeRate;
tokenCrowdsaleCap = _tokenCrowdsaleCap;
fundingStartBlock = _fundingStartBlock;
fundingEndBlock = _fundingEndBlock;
}
function finalize() onlyOwner external {
assert(!isFinalized);
isFinalized = true;
assert(ethFundDeposit.send(this.balance));
}
}