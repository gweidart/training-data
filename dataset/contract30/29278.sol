pragma solidity ^0.4.19;
contract BurnTokens {
address owner;
function BurnTokens() public {
owner = msg.sender;
}
function destroy() public {
assert(msg.sender == owner);
selfdestruct(this);
}
}