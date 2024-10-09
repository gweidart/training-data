pragma solidity ^0.4.4;
contract Authorization {
address internal admin;
function Authorization() {
admin = msg.sender;
}
modifier onlyAdmin() {
if(msg.sender != admin) throw;
_;
}
}
contract NATVCoin is Authorization {
function checkIfFundingCompleteOrExpired() private {
if (fundingMaximumTargetInWei != 0 && totalRaised >= fundingMaximumTargetInWei) {
state = State.Closed;
LogFundingSuccessful(totalRaised);
completedAt = now;
} else if ( now > deadline )  {
if(totalRaised >= fundingMinimumTargetInWei){
state = State.Closed;
LogFundingSuccessful(totalRaised);
completedAt = now;
} else{
state = State.Failed;
completedAt = now;
}
}
}
function payOut()
private
inState(State.Fundraising)
{
if(!beneficiary.send(this.balance)) {
throw;
}
if (state == State.Successful) {
state = State.Closed;
}
currentBalance = 0;
LogWinnerPaid(beneficiary);
}
function () payable inState(State.Fundraising) isMinimum() { contribute(msg.sender); }
}