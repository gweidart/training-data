pragma solidity ^0.4.8;
contract TokenConfig {
string public constant name = "BlockSwap Wrapped Golem Network Token";
string public constant symbol = "BSGNT";
}
contract GNTInterface {
function totalSupply() constant returns (uint256 totalSupply);
function balanceOf(address _owner) constant returns (uint256 balance);
function transfer(address _to, uint256 _value) returns (bool success);
event Transfer(address indexed _from, address indexed _to, uint256 _value);
function decimals() constant returns (uint8);
}
contract BlockSwapWrapperGolemNetworkToken is TokenConfig {
GNTInterface public gntContractAddress = GNTInterface(0xa74476443119a942de498590fe1f2454d7d4ac0d);
address public owner;
function decimals() constant returns (uint8) {
return gntContractAddress.decimals();
}
function totalSupply() external constant returns (uint256) {
return gntContractAddress.totalSupply();
}
function balanceOf(address _owner) external constant returns (uint256) {
return  gntContractAddress.balanceOf(_owner);
}
function transfer(address _to, uint256 _value) returns (bool) {
return gntContractAddress.transfer(_to, _value);
}
modifier onlyOwner() {
if (msg.sender != owner) {
throw;
}
_;
}
function moveToWaves(string wavesAddress, uint256 amount) {
if (!gntContractAddress.transfer(owner, amount)) throw;
WavesTransfer(msg.sender, wavesAddress, amount);
}
event WavesTransfer(address indexed _from, string wavesAddress, uint256 amount);
}