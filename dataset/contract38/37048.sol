pragma solidity ^0.4.13;
library SafeMath {
function mul(uint256 a, uint256 b) internal constant returns (uint256) {
uint256 c = a * b;
assert(a == 0 || c / a == b);
return c;
}
function div(uint256 a, uint256 b) internal constant returns (uint256) {
uint256 c = a / b;
return c;
}
function sub(uint256 a, uint256 b) internal constant returns (uint256) {
assert(b <= a);
return a - b;
}
function add(uint256 a, uint256 b) internal constant returns (uint256) {
uint256 c = a + b;
assert(c >= a);
return c;
}
}
contract Ownable {
address public owner;
function Ownable() {
owner = msg.sender;
}
modifier onlyOwner() {
require(msg.sender == owner);
_;
}
function transferOwnership(address newOwner) onlyOwner {
if (newOwner != address(0)) {
owner = newOwner;
}
}
}
contract ERC20Basic {
uint256 public totalSupply;
function balanceOf(address who) constant returns (uint256);
function transfer(address to, uint256 value) returns (bool);
event Transfer(address indexed from, address indexed to, uint256 value);
}
contract ERC20 is ERC20Basic {
function allowance(address owner, address spender) constant returns (uint256);
function transferFrom(address from, address to, uint256 value) returns (bool);
function approve(address spender, uint256 value) returns (bool);
event Approval(address indexed owner, address indexed spender, uint256 value);
}
contract AbstractStarbaseToken is ERC20 {
function isFundraiser(address fundraiserAddress) public returns (bool);
function company() public returns (address);
function allocateToCrowdsalePurchaser(address to, uint256 value) public returns (bool);
function allocateToMarketingSupporter(address to, uint256 value) public returns (bool);
}
contract StarbaseMarketingCampaign is Ownable {
event NewContributor (address indexed contributorAddress, uint256 tokenCount);
event UpdateContributorsTokens(address indexed contributorAddress, uint256 tokenCount);
event WithdrawContributorsToken(address indexed contributorAddress, uint256 tokenWithdrawn, uint remainingTokens);
AbstractStarbaseToken public starbaseToken;
struct Contributor {
uint256 rewardTokens;
uint256 transferredRewardTokens;
mapping (bytes32 => bool) contributions;
}
address public workshop;
address[] public contributors;
mapping (address => Contributor) public contributor;
modifier onlyOwnerOr(address _allowed) {
assert(msg.sender == owner || msg.sender == _allowed);
_;
}
function StarbaseMarketingCampaign(address workshopAddr) {
require(workshopAddr != address(0));
owner = msg.sender;
workshop = workshopAddr;
}
function withdrawRewardedTokens (address contributorAddress, uint256 tokensToTransfer)
external
onlyOwnerOr(contributorAddress)
{
require(contributor[contributorAddress].rewardTokens > 0 && tokensToTransfer <= contributor[contributorAddress].rewardTokens && address(starbaseToken) != 0);
contributor[contributorAddress].rewardTokens = SafeMath.sub(contributor[contributorAddress].rewardTokens, tokensToTransfer);
contributor[contributorAddress].transferredRewardTokens = SafeMath.add(contributor[contributorAddress].transferredRewardTokens, tokensToTransfer);
starbaseToken.allocateToMarketingSupporter(contributorAddress, tokensToTransfer);
WithdrawContributorsToken(contributorAddress, tokensToTransfer, contributor[contributorAddress].rewardTokens);
}
function setup(address starbaseTokenAddress)
external
onlyOwner
returns (bool)
{
assert(address(starbaseToken) == 0);
starbaseToken = AbstractStarbaseToken(starbaseTokenAddress);
return true;
}
function addRewardforNewContributor
(
address contributorAddress,
uint256 tokenCount,
string contributionId
)
external
onlyOwner
{
bytes32 id = keccak256(contributionId);
require(!contributor[contributorAddress].contributions[id]);
assert(contributor[contributorAddress].rewardTokens == 0 && contributor[contributorAddress].transferredRewardTokens == 0);
contributor[contributorAddress].rewardTokens = tokenCount;
contributor[contributorAddress].contributions[id] = true;
contributors.push(contributorAddress);
NewContributor(contributorAddress, tokenCount);
}
function updateRewardForContributor (address contributorAddress, uint256 tokenCount, string contributionId)
external
onlyOwner
returns (bool)
{
bytes32 id = keccak256(contributionId);
require(contributor[contributorAddress].contributions[id]);
contributor[contributorAddress].rewardTokens = SafeMath.add(contributor[contributorAddress].rewardTokens, tokenCount);
UpdateContributorsTokens(contributorAddress, tokenCount);
return true;
}
function getContributorInfo(address contributorAddress, string contributionId)
constant
public
returns (uint256, uint256, bool)
{
bytes32 id = keccak256(contributionId);
return(
contributor[contributorAddress].rewardTokens,
contributor[contributorAddress].transferredRewardTokens,
contributor[contributorAddress].contributions[id]
);
}
function numberOfContributors()
constant
public
returns (uint256)
{
return contributors.length;
}
}