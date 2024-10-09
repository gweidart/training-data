pragma solidity ^0.4.13;
contract token {
function transfer(address _to, uint256 _value);
function balanceOf(address _owner) constant returns (uint256 balance);
}
contract BDSM_Crowdsale {
token public sharesTokenAddress;
address public owner;
address public safeContract;
uint public startICO_20_December = 1513728060;
uint public stopICO_20_March = 1521504060;
uint public increasePrice_20_January = 1516406460;
uint public increasePrice_20_February = 1519084860;
uint public price = 0.0035 * 1 ether;
uint coeff = 100000;
uint256 public tokenSold = 0;
uint256 public tokenFree = 0;
bool public crowdsaleClosed = false;
bool public tokenWithdraw = false;
event TokenFree(uint256 value);
event CrowdsaleClosed(bool value);
function BDSM_Crowdsale(address _tokenAddress, address _owner, address _stopScamHolder) {
owner = _owner;
sharesTokenAddress = token(_tokenAddress);
safeContract = _stopScamHolder;
}
function() payable {
if(now > increasePrice_20_February) price = 0.070 * 1 ether;
else if(now > increasePrice_20_January) price = 0.00525 * 1 ether;
tokenFree = sharesTokenAddress.balanceOf(this);
if (now < startICO_20_December) {
msg.sender.transfer(msg.value);
}
else if (now > stopICO_20_March) {
msg.sender.transfer(msg.value);
if(!tokenWithdraw){
sharesTokenAddress.transfer(safeContract, sharesTokenAddress.balanceOf(this));
tokenFree = sharesTokenAddress.balanceOf(this);
tokenWithdraw = true;
crowdsaleClosed = true;
}
}
else if (crowdsaleClosed) {
msg.sender.transfer(msg.value);
}
else {
uint256 tokenToBuy = msg.value / price * coeff;
if(tokenToBuy <= 0) msg.sender.transfer(msg.value);
require(tokenToBuy > 0);
uint256 actualETHTransfer = tokenToBuy * price / coeff;
if (tokenFree >= tokenToBuy) {
owner.transfer(actualETHTransfer);
if (msg.value > actualETHTransfer){
msg.sender.transfer(msg.value - actualETHTransfer);
}
sharesTokenAddress.transfer(msg.sender, tokenToBuy);
tokenSold += tokenToBuy;
tokenFree -= tokenToBuy;
if(tokenFree==0) crowdsaleClosed = true;
} else {
uint256 sendETH = tokenFree * price / coeff;
owner.transfer(sendETH);
sharesTokenAddress.transfer(msg.sender, tokenFree);
msg.sender.transfer(msg.value - sendETH);
tokenSold += tokenFree;
tokenFree = sharesTokenAddress.balanceOf(this);
crowdsaleClosed = true;
}
}
TokenFree(tokenFree);
CrowdsaleClosed(crowdsaleClosed);
}
}