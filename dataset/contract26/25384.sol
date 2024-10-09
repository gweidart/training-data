pragma solidity ^0.4.13;
interface FundInterface {
event PortfolioContent(uint holdings, uint price, uint decimals);
event RequestUpdated(uint id);
event Invested(address indexed ofParticipant, uint atTimestamp, uint shareQuantity);
event Redeemed(address indexed ofParticipant, uint atTimestamp, uint shareQuantity);
event SpendingApproved(address onConsigned, address ofAsset, uint amount);
event FeesConverted(uint atTimestamp, uint shareQuantityConverted, uint unclaimed);
event CalculationUpdate(uint atTimestamp, uint managementFee, uint performanceFee, uint nav, uint sharePrice, uint totalSupply);
event OrderUpdated(uint id);
event LogError(uint ERROR_CODE);
event ErrorMessage(string errorMessage);
function requestInvestment(uint giveQuantity, uint shareQuantity, bool isNativeAsset) external;
function requestRedemption(uint shareQuantity, uint receiveQuantity, bool isNativeAsset) external;
function executeRequest(uint requestId) external;
function cancelRequest(uint requestId) external;
function redeemAllOwnedAssets(uint shareQuantity) external returns (bool);
function enableInvestment() external;
function disableInvestment() external;
function enableRedemption() external;
function disableRedemption() external;
function shutDown() external;
function makeOrder(uint exchangeId, address sellAsset, address buyAsset, uint sellQuantity, uint buyQuantity) external;
function takeOrder(uint exchangeId, uint id, uint quantity) external;
function cancelOrder(uint exchangeId, uint id) external;
function emergencyRedeem(uint shareQuantity, address[] requestedAssets) public returns (bool success);
function allocateUnclaimedFees();
function getModules() view returns (address, address, address);
function getLastOrderId() view returns (uint);
function getLastRequestId() view returns (uint);
function getNameHash() view returns (bytes32);
function getManager() view returns (address);
function performCalculations() view returns (uint, uint, uint, uint, uint, uint, uint);
function calcSharePrice() view returns (uint);
}
interface ComplianceInterface {
function isInvestmentPermitted(
address ofParticipant,
uint256 giveQuantity,
uint256 shareQuantity
) view returns (bool);
function isRedemptionPermitted(
address ofParticipant,
uint256 shareQuantity,
uint256 receiveQuantity
) view returns (bool);
}
contract OnlyManager is ComplianceInterface {
function isInvestmentPermitted(
address ofParticipant,
uint256 giveQuantity,
uint256 shareQuantity
)
view
returns (bool)
{
return FundInterface(msg.sender).getManager() == ofParticipant;
}
function isRedemptionPermitted(
address ofParticipant,
uint256 shareQuantity,
uint256 receiveQuantity
)
view
returns (bool)
{
return true;
}
}