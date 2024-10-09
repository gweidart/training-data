pragma solidity ^0.4.18;
contract KetherHomepage {
event Buy(
uint indexed idx,
address owner,
uint x,
uint y,
uint width,
uint height
);
event Publish(
uint indexed idx,
string link,
string image,
string title,
bool NSFW
);
event SetAdOwner(
uint indexed idx,
address from,
address to
);
uint public constant weiPixelPrice = 1000000000000000;
uint public constant pixelsPerCell = 100;
bool[100][100] public grid;
address contractOwner;
address withdrawWallet;
struct Ad {
address owner;
uint x;
uint y;
uint width;
uint height;
string link;
string image;
string title;
bool NSFW;
bool forceNSFW;
}
Ad[] public ads;
function KetherHomepage(address _contractOwner, address _withdrawWallet)public {
require(_contractOwner != address(0));
require(_withdrawWallet != address(0));
contractOwner = _contractOwner;
withdrawWallet = _withdrawWallet;
}
function getAdsLength() constant public returns (uint) {
return ads.length;
}
function  getContractOwner() constant public returns (address){
return contractOwner;
}
function getWithdrawalAddress() constant public returns (address){
return withdrawWallet;
}
function buy(uint _x, uint _y, uint _width, uint _height) payable public returns (uint idx) {
uint cost = _width * _height * pixelsPerCell * weiPixelPrice;
require(cost > 0);
require(msg.value >= cost);
idx = addAd(_x, _y, _width, _height);
return idx;
}
function reserveAdd(uint _x, uint _y, uint _width, uint _height) public returns (uint idx) {
require(contractOwner == msg.sender);
idx = addAd(_x, _y, _width, _height);
return idx;
}
function addAd(uint _x, uint _y, uint _width, uint _height)private returns(uint idx){
for(uint i=0; i<_width; i++) {
for(uint j=0; j<_height; j++) {
if (grid[_x+i][_y+j]) {
revert();
}
grid[_x+i][_y+j] = true;
}
}
Ad memory ad = Ad(msg.sender, _x, _y, _width, _height, "", "", "", false, false);
idx = ads.push(ad) - 1;
Buy(idx, msg.sender, _x, _y, _width, _height);
return idx;
}
function publish(uint _idx, string _link, string _image, string _title, bool _NSFW) public{
Ad storage ad = ads[_idx];
require(msg.sender == ad.owner);
ad.link = _link;
ad.image = _image;
ad.title = _title;
ad.NSFW = _NSFW;
Publish(_idx, ad.link, ad.image, ad.title, ad.NSFW || ad.forceNSFW);
}
function setAdOwner(uint _idx, address _newOwner) public{
Ad storage ad = ads[_idx];
require(msg.sender == ad.owner);
ad.owner = _newOwner;
SetAdOwner(_idx, msg.sender, _newOwner);
}
function forceNSFW(uint _idx, bool _NSFW) public{
require(msg.sender == contractOwner);
Ad storage ad = ads[_idx];
ad.forceNSFW = _NSFW;
Publish(_idx, ad.link, ad.image, ad.title, ad.NSFW || ad.forceNSFW);
}
function withdraw() public{
require(msg.sender == contractOwner);
withdrawWallet.transfer(this.balance);
}
}