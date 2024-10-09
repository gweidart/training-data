pragma solidity ^0.4.24;
contract BigOneEvents {
event onNewPlayer
(
uint256 indexed playerID,
address indexed playerAddress,
bytes32 indexed playerName,
bool isNewPlayer,
uint256 affiliateID,
address affiliateAddress,
bytes32 affiliateName,
uint256 amountPaid,
uint256 timeStamp
);
event onEndTx
(
uint256 indexed playerID,
address indexed playerAddress,
uint256 roundID,
uint256 ethIn,
uint256 pot
);
event onWithdraw
(
uint256 indexed playerID,
address playerAddress,
bytes32 playerName,
uint256 ethOut,
uint256 timeStamp
);
event onAffiliatePayout
(
uint256 indexed affiliateID,
address affiliateAddress,
uint256 indexed roundID,
uint256 indexed buyerID,
uint256 amount,
uint256 timeStamp
);
event onEndRound
(
uint256 roundID,
uint256 roundTypeID,
address winnerAddr,
uint256 winnerNum,
uint256 amountWon
);
}
contract BigOne is BigOneEvents {
using SafeMath for *;
using NameFilter for string;
UserDataManagerInterface constant private UserDataManager = UserDataManagerInterface(0x5576250692275701eFdE5EEb51596e2D9460790b);
function mul(uint256 _a, uint256 _b) internal pure returns (uint256) {
if (_a == 0) {
return 0;
}
uint256 c = _a * _b;
require(c / _a == _b);
return c;
}
function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
require(_b > 0);
uint256 c = _a / _b;
return c;
}
function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
require(_b <= _a);
uint256 c = _a - _b;
return c;
}
function add(uint256 _a, uint256 _b) internal pure returns (uint256) {
uint256 c = _a + _b;
require(c >= _a);
return c;
}
function mod(uint256 a, uint256 b) internal pure returns (uint256) {
require(b != 0);
return a % b;
}
}