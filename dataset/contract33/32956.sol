pragma solidity ^0.4.18;
contract Token {
function balanceOf(address _account) public constant returns (uint balance);
function transfer(address _to, uint _value) public returns (bool success);
}
contract CrowdSale {
address owner;
address Kiyomi = 0xc349d0F5dbdaF14dab04DAF5521284448C948Ec5;
uint public unitCost;
function CrowdSale() public {
owner = msg.sender;
}
function() public payable {
Token ppp = Token(Kiyomi);
uint CrowdSaleSupply = ppp.balanceOf(this);
require(msg.value > 0 && CrowdSaleSupply > 0 && unitCost > 0);
uint units = msg.value / unitCost;
units = CrowdSaleSupply < units ? CrowdSaleSupply : units;
require(units > 0 && ppp.transfer(msg.sender, units));
uint remainEther = msg.value - (units * unitCost);
if (remainEther >= 10 ** 15) {
msg.sender.transfer(remainEther);
}
}
function icoPrice(uint perEther) public returns (bool success) {
require(msg.sender == owner);
unitCost = 1 ether / (perEther * 10 ** 8);
return true;
}
function withdrawFunds(address _token) public returns (bool success) {
require(msg.sender == owner);
if (_token == address(0)) {
owner.transfer(this.balance);
}
else {
Token ERC20 = Token(_token);
ERC20.transfer(owner, ERC20.balanceOf(this));
}
return true;
}
}