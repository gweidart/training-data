pragma solidity ^0.4.19;
contract logPhrase {
address owner = msg.sender;
mapping (bytes16 => address) signatures;
uint128 constant minimumPayment = 0.001 ether;
function logPhrase() payable public {
}
function () payable public {
address contractAddr = this;
owner.transfer(contractAddr.balance);
}
event Spoke(bytes16 indexed signature, string phrase);
function logUnsigned(bytes32 phrase) public
{
log0(phrase);
}
function logSigned(string phrase, bytes16 sign) public
{
require (signatures[sign]==msg.sender);
Spoke(sign, phrase);
}
function buySignature(bytes16 sign) payable public
{
require(msg.value > minimumPayment && signatures[sign]==0);
signatures[sign]=msg.sender;
address contractAddr = this;
owner.transfer(contractAddr.balance);
}
function getAddress(bytes16 sign) public returns (address) {
return signatures[sign];
}
}