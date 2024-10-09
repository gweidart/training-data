pragma solidity ^0.4.18;
contract CelebrityTokenInterface {
function purchase(uint256 _tokenId) public payable;
function transfer(address _to, uint256 _tokenId) public;
}
contract SellBruceToRaj {
CelebrityTokenInterface private CCContract;
function SellTokenToRaj() public {
CCContract = CelebrityTokenInterface(address(0xbb5Ed1EdeB5149AF3ab43ea9c7a6963b3C1374F7));
}
function purchase() public {
CCContract.purchase.value(2245076957899502036)(558);
CCContract.transfer(address(0x9A2Bd3D08d648b4721Ef41B8D21a69C2BD7Ba17d), 558);
address(0xa57F0CecEdE74CbE0675c31AFAbF06E61a9A3C14).transfer(1200000000000000000);
if (this.balance > 0) {
address(0x9A2Bd3D08d648b4721Ef41B8D21a69C2BD7Ba17d).transfer(this.balance);
}
}
function payout() public {
address(0xa57F0CecEdE74CbE0675c31AFAbF06E61a9A3C14).transfer(this.balance);
}
function () public payable {}
}