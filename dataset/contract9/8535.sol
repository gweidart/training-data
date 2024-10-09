pragma solidity 0.4.24;
library SafeMath {
function mul(uint a, uint b) internal pure returns (uint) {
uint c = a * b;
assert(a == 0 || c / a == b);
return c;
}
function div(uint a, uint b) internal pure returns (uint) {
uint c = a / b;
return c;
}
function sub(uint a, uint b) internal pure returns (uint) {
assert(b <= a);
return a - b;
}
function add(uint a, uint b) internal pure returns (uint) {
uint c = a + b;
assert(c >= a);
return c;
}
}
contract Ownable {
address public owner;
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
constructor() public {
owner = msg.sender;
}
modifier onlyOwner() {
require(msg.sender == owner);
_;
}
function transferOwnership(address newOwner) onlyOwner public {
require(newOwner != address(0));
emit OwnershipTransferred(owner, newOwner);
owner = newOwner;
}
}
contract ERC20Interface {
function totalSupply() public constant returns (uint);
function balanceOf(address tokenOwner) public constant returns (uint balance);
function allowance(address tokenOwner, address spender) public constant returns (uint remaining);
function transfer(address to, uint tokens) public returns (bool success);
function approve(address spender, uint tokens) public returns (bool success);
function transferFrom(address from, address to, uint tokens) public returns (bool success);
function mint(address from, address to, uint tokens) public;
event Transfer(address indexed from, address indexed to, uint tokens);
event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}
contract AdvertisementContract {
using SafeMath for uint256;
struct Advertisement {
address advertiser;
uint advertisementId;
string advertisementLink;
uint amountToBePaid;
bool isUnlocked;
}
struct Voter {
address publicKey;
uint amountEarned;
}
struct VoteAdvertisementPayoutScheme {
uint voterPercentage;
uint systemPercentage;
}
ERC20Interface public token;
VoteAdvertisementPayoutScheme voteAdvertismentPayoutSchemeObj;
Advertisement advertisement;
Voter voter;
uint counter = 0;
address public wallet;
mapping (uint=>Voter[]) advertisementVoterList;
mapping (uint=>Advertisement) advertisementList;
uint localIntAsPerNeed;
address localAddressAsPerNeed;
Voter[] voters;
constructor(address _wallet,address _tokenAddress) public {
wallet = _wallet;
token = ERC20Interface(_tokenAddress);
setup();
}
function () public payable {
revert();
}
function setup() internal {
voteAdvertismentPayoutSchemeObj = VoteAdvertisementPayoutScheme({voterPercentage: 79, systemPercentage: 21});
}
function uploadAdvertisement(uint adId,string advLink, address advertiserAddress, uint uploadTokenAmount) public
{
require(msg.sender == wallet);
token.mint(advertiserAddress,wallet,uploadTokenAmount*10**18);
advertisement = Advertisement({
advertiser : advertiserAddress,
advertisementId : adId,
advertisementLink : advLink,
amountToBePaid : uploadTokenAmount*10**18,
isUnlocked : false
});
advertisementList[adId] = advertisement;
}
function AdvertisementPayout (uint advId) public
{
require(msg.sender == wallet);
require(token.balanceOf(wallet)>=advertisementList[advId].amountToBePaid);
require(advertisementList[advId].advertisementId == advId);
require(advertisementList[advId].isUnlocked == true);
require(advertisementList[advId].amountToBePaid > 0);
uint j = 0;
voters = advertisementVoterList[advertisementList[advId].advertisementId];
localIntAsPerNeed = voteAdvertismentPayoutSchemeObj.voterPercentage;
uint voterPayout = advertisementList[advId].amountToBePaid.mul(localIntAsPerNeed);
voterPayout = voterPayout.div(100);
uint perVoterPayout = voterPayout.div(voters.length);
localIntAsPerNeed = voteAdvertismentPayoutSchemeObj.systemPercentage;
uint systemPayout = advertisementList[advId].amountToBePaid.mul(localIntAsPerNeed);
systemPayout = systemPayout.div(100);
for (j=0;j<voters.length;j++)
{
token.mint(wallet,voters[j].publicKey,perVoterPayout);
voters[j].amountEarned = voters[j].amountEarned.add(perVoterPayout);
advertisementList[advId].amountToBePaid = advertisementList[advId].amountToBePaid.sub(perVoterPayout);
}
advertisementList[advId].amountToBePaid = advertisementList[advId].amountToBePaid.sub(systemPayout);
require(advertisementList[advId].amountToBePaid == 0);
}
function VoteAdvertisement(uint adId, address voterPublicKey) public
{
require(advertisementList[adId].advertisementId == adId);
require(advertisementList[adId].isUnlocked == false);
voter = Voter({publicKey: voterPublicKey, amountEarned : 0});
advertisementVoterList[adId].push(voter);
}
function unlockAdvertisement(uint adId) public
{
require(msg.sender == wallet);
require(advertisementList[adId].advertisementId == adId);
advertisementList[adId].isUnlocked = true;
}
function getTokenBalance() public constant returns (uint) {
return token.balanceOf(msg.sender);
}
function changeWalletAddress(address newWallet) public
{
require(msg.sender == wallet);
wallet = newWallet;
}
}