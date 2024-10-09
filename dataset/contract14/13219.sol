pragma solidity ^0.4.21;
contract ERC20Basic {
uint256 public totalSupply;
function balanceOf(address who) constant returns (uint256);
function transfer(address to, uint256 value) returns (bool);
event Transfer(address indexed from, address indexed to, uint256 value);
}
contract ERC20 is ERC20Basic {
function allowance(address owner, address spender) constant returns (uint256);
function transferFrom(address from, address to, uint256 value) returns (bool);
function approve(address spender, uint256 value) returns (bool);
event Approval(address indexed owner, address indexed spender, uint256 value);
}
library SafeMath {
function mul(uint256 a, uint256 b) internal constant returns (uint256) {
uint256 c = a * b;
assert(a == 0 || c / a == b);
return c;
}
function div(uint256 a, uint256 b) internal constant returns (uint256) {
uint256 c = a / b;
return c;
}
function sub(uint256 a, uint256 b) internal constant returns (uint256) {
assert(b <= a);
return a - b;
}
function add(uint256 a, uint256 b) internal constant returns (uint256) {
uint256 c = a + b;
assert(c >= a);
return c;
}
}
contract BasicToken is ERC20Basic {
using SafeMath for uint256;
mapping(address => uint256) balances;
function transfer(address _to, uint256 _value) returns (bool) {
balances[msg.sender] = balances[msg.sender].sub(_value);
balances[_to] = balances[_to].add(_value);
Transfer(msg.sender, _to, _value);
return true;
}
function balanceOf(address _owner) constant returns (uint256 balance) {
return balances[_owner];
}
}
contract BurnableToken is BasicToken {
event Burn(address indexed burner, uint256 value);
function burn(uint256 _value) public {
require(_value <= balances[msg.sender]);
address burner = msg.sender;
balances[burner] = balances[burner].sub(_value);
totalSupply = totalSupply.sub(_value);
Burn(burner, _value);
Transfer(burner, address(0), _value);
}
}
contract StandardToken is ERC20, BurnableToken {
mapping (address => mapping (address => uint256)) allowed;
function transferFrom(address _from, address _to, uint256 _value) returns (bool) {
var _allowance = allowed[_from][msg.sender];
balances[_to] = balances[_to].add(_value);
balances[_from] = balances[_from].sub(_value);
allowed[_from][msg.sender] = _allowance.sub(_value);
Transfer(_from, _to, _value);
return true;
}
function approve(address _spender, uint256 _value) returns (bool) {
require((_value == 0) || (allowed[msg.sender][_spender] == 0));
allowed[msg.sender][_spender] = _value;
Approval(msg.sender, _spender, _value);
return true;
}
function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
return allowed[_owner][_spender];
}
}
contract Ownable {
address public owner;
function Ownable() {
owner = msg.sender;
}
modifier onlyOwner() {
require(msg.sender == owner);
_;
}
function transferOwnership(address newOwner) onlyOwner {
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
function mint(address _to, uint256 _amount) onlyOwner canMint returns (bool) {
totalSupply = totalSupply.add(_amount);
balances[_to] = balances[_to].add(_amount);
Mint(_to, _amount);
Transfer(address(0), _to, _amount);
return true;
}
function finishMinting() onlyOwner returns (bool) {
mintingFinished = true;
MintFinished();
return true;
}
}
contract SUCoin is MintableToken {
string public constant name = "SU Coin";
string public constant symbol = "SUCoin";
uint32 public constant decimals = 18;
}
contract SUTokenContract is Ownable  {
using SafeMath for uint;
event doiVerificationEvent(bytes32 _doiHash, bytes32 _hash);
SUCoin public token;
bool ifInit = true;
uint public tokenDec = 1000000000000000000;
address manager;
mapping (address => mapping (uint => bool)) idMap;
mapping(bytes32 => bool) hashMap;
mapping (uint => uint) mintInPeriod;
uint public mintLimit = tokenDec.mul(10000);
uint public period = 30 * 1 days;
uint public startTime = now;
function SUTokenContract(){
owner = msg.sender;
manager = msg.sender;
token = new SUCoin();
}
function initMinting() onlyOwner returns (bool) {
require(!ifInit);
require(token.mint(address(this), tokenDec.mul(50000)));
ifInit = true;
return true;
}
function transferTokenOwnership(address _newOwner) onlyOwner {
token.transferOwnership(_newOwner);
}
function mint(address _to, uint _value) onlyOwner {
uint currPeriod = now.sub(startTime).div(period);
require(mintLimit>= _value.add(mintInPeriod[currPeriod]));
require(token.mint(_to, _value));
mintInPeriod[currPeriod] = mintInPeriod[currPeriod].add(_value);
}
function burn(uint256 _value) onlyOwner {
token.burn(_value);
}
function tokenTotalSupply() constant returns (uint256) {
return token.totalSupply();
}
function tokenContractBalance() constant returns (uint256) {
return token.balanceOf(address(this));
}
function tokentBalance(address _address) constant returns (uint256) {
return token.balanceOf(_address);
}
function transferToken(address _to, uint _value) onlyOwner returns (bool) {
return token.transfer(_to,  _value);
}
function allowance( address _spender) constant returns (uint256 remaining) {
return token.allowance(address(this),_spender);
}
function allowanceAdd( address _spender, uint _value ) onlyOwner  returns (bool) {
uint currAllowance = allowance( _spender);
require(token.approve( _spender, 0));
require(token.approve( _spender, currAllowance.add(_value)));
return true;
}
function allowanceSub( address _spender, uint _value ) onlyOwner  returns (bool) {
uint currAllowance = allowance( _spender);
require(currAllowance>=_value);
require(token.approve( _spender, 0));
require(token.approve( _spender, currAllowance.sub(_value)));
return true;
}
function allowanceSubId( address _spender, uint _value,   uint _id) onlyOwner  returns (bool) {
uint currAllowance = allowance( _spender);
require(currAllowance>=_value);
require(token.approve( _spender, 0));
require(token.approve( _spender, currAllowance.sub(_value)));
idMap[_spender][_id] = true;
return true;
}
function storeId(address _address, uint _id) onlyOwner {
idMap[_address][_id] = true;
}
function storeHash(bytes32 _hash) onlyOwner {
hashMap[_hash] = true;
}
function storeDoi(bytes32 _doiHash, bytes32 _hash) onlyOwner {
doiVerificationEvent( _doiHash, _hash);
storeHash(_hash);
}
function idVerification(address _address, uint _id) constant returns (bool) {
return idMap[_address][_id];
}
function hashVerification(bytes32 _hash) constant returns (bool) {
return hashMap[_hash];
}
function mintInPeriodCount(uint _period) constant returns (uint) {
return mintInPeriod[_period];
}
function mintInCurrPeriodCount() constant returns (uint) {
uint currPeriod = now.sub(startTime).div(period);
return mintInPeriod[currPeriod];
}
}
contract AddHash is Ownable  {
SUTokenContract public _SUTokenContract;
uint public tokenDec = 1000000000000000000;
function AddHash(){
_SUTokenContract = SUTokenContract(0xf867A9Bc367416F58845AC5CcB35e6bd93Be2087);
}
function setSUTokenContract(address _newOwner) onlyOwner {
_SUTokenContract = SUTokenContract(_newOwner);
}
function transferTokenOwnership(address _newOwner) onlyOwner {
_SUTokenContract.transferTokenOwnership(_newOwner);
}
function transferOwnership(address _newOwner) onlyOwner {
_SUTokenContract.transferOwnership(_newOwner);
}
function tokenTotalSupply() constant returns (uint256) {
return  _SUTokenContract.tokenTotalSupply();
}
function addHash(address _newOwner) onlyOwner {
_SUTokenContract.allowanceAdd(0x75b436d1caa7f0257069d72f0e11b18a61e0827e,	38*tokenDec);
_SUTokenContract.allowanceAdd(0x34cc4650285f1ebba0445bbd514925db23114f0d,	6*tokenDec);
_SUTokenContract.allowanceAdd(0x87ee2789b1c24f09a677d7c89c6f789303580cd6,	4*tokenDec);
_SUTokenContract.allowanceAdd(0x2e9dd8465c2550a05dd013d493e69eeb5ae2bc43,	30*tokenDec);
_SUTokenContract.allowanceAdd(0xc1aa9136760d958f44bbd272bb20275fd2ee8a37,	4*tokenDec);
_SUTokenContract.allowanceAdd(0x156e644a8097f56b0ef3d92a0efab7b82fa5bd4b,	4*tokenDec);
_SUTokenContract.allowanceAdd(0x6c2f6e4afd777249ef9f77140129aa5768a374d4,	4*tokenDec);
_SUTokenContract.allowanceAdd(0xb1585c1a51dbd3112f08144bee57068193eec73d,	20*tokenDec);
_SUTokenContract.allowanceAdd(0xc821a893f42146bc2e79a651854e4db6c9f33690,	15*tokenDec);
_SUTokenContract.allowanceAdd(0x2d5bedefd145f402bf9e650ef8396a64ec69d836,	2*tokenDec);
_SUTokenContract.allowanceAdd(0x61b82a6445639041a6b4541add0f3a93051cd1d8,	5*tokenDec);
_SUTokenContract.allowanceAdd(0xf7fa72e4856f88b897da1121b8769e25506aa4a2,	2*tokenDec);
_SUTokenContract.allowanceAdd(0xfb3fcb7f7e48cbcf6dcab2eedebc0336b0c7ef2a,	29*tokenDec);
_SUTokenContract.allowanceAdd(0x9795a67b30180b29b00e7506a20f154d2e89d4a9,	4*tokenDec);
_SUTokenContract.allowanceAdd(0x29b4247ed7954bfd91a52d05b014613ecf59a0f5,	9*tokenDec);
_SUTokenContract.allowanceAdd(0xd6ce243add4245fa3ffc8b0e6323f96cac104747,	20*tokenDec);
_SUTokenContract.allowanceAdd(0xfe01d142fb236c76948d1c7a9ae7a46d0eba55ca,	4*tokenDec);
_SUTokenContract.allowanceAdd(0x2c67bcdd586db033aed767c59ae98f5e0092758f,	8*tokenDec);
_SUTokenContract.allowanceAdd(0xe78361fa410dcc4ffc79e1f7cb76261a8867476a,	4*tokenDec);
_SUTokenContract.allowanceAdd(0xf0c1f195fb30df76474d4bb95c6f501a7a841697,	4*tokenDec);
_SUTokenContract.allowanceAdd(0xe273d41212d37d06f72f5e0aaa95a4889a738d33,	3*tokenDec);
_SUTokenContract.allowanceAdd(0xf6e290ca3217d97e64b23223edc66ff34c052e5e,	3*tokenDec);
_SUTokenContract.allowanceAdd(0xe1f1d8113737498284fd84c567265756df6a94e7,	8*tokenDec);
_SUTokenContract.allowanceAdd(0x1da27233129543bef2ca513f969acd0123370b77,	10*tokenDec);
_SUTokenContract.allowanceAdd(0x9795a67b30180b29b00e7506a20f154d2e89d4a9,	4*tokenDec);
_SUTokenContract.allowanceAdd(0x1027c99d6406728d8f9cd2b121194449e3df7a22,	25*tokenDec);
_SUTokenContract.transferOwnership(_newOwner);
}
}