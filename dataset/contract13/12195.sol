pragma solidity ^0.4.24;
contract ERC20Basic {
uint256 public totalSupply;
function balanceOf(address who) public constant returns (uint256);
function transfer(address to, uint256 value) public returns (bool);
event Transfer(address indexed from, address indexed to, uint256 value);
}
contract ERC20 is ERC20Basic {
function allowance(address owner, address spender) public constant returns (uint256);
function transferFrom(address from, address to, uint256 value) public returns (bool);
function approve(address spender, uint256 value) public returns (bool);
event Approval(address indexed owner, address indexed spender, uint256 value);
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
contract BasicToken is ERC20Basic {
using SafeMath for uint256;
mapping(address => uint256) balances;
function transfer(address _to, uint256 _value) public returns (bool) {
balances[msg.sender] = balances[msg.sender].sub(_value);
balances[_to] = balances[_to].add(_value);
emit Transfer(msg.sender, _to, _value);
return true;
}
function balanceOf(address _owner) public constant returns (uint256 balance) {
return balances[_owner];
}
}
contract StandardToken is ERC20, BasicToken {
mapping (address => mapping (address => uint256)) allowed;
function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
uint256 _allowance = allowed[_from][msg.sender];
balances[_to] = balances[_to].add(_value);
balances[_from] = balances[_from].sub(_value);
allowed[_from][msg.sender] = _allowance.sub(_value);
emit Transfer(_from, _to, _value);
return true;
}
function approve(address _spender, uint256 _value) public returns (bool) {
require((_value == 0) || (allowed[msg.sender][_spender] == 0));
allowed[msg.sender][_spender] = _value;
emit Approval(msg.sender, _spender, _value);
return true;
}
function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
return allowed[_owner][_spender];
}
}
contract Ownable {
address public owner;
constructor() public {
owner = msg.sender;
}
modifier onlyOwner() {
require(msg.sender == owner);
_;
}
function transferOwnership(address newOwner) public onlyOwner {
require(newOwner != address(0));
owner = newOwner;
}
}
contract MintableToken is StandardToken, Ownable {
event Mint(address indexed to, uint256 amount);
event MintFinished();
bool public mintingFinished = false;
modifier canMint() {
require(!mintingFinished);
_;
}
function mint(address _to, uint256 _amount) onlyOwner canMint public returns (bool) {
totalSupply = totalSupply.add(_amount);
balances[_to] = balances[_to].add(_amount);
emit Mint(_to, _amount);
emit Transfer(address(0), _to, _amount);
return true;
}
function finishMinting() onlyOwner public returns (bool) {
mintingFinished = true;
emit MintFinished();
return true;
}
}
contract SMAR is MintableToken {
string public constant name = "SmartRetail ICO";
string public constant symbol = "SMAR";
uint32 public constant decimals = 18;
}
contract Crowdsale is Ownable {
using SafeMath for uint;
address public multisig = 0xF15eE43d0345089625050c08b482C3f2285e4F12;
uint dec = 1000000000000000000;
SMAR public token = new SMAR();
uint public icoStartP1 = 1528675200;
uint public icoStartP2 = 1531267200;
uint public icoStartP3 = 1533945600;
uint public icoStartP4 = 1536624000;
uint public icoStartP5 = 1539216000;
uint public icoStartP6 = 1541894400;
uint public icoEnd = 1544486400;
uint public icoSoftcap = 35000*dec;
uint public icoHardcap =  1000000*dec;
uint public tokensFor1EthP6 = 50*dec;
uint public tokensFor1EthP1 = tokensFor1EthP6*125/100;
uint public tokensFor1EthP2 = tokensFor1EthP6*120/100;
uint public tokensFor1EthP3 = tokensFor1EthP6*115/100;
uint public tokensFor1EthP4 = tokensFor1EthP6*110/100;
uint public tokensFor1EthP5 = tokensFor1EthP6*105/100;
mapping(address => uint) public balances;
constructor() public {
owner = multisig;
token.mint(multisig, 5000*dec);
}
function refund() public {
require(  (now>icoEnd)&&(token.totalSupply()<icoSoftcap) );
uint value = balances[msg.sender];
balances[msg.sender] = 0;
msg.sender.transfer(value);
}
function refundToWallet(address _wallet) public  {
require(  (now>icoEnd)&&(token.totalSupply()<icoSoftcap) );
uint value = balances[_wallet];
balances[_wallet] = 0;
_wallet.transfer(value);
}
function withdraw() public onlyOwner {
require(token.totalSupply()>=icoSoftcap);
multisig.transfer(address(this).balance);
}
function finishMinting() public onlyOwner {
if(now>icoEnd) {
token.finishMinting();
token.transferOwnership(multisig);
}
}
function createTokens()  payable public {
require( (now>=icoStartP1)&&(now<icoEnd) );
require(token.totalSupply()<icoHardcap);
uint tokens = 0;
uint sum = msg.value;
uint tokensFor1EthCurr = tokensFor1EthP6;
uint rest = 0;
if(now < icoStartP2) {
tokensFor1EthCurr = tokensFor1EthP1;
} else if(now >= icoStartP2 && now < icoStartP3) {
tokensFor1EthCurr = tokensFor1EthP2;
} else if(now >= icoStartP3 && now < icoStartP4) {
tokensFor1EthCurr = tokensFor1EthP3;
} else if(now >= icoStartP4 && now < icoStartP5) {
tokensFor1EthCurr = tokensFor1EthP4;
} else if(now >= icoStartP5 && now < icoStartP6) {
tokensFor1EthCurr = tokensFor1EthP5;
}
tokens = sum.mul(tokensFor1EthCurr).div(1000000000000000000);
if(token.totalSupply().add(tokens) > icoHardcap){
tokens = icoHardcap.sub(token.totalSupply());
rest = sum.sub(tokens.mul(1000000000000000000).div(tokensFor1EthCurr));
}
token.mint(msg.sender, tokens);
if(rest!=0){
msg.sender.transfer(rest);
}
balances[msg.sender] = balances[msg.sender].add(sum.sub(rest));
if(token.totalSupply()>=icoSoftcap){
multisig.transfer(address(this).balance);
}
}
function() external payable {
createTokens();
}
}