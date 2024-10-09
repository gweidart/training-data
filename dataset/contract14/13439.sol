pragma solidity ^0.4.11;
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
contract Ownable {
address public owner;
function Ownable() public {
owner = msg.sender;
}
modifier onlyOwner() {
require(msg.sender == owner);
_;
}
}
interface Token {
function transfer(address _reciever, uint256 _value);
function transferOwner(address _from, address _to,  uint256 _value);
}
contract StepCoinIco is Ownable {
using SafeMath for uint256;
uint public buyPrice;
Token public token;
address multisigMain;
address multisig01;
address multisig02;
address multisig03;
address multisig04;
address multisig05;
address multisig06;
uint constant startIco = 1530403200;
uint constant endIco = 1535760000;
modifier saleIsOn() {
require(now >= startIco && now < endIco);
_;
}
modifier limits() {
require(msg.value >= 1 finney && msg.value <= 100 ether);
_;
}
function StepCoinIco(Token _token) {
multisigMain = 0x29172317dBB1b894f4224a5a0f6552bF56837A80;
multisig01 = 0x077Dd1D4B19805E7f3e492E6a99977C08dCb0B50;
multisig02 = 0xC91164BC5bC9d053Af3653745378439a07d42Fd0;
multisig03 = 0x36F31F604ABf3ecFdB6E34F6C0426bDFb941F1F2;
multisig04 = 0xCd4bcD9BFD29f224D1a97C0FF0f7423113d6B820;
multisig05 = 0xD3f1DA8C238ea8AAf11082FADE14e5015956865d;
multisig06 = 0xAc2524dD77E72AB3760BA8501B509cd9858F9D67;
token = _token;
buyPrice = 1000000000000;
}
function () payable {
_buy(msg.sender, msg.value);
}
function buy() payable returns (uint) {
uint tokens = _buy(msg.sender, msg.value);
return tokens;
}
function _buy(address _sender, uint256 _amount) saleIsOn limits internal returns (uint) {
uint _tokensAmountMultisigMain = msg.value.div(2);
uint _tokensAmountMultisig01 = msg.value.div(10);
uint _tokensAmountMultisig02 = msg.value.div(10);
uint _tokensAmountMultisig03 = msg.value.div(10);
uint _tokensAmountMultisig04 = msg.value.div(10);
uint _tokensAmountMultisig05 = msg.value.div(20);
uint _tokensAmountMultisig06 = msg.value.div(20);
multisigMain.transfer(_tokensAmountMultisigMain);
multisig01.transfer(_tokensAmountMultisig01);
multisig02.transfer(_tokensAmountMultisig02);
multisig03.transfer(_tokensAmountMultisig03);
multisig04.transfer(_tokensAmountMultisig04);
multisig05.transfer(_tokensAmountMultisig05);
multisig06.transfer(_tokensAmountMultisig06);
uint tokens = _amount.div(buyPrice);
token.transfer(_sender, tokens);
return tokens;
}
function sendTokens(address _address, uint _amount) onlyOwner external {
require(_address != 0x0);
token.transferOwner(address(this), _address, _amount);
}
}