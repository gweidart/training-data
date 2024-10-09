pragma solidity ^0.4.23;
contract NoneToken {
function balanceOf(address) public pure returns (uint256) {
return 0;
}
function transfer(address, uint256) public pure returns (bool) {
return false;
}
function transferFrom(address, address , uint256 ) public pure returns (bool) {
return false;
}
function approve(address, uint256) public pure returns (bool) {
return false;
}
function allowance(address, address) public pure returns (uint256) {
return 0;
}
function totalSupply() public pure returns (uint256) {
return 0;
}
function name() public pure returns (string) {
return "None";
}
function symbol() public pure returns (string) {
return "NONE";
}
function decimals() public pure returns (uint8) {
return 0;
}
}