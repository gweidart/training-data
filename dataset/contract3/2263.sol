pragma solidity ^0.4.24;
contract ZethrProxy_Two {
ZethrInterface zethr = ZethrInterface(address(0xD48B633045af65fF636F3c6edd744748351E020D));
address bankroll = 0x7430984e1D05d5F447c747123dd26845f6f17544;
address owner = msg.sender;
event onTokenPurchase(
address indexed customerAddress,
uint incomingEthereum,
uint tokensMinted,
address indexed referredBy
);
function buyTokensWithProperEvent(address _referredBy, uint8 divChoice) public payable {
uint balanceBefore = zethr.balanceOf(msg.sender);
zethr.buyAndTransfer.value(msg.value)(_referredBy, msg.sender, "", divChoice);
uint balanceAfter = zethr.balanceOf(msg.sender);
emit onTokenPurchase(
msg.sender,
msg.value,
balanceAfter - balanceBefore,
_referredBy
);
}
function () public payable {
}
function changeBankroll(address _newBankroll)
public
{
require(msg.sender == owner);
bankroll = _newBankroll;
}
function sendDivsToBankroll() public {
require(msg.sender == owner);
bankroll.transfer(address(this).balance);
}
}
contract ZethrInterface {
function buyAndTransfer(address _referredBy, address target, bytes _data, uint8 divChoice) public payable;
function balanceOf(address _owner) view public returns(uint);
}