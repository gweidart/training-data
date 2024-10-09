pragma solidity ^0.4.21;
contract Ownable {
address public owner;
function Ownable()
public
{
owner = msg.sender;
}
modifier onlyOwner() {
require(msg.sender == owner);
_;
}
function transferOwnership(address newOwner)
public
onlyOwner
{
if (newOwner != address(0)) {
owner = newOwner;
}
}
}
contract ITrader {
function getDataLength(
) public pure returns (uint256);
function getProtocol(
) public pure returns (uint8);
function getAvailableVolume(
bytes orderData
) public view returns(uint);
function isExpired(
bytes orderData
) public view returns (bool);
function trade(
bool isSell,
bytes orderData,
uint volume,
uint volumeEth
) public;
function getFillVolumes(
bool isSell,
bytes orderData,
uint volume,
uint volumeEth
) public view returns(uint, uint);
}
contract ITraders {
function addTrader(uint8 id, ITrader trader) public;
function removeTrader(uint8 id) public;
function getTrader(uint8 id) public view returns(ITrader);
function isValidTraderAddress(address addr) public view returns(bool);
}
contract Traders is ITraders, Ownable {
mapping(uint8 => ITrader) public traders;
mapping(address => bool) public addresses;
function addTrader(uint8 protocolId, ITrader trader) public onlyOwner {
require(protocolId == trader.getProtocol());
traders[protocolId] = trader;
addresses[trader] = true;
}
function removeTrader(uint8 protocolId) public onlyOwner {
delete addresses[traders[protocolId]];
delete traders[protocolId];
}
function getTrader(uint8 protocolId) public view returns(ITrader) {
return traders[protocolId];
}
function isValidTraderAddress(address addr) public view returns(bool) {
return addresses[addr];
}
}