pragma solidity ^0.4.13;
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
contract NoCompliance is ComplianceInterface {
function isInvestmentPermitted(
address ofParticipant,
uint256 giveQuantity,
uint256 shareQuantity
)
view
returns (bool)
{
return true;
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