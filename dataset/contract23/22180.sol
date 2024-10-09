pragma solidity ^0.4.20;
contract PHXReceivingContract {
function tokenFallback(address _from, uint _value, bytes _data) public;
}
contract PHXInterface {
function balanceOf(address who) public view returns (uint);
function transfer(address _to, uint _value) public returns (bool);
function transfer(address _to, uint _value, bytes _data) public returns (bool);
}
contract PHXFlip is PHXReceivingContract {
address public constant PHXTKNADDR = 0x14b759A158879B133710f4059d32565b4a66140C;
PHXInterface public PHXTKN;
event result(address indexed _roller, uint _wager, uint _payout, uint indexed _rollednumber);
function PHXFlip() public {
PHXTKN = PHXInterface(PHXTKNADDR);
}
function tokenFallback(address _from, uint _value, bytes _data) public {
require(_humanSender(_from));
require(_phxToken(msg.sender));
uint _balance = PHXTKN.balanceOf(this);
uint _possibleWinnings = 2 * _value;
uint _rollednumber = _prand(100) + 1;
if(_rollednumber < 48) {
if(_balance >= _possibleWinnings) {
PHXTKN.transfer(_from, _possibleWinnings);
emit result(_from, _value, _possibleWinnings, _rollednumber);
} else {
PHXTKN.transfer(_from,_balance);
emit result(_from, _value, _balance, _rollednumber);
}
} else {
PHXTKN.transfer(_from, 1);
emit result(_from, _value, 1, _rollednumber);
}
}
function _prand(uint _modulo) private view returns (uint) {
uint seed1 = uint(block.coinbase);
uint seed2 = now;
return uint(keccak256(seed1, seed2)) % _modulo;
}
function _phxToken(address _tokenContract) private pure returns (bool) {
return _tokenContract == PHXTKNADDR;
}
function _humanSender(address _from) private view returns (bool) {
uint codeLength;
assembly { codeLength := extcodesize(_from)  }
return (codeLength == 0);
}
}