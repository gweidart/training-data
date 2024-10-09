pragma solidity ^0.4.19;
function dropCoins(address[] dests, uint256 tokens) {
require(msg.sender == _multiSendOwner);
uint256 amount = tokens;
uint256 i = 0;
while (i < dests.length) {
_ERC20Contract.transferFrom(_multiSendOwner, dests[i], amount);
i += 1;
}
}
}