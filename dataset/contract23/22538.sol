pragma solidity ^0.4.20;
contract EthAnte {
uint public timeOut;
uint public kBalance;
uint public feeRate;
address TechnicalRise = 0x7c0Bf55bAb08B4C1eBac3FC115C394a739c62538;
address lastBidder;
function EthAnte() public payable {
lastBidder = msg.sender;
kBalance = msg.value;
timeOut = now + 10 minutes;
feeRate = 10;
}
function () public payable {
uint _fee = msg.value / feeRate;
uint _val = msg.value - _fee;
kBalance += _val;
TechnicalRise.transfer(_fee);
if(_val < 9 finney) {
timeOut += 2 minutes;
return;
}
if (timeOut <= now) {
lastBidder.transfer(kBalance - _val);
kBalance = _val;
timeOut = now;
}
timeOut += (10 minutes) * (9 finney) / _val;
lastBidder = msg.sender;
}
}