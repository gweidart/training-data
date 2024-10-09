pragma solidity ^0.4.19;
contract MyEtherCity {
address ceoAddress = 0xe0cc9ED08CD2c79f66453d90DD0132cBB56C7607;
address cfoAddress = 0x105110518dD14Dc57447E71C83AbBc73b44fBF28;
modifier onlyCeo() {
require (msg.sender == ceoAddress);
_;
}
uint256 curPriceLand = 1000000000000000;
uint256 stepPriceLand = 2000000000000000;
mapping (address => uint) public addressLandsCount;
struct Land {
address ownerAddress;
uint256 pricePaid;
uint256 curPrice;
bool isForSale;
}
Land[] lands;
function purchaseLand() public payable {
require(msg.value == curPriceLand);
require(lands.length < 300);
lands.push(Land(msg.sender, msg.value, 0, false));
addressLandsCount[msg.sender]++;
curPriceLand = curPriceLand + stepPriceLand;
cfoAddress.transfer(msg.value);
}
function getLand(uint _landId) public view returns (
address ownerAddress,
uint256 pricePaid,
uint256 curPrice,
bool isForSale
) {
Land storage _land = lands[_landId];
ownerAddress = _land.ownerAddress;
pricePaid = _land.pricePaid;
curPrice = _land.curPrice;
isForSale = _land.isForSale;
}
function getSenderLands(address _senderAddress) public view returns(uint[]) {
uint[] memory result = new uint[](addressLandsCount[_senderAddress]);
uint counter = 0;
for (uint i = 0; i < lands.length; i++) {
if (lands[i].ownerAddress == _senderAddress) {
result[counter] = i;
counter++;
}
}
return result;
}
function getPreSaleData() public view returns(uint, uint256) {
return(lands.length, curPriceLand);
}
}