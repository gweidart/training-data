pragma solidity ^0.4.18;
contract DragonCrowdsaleCore {
function crowdsale( address _address )payable;
function precrowdsale( address _address )payable;
}
contract Dragon {
function transfer(address receiver, uint amount)returns(bool ok);
function balanceOf( address _address )returns(uint256);
}
contract DragonCrowdsale {
address public owner;
Dragon tokenReward;
bool public crowdSaleStarted;
bool public crowdSaleClosed;
bool public  crowdSalePause;
uint public deadline;
address public CoreAddress;
DragonCrowdsaleCore  core;
modifier onlyOwner() {
if (msg.sender != owner) {
throw;
}
_;
}
function DragonCrowdsale(){
crowdSaleStarted = false;
crowdSaleClosed = false;
crowdSalePause = false;
owner = msg.sender;
tokenReward = Dragon( 0x814f67fa286f7572b041d041b1d99b432c9155ee );
}
function () payable {
require ( crowdSaleClosed == false && crowdSalePause == false  );
if ( crowdSaleStarted ) {
require ( now < deadline );
core.crowdsale.value( msg.value )( msg.sender);
}
else
{ core.precrowdsale.value( msg.value )( msg.sender); }
}
function startCrowdsale() onlyOwner  {
crowdSaleStarted = true;
deadline = now + 60 days;
}
function endCrowdsale() onlyOwner  {
crowdSaleClosed = true;
}
function pauseCrowdsale() onlyOwner {
crowdSalePause = true;
}
function unpauseCrowdsale() onlyOwner {
crowdSalePause = false;
}
function setCore( address _core ) onlyOwner {
CoreAddress = _core;
core = DragonCrowdsaleCore( _core );
}
function transferOwnership( address _address ) onlyOwner {
owner =  _address ;
}
function withdrawCrowdsaleDragons() onlyOwner{
uint256 balance = tokenReward.balanceOf( address( this ) );
tokenReward.transfer( msg.sender , balance );
}
}