pragma solidity ^0.4.24;
contract Ownable {
address public owner;
event OwnershipRenounced(address indexed previousOwner);
event OwnershipTransferred(
address indexed previousOwner,
address indexed newOwner
);
constructor() public {
owner = msg.sender;
}
modifier onlyOwner() {
require(msg.sender == owner);
_;
}
function renounceOwnership() public onlyOwner {
emit OwnershipRenounced(owner);
owner = address(0);
}
function transferOwnership(address _newOwner) public onlyOwner {
_transferOwnership(_newOwner);
}
function _transferOwnership(address _newOwner) internal {
require(_newOwner != address(0));
emit OwnershipTransferred(owner, _newOwner);
owner = _newOwner;
}
}
contract ERC20Basic {
function totalSupply() public view returns (uint256);
function balanceOf(address who) public view returns (uint256);
function transfer(address to, uint256 value) public returns (bool);
event Transfer(address indexed from, address indexed to, uint256 value);
}
pragma solidity ^0.4.24;
contract MyanmarDonations is Ownable {
address public SENC_CONTRACT_ADDRESS = 0xA13f0743951B4f6E3e3AA039f682E17279f52bc3;
address public DONATION_WALLET = 0xB4ea16258020993520F59cC786c80175C1b807D7;
address public FOUNDATION_WALLET = 0x2c76E65d3b3E38602CAa2fAB56e0640D0182D8F8;
uint256 public START_DATE = 1533693600;
uint256 public END_DATE = 1533895200;
uint256 public ETHER_HARD_CAP = 30 ether;
uint256 public INFOCORP_DONATION = 30 ether;
uint256 public TOTAL_ETHER_HARD_CAP = ETHER_HARD_CAP + INFOCORP_DONATION;
uint256 constant public FIXED_RATE = 41369152116499 wei;
uint256 public SENC_HARD_CAP = ETHER_HARD_CAP * 10 ** 18 / FIXED_RATE;
uint256 public totalSencCollected;
bool public finalized = false;
modifier onlyDonationAddress() {
require(msg.sender == DONATION_WALLET);
_;
}
function() public payable {
require(msg.value == TOTAL_ETHER_HARD_CAP);
require(
address(this).balance <= TOTAL_ETHER_HARD_CAP,
"Contract balance hardcap reachead"
);
}
function finalize() public onlyDonationAddress returns (bool) {
require(getSencBalance() >= SENC_HARD_CAP || now >= END_DATE, "SENC hard cap rached OR End date reached");
require(!finalized, "Donation not already finalized");
totalSencCollected = getSencBalance();
if (totalSencCollected >= SENC_HARD_CAP) {
DONATION_WALLET.transfer(address(this).balance);
} else {
uint256 totalDonatedEthers = convertToEther(totalSencCollected) + INFOCORP_DONATION;
DONATION_WALLET.transfer(totalDonatedEthers);
claimTokens(address(0), FOUNDATION_WALLET);
}
claimTokens(SENC_CONTRACT_ADDRESS, FOUNDATION_WALLET);
finalized = true;
return finalized;
}
function claimTokens(address _token, address _to) public onlyDonationAddress {
require(_to != address(0), "Wallet format error");
if (_token == address(0)) {
_to.transfer(address(this).balance);
return;
}
ERC20Basic token = ERC20Basic(_token);
uint256 balance = token.balanceOf(this);
require(token.transfer(_to, balance), "Token transfer unsuccessful");
}
function sencToken() public view returns (ERC20Basic) {
return ERC20Basic(SENC_CONTRACT_ADDRESS);
}
function getSencBalance() public view returns (uint256) {
return sencToken().balanceOf(address(this));
}
function getTotalDonations() public view returns (uint256) {
return convertToEther(finalized ? totalSencCollected : getSencBalance());
}
function setEndDate(uint256 _endDate) external onlyOwner returns (bool){
END_DATE = _endDate;
return true;
}
function convertToEther(uint256 _value) private pure returns (uint256) {
return _value * FIXED_RATE / 10 ** 18;
}
}