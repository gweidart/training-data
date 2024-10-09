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
function PHXFlip() public {
PHXTKN = PHXInterface(PHXTKNADDR);
}
function tokenFallback(address _from, uint _value, bytes _data) public {
require(_humanSender(_from));
require(_phxToken(msg.sender));
uint _possibleWinnings = 2 * _value;
if(_prand(2) == 1) {
if(PHXTKN.balanceOf(this) >= _possibleWinnings) {
PHXTKN.transfer(_from, _possibleWinnings);
} else {
PHXTKN.transfer(_from,PHXTKN.balanceOf(this));
}
} else {
}
}
function _prand(uint _modulo) private view returns (uint) {
require((1 < _modulo) && (_modulo <= 10000));
uint seed1 = uint(block.coinbase);
uint seed2 = now;
return uint(keccak256(seed1, seed2)) % _modulo;
}
function _phxToken(address _tokenContract) private pure returns (bool) {
return _tokenContract == PHXTKNADDR;
}
function _humanSender(address _from) private view returns (bool) {
uint codeLength;
assembly {
codeLength := extcodesize(_from)
}
return (codeLength == 0);
}
}