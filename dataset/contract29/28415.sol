pragma solidity ^0.4.16;
interface token {
function transfer(address receiver, uint amount) public;
function balanceOf(address addr) public returns (uint);
}
contract TimedVault {
address public beneficiary;
uint public releaseDate = 1551452400;
token public tokenReward;
uint public amountOfTokens;
function TimedVault(
address ifSuccessfulSendTo,
address addressOfTokenUsedAsReward
) public {
beneficiary = ifSuccessfulSendTo;
tokenReward = token(addressOfTokenUsedAsReward);
}
function () payable public {
}
modifier afterDeadline() { if (now >= releaseDate) _; }
function safeWithdrawal() afterDeadline public {
amountOfTokens = tokenReward.balanceOf(this);
tokenReward.transfer(beneficiary, amountOfTokens);
}
}