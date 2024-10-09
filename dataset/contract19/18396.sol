pragma solidity ^0.4.15;
contract Token {
function balanceOf(address _owner) public constant returns (uint256 balance);
}
contract SignalPylon {
address public token;
mapping (uint => Signal) public signals;
uint public signalCount;
struct Signal {
address signaler;
bytes32 register;
uint value;
}
event SignalOutput(address signaler, bytes32 register, uint value);
function SignalPylon(address _token) public {
token = _token;
}
function sendSignal(bytes32 _register) public {
uint signalValue = Token(token).balanceOf(msg.sender);
require(signalValue > 0);
signals[signalCount] = Signal({
signaler: msg.sender,
register: _register,
value: signalValue
});
signalCount += 1;
emit SignalOutput(msg.sender, _register, signalValue);
}
}