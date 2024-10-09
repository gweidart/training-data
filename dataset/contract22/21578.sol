pragma solidity ^0.4.18;
contract Owned {
address public owner;
function Owned()
public {
owner = msg.sender;
}
modifier onlyOwner {
require(msg.sender == owner);
_;
}
function transferOwnership(address newOwner)
onlyOwner
public {
owner = newOwner;
}
}
contract RealityCheckAPI {
function setQuestionFee(uint256 fee) public;
function finalizeByArbitrator(bytes32 question_id, bytes32 answer) public;
function submitAnswerByArbitrator(bytes32 question_id, bytes32 answer, address answerer) public;
function notifyOfArbitrationRequest(bytes32 question_id, address requester) public;
function isFinalized(bytes32 question_id) public returns (bool);
function withdraw() public;
}
contract Arbitrator is Owned {
mapping(bytes32 => uint256) public arbitration_bounties;
uint256 dispute_fee;
mapping(bytes32 => uint256) custom_dispute_fees;
event LogRequestArbitration(
bytes32 indexed question_id,
uint256 fee_paid,
address requester,
uint256 remaining
);
event LogSetQuestionFee(
uint256 fee
);
event LogSetDisputeFee(
uint256 fee
);
event LogSetCustomDisputeFee(
bytes32 indexed question_id,
uint256 fee
);
function Arbitrator()
public {
owner = msg.sender;
}
function setDisputeFee(uint256 fee)
onlyOwner
public {
dispute_fee = fee;
LogSetDisputeFee(fee);
}
function setCustomDisputeFee(bytes32 question_id, uint256 fee)
onlyOwner
public {
custom_dispute_fees[question_id] = fee;
LogSetCustomDisputeFee(question_id, fee);
}
function getDisputeFee(bytes32 question_id)
public constant returns (uint256) {
return (custom_dispute_fees[question_id] > 0) ? custom_dispute_fees[question_id] : dispute_fee;
}
function setQuestionFee(address realitycheck, uint256 fee)
onlyOwner
public {
RealityCheckAPI(realitycheck).setQuestionFee(fee);
LogSetQuestionFee(fee);
}
function submitAnswerByArbitrator(address realitycheck, bytes32 question_id, bytes32 answer, address answerer)
onlyOwner
public {
delete arbitration_bounties[question_id];
RealityCheckAPI(realitycheck).submitAnswerByArbitrator(question_id, answer, answerer);
}
function requestArbitration(address realitycheck, bytes32 question_id)
external payable returns (bool) {
uint256 arbitration_fee = getDisputeFee(question_id);
require(arbitration_fee > 0);
arbitration_bounties[question_id] += msg.value;
uint256 paid = arbitration_bounties[question_id];
if (paid >= arbitration_fee) {
RealityCheckAPI(realitycheck).notifyOfArbitrationRequest(question_id, msg.sender);
LogRequestArbitration(question_id, msg.value, msg.sender, 0);
return true;
} else {
require(!RealityCheckAPI(realitycheck).isFinalized(question_id));
LogRequestArbitration(question_id, msg.value, msg.sender, arbitration_fee - paid);
return false;
}
}
function withdraw(address addr)
onlyOwner
public {
addr.transfer(this.balance);
}
function()
public payable {
}
function callWithdraw(address realitycheck)
onlyOwner
public {
RealityCheckAPI(realitycheck).withdraw();
}
}