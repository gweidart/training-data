pragma solidity ^0.4.11;
contract Finalizable {
uint256 public finalizedBlock;
bool public goalMet;
function finalize();
}
contract Refundable {
function refund(address th, uint amount) returns (bool);
}
contract ContributionWallet is Refundable {
address public multisig;
Finalizable public contribution;
function ContributionWallet(address _multisig, address _contribution) {
require(_multisig != 0x0);
require(_contribution != 0x0);
multisig = _multisig;
contribution = Finalizable(_contribution);
}
function () public payable {}
function withdraw() public {
require(msg.sender == multisig);
assert(contribution.goalMet() || contribution.finalizedBlock() != 0);
multisig.transfer(this.balance);
}
function refund(address th, uint amount) returns (bool) {
assert(msg.sender == address(contribution));
th.transfer(amount);
return true;
}
}