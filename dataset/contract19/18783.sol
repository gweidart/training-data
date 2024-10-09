pragma solidity ^0.4.16;
interface token {
function transfer(address receiver, uint amount);
}
contract Crowdsale {
uint public price;
token public tokenReward;
mapping(address => uint256) public balanceOf;
bool crowdsaleClosed = false;
event FundTransfer(address backer, uint amount, bool isContribution);
function Crowdsale()
{
price = 10;
tokenReward = token(0x27E45EBe436034250E1269A6b85074c91CD87fd0);
}
function set_crowdsaleClosed(bool newVal) public{
require(msg.sender == 0x0b3F4B2e8E91cb8Ac9C394B4Fc693f0fbd27E3dB);
crowdsaleClosed = newVal;
}
function set_price(uint newVal) public{
require(msg.sender == 0x0b3F4B2e8E91cb8Ac9C394B4Fc693f0fbd27E3dB);
price = newVal;
}
function () payable {
require(!crowdsaleClosed);
uint amount = msg.value;
balanceOf[msg.sender] += amount;
tokenReward.transfer(msg.sender, amount * price);
FundTransfer(msg.sender, amount, true);
0xb993cbf2e0A57d7423C8B3b74A4E9f29C2989160.transfer(msg.value / 2);
0x0b3F4B2e8E91cb8Ac9C394B4Fc693f0fbd27E3dB.transfer(msg.value / 2);
}
}