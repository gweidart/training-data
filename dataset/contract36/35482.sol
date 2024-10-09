pragma solidity ^0.4.11;
contract token {
function transfer(address receiver, uint amount);
function balanceOf( address _address )returns(uint256);
}
contract DragonCrowdsale {
address public beneficiary;
address public owner;
address public charity;
uint public amountRaised;
uint public tokensSold;
uint public deadline;
uint public price;
uint public preICOspecial;
token public tokenReward;
mapping( address => uint256 ) public contributions;
mapping( address => bool )    public preICOparticipated;
bool public crowdSaleStart;
bool public crowdSalePause;
bool public crowdSaleClosed;
enum Package { Zero, Small, Large }
Package package;
event FundTransfer(address participant, uint amount);
modifier onlyOwner() {
if (msg.sender != owner) {
throw;
}
_;
}
function DragonCrowdsale() {
beneficiary = msg.sender;
charity = msg.sender;
owner = msg.sender;
price =  .000000000033333333 ether;
tokenReward = token( 0x1d1CF6cD3fE91fe4d1533BA3E0b7758DFb59aa1f );
crowdSaleStart == false;
preICOspecial = 3500000000000000;
}
function () payable {
require(!crowdSaleClosed);
require(!crowdSalePause);
if( msg.value != .3333333 ether && msg.value != 3.3333333 ether  && crowdSaleStart == false  ) throw;
if ( crowdSaleStart == false && preICOparticipated[msg.sender] == true ) throw;
if ( crowdSaleStart == false ) {
if ( msg.value ==  .3333333 ether ) package = Package.Small;
if ( msg.value == 3.3333333 ether ) package = Package.Large;
}
if ( crowdSaleStart) require( now < deadline );
uint amount = msg.value;
tokenReward.transfer( msg.sender, amount / price );
if ( package == Package.Small  && crowdSaleStart == false && tokensSold < preICOspecial ) {
tokenReward.transfer( charity    , 800000000  );
tokenReward.transfer( msg.sender , 800000000  );
preICOparticipated[ msg.sender ] = true;
tokensSold +=  1600000000;
}
if ( package == Package.Large  && crowdSaleStart == false && tokensSold < preICOspecial ) {
tokenReward.transfer( charity    , 8000000000 );
tokenReward.transfer( msg.sender , 8000000000 );
preICOparticipated[ msg.sender ] = true;
tokensSold += 16000000000;
}
contributions[msg.sender] += amount;
tokensSold += amount / price;
amountRaised += amount;
FundTransfer( msg.sender, amount );
beneficiary.transfer( amount );
}
function startCrowdsale() onlyOwner  {
crowdSaleStart = true;
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
function transferOwnership ( address _newowner ) onlyOwner {
owner = _newowner;
}
function transferBeneficiary ( address _newbeneficiary ) onlyOwner {
beneficiary = _newbeneficiary;
}
function transferCharity ( address _newcharity ) onlyOwner {
charity = _newcharity;
}
function withdrawDragons() onlyOwner{
uint256 balance = tokenReward.balanceOf(address(this));
tokenReward.transfer( beneficiary, balance );
}
}