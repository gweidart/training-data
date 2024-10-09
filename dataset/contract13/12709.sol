pragma solidity ^0.4.18;
contract HundredEtherWall {
address public contractOwner;
modifier onlyContractOwner {
require(msg.sender == contractOwner);
_;
}
uint public constant pixelPrice = 80000000000000;
uint public constant pixelsPerCell = 625;
address receiver;
event Buy (
uint indexed idx,
address owner,
uint x,
uint y,
uint width,
uint height
);
event Update (
uint indexed idx,
string link,
string ipfsHash,
string title
);
event SetSale (
uint indexed idx,
bool forSale,
uint marketPrice
);
event MarketBuy (
uint indexed idx,
address owner,
bool forSale,
uint marketPrice
);
event SetActive (
uint indexed idx,
bool active
);
struct Ad {
address owner;
uint width;
uint height;
uint x;
uint y;
string title;
string link;
string ipfsHash;
bool forSale;
bool active;
uint marketPrice;
}
Ad[] public ads;
bool[40][50] public grid;
constructor() public {
contractOwner = msg.sender;
}
function buy(uint _x, uint _y, uint _width, uint _height, string _title, string _link, string _ipfsHash) public payable returns (uint idx) {
uint price = _width * _height * pixelPrice;
require(price > 0);
require(msg.value >= price);
require(_width % 25 == 0);
require(_height % 25 == 0);
for(uint i = 0; i < _width / 25; i++) {
for(uint j = 0; j < _height / 25; j++) {
if (grid[_x / 25 + i][_y / 25 + j]) {
revert();
}
grid[_x / 25 + i][_y / 25 + j] = true;
}
}
Ad memory ad = Ad(msg.sender, _x, _y, _width, _height, _title, _link, _ipfsHash, false, true, price);
idx = ads.push(ad) - 1;
emit Buy(idx, msg.sender, _x, _y, _width, _height);
return idx;
}
function update(uint _idx, string _title, string _link, string _ipfsHash) public {
Ad storage ad = ads[_idx];
require(msg.sender == ad.owner || msg.sender == contractOwner);
ad.link = _link;
ad.ipfsHash = _ipfsHash;
ad.title = _title;
emit Update(_idx, ad.link, ad.ipfsHash, ad.title);
}
function setSale(uint _idx, bool _sale, uint _marketPrice) public {
Ad storage ad = ads[_idx];
require(msg.sender == ad.owner);
ad.forSale = _sale;
ad.marketPrice = _marketPrice;
emit SetSale(_idx, ad.forSale, ad.marketPrice);
}
function marketBuy(uint _idx) public payable {
Ad storage ad = ads[_idx];
require(msg.sender != ad.owner);
require(msg.value > 0);
require(msg.value >= ad.marketPrice);
require(ad.forSale == true);
receiver = ad.owner;
ad.owner = msg.sender;
ad.forSale = false;
uint price = ad.width * ad.height * pixelPrice;
receiver.transfer(msg.value);
emit MarketBuy(_idx, ad.owner, ad.forSale, price);
}
function setActive(uint _idx, bool _active) public onlyContractOwner {
Ad storage ad = ads[_idx];
ad.active = _active;
emit SetActive(_idx, ad.active);
}
function getAds() public constant returns (uint) {
return ads.length;
}
function withdraw() public onlyContractOwner {
contractOwner.transfer(address(this).balance);
}
}