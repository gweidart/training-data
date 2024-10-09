pragma solidity 0.4.20;
library Reporting {
uint256 private constant DESIGNATED_REPORTING_DURATION_SECONDS = 3 days;
uint256 private constant DISPUTE_ROUND_DURATION_SECONDS = 7 days;
uint256 private constant CLAIM_PROCEEDS_WAIT_TIME = 3 days;
uint256 private constant FORK_DURATION_SECONDS = 60 days;
uint256 private constant INITIAL_REP_SUPPLY = 11 * 10 ** 6 * 10 ** 18;
uint256 private constant DEFAULT_VALIDITY_BOND = 1 ether / 100;
uint256 private constant VALIDITY_BOND_FLOOR = 1 ether / 100;
uint256 private constant DEFAULT_REPORTING_FEE_DIVISOR = 100;
uint256 private constant MAXIMUM_REPORTING_FEE_DIVISOR = 10000;
uint256 private constant MINIMUM_REPORTING_FEE_DIVISOR = 3;
uint256 private constant TARGET_INVALID_MARKETS_DIVISOR = 100;
uint256 private constant TARGET_INCORRECT_DESIGNATED_REPORT_MARKETS_DIVISOR = 100;
uint256 private constant TARGET_DESIGNATED_REPORT_NO_SHOWS_DIVISOR = 100;
uint256 private constant TARGET_REP_MARKET_CAP_MULTIPLIER = 15;
uint256 private constant TARGET_REP_MARKET_CAP_DIVISOR = 2;
uint256 private constant FORK_MIGRATION_PERCENTAGE_BONUS_DIVISOR = 20;
function getDesignatedReportingDurationSeconds() internal pure returns (uint256) { return DESIGNATED_REPORTING_DURATION_SECONDS; }
function getDisputeRoundDurationSeconds() internal pure returns (uint256) { return DISPUTE_ROUND_DURATION_SECONDS; }
function getClaimTradingProceedsWaitTime() internal pure returns (uint256) { return CLAIM_PROCEEDS_WAIT_TIME; }
function getForkDurationSeconds() internal pure returns (uint256) { return FORK_DURATION_SECONDS; }
function getDefaultValidityBond() internal pure returns (uint256) { return DEFAULT_VALIDITY_BOND; }
function getValidityBondFloor() internal pure returns (uint256) { return VALIDITY_BOND_FLOOR; }
function getTargetInvalidMarketsDivisor() internal pure returns (uint256) { return TARGET_INVALID_MARKETS_DIVISOR; }
function getTargetIncorrectDesignatedReportMarketsDivisor() internal pure returns (uint256) { return TARGET_INCORRECT_DESIGNATED_REPORT_MARKETS_DIVISOR; }
function getTargetDesignatedReportNoShowsDivisor() internal pure returns (uint256) { return TARGET_DESIGNATED_REPORT_NO_SHOWS_DIVISOR; }
function getTargetRepMarketCapMultiplier() internal pure returns (uint256) { return TARGET_REP_MARKET_CAP_MULTIPLIER; }
function getTargetRepMarketCapDivisor() internal pure returns (uint256) { return TARGET_REP_MARKET_CAP_DIVISOR; }
function getForkMigrationPercentageBonusDivisor() internal pure returns (uint256) { return FORK_MIGRATION_PERCENTAGE_BONUS_DIVISOR; }
function getMaximumReportingFeeDivisor() internal pure returns (uint256) { return MAXIMUM_REPORTING_FEE_DIVISOR; }
function getMinimumReportingFeeDivisor() internal pure returns (uint256) { return MINIMUM_REPORTING_FEE_DIVISOR; }
function getDefaultReportingFeeDivisor() internal pure returns (uint256) { return DEFAULT_REPORTING_FEE_DIVISOR; }
function getInitialREPSupply() internal pure returns (uint256) { return INITIAL_REP_SUPPLY; }
}