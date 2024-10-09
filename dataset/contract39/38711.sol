pragma solidity ^0.4.10;
contract HodlBox {
uint public hodlTillBlock;
address public hodler;
uint public hodling;
bool public withdrawn;
event HodlReleased(bool _isReleased);
event Hodling(bool _isCreated);
function HodlBox(uint _blocks) payable {
hodler = msg.sender;
hodling = msg.value;
hodlTillBlock = block.number + _blocks;
withdrawn = false;
Hodling(true);
}
function deposit() payable {
hodling += msg.value;
}
function releaseTheHodl() {
if (msg.sender != hodler) throw;
if (block.number < hodlTillBlock) throw;
if (withdrawn) throw;
if (hodling <= 0) throw;
withdrawn = true;
hodling = 0;
HodlReleased(true);
selfdestruct(hodler);
}
function hodlCountdown() constant returns (uint) {
var hodlCount = hodlTillBlock - block.number;
if (block.number >= hodlTillBlock) {
return 0;
}
return hodlCount;
}
function isDeholdable() constant returns (bool) {
if (block.number < hodlTillBlock) {
return false;
} else {
return true;
}
}
}