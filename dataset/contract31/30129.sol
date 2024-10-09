pragma solidity ^0.4.18;
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
contract OsherCrowdsale {
function crowdSaleStartTime() returns (uint);
function preicostarted() returns (uint);
}
contract OsherCoinPricing is Ownable {
OsherCoinCrowdsaleCore oshercoincrowdsalecore;
uint public preicostarted;
uint public icostarted;
uint public price;
address oshercrowdsaleaddress;
function OsherCoinPricing() {
price =.00000000001 ether;
oshercrowdsaleaddress = 0x2Ef8DcDeCd124660C8CC8E55114f615C2e657da6;
}
function crowdsalepricing( address tokenholder, uint amount  )  returns ( uint , uint ) {
uint award;
uint bonus;
return ( OsherCoinAward ( amount ) , bonus );
}
function precrowdsalepricing( address tokenholder, uint amount )   returns ( uint, uint )  {
uint award;
uint bonus;
( award, bonus ) = OsherCoinPresaleAward ( amount  );
return ( award, bonus );
}
function OsherCoinPresaleAward ( uint amount  ) public constant  returns ( uint, uint  ){
uint divisions = (amount / price) / 20;
uint bonus =   ( currentpreicobonus()/5 ) * divisions;
return ( (amount / price) , bonus );
}
function currentpreicobonus() public constant returns ( uint) {
uint bonus;
OsherCrowdsale oshercrowdsale =  OsherCrowdsale ( oshercrowdsaleaddress );
if ( now < ( oshercrowdsale.preicostarted() +   7 days ) ) bonus =   35;
if ( now > ( oshercrowdsale.preicostarted() +   7 days ) ) bonus =   30;
if ( now > ( oshercrowdsale.preicostarted() +  12 days ) ) bonus =   25;
if ( now > ( oshercrowdsale.preicostarted() +  17 days ) ) bonus =   20;
if ( now > ( oshercrowdsale.preicostarted() +  22 days ) ) bonus =   15;
if ( now > ( oshercrowdsale.preicostarted() +  27 days ) ) bonus =   10;
return bonus;
}
function OsherCoinAward ( uint amount ) public constant returns ( uint ){
return amount /  OsherCurrentICOPrice();
}
function OsherCurrentICOPrice() public constant returns ( uint ){
uint priceincrease;
OsherCrowdsale oshercrowdsale =  OsherCrowdsale ( oshercrowdsaleaddress );
uint spotprice;
uint dayspassed = now - oshercrowdsale.crowdSaleStartTime();
uint todays = dayspassed/60;
if ( todays > 20 ) todays = 20;
spotprice = (todays * .0000000000005 ether) + price;
return spotprice;
}
function setFirstRoundPricing ( uint _pricing ) onlyOwner {
price = _pricing;
}
}
contract OsherCoin {
function transfer(address receiver, uint amount)returns(bool ok);
function balanceOf( address _address )returns(uint256);
}
contract OsherCoinCrowdsaleCore is Ownable, OsherCoinPricing {
using SafeMath for uint;
address public beneficiary;
address public front;
uint public tokensSold;
uint public etherRaised;
uint public presold;
OsherCoin public tokenReward;
event ShowBool ( bool );
modifier onlyFront() {
if (msg.sender != front) {
throw;
}
_;
}
function OsherCoinCrowdsaleCore(){
tokenReward = OsherCoin(  0xa8a07e3fa28bd207e405c482ce8d02402cd60d92 );
owner = msg.sender;
beneficiary = msg.sender;
preicostarted = now;
front = 0x2Ef8DcDeCd124660C8CC8E55114f615C2e657da6;
}
function precrowdsale ( address tokenholder ) onlyFront payable {
uint award;
uint bonus;
OsherCoinPricing pricingstructure = new OsherCoinPricing();
( award, bonus ) = pricingstructure.precrowdsalepricing( tokenholder , msg.value );
presold = presold.add( award + bonus );
tokenReward.transfer ( tokenholder , award + bonus );
beneficiary.transfer ( msg.value );
etherRaised = etherRaised.add( msg.value );
tokensSold = tokensSold.add( award + bonus );
}
function crowdsale ( address tokenholder  ) onlyFront payable {
uint award;
uint bonus;
OsherCoinPricing pricingstructure = new OsherCoinPricing();
( award , bonus ) = pricingstructure.crowdsalepricing( tokenholder, msg.value );
tokenReward.transfer ( tokenholder , award );
beneficiary.transfer ( msg.value );
etherRaised = etherRaised.add( msg.value );
tokensSold = tokensSold.add( award );
}
function transferBeneficiary ( address _newbeneficiary ) onlyOwner {
beneficiary = _newbeneficiary;
}
function setFront ( address _front ) onlyOwner {
front = _front;
}
function withdrawCrowdsaleOsherCoins() onlyOwner{
uint256 balance = tokenReward.balanceOf( address( this ) );
tokenReward.transfer( beneficiary, balance );
}
}