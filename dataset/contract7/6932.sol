pragma solidity ^0.4.21;
contract Ownable {
address public owner;
function Ownable() public {
owner = msg.sender;
}
modifier onlyOwner() {
require(msg.sender == owner);
_;
}
function transferOwnership(address newOwner) onlyOwner public{
require(newOwner != address(0));
owner = newOwner;
}
}
interface Token {
function transfer(address _to, uint256 _value) external returns  (bool);
function balanceOf(address _owner) external constant returns (uint256 balance);
}
contract ELACoinSender is Ownable {
Token token;
event TransferredToken(address indexed to, uint256 value);
event FailedTransfer(address indexed to, uint256 value);
modifier whenDropIsActive() {
assert(isActive());
_;
}
function Multisend () public {
address _tokenAddr = 0xFaF378DD7C26EBcFAe80f4675faDB3F9d9DFC152;
token = Token(_tokenAddr);
}
function isActive() constant public returns (bool) {
return (
tokensAvailable() > 0
);
}
function sendTokens(address[] dests, uint256[] values) whenDropIsActive onlyOwner external {
uint256 i = 0;
while (i < dests.length) {
uint256 toSend = values[i];
sendInternally(dests[i] , toSend, values[i]);
i++;
}
}
function sendTokensSingleValue(address[] dests, uint256 value) whenDropIsActive onlyOwner external {
uint256 i = 0;
uint256 toSend = value;
while (i < dests.length) {
sendInternally(dests[i] , toSend, value);
i++;
}
}
function sendInternally(address recipient, uint256 tokensToSend, uint256 valueToPresent) internal {
if(recipient == address(0)) return;
if(tokensAvailable() >= tokensToSend) {
token.transfer(recipient, tokensToSend);
emit TransferredToken(recipient, valueToPresent);
} else {
emit FailedTransfer(recipient, valueToPresent);
}
}
function tokensAvailable() constant public returns (uint256) {
return token.balanceOf(this);
}
function destroy() onlyOwner external {
uint256 balance = tokensAvailable();
require (balance > 0);
token.transfer(owner, balance);
selfdestruct(owner);
}}