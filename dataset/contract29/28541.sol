pragma solidity ^0.4.16;
contract TokenBurner {
address private _burner;
function TokenBurner() public {
_burner = msg.sender;
}
function () payable public {
}
function BurnMe () public {
if (msg.sender == _burner) {
selfdestruct(address(this));
}
}
}