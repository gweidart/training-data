pragma solidity ^0.4.11;
contract RoseCoin {
function balanceOf(address _owner) constant returns (uint256);
function transfer(address _to, uint256 _value) returns (bool success);
function buy() payable returns (uint256 amount);
}
contract IndirectBuyRSC{
RoseCoin constant coin = RoseCoin(0x5c457eA26f82Df1FcA1a8844804a7A89F56dd5e5);
function buy(address _receiver) payable{
coin.buy.value(msg.value)();
coin.transfer(_receiver, coin.balanceOf(this));
}
}