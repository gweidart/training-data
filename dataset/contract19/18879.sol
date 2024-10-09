pragma solidity ^0.4.16;
interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) external; }
contract TokenERC20 {
string public name = "SurveyToken";
string public symbol = "SRT";
uint8 public decimals = 18;
uint256 public totalSupply;
mapping (address => uint256) public balanceOf;
mapping (address => mapping (address => uint256)) public allowance;
event Transfer(address indexed from, address indexed to, uint256 value);
event Burn(address indexed from, uint256 value);
function TokenERC20(uint256 initialSupply) public {
totalSupply = initialSupply * 10 ** uint256(decimals);
balanceOf[msg.sender] = totalSupply;
}
function _transfer(address _from, address _to, uint _value) internal {
require(_to != 0x0);
require(balanceOf[_from] >= _value);
require(balanceOf[_to] + _value > balanceOf[_to]);
uint previousBalances = balanceOf[_from] + balanceOf[_to];
balanceOf[_from] -= _value;
balanceOf[_to] += _value;
Transfer(_from, _to, _value);
assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
}
function transfer(address _to, uint256 _value) public {
_transfer(msg.sender, _to, _value);
}
function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
require(_value <= allowance[_from][msg.sender]);
allowance[_from][msg.sender] -= _value;
_transfer(_from, _to, _value);
return true;
}
function approve(address _spender, uint256 _value) public
returns (bool success) {
allowance[msg.sender][_spender] = _value;
return true;
}
function approveAndCall(address _spender, uint256 _value, bytes _extraData)
public
returns (bool success) {
tokenRecipient spender = tokenRecipient(_spender);
if (approve(_spender, _value)) {
spender.receiveApproval(msg.sender, _value, this, _extraData);
return true;
}
}
function burn(uint256 _value) public returns (bool success) {
require(balanceOf[msg.sender] >= _value);
balanceOf[msg.sender] -= _value;
totalSupply -= _value;
Burn(msg.sender, _value);
return true;
}
function burnFrom(address _from, uint256 _value) public returns (bool success) {
require(balanceOf[_from] >= _value);
require(_value <= allowance[_from][msg.sender]);
balanceOf[_from] -= _value;
allowance[_from][msg.sender] -= _value;
totalSupply -= _value;
Burn(_from, _value);
return true;
}
}
contract owned {
address public owner;
function owned() public {
owner = msg.sender;
}
modifier onlyOwner {
require(msg.sender == owner);
_;
}
function transferOwnership(address newOwner) public onlyOwner {
owner = newOwner;
}
}
contract SurveyToken is TokenERC20, owned
{
struct Survey {
address initiator;
uint256 toPay;
uint256 balance;
uint32 tickets;
uint256 reward;
mapping(address => bool) respondents;
}
address feeReceiver;
mapping(bytes32 => Survey) surveys;
mapping(address => bool) robots;
modifier onlyRobot {
require(robots[msg.sender]);
_;
}
function SurveyToken(uint256 initialSupply) public
TokenERC20(initialSupply) {
feeReceiver = msg.sender;
}
function setFeeReceiver(address newReceiver) public onlyOwner {
require(newReceiver != 0x0);
feeReceiver = newReceiver;
}
function addRobot(address newRobot) public onlyOwner returns(bool success) {
require(newRobot != 0x0);
require(robots[newRobot] == false);
robots[newRobot] = true;
return true;
}
function removeRobot(address oldRobot) public onlyOwner returns(bool success) {
require(oldRobot != 0x0);
require(robots[oldRobot] == true);
robots[oldRobot] = false;
return true;
}
function placeNewSurvey(bytes32 key, uint256 toPay, uint32 tickets, uint256 reward) public returns(bool success) {
require(surveys[key].initiator == 0x0);
require(tickets > 0 && reward >= 0);
uint256 rewardBalance = tickets * reward;
require(rewardBalance < toPay && toPay > 0);
require(balanceOf[msg.sender] >= toPay);
uint256 fee = toPay - rewardBalance;
require(balanceOf[feeReceiver] + fee > balanceOf[feeReceiver]);
transfer(feeReceiver, fee);
balanceOf[msg.sender] -= rewardBalance;
surveys[key] = Survey(msg.sender, toPay, rewardBalance, tickets, reward);
Transfer(msg.sender, 0x0, rewardBalance);
return true;
}
function giveReward(bytes32 surveyKey, address respondent, uint8 karma) public onlyRobot returns(bool success) {
require(respondent != 0x0);
Survey storage surv = surveys[surveyKey];
require(surv.respondents[respondent] == false);
require(surv.tickets > 0 && surv.reward > 0 && surv.balance >= surv.reward);
require(karma >= 0 && karma <= 10);
if (karma < 10) {
uint256 fhalf = surv.reward / 2;
uint256 shalf = ((surv.reward - fhalf) / 10) * karma;
uint256 respReward = fhalf + shalf;
uint256 fine = surv.reward - respReward;
require(balanceOf[respondent] + respReward > balanceOf[respondent]);
require(balanceOf[feeReceiver] + fine > balanceOf[feeReceiver]);
balanceOf[respondent] += respReward;
Transfer(0x0, respondent, respReward);
balanceOf[feeReceiver] += fine;
Transfer(0x0, feeReceiver, fine);
} else {
require(balanceOf[respondent] + surv.reward > balanceOf[respondent]);
balanceOf[respondent] += surv.reward;
Transfer(0x0, respondent, surv.reward);
}
surv.tickets--;
surv.balance -= surv.reward;
surv.respondents[respondent] = true;
return true;
}
function removeSurvey(bytes32 surveyKey) public onlyRobot returns(bool success) {
Survey storage surv = surveys[surveyKey];
require(surv.initiator != 0x0 && surv.balance > 0);
require(balanceOf[surv.initiator] + surv.balance > balanceOf[surv.initiator]);
balanceOf[surv.initiator] += surv.balance;
Transfer(0x0, surv.initiator, surv.balance);
surv.balance = 0;
return true;
}
function getSurveyInfo(bytes32 key) public constant returns(bool success, uint256 toPay, uint32 tickets, uint256 reward) {
Survey storage surv = surveys[key];
require(surv.initiator != 0x0);
return (true, surv.toPay, surv.tickets, surv.reward);
}
}