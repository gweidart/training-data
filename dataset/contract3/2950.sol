pragma solidity 0.4.24;
library SafeMath {
function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
if (a == 0) {
return 0;
}
c = a * b;
assert(c / a == b);
return c;
}
function div(uint256 a, uint256 b) internal pure returns (uint256) {
return a / b;
}
function sub(uint256 a, uint256 b) internal pure returns (uint256) {
assert(b <= a);
return a - b;
}
function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
c = a + b;
assert(c >= a);
return c;
}
}
contract EthRaised {
using SafeMath for uint256;
address public thisContractAddress;
address public admin;
uint public createdAt;
address public teamEthContract = 0x9c229Dd7546eb8f5A12896e03e977b644a96B961;
address public toteLiquidatorWallet = 0x8AF2dA3182a3dae379d51367a34480Bd5d04F4e2;
address public ethertoteDevelopmentWallet = 0x1a3c1ca46c58e9b140485A9B0B740d42aB3B4a26;
bool public teamEthTransferComplete;
bool public toteLiquidatorTranserComplete;
bool public ethertoteDevelopmentTransferComplete;
uint public ethToBeDistributed;
uint public percentageToEthertoteDevelopmentWallet = 40;
uint public percentageToTeamEthContract = 30;
uint public percentageToToteLiquidatorWallet = 30;
uint public oneHundred = 100;
uint public toEthertoteDevelopmentWallet = oneHundred.div(percentageToEthertoteDevelopmentWallet);
uint public toTeamEthContract = oneHundred.div(percentageToTeamEthContract);
uint public toToteLiquidatorWallet = oneHundred.div(percentageToToteLiquidatorWallet);
event Received(address from, uint256 amount);
event SentToTeamEth(address to, uint256 amount);
event SentToLiquidator(address to, uint256 amount);
event SentToDev(address to, uint256 amount);
modifier onlyAdmin {
require(msg.sender == admin);
_;
}
constructor () public {
admin = msg.sender;
thisContractAddress = address(this);
createdAt = now;
}
function() payable public {
emit Received(msg.sender, msg.value);
}
function thisContractBalance() public view returns(uint) {
return address(this).balance;
}
function sendToTeamEthContract() onlyAdmin public {
require(teamEthTransferComplete == false);
require(ethToBeDistributed > 0);
address(teamEthContract).transfer(ethToBeDistributed.div(toTeamEthContract));
emit SentToTeamEth(msg.sender, ethToBeDistributed.div(toTeamEthContract));
teamEthTransferComplete = true;
}
function sendToToteLiquidatorWallet() onlyAdmin public {
require(toteLiquidatorTranserComplete == false);
require(ethToBeDistributed > 0);
address(toteLiquidatorWallet).transfer(ethToBeDistributed.div(toToteLiquidatorWallet));
emit SentToLiquidator(msg.sender, ethToBeDistributed.div(toToteLiquidatorWallet));
toteLiquidatorTranserComplete = true;
}
function sendToEthertoteDevelopmentWallet() onlyAdmin public {
require(ethertoteDevelopmentTransferComplete == false);
require(ethToBeDistributed > 0);
address(ethertoteDevelopmentWallet).transfer(ethToBeDistributed.div(toEthertoteDevelopmentWallet));
emit SentToDev(msg.sender, ethToBeDistributed.div(toEthertoteDevelopmentWallet));
ethertoteDevelopmentTransferComplete = true;
}
function tokenSaleCompleted() onlyAdmin public {
ethToBeDistributed = address(this).balance;
}
}