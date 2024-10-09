pragma solidity ^0.4.23;
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
emit OwnershipTransferred(owner, newOwner);
owner = newOwner;
}
}
contract NetworkSettings is Ownable {
uint256 public registrationFee;
uint256 public activationFee;
uint256 public defaultReputationReward;
uint256 public reputationIRNNodeShare;
uint256 public blockThreshold;
event RegistrationFeeUpdated(
address indexed _sender,
uint256 _amount
);
event ActivationFeeUpdated(
address indexed _sender,
uint256 _amount
);
event DefaultReputationRewardUpdated(
address indexed _sender,
uint256 _amount
);
event ReputationIRNNodeShareUpdated(
address indexed _sender,
uint256 _percentage
);
event RewardBlockThresholdChanged(
address indexed _sender,
uint256 _newBlockThreshold
);
constructor(
uint256 _registrationFee,
uint256 _activationFee,
uint256 _defaultReputationReward,
uint256 _reputationIRNNodeShare,
uint256 _blockThreshold) public {
require(_activationFee > 0, "activation fee must be greater than 0");
require(_registrationFee > 0, "registration fee must be greater than 0");
require(_defaultReputationReward > 0, "default reputation reward must be greater than 0");
require(_reputationIRNNodeShare > 0, "new share must be larger than zero");
require(_reputationIRNNodeShare < 100, "new share must be less than 100");
activationFee = _activationFee;
registrationFee = _registrationFee;
defaultReputationReward = _defaultReputationReward;
reputationIRNNodeShare = _reputationIRNNodeShare;
blockThreshold = _blockThreshold;
}
function setRegistrationFee(uint256 _registrationFee) public onlyOwner returns (bool) {
require(_registrationFee > 0, "new registration fee must be greater than zero");
require(_registrationFee != registrationFee, "new registration fee must be different");
registrationFee = _registrationFee;
emit RegistrationFeeUpdated(msg.sender, _registrationFee);
return true;
}
function setActivationFee(uint256 _activationFee) public onlyOwner returns (bool) {
require(_activationFee > 0, "new activation fee must be greater than zero");
require(_activationFee != activationFee, "new activation fee must be different");
activationFee = _activationFee;
emit ActivationFeeUpdated(msg.sender, _activationFee);
return true;
}
function setDefaultReputationReward(uint256 _defaultReputationReward) public onlyOwner returns (bool) {
require(_defaultReputationReward > 0, "new reputation reward must be greater than zero");
require(_defaultReputationReward != defaultReputationReward, "new reputation reward must be different");
defaultReputationReward = _defaultReputationReward;
emit DefaultReputationRewardUpdated(msg.sender, _defaultReputationReward);
return true;
}
function setReputationIRNNodeShare(uint256 _reputationIRNNodeShare) public onlyOwner returns (bool) {
require(_reputationIRNNodeShare > 0, "new share must be larger than zero");
require(_reputationIRNNodeShare < 100, "new share must be less than to 100");
require(reputationIRNNodeShare != _reputationIRNNodeShare, "new share must be different");
reputationIRNNodeShare = _reputationIRNNodeShare;
emit ReputationIRNNodeShareUpdated(msg.sender, _reputationIRNNodeShare);
return true;
}
function setRewardBlockThreshold(uint _newBlockThreshold) public onlyOwner returns (bool) {
require(_newBlockThreshold != blockThreshold, "must be different");
blockThreshold = _newBlockThreshold;
emit RewardBlockThresholdChanged(msg.sender, _newBlockThreshold);
return true;
}
}